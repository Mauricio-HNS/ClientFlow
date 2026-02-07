import 'package:flutter/material.dart';

import '../api/clientflow_api.dart';
import '../models/alert_item.dart';
import '../theme/clientflow_palette.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key, required this.api});

  final ClientFlowApi api;

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late Future<List<AlertItem>> _alerts;

  @override
  void initState() {
    super.initState();
    _alerts = widget.api.fetchAlerts();
  }

  Future<void> _reload() async {
    setState(() {
      _alerts = widget.api.fetchAlerts();
    });
    await _alerts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos'),
      ),
      body: FutureBuilder<List<AlertItem>>(
        future: _alerts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final alerts = snapshot.data ?? [];
          if (alerts.isEmpty) {
            return const Center(
              child: Text(
                'Sem avisos no momento.',
                style: TextStyle(color: ClientFlowPalette.muted),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _AlertCard(
                  title: alert.title,
                  body: alert.body,
                  tone: _alertToneFromValue(alert.tone),
                  createdAt: alert.createdAt,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

enum _AlertTone { info, warning, danger }

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.title,
    required this.body,
    required this.tone,
    required this.createdAt,
  });

  final String title;
  final String body;
  final _AlertTone tone;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      _AlertTone.info => ClientFlowPalette.primary,
      _AlertTone.warning => ClientFlowPalette.accent,
      _AlertTone.danger => Colors.redAccent,
    };

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
                const SizedBox(height: 8),
                Text(
                  _formatDate(createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: ClientFlowPalette.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

_AlertTone _alertToneFromValue(String value) {
  switch (value.toLowerCase()) {
    case 'warning':
      return _AlertTone.warning;
    case 'danger':
      return _AlertTone.danger;
    default:
      return _AlertTone.info;
  }
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/${local.year} $hour:$minute';
}
