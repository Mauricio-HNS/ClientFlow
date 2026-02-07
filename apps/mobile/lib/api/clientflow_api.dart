import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/appointment.dart';
import '../models/client.dart';
import '../models/conversation_summary.dart';
import '../models/message.dart';

class ClientFlowApi {
  ClientFlowApi({required this.baseUrl});

  final String baseUrl;

  Future<List<Client>> fetchClients() async {
    final response = await http.get(Uri.parse('$baseUrl/clients'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar clientes (${response.statusCode}).');
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data
        .map((item) => Client.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Client> createClient({
    required String name,
    String? phone,
    String? email,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'phone': phone ?? '',
        'email': email ?? '',
        'notes': notes ?? '',
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao criar cliente (${response.statusCode}).');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return Client.fromJson(data);
  }

  Future<List<Appointment>> fetchAppointments() async {
    final response = await http.get(Uri.parse('$baseUrl/appointments'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar agendamentos (${response.statusCode}).');
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data
        .map((item) => Appointment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ConversationSummary>> fetchConversations() async {
    final response = await http.get(Uri.parse('$baseUrl/conversations'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar conversas (${response.statusCode}).');
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data
        .map((item) => ConversationSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<String> getOrCreateConversation(String clientId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/conversations'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'clientId': clientId}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erro ao criar conversa (${response.statusCode}).');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return data['id'] as String;
  }

  Future<List<Message>> fetchMessages(String conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversations/$conversationId/messages'),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar mensagens (${response.statusCode}).');
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data
        .map((item) => Message.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Message> sendMessage({
    required String conversationId,
    required String body,
    String senderType = 'salon',
    String senderName = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/conversations/$conversationId/messages'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'senderType': senderType,
        'senderName': senderName,
        'body': body,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao enviar mensagem (${response.statusCode}).');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return Message.fromJson(data);
  }
}

class DashboardData {
  DashboardData({required this.clients, required this.appointments});

  final List<Client> clients;
  final List<Appointment> appointments;
}
