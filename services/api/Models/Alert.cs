namespace ClientFlow.Api.Models;

public class Alert
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public AppUser? User { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public string Tone { get; set; } = "info"; // info, warning, danger
    public DateTime CreatedAt { get; set; }
}
