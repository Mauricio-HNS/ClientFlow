import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/appointment.dart';
import '../models/client.dart';

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
}

class DashboardData {
  DashboardData({required this.clients, required this.appointments});

  final List<Client> clients;
  final List<Appointment> appointments;
}
