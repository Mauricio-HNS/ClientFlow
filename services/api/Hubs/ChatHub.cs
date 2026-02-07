using Microsoft.AspNetCore.SignalR;

namespace ClientFlow.Api.Hubs;

public class ChatHub : Hub
{
    public Task JoinConversation(string conversationId)
    {
        return Groups.AddToGroupAsync(Context.ConnectionId, conversationId);
    }

    public Task LeaveConversation(string conversationId)
    {
        return Groups.RemoveFromGroupAsync(Context.ConnectionId, conversationId);
    }
}
