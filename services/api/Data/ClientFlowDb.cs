using ClientFlow.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace ClientFlow.Api.Data;

public class ClientFlowDb : DbContext
{
    public ClientFlowDb(DbContextOptions<ClientFlowDb> options) : base(options)
    {
    }

    public DbSet<Client> Clients => Set<Client>();
    public DbSet<Appointment> Appointments => Set<Appointment>();
    public DbSet<Conversation> Conversations => Set<Conversation>();
    public DbSet<Message> Messages => Set<Message>();
    public DbSet<AppUser> Users => Set<AppUser>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Client>(entity =>
        {
            entity.Property(client => client.Name).IsRequired();
            entity.Property(client => client.CreatedAt).HasDefaultValueSql("NOW() AT TIME ZONE 'UTC'");
        });

        modelBuilder.Entity<AppUser>(entity =>
        {
            entity.HasIndex(user => user.Email).IsUnique();
            entity.Property(user => user.Name).IsRequired();
            entity.Property(user => user.Email).IsRequired();
            entity.Property(user => user.Role).IsRequired();
            entity.Property(user => user.CreatedAt).HasDefaultValueSql("NOW() AT TIME ZONE 'UTC'");
        });

        modelBuilder.Entity<Conversation>(entity =>
        {
            entity.HasOne(conversation => conversation.Client)
                .WithMany(client => client.Conversations)
                .HasForeignKey(conversation => conversation.ClientId);
        });

        modelBuilder.Entity<Message>(entity =>
        {
            entity.HasOne(message => message.Conversation)
                .WithMany(conversation => conversation.Messages)
                .HasForeignKey(message => message.ConversationId);
        });

        modelBuilder.Entity<Appointment>(entity =>
        {
            entity.HasOne(appointment => appointment.Client)
                .WithMany(client => client.Appointments)
                .HasForeignKey(appointment => appointment.ClientId);
        });
    }
}
