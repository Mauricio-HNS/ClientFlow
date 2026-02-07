import 'package:flutter/material.dart';

import '../theme/clientflow_palette.dart';

class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 46, color: ClientFlowPalette.accent),
              const SizedBox(height: 16),
              const Text(
                'Conta suspensa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ClientFlowPalette.deepest,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: ClientFlowPalette.muted),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {},
                child: const Text('Regularizar pagamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
