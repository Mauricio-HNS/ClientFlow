namespace ClientFlow.Api.Models;

public class SalonStatusLog
{
    public Guid Id { get; set; }
    public Guid SalonId { get; set; }
    public AppUser? Salon { get; set; }
    public string FromStatus { get; set; } = string.Empty;
    public string ToStatus { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}
