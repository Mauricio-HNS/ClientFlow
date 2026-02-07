import 'package:flutter/material.dart';

import '../api/chat_hub.dart';
import '../api/clientflow_api.dart';
import '../models/client.dart';
import '../screens/chat_screen.dart';
import '../theme/clientflow_palette.dart';

class ClientDetailScreen extends StatelessWidget {
  const ClientDetailScreen({
    super.key,
    required this.client,
    required this.api,
    required this.hub,
  });

  final Client client;
  final ClientFlowApi api;
  final ChatHubClient hub;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe do cliente'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Header(client: client),
          const SizedBox(height: 24),
          _InfoCard(
            title: 'Contato',
            rows: [
              _InfoRow(label: 'Telefone', value: _valueOrDash(client.phone)),
              _InfoRow(label: 'E-mail', value: _valueOrDash(client.email)),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Observacoes',
            child: Text(
              client.notes.isNotEmpty
                  ? client.notes
                  : 'Sem observacoes cadastradas.',
              style: const TextStyle(color: ClientFlowPalette.muted),
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Cadastro',
            rows: [
              _InfoRow(
                label: 'Criado em',
                value: _formatDate(client.createdAt),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final conversationId =
                        await api.getOrCreateConversation(client.id);
                    if (!context.mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          api: api,
                          hub: hub,
                          conversationId: conversationId,
                          clientName: client.name,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message_outlined),
                  label: const Text('Mensagem'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ClientFlowPalette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ClientFlowPalette.surfaceBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: ClientFlowPalette.primary.withOpacity(0.4),
            child: Text(
              client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ClientFlowPalette.deep,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ClientFlowPalette.deepest,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _valueOrDash(client.phone),
                  style: const TextStyle(color: ClientFlowPalette.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, this.rows, this.child});

  final String title;
  final List<_InfoRow>? rows;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: ClientFlowPalette.deepest,
              ),
            ),
            const SizedBox(height: 12),
            if (rows != null)
              for (final row in rows!)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: row,
                ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: ClientFlowPalette.muted),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: ClientFlowPalette.deep,
            ),
          ),
        ),
      ],
    );
  }
}

String _valueOrDash(String value) {
  return value.isNotEmpty ? value : '-';
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}
