namespace ClientFlow.Api.Services;

public interface INotifier
{
    Task SendEmailAsync(string to, string subject, string body);
    Task SendWhatsAppAsync(string to, string body);
}

public class LogNotifier : INotifier
{
    public Task SendEmailAsync(string to, string subject, string body)
    {
        Console.WriteLine($"[email] to={to} subject={subject} body={body}");
        return Task.CompletedTask;
    }

    public Task SendWhatsAppAsync(string to, string body)
    {
        Console.WriteLine($"[whatsapp] to={to} body={body}");
        return Task.CompletedTask;
    }
}
