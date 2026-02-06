import 'package:flutter/material.dart';

import '../api/clientflow_api.dart';
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

  @override
  void initState() {
    super.initState();
    _clients = widget.api.fetchClients();
  }

  Future<void> _refresh() async {
    setState(() {
      _clients = widget.api.fetchClients();
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
