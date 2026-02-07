import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/appointment.dart';
import '../models/client.dart';
import '../models/conversation_summary.dart';
import '../models/message.dart';

class ClientFlowApi {
  ClientFlowApi({required this.baseUrl});

  final String baseUrl;
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<List<Client>> fetchClients() async {
    final response = await http.get(
      Uri.parse('$baseUrl/clients'),
      headers: _headers(),
    );
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
      headers: _headers(),
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
    final response = await http.get(
      Uri.parse('$baseUrl/appointments'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar agendamentos (${response.statusCode}).');
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data
        .map((item) => Appointment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ConversationSummary>> fetchConversations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversations'),
      headers: _headers(),
    );
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
      headers: _headers(),
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
      headers: _headers(),
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
      headers: _headers(),
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

class AuthResult {
  AuthResult({required this.token, required this.role});

  final String token;
  final String role;
}

extension AuthApi on ClientFlowApi {
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Credenciais invalidas.');
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    final role = user['role'] as String? ?? 'client';
    if (role != 'client') {
      throw Exception('Use o app correto para este perfil.');
    }
    setToken(token);
    return AuthResult(token: token, role: role);
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(),
      body: json.encode({
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
        'role': 'client',
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao cadastrar usuario.');
    }
  }
}
