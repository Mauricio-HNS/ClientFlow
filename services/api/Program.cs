using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using BCrypt.Net;
using ClientFlow.Api.Data;
using ClientFlow.Api.Hubs;
using ClientFlow.Api.Models;
using ClientFlow.Api.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();

builder.Services.AddDbContext<ClientFlowDb>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("Default")
                           ?? "Host=localhost;Port=5433;Database=clientflow;Username=postgres;Password=postgres";
    options.UseNpgsql(connectionString);
});

builder.Services.AddSignalR();

builder.Services.AddCors(options =>
{
    options.AddPolicy("dev", policy =>
    {
        policy
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowAnyOrigin();
    });
});

builder.Services.AddSingleton<INotifier, LogNotifier>();

var jwtKey = builder.Configuration["Jwt:Key"] ?? "dev_secret_change_me_please_12345";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "clientflow";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "clientflow";
var signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = signingKey,
            ClockSkew = TimeSpan.FromMinutes(1)
        };
    });

builder.Services.AddAuthorization();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseCors("dev");
app.UseAuthentication();

app.Use(async (context, next) =>
{
    if (context.User.Identity?.IsAuthenticated == true && context.User.IsInRole("salon"))
    {
        var userId = context.User.FindFirstValue(JwtRegisteredClaimNames.Sub);
        if (Guid.TryParse(userId, out var parsedId))
        {
            var db = context.RequestServices.GetRequiredService<ClientFlowDb>();
            var user = await db.Users.FirstOrDefaultAsync(u => u.Id == parsedId);
            if (user is not null && user.Status == SalonStatus.Suspended)
            {
                context.Response.StatusCode = StatusCodes.Status403Forbidden;
                await context.Response.WriteAsJsonAsync(new
                {
                    message = "Conta suspensa. Regularize o pagamento para continuar usando."
                });
                return;
            }
        }
    }

    await next();
});

app.UseAuthorization();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ClientFlowDb>();
    db.Database.EnsureCreated();

    if (!db.Users.Any())
    {
        db.Users.AddRange(
            new AppUser
            {
                Id = Guid.NewGuid(),
                Name = "Admin",
                Email = "admin@clientflow.local",
                Phone = "",
                Role = "admin",
                Status = SalonStatus.Active,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123"),
                CreatedAt = DateTime.UtcNow
            },
            new AppUser
            {
                Id = Guid.NewGuid(),
                Name = "Salao Demo",
                Email = "salao@clientflow.local",
                Phone = "",
                Role = "salon",
                Status = SalonStatus.Active,
                NextBillingAt = DateTime.UtcNow.AddDays(30),
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("salao123"),
                CreatedAt = DateTime.UtcNow
            },
            new AppUser
            {
                Id = Guid.NewGuid(),
                Name = "Cliente Demo",
                Email = "cliente@clientflow.local",
                Phone = "",
                Role = "client",
                Status = SalonStatus.Active,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("cliente123"),
                CreatedAt = DateTime.UtcNow
            }
        );
    }

    if (!db.Clients.Any())
    {
        var client1 = new Client
        {
            Id = Guid.NewGuid(),
            Name = "Carolina Souza",
            Phone = "+55 11 99999-1111",
            Email = "carolina@email.com",
            Notes = "Prefere atendimento pela manha",
            CreatedAt = DateTime.UtcNow
        };
        var client2 = new Client
        {
            Id = Guid.NewGuid(),
            Name = "Marco Antonio",
            Phone = "+55 21 98888-2222",
            Email = "marco@email.com",
            Notes = "Cliente premium",
            CreatedAt = DateTime.UtcNow
        };

        db.Clients.AddRange(client1, client2);

        db.Appointments.AddRange(
            new Appointment
            {
                Id = Guid.NewGuid(),
                ClientId = client1.Id,
                Title = "Corte + Tratamento",
                StartAt = DateTime.UtcNow.AddHours(2),
                DurationMinutes = 60,
                Notes = "Confirmado",
                Status = "confirmado"
            },
            new Appointment
            {
                Id = Guid.NewGuid(),
                ClientId = client2.Id,
                Title = "Consulta de retorno",
                StartAt = DateTime.UtcNow.AddHours(4),
                DurationMinutes = 45,
                Notes = "Solicitou ajuste",
                Status = "pendente"
            }
        );
    }

    db.SaveChanges();
}

app.MapGet("/health", () => Results.Ok(new { status = "ok", service = "clientflow-api" }));

app.MapPost("/auth/register", async (RegisterInput input, ClientFlowDb db) =>
{
    if (string.IsNullOrWhiteSpace(input.Email) || string.IsNullOrWhiteSpace(input.Password))
    {
        return Results.BadRequest(new { message = "Email e senha sao obrigatorios." });
    }

    var role = string.IsNullOrWhiteSpace(input.Role) ? "client" : input.Role.Trim().ToLower();
    if (role is not ("client" or "salon" or "admin"))
    {
        return Results.BadRequest(new { message = "Role invalido." });
    }

    var exists = await db.Users.AnyAsync(u => u.Email == input.Email);
    if (exists)
    {
        return Results.BadRequest(new { message = "Email ja cadastrado." });
    }

    var user = new AppUser
    {
        Id = Guid.NewGuid(),
        Name = input.Name?.Trim() ?? "",
        Email = input.Email.Trim().ToLower(),
        Phone = input.Phone?.Trim() ?? "",
        Role = role,
        Status = SalonStatus.Active,
        PasswordHash = BCrypt.Net.BCrypt.HashPassword(input.Password),
        CreatedAt = DateTime.UtcNow
    };

    db.Users.Add(user);
    await db.SaveChangesAsync();

    return Results.Created($"/users/{user.Id}", new
    {
        user.Id,
        user.Name,
        user.Email,
        user.Role
    });
});

app.MapPost("/auth/login", async (LoginInput input, ClientFlowDb db) =>
{
    if (string.IsNullOrWhiteSpace(input.Email) || string.IsNullOrWhiteSpace(input.Password))
    {
        return Results.BadRequest(new { message = "Email e senha sao obrigatorios." });
    }

    var user = await db.Users.FirstOrDefaultAsync(u => u.Email == input.Email.Trim().ToLower());
    if (user is null || !BCrypt.Net.BCrypt.Verify(input.Password, user.PasswordHash))
    {
        return Results.Unauthorized();
    }

    var claims = new List<Claim>
    {
        new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
        new(JwtRegisteredClaimNames.Email, user.Email),
        new(ClaimTypes.Role, user.Role),
        new("name", user.Name)
    };

    var tokenDescriptor = new SecurityTokenDescriptor
    {
        Subject = new ClaimsIdentity(claims),
        Expires = DateTime.UtcNow.AddHours(12),
        Issuer = jwtIssuer,
        Audience = jwtAudience,
        SigningCredentials = new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256Signature)
    };

    var tokenHandler = new JwtSecurityTokenHandler();
    var token = tokenHandler.CreateToken(tokenDescriptor);

    return Results.Ok(new
    {
        token = tokenHandler.WriteToken(token),
        user = new { user.Id, user.Name, user.Email, user.Role, user.Status }
    });
});

var api = app.MapGroup("/").RequireAuthorization();

api.MapGet("/me", async (ClaimsPrincipal user, ClientFlowDb db) =>
{
    var id = user.FindFirstValue(JwtRegisteredClaimNames.Sub);
    if (!Guid.TryParse(id, out var parsedId))
    {
        return Results.Unauthorized();
    }

    var account = await db.Users.FirstOrDefaultAsync(u => u.Id == parsedId);
    if (account is null)
    {
        return Results.NotFound();
    }

    return Results.Ok(new { account.Id, account.Name, account.Email, account.Role, account.Status });
});

api.MapGet("/salon/alerts", async (ClaimsPrincipal user, ClientFlowDb db) =>
{
    if (!user.IsInRole("salon"))
    {
        return Results.Forbid();
    }

    var id = user.FindFirstValue(JwtRegisteredClaimNames.Sub);
    if (!Guid.TryParse(id, out var parsedId))
    {
        return Results.Unauthorized();
    }

    var alerts = await db.Alerts
        .Where(a => a.UserId == parsedId)
        .OrderByDescending(a => a.CreatedAt)
        .Select(a => new { a.Id, a.Title, a.Body, a.Tone, a.CreatedAt })
        .ToListAsync();

    return Results.Ok(alerts);
});

api.MapGet("/admin/salons", async (ClaimsPrincipal user, ClientFlowDb db) =>
{
    if (!user.IsInRole("admin"))
    {
        return Results.Forbid();
    }

    var salons = await db.Users
        .Where(u => u.Role == "salon")
        .Select(u => new
        {
            u.Id,
            u.Name,
            u.Email,
            u.Status,
            u.NextBillingAt,
            u.PastDueSince,
            u.SuspendedAt
        })
        .ToListAsync();

    return Results.Ok(salons);
});

api.MapGet("/admin/salons/{id:guid}/status/logs", async (Guid id, ClaimsPrincipal user, ClientFlowDb db) =>
{
    if (!user.IsInRole("admin"))
    {
        return Results.Forbid();
    }

    var logs = await db.SalonStatusLogs
        .Where(l => l.SalonId == id)
        .OrderByDescending(l => l.CreatedAt)
        .Select(l => new { l.Id, l.FromStatus, l.ToStatus, l.CreatedAt })
        .ToListAsync();

    return Results.Ok(logs);
});

api.MapPost("/admin/salons/{id:guid}/status", async (
    Guid id,
    SalonStatusInput input,
    ClaimsPrincipal user,
    ClientFlowDb db,
    INotifier notifier
) =>
{
    if (!user.IsInRole("admin"))
    {
        return Results.Forbid();
    }

    var salon = await db.Users.FirstOrDefaultAsync(u => u.Id == id && u.Role == "salon");
    if (salon is null)
    {
        return Results.NotFound();
    }

    var status = input.Status?.Trim().ToUpper() ?? SalonStatus.Active;
    if (status is not (SalonStatus.Active or SalonStatus.PastDue or SalonStatus.Suspended))
    {
        return Results.BadRequest(new { message = "Status invalido." });
    }

    var previousStatus = salon.Status;
    salon.Status = status;
    if (status == SalonStatus.PastDue && salon.PastDueSince is null)
    {
        salon.PastDueSince = DateTime.UtcNow;
    }

    if (status == SalonStatus.Suspended)
    {
        salon.SuspendedAt = DateTime.UtcNow;
    }

    if (status == SalonStatus.Active)
    {
        salon.PastDueSince = null;
        salon.SuspendedAt = null;
    }

    db.SalonStatusLogs.Add(new SalonStatusLog
    {
        Id = Guid.NewGuid(),
        SalonId = salon.Id,
        FromStatus = previousStatus,
        ToStatus = status,
        CreatedAt = DateTime.UtcNow
    });

    db.Alerts.Add(new Alert
    {
        Id = Guid.NewGuid(),
        UserId = salon.Id,
        Title = status == SalonStatus.Active ? "Conta reativada" :
            status == SalonStatus.PastDue ? "Pagamento pendente" : "Conta suspensa",
        Body = status == SalonStatus.Active
            ? "Seu acesso foi reativado. Obrigado por manter o pagamento em dia."
            : status == SalonStatus.PastDue
                ? "Seu pagamento esta pendente. Regularize para evitar bloqueio."
                : "Sua conta foi suspensa. Regularize o pagamento para voltar a usar.",
        Tone = status == SalonStatus.Active ? "info" : status == SalonStatus.PastDue ? "warning" : "danger",
        CreatedAt = DateTime.UtcNow
    });

    await notifier.SendEmailAsync(
        salon.Email,
        "Status da conta atualizado",
        $"Seu status foi alterado para: {status}"
    );
    if (!string.IsNullOrWhiteSpace(salon.Phone))
    {
        await notifier.SendWhatsAppAsync(
            salon.Phone,
            $"ClientFlow: seu status foi alterado para {status}."
        );
    }

    await db.SaveChangesAsync();
    return Results.Ok(new { salon.Id, salon.Status });
});

api.MapGet("/clients", async (ClientFlowDb db) =>
    await db.Clients.OrderBy(c => c.Name).ToListAsync());

api.MapGet("/clients/{id:guid}", async (Guid id, ClientFlowDb db) =>
{
    var client = await db.Clients.FirstOrDefaultAsync(item => item.Id == id);
    return client is null ? Results.NotFound() : Results.Ok(client);
});

api.MapPost("/clients", async (ClientInput input, ClientFlowDb db) =>
{
    if (string.IsNullOrWhiteSpace(input.Name))
    {
        return Results.BadRequest(new { message = "Nome e obrigatorio." });
    }

    var client = new Client
    {
        Id = Guid.NewGuid(),
        Name = input.Name.Trim(),
        Phone = input.Phone?.Trim() ?? string.Empty,
        Email = input.Email?.Trim() ?? string.Empty,
        Notes = input.Notes?.Trim() ?? string.Empty,
        CreatedAt = DateTime.UtcNow
    };

    db.Clients.Add(client);
    await db.SaveChangesAsync();
    return Results.Created($"/clients/{client.Id}", client);
});

api.MapPut("/clients/{id:guid}", async (Guid id, ClientInput input, ClientFlowDb db) =>
{
    var client = await db.Clients.FirstOrDefaultAsync(item => item.Id == id);
    if (client is null)
    {
        return Results.NotFound();
    }

    client.Name = string.IsNullOrWhiteSpace(input.Name) ? client.Name : input.Name.Trim();
    client.Phone = input.Phone?.Trim() ?? client.Phone;
    client.Email = input.Email?.Trim() ?? client.Email;
    client.Notes = input.Notes?.Trim() ?? client.Notes;

    await db.SaveChangesAsync();
    return Results.Ok(client);
});

api.MapDelete("/clients/{id:guid}", async (Guid id, ClientFlowDb db) =>
{
    var client = await db.Clients.FirstOrDefaultAsync(item => item.Id == id);
    if (client is null)
    {
        return Results.NotFound();
    }

    db.Clients.Remove(client);
    await db.SaveChangesAsync();
    return Results.NoContent();
});

api.MapGet("/appointments", async (ClientFlowDb db) =>
    await db.Appointments.OrderBy(a => a.StartAt).ToListAsync());

api.MapGet("/appointments/{id:guid}", async (Guid id, ClientFlowDb db) =>
{
    var appointment = await db.Appointments.FirstOrDefaultAsync(item => item.Id == id);
    return appointment is null ? Results.NotFound() : Results.Ok(appointment);
});

api.MapPost("/appointments", async (AppointmentInput input, ClientFlowDb db) =>
{
    if (input.ClientId == Guid.Empty)
    {
        return Results.BadRequest(new { message = "Cliente e obrigatorio." });
    }

    if (string.IsNullOrWhiteSpace(input.Title))
    {
        return Results.BadRequest(new { message = "Titulo e obrigatorio." });
    }

    var clientExists = await db.Clients.AnyAsync(client => client.Id == input.ClientId);
    if (!clientExists)
    {
        return Results.BadRequest(new { message = "Cliente nao encontrado." });
    }

    var appointment = new Appointment
    {
        Id = Guid.NewGuid(),
        ClientId = input.ClientId,
        Title = input.Title.Trim(),
        StartAt = input.StartAt == default ? DateTime.UtcNow.AddHours(1) : input.StartAt,
        DurationMinutes = input.DurationMinutes <= 0 ? 60 : input.DurationMinutes,
        Notes = input.Notes?.Trim() ?? string.Empty,
        Status = string.IsNullOrWhiteSpace(input.Status) ? "pendente" : input.Status.Trim()
    };

    db.Appointments.Add(appointment);
    await db.SaveChangesAsync();
    return Results.Created($"/appointments/{appointment.Id}", appointment);
});

api.MapPut("/appointments/{id:guid}", async (Guid id, AppointmentInput input, ClientFlowDb db) =>
{
    var appointment = await db.Appointments.FirstOrDefaultAsync(item => item.Id == id);
    if (appointment is null)
    {
        return Results.NotFound();
    }

    appointment.Title = string.IsNullOrWhiteSpace(input.Title) ? appointment.Title : input.Title.Trim();
    appointment.StartAt = input.StartAt == default ? appointment.StartAt : input.StartAt;
    appointment.DurationMinutes = input.DurationMinutes <= 0 ? appointment.DurationMinutes : input.DurationMinutes;
    appointment.Notes = input.Notes?.Trim() ?? appointment.Notes;
    appointment.Status = string.IsNullOrWhiteSpace(input.Status) ? appointment.Status : input.Status.Trim();

    await db.SaveChangesAsync();
    return Results.Ok(appointment);
});

api.MapDelete("/appointments/{id:guid}", async (Guid id, ClientFlowDb db) =>
{
    var appointment = await db.Appointments.FirstOrDefaultAsync(item => item.Id == id);
    if (appointment is null)
    {
        return Results.NotFound();
    }

    db.Appointments.Remove(appointment);
    await db.SaveChangesAsync();
    return Results.NoContent();
});

api.MapGet("/conversations", async (ClientFlowDb db) =>
{
    var response = await db.Conversations
        .Include(c => c.Client)
        .OrderByDescending(c => c.LastMessageAt)
        .Select(c => new ConversationSummary(
            c.Id,
            c.ClientId,
            c.Client != null ? c.Client.Name : "Cliente",
            db.Messages
                .Where(m => m.ConversationId == c.Id)
                .OrderByDescending(m => m.CreatedAt)
                .Select(m => m.Body)
                .FirstOrDefault(),
            c.LastMessageAt
        ))
        .ToListAsync();

    return Results.Ok(response);
});

api.MapPost("/conversations", async (ConversationInput input, ClientFlowDb db) =>
{
    if (input.ClientId == Guid.Empty)
    {
        return Results.BadRequest(new { message = "Cliente e obrigatorio." });
    }

    var existing = await db.Conversations.FirstOrDefaultAsync(c => c.ClientId == input.ClientId);
    if (existing is not null)
    {
        return Results.Ok(existing);
    }

    var conversation = new Conversation
    {
        Id = Guid.NewGuid(),
        ClientId = input.ClientId,
        CreatedAt = DateTime.UtcNow,
        LastMessageAt = DateTime.UtcNow
    };

    db.Conversations.Add(conversation);
    await db.SaveChangesAsync();
    return Results.Created($"/conversations/{conversation.Id}", conversation);
});

api.MapGet("/conversations/{id:guid}/messages", async (Guid id, ClientFlowDb db) =>
{
    var messages = await db.Messages
        .Where(m => m.ConversationId == id)
        .OrderBy(m => m.CreatedAt)
        .ToListAsync();

    return Results.Ok(messages);
});

api.MapPost("/conversations/{id:guid}/messages", async (
    Guid id,
    MessageInput input,
    ClientFlowDb db,
    IHubContext<ChatHub> hub
) =>
{
    if (string.IsNullOrWhiteSpace(input.Body))
    {
        return Results.BadRequest(new { message = "Mensagem vazia." });
    }

    var conversation = await db.Conversations.FirstOrDefaultAsync(c => c.Id == id);
    if (conversation is null)
    {
        return Results.NotFound();
    }

    var message = new Message
    {
        Id = Guid.NewGuid(),
        ConversationId = id,
        SenderType = string.IsNullOrWhiteSpace(input.SenderType) ? "salon" : input.SenderType.Trim(),
        SenderName = input.SenderName?.Trim() ?? string.Empty,
        Body = input.Body.Trim(),
        CreatedAt = DateTime.UtcNow
    };

    db.Messages.Add(message);
    conversation.LastMessageAt = message.CreatedAt;
    await db.SaveChangesAsync();

    await hub.Clients.Group(id.ToString())
        .SendAsync("message:new", new MessageDto(
            message.Id,
            message.ConversationId,
            message.SenderType,
            message.SenderName,
            message.Body,
            message.CreatedAt
        ));

    return Results.Created($"/conversations/{id}/messages/{message.Id}", message);
});

app.MapHub<ChatHub>("/hubs/chat");

app.Run();

record RegisterInput(string Email, string Password, string? Name, string? Phone, string? Role);
record LoginInput(string Email, string Password);
record SalonStatusInput(string? Status);
record ClientInput(string Name, string? Phone, string? Email, string? Notes);
record AppointmentInput(Guid ClientId, string Title, DateTime StartAt, int DurationMinutes, string? Notes, string? Status);
record ConversationInput(Guid ClientId);
record MessageInput(string SenderType, string? SenderName, string Body);
record ConversationSummary(Guid Id, Guid ClientId, string ClientName, string? LastMessage, DateTime LastMessageAt);
record MessageDto(Guid Id, Guid ConversationId, string SenderType, string SenderName, string Body, DateTime CreatedAt);
