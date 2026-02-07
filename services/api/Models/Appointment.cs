namespace ClientFlow.Api.Models;

public class Appointment
{
    public Guid Id { get; set; }
    public Guid ClientId { get; set; }
    public Client? Client { get; set; }
    public string Title { get; set; } = string.Empty;
    public DateTime StartAt { get; set; }
    public int DurationMinutes { get; set; }
    public string Notes { get; set; } = string.Empty;
    public string Status { get; set; } = "pendente";
}
