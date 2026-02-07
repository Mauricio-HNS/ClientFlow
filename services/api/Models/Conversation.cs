namespace ClientFlow.Api.Models;

public class Conversation
{
    public Guid Id { get; set; }
    public Guid ClientId { get; set; }
    public Client? Client { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime LastMessageAt { get; set; }
    public List<Message> Messages { get; set; } = new();
}
