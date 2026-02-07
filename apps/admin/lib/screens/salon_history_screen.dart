import 'package:flutter/material.dart';

import '../api/clientflow_api.dart';
import '../models/salon_status_log.dart';
import '../theme/clientflow_palette.dart';

class SalonHistoryScreen extends StatefulWidget {
  const SalonHistoryScreen({
    super.key,
    required this.api,
    required this.salonId,
    required this.salonName,
  });

  final ClientFlowApi api;
  final String salonId;
  final String salonName;

  @override
  State<SalonHistoryScreen> createState() => _SalonHistoryScreenState();
}

class _SalonHistoryScreenState extends State<SalonHistoryScreen> {
  late Future<List<SalonStatusLog>> _logs;

  @override
  void initState() {
    super.initState();
    _logs = _loadLogs();
  }

  Future<List<SalonStatusLog>> _loadLogs() async {
    final response =
        await widget.api.rawGet('/admin/salons/${widget.salonId}/status/logs');
    final data = response as List<dynamic>;
    return data
        .map((item) => SalonStatusLog.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _reload() async {
    setState(() {
      _logs = _loadLogs();
    });
    await _logs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historico - ${widget.salonName}'),
      ),
      body: FutureBuilder<List<SalonStatusLog>>(
        future: _logs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return const Center(
              child: Text(
                'Sem historico de status.',
                style: TextStyle(color: ClientFlowPalette.muted),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final log = logs[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.history,
                          color: _statusColor(log.toStatus),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_statusLabel(log.fromStatus)} → ${_statusLabel(log.toStatus)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: ClientFlowPalette.deepest,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(log.createdAt),
                                style: const TextStyle(
                                  color: ClientFlowPalette.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status.toUpperCase()) {
    case 'PAST_DUE':
      return 'Em atraso';
    case 'SUSPENDED':
      return 'Suspenso';
    default:
      return 'Ativo';
  }
}

Color _statusColor(String status) {
  switch (status.toUpperCase()) {
    case 'PAST_DUE':
      return ClientFlowPalette.accent;
    case 'SUSPENDED':
      return Colors.redAccent;
    default:
      return ClientFlowPalette.primary;
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
