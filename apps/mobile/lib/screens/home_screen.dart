import 'package:flutter/material.dart';

import '../api/clientflow_api.dart';
import '../demo/demo_data.dart';
import '../theme/clientflow_palette.dart';
import '../models/appointment.dart';
import '../models/client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api});

  final ClientFlowApi api;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<DashboardData> _dashboard;
  bool _isDemo = false;

  @override
  void initState() {
    super.initState();
    _dashboard = _loadDashboard();
  }

  Future<DashboardData> _loadDashboard() async {
    try {
      final clients = await widget.api.fetchClients();
      final appointments = await widget.api.fetchAppointments();
      if (mounted && _isDemo) {
        setState(() {
          _isDemo = false;
        });
      }
      return DashboardData(clients: clients, appointments: appointments);
    } catch (_) {
      if (mounted && !_isDemo) {
        setState(() {
          _isDemo = true;
        });
      }
      return DashboardData(
        clients: demoClients(),
        appointments: demoAppointments(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClientFlow'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Alertas',
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<DashboardData>(
          future: _dashboard,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorState(
                message: snapshot.error.toString(),
                onRetry: () {
                  setState(() {
                    _dashboard = _loadDashboard();
                  });
                },
              );
            }

            final data = snapshot.data!;
            final upcoming = data.appointments.toList()
              ..sort((a, b) => a.startAt.compareTo(b.startAt));

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const _HomeHeader(),
                const SizedBox(height: 16),
                const _AppBrandCard(),
                const SizedBox(height: 16),
                const _BusinessPhotoCard(),
                if (_isDemo) ...[
                  const SizedBox(height: 16),
                  const _DemoBanner(),
                ],
                const SizedBox(height: 24),
                _QuickStats(
                  clientsCount: data.clients.length,
                  todayAppointments: upcoming.length,
                ),
                const SizedBox(height: 24),
                const _SectionTitle(
                  title: 'Seus agendamentos',
                  subtitle: 'Proximos horarios confirmados',
                ),
                const SizedBox(height: 12),
                if (upcoming.isEmpty)
                  const _EmptyState(),
                for (final appointment in upcoming.take(4))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ScheduleCard(
                      appointment: appointment,
                      client: _findClient(data.clients, appointment.clientId),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Novo agendamento'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Client? _findClient(List<Client> clients, String id) {
  for (final client in clients) {
    if (client.id == id) {
      return client;
    }
  }
  return null;
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ClientFlowPalette.primary, ClientFlowPalette.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seu fluxo de clientes, sem atrito.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: ClientFlowPalette.deepest,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Agenda inteligente, historico completo e follow-ups automaticos.',
            style: TextStyle(
              color: ClientFlowPalette.deep,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Ola, Mauricio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ClientFlowPalette.deepest,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Aqui estao seus proximos agendamentos',
                style: TextStyle(color: ClientFlowPalette.muted),
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 22,
          backgroundColor: ClientFlowPalette.primary,
          child: Icon(Icons.person, color: ClientFlowPalette.deepest),
        ),
      ],
    );
  }
}

class _AppBrandCard extends StatelessWidget {
  const _AppBrandCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ClientFlowPalette.surface,
        border: Border.all(color: ClientFlowPalette.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: ClientFlowPalette.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: ClientFlowPalette.deepest,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'ClientFlow\nGestao inteligente do seu salao',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ClientFlowPalette.deep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessPhotoCard extends StatelessWidget {
  const _BusinessPhotoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [ClientFlowPalette.accent, ClientFlowPalette.deep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            bottom: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Salao Luma Beauty',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Foto do comercio (personalizavel)',
                  style: TextStyle(color: Color(0xFFD6EAF5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ClientFlowPalette.primary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ClientFlowPalette.primary.withOpacity(0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: ClientFlowPalette.deep),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Modo demo ativo. Mostrando dados locais enquanto a API nao responde.',
              style: TextStyle(color: ClientFlowPalette.deep),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.clientsCount, required this.todayAppointments});

  final int clientsCount;
  final int todayAppointments;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Clientes ativos',
            value: clientsCount.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Agendamentos hoje',
            value: todayAppointments.toString(),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ClientFlowPalette.dark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: ClientFlowPalette.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ClientFlowPalette.deepest,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: ClientFlowPalette.muted,
          ),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.appointment, required this.client});

  final Appointment appointment;
  final Client? client;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 44,
              decoration: BoxDecoration(
                color: appointment.status.toLowerCase() == 'confirmado'
                    ? ClientFlowPalette.accent
                    : ClientFlowPalette.muted,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: ClientFlowPalette.deepest,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    client?.name ?? 'Cliente nao identificado',
                    style: const TextStyle(
                      color: ClientFlowPalette.muted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatTime(appointment.startAt),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: ClientFlowPalette.deep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: ClientFlowPalette.surface,
        border: Border.all(color: ClientFlowPalette.surfaceBorder),
      ),
      child: const Text(
        'Sem compromissos na agenda. Que tal criar o primeiro?',
        style: TextStyle(color: ClientFlowPalette.muted),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 42, color: ClientFlowPalette.muted),
            const SizedBox(height: 12),
            const Text(
              'Nao foi possivel carregar os dados.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: ClientFlowPalette.muted),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
