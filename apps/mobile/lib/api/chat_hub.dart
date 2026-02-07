import 'dart:async';

import 'package:signalr_core/signalr_core.dart';

import '../models/message.dart';

class ChatHubClient {
  ChatHubClient({required String baseUrl})
      : _connection = HubConnectionBuilder()
            .withUrl('$baseUrl/hubs/chat')
            .withAutomaticReconnect()
            .build() {
    _connection.on('message:new', (arguments) {
      if (arguments == null || arguments.isEmpty) {
        return;
      }
      final payload = arguments.first;
      if (payload is Map<String, dynamic>) {
        _messages.add(Message.fromJson(payload));
      }
    });
  }

  final HubConnection _connection;
  final StreamController<Message> _messages = StreamController.broadcast();

  Stream<Message> get messages => _messages.stream;

  Future<void> connect() async {
    if (_connection.state == HubConnectionState.disconnected) {
      await _connection.start();
    }
  }

  Future<void> joinConversation(String conversationId) async {
    await _connection.invoke('JoinConversation', args: [conversationId]);
  }

  Future<void> leaveConversation(String conversationId) async {
    await _connection.invoke('LeaveConversation', args: [conversationId]);
  }

  Future<void> dispose() async {
    await _connection.stop();
    await _messages.close();
  }
}
