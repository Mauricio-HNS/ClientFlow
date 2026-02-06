import 'package:flutter/material.dart';

import '../api/clientflow_api.dart';
import '../demo/demo_data.dart';
import '../models/client.dart';
import '../screens/client_detail_screen.dart';
import '../theme/clientflow_palette.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key, required this.api});

  final ClientFlowApi api;

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  late Future<List<Client>> _clients;
  bool _isDemo = false;

  @override
  void initState() {
    super.initState();
    _clients = _loadClients();
  }

  Future<List<Client>> _loadClients() async {
    try {
      final clients = await widget.api.fetchClients();
      if (mounted && _isDemo) {
        setState(() {
          _isDemo = false;
        });
      }
      return clients;
    } catch (_) {
      if (mounted && !_isDemo) {
        setState(() {
          _isDemo = true;
        });
      }
      return demoClients();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _clients = _loadClients();
    });
    await _clients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar',
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Client>>(
          future: _clients,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorState(
                message: snapshot.error.toString(),
                onRetry: _refresh,
              );
            }

            final clients = snapshot.data ?? [];
            if (clients.isEmpty) {
              return const _EmptyState();
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: clients.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final client = clients[index];
                  if (index == 0 && _isDemo) {
                    return Column(
                      children: [
                        const _DemoBanner(),
                        const SizedBox(height: 12),
                        _ClientCard(client: client),
                      ],
                    );
                  }
                  return _ClientCard(client: client);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: ClientFlowPalette.accent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ClientDetailScreen(client: client),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: ClientFlowPalette.primary.withOpacity(0.35),
                child: Text(
                  client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: ClientFlowPalette.deep,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ClientFlowPalette.deepest,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      client.phone.isNotEmpty ? client.phone : 'Sem telefone',
                      style: const TextStyle(color: ClientFlowPalette.muted),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: ClientFlowPalette.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.people_outline, size: 42, color: ClientFlowPalette.muted),
            SizedBox(height: 12),
            Text(
              'Nenhum cliente cadastrado ainda.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Crie o primeiro cliente para comecar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ClientFlowPalette.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

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
              'Nao foi possivel carregar os clientes.',
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
              onPressed: () => onRetry(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
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
