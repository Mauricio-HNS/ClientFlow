import '../models/appointment.dart';
import '../models/client.dart';

const _client1Id = '9b7d9f1f-3c7e-4c1f-9b2c-2b2d9f6d4e31';
const _client2Id = '0f28a9b9-4c3a-4c6f-9e2e-3f2e8c0d1e54';
const _client3Id = '5a8c2f3d-1b4d-4b7e-8a1f-7c2b9a3d6f22';

List<Client> demoClients() {
  return [
    Client(
      id: _client1Id,
      name: 'Carolina Souza',
      phone: '+55 11 99999-1111',
      email: 'carolina@email.com',
      notes: 'Prefere atendimento pela manha.',
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
    ),
    Client(
      id: _client2Id,
      name: 'Marco Antonio',
      phone: '+55 21 98888-2222',
      email: 'marco@email.com',
      notes: 'Cliente premium.',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    Client(
      id: _client3Id,
      name: 'Livia Martins',
      phone: '+55 31 97777-3333',
      email: 'livia@email.com',
      notes: 'Gosta de lembrete 1 dia antes.',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];
}

List<Appointment> demoAppointments() {
  final now = DateTime.now();
  return [
    Appointment(
      id: 'a63a81b7-0d1f-4e16-9d8a-4d82f021ac11',
      clientId: _client1Id,
      title: 'Corte + Tratamento',
      startAt: now.add(const Duration(hours: 2)),
      durationMinutes: 60,
      notes: 'Confirmado por WhatsApp',
      status: 'confirmado',
    ),
    Appointment(
      id: 'c1b37a6a-2e8b-4cf0-9f1c-2bd29b1f0d55',
      clientId: _client2Id,
      title: 'Consulta de retorno',
      startAt: now.add(const Duration(hours: 4)),
      durationMinutes: 45,
      notes: 'Ajuste de horario solicitado',
      status: 'pendente',
    ),
    Appointment(
      id: 'f0d18a9a-9b2a-4e2c-9a21-2ff7e7b4a931',
      clientId: _client3Id,
      title: 'Sessao de avaliacao',
      startAt: now.add(const Duration(days: 1, hours: 1)),
      durationMinutes: 30,
      notes: 'Primeiro atendimento',
      status: 'confirmado',
    ),
  ];
}
