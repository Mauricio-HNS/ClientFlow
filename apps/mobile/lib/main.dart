import 'package:flutter/material.dart';

void main() {
  runApp(const ClientFlowApp());
}

const _palette = _ClientFlowPalette();

class ClientFlowApp extends StatelessWidget {
  const ClientFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _palette.primary,
      onPrimary: Colors.white,
      secondary: _palette.accent,
      onSecondary: _palette.deep,
      error: const Color(0xFFB91C1C),
      onError: Colors.white,
      surface: _palette.surface,
      onSurface: _palette.deep,
    );

    return MaterialApp(
      title: 'ClientFlow',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _palette.background,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: _palette.deep,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _palette.primary,
            foregroundColor: _palette.deep,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _HeroHeader(),
            const SizedBox(height: 24),
            _QuickStats(),
            const SizedBox(height: 24),
            const _SectionTitle(
              title: 'Proximos compromissos',
              subtitle: 'Organize o dia em segundos',
            ),
            const SizedBox(height: 12),
            _ScheduleCard(
              title: 'Corte + Tratamento',
              customer: 'Carolina S.',
              time: '09:30',
              color: _palette.accent,
            ),
            const SizedBox(height: 12),
            _ScheduleCard(
              title: 'Consulta de retorno',
              customer: 'Marco A.',
              time: '11:00',
              color: _palette.muted,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Novo agendamento'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_palette.primary, _palette.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Seu fluxo de clientes, sem atrito.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B1E26),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Agenda inteligente, historico completo e follow-ups automaticos.',
            style: TextStyle(
              color: Color(0xFF18333D),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _StatCard(
            label: 'Clientes ativos',
            value: '124',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Agendamentos hoje',
            value: '9',
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
                color: Color(0xFF1C621B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF487070)),
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
            color: Color(0xFF0B1E26),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF487070),
          ),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.title,
    required this.customer,
    required this.time,
    required this.color,
  });

  final String title;
  final String customer;
  final String time;
  final Color color;

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
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B1E26),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer,
                    style: const TextStyle(
                      color: Color(0xFF487070),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF18333D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientFlowPalette {
  const _ClientFlowPalette();

  final Color primary = const Color(0xFFA5EC60);
  final Color accent = const Color(0xFF419310);
  final Color dark = const Color(0xFF1C621B);
  final Color muted = const Color(0xFF487070);
  final Color deep = const Color(0xFF18333D);
  final Color background = const Color(0xFFF4F7F6);
  final Color surface = const Color(0xFFFFFFFF);
}
