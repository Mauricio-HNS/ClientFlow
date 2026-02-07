namespace ClientFlow.Api.Models;

public class Client
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Notes { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }

    public List<Conversation> Conversations { get; set; } = new();
    public List<Appointment> Appointments { get; set; } = new();
}
