import 'package:flutter/material.dart';

import '../api/clientflow_api.dart';
import '../theme/clientflow_palette.dart';

class SalonsAdminScreen extends StatefulWidget {
  const SalonsAdminScreen({super.key, required this.api});

  final ClientFlowApi api;

  @override
  State<SalonsAdminScreen> createState() => _SalonsAdminScreenState();
}

class _SalonsAdminScreenState extends State<SalonsAdminScreen> {
  late Future<List<dynamic>> _salons;

  @override
  void initState() {
    super.initState();
    _salons = _loadSalons();
  }

  Future<List<dynamic>> _loadSalons() async {
    final response = await widget.api.rawGet('/admin/salons');
    return response as List<dynamic>;
  }

  Future<void> _updateStatus(String id, String status) async {
    await widget.api.rawPost('/admin/salons/$id/status', {
      'status': status,
    });
    setState(() {
      _salons = _loadSalons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saloes'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _salons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final salons = snapshot.data ?? [];
          if (salons.isEmpty) {
            return const Center(child: Text('Nenhum salao encontrado.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: salons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final salon = salons[index] as Map<String, dynamic>;
              final status = (salon['status'] as String?) ?? 'ACTIVE';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salon['name'] as String? ?? 'Salao',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ClientFlowPalette.deepest,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        salon['email'] as String? ?? '',
                        style: const TextStyle(color: ClientFlowPalette.muted),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          _StatusChip(
                            label: 'Ativo',
                            selected: status == 'ACTIVE',
                            onTap: () => _updateStatus(salon['id'], 'ACTIVE'),
                          ),
                          _StatusChip(
                            label: 'Em atraso',
                            selected: status == 'PAST_DUE',
                            onTap: () => _updateStatus(salon['id'], 'PAST_DUE'),
                          ),
                          _StatusChip(
                            label: 'Suspenso',
                            selected: status == 'SUSPENDED',
                            onTap: () => _updateStatus(salon['id'], 'SUSPENDED'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? ClientFlowPalette.accent : ClientFlowPalette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ClientFlowPalette.surfaceBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? ClientFlowPalette.deepest : ClientFlowPalette.muted,
          ),
        ),
      ),
    );
  }
}
