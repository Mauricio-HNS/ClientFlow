import 'package:flutter/material.dart';

import 'api/clientflow_api.dart';
import 'screens/clients_screen.dart';
import 'screens/home_screen.dart';
import 'theme/clientflow_palette.dart';

void main() {
  runApp(const ClientFlowApp());
}

const clientFlowApiBaseUrl = String.fromEnvironment(
  'CLIENTFLOW_API_URL',
  defaultValue: 'http://localhost:5078',
);

class ClientFlowApp extends StatelessWidget {
  const ClientFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: ClientFlowPalette.primary,
      onPrimary: Colors.white,
      secondary: ClientFlowPalette.accent,
      onSecondary: ClientFlowPalette.deep,
      error: const Color(0xFFB91C1C),
      onError: Colors.white,
      surface: ClientFlowPalette.surface,
      onSurface: ClientFlowPalette.deep,
    );

    return MaterialApp(
      title: 'ClientFlow',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: ClientFlowPalette.background,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: ClientFlowPalette.deep,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: ClientFlowPalette.surface,
          indicatorColor: ClientFlowPalette.primary.withOpacity(0.35),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? ClientFlowPalette.deep
                  : ClientFlowPalette.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? ClientFlowPalette.deep
                  : ClientFlowPalette.muted,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: ClientFlowPalette.primary,
            foregroundColor: ClientFlowPalette.deep,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: HomeShell(
        api: ClientFlowApi(baseUrl: clientFlowApiBaseUrl),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.api});

  final ClientFlowApi api;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(api: widget.api),
      ClientsScreen(api: widget.api),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Clientes',
          ),
        ],
      ),
    );
  }
}
