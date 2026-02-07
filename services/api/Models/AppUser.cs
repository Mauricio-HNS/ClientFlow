namespace ClientFlow.Api.Models;

public class AppUser
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string Role { get; set; } = "client"; // client, salon, admin
    public string Status { get; set; } = SalonStatus.Active;
    public DateTime? NextBillingAt { get; set; }
    public DateTime? PastDueSince { get; set; }
    public DateTime? SuspendedAt { get; set; }
    public DateTime CreatedAt { get; set; }
}
