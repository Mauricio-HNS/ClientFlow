var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

var clients = new List<Client>
{
    new(Guid.NewGuid(), "Carolina Souza", "+55 11 99999-1111", "carolina@email.com", "Prefere atendimento pela manha", DateTime.UtcNow),
    new(Guid.NewGuid(), "Marco Antonio", "+55 21 98888-2222", "marco@email.com", "Cliente premium", DateTime.UtcNow)
};

var appointments = new List<Appointment>
{
    new(Guid.NewGuid(), clients[0].Id, "Corte + Tratamento", DateTime.UtcNow.AddHours(2), 60, "Confirmado", "confirmado"),
    new(Guid.NewGuid(), clients[1].Id, "Consulta de retorno", DateTime.UtcNow.AddHours(4), 45, "Solicitou ajuste", "pendente")
};

app.MapGet("/health", () => Results.Ok(new { status = "ok", service = "clientflow-api" }));

app.MapGet("/clients", () => Results.Ok(clients));

app.MapGet("/clients/{id:guid}", (Guid id) =>
{
    var client = clients.FirstOrDefault(item => item.Id == id);
    return client is null ? Results.NotFound() : Results.Ok(client);
});

app.MapPost("/clients", (ClientInput input) =>
{
    if (string.IsNullOrWhiteSpace(input.Name))
    {
        return Results.BadRequest(new { message = "Nome e obrigatorio." });
    }

    var client = new Client(
        Guid.NewGuid(),
        input.Name.Trim(),
        input.Phone?.Trim() ?? string.Empty,
        input.Email?.Trim() ?? string.Empty,
        input.Notes?.Trim() ?? string.Empty,
        DateTime.UtcNow
    );

    clients.Add(client);
    return Results.Created($"/clients/{client.Id}", client);
});

app.MapPut("/clients/{id:guid}", (Guid id, ClientInput input) =>
{
    var index = clients.FindIndex(item => item.Id == id);
    if (index < 0)
    {
        return Results.NotFound();
    }

    var existing = clients[index];
    var updated = existing with
    {
        Name = string.IsNullOrWhiteSpace(input.Name) ? existing.Name : input.Name.Trim(),
        Phone = input.Phone?.Trim() ?? existing.Phone,
        Email = input.Email?.Trim() ?? existing.Email,
        Notes = input.Notes?.Trim() ?? existing.Notes
    };

    clients[index] = updated;
    return Results.Ok(updated);
});

app.MapDelete("/clients/{id:guid}", (Guid id) =>
{
    var removed = clients.RemoveAll(item => item.Id == id);
    return removed == 0 ? Results.NotFound() : Results.NoContent();
});

app.MapGet("/appointments", () => Results.Ok(appointments));

app.MapGet("/appointments/{id:guid}", (Guid id) =>
{
    var appointment = appointments.FirstOrDefault(item => item.Id == id);
    return appointment is null ? Results.NotFound() : Results.Ok(appointment);
});

app.MapPost("/appointments", (AppointmentInput input) =>
{
    if (input.ClientId == Guid.Empty)
    {
        return Results.BadRequest(new { message = "Cliente e obrigatorio." });
    }

    if (string.IsNullOrWhiteSpace(input.Title))
    {
        return Results.BadRequest(new { message = "Titulo e obrigatorio." });
    }

    if (clients.All(client => client.Id != input.ClientId))
    {
        return Results.BadRequest(new { message = "Cliente nao encontrado." });
    }

    var appointment = new Appointment(
        Guid.NewGuid(),
        input.ClientId,
        input.Title.Trim(),
        input.StartAt == default ? DateTime.UtcNow.AddHours(1) : input.StartAt,
        input.DurationMinutes <= 0 ? 60 : input.DurationMinutes,
        input.Notes?.Trim() ?? string.Empty,
        string.IsNullOrWhiteSpace(input.Status) ? "pendente" : input.Status.Trim()
    );

    appointments.Add(appointment);
    return Results.Created($"/appointments/{appointment.Id}", appointment);
});

app.MapPut("/appointments/{id:guid}", (Guid id, AppointmentInput input) =>
{
    var index = appointments.FindIndex(item => item.Id == id);
    if (index < 0)
    {
        return Results.NotFound();
    }

    var existing = appointments[index];
    var updated = existing with
    {
        Title = string.IsNullOrWhiteSpace(input.Title) ? existing.Title : input.Title.Trim(),
        StartAt = input.StartAt == default ? existing.StartAt : input.StartAt,
        DurationMinutes = input.DurationMinutes <= 0 ? existing.DurationMinutes : input.DurationMinutes,
        Notes = input.Notes?.Trim() ?? existing.Notes,
        Status = string.IsNullOrWhiteSpace(input.Status) ? existing.Status : input.Status.Trim()
    };

    appointments[index] = updated;
    return Results.Ok(updated);
});

app.MapDelete("/appointments/{id:guid}", (Guid id) =>
{
    var removed = appointments.RemoveAll(item => item.Id == id);
    return removed == 0 ? Results.NotFound() : Results.NoContent();
});

app.Run();

record Client(Guid Id, string Name, string Phone, string Email, string Notes, DateTime CreatedAt);
record ClientInput(string Name, string? Phone, string? Email, string? Notes);

record Appointment(
    Guid Id,
    Guid ClientId,
    string Title,
    DateTime StartAt,
    int DurationMinutes,
    string Notes,
    string Status
);

record AppointmentInput(
    Guid ClientId,
    string Title,
    DateTime StartAt,
    int DurationMinutes,
    string? Notes,
    string? Status
);
