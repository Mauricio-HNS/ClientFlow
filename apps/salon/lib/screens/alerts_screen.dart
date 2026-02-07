import 'package:flutter/material.dart';

import '../theme/clientflow_palette.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _AlertCard(
            title: 'Pagamento pendente',
            body:
                'Seu pagamento vence em 3 dias. Regularize para evitar bloqueio.',
            tone: _AlertTone.warning,
          ),
          SizedBox(height: 12),
          _AlertCard(
            title: 'Aviso final',
            body: 'Pagamento em atraso ha 7 dias. Sua conta sera suspensa.',
            tone: _AlertTone.danger,
          ),
        ],
      ),
    );
  }
}

enum _AlertTone { warning, danger }

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.title,
    required this.body,
    required this.tone,
  });

  final String title;
  final String body;
  final _AlertTone tone;

  @override
  Widget build(BuildContext context) {
    final color = tone == _AlertTone.warning
        ? ClientFlowPalette.accent
        : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ClientFlowPalette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ClientFlowPalette.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notifications_active, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ClientFlowPalette.deepest,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
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
