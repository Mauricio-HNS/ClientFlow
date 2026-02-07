import 'package:flutter/material.dart';

import 'api/clientflow_api.dart';
import 'api/chat_hub.dart';
import 'screens/clients_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
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
      brightness: Brightness.dark,
      primary: ClientFlowPalette.accent,
      onPrimary: ClientFlowPalette.deepest,
      secondary: ClientFlowPalette.primary,
      onSecondary: ClientFlowPalette.deepest,
      error: const Color(0xFFB91C1C),
      onError: Colors.white,
      surface: ClientFlowPalette.surface,
      onSurface: ClientFlowPalette.deepest,
      background: ClientFlowPalette.background,
      onBackground: ClientFlowPalette.deepest,
    );

    return MaterialApp(
      title: 'ClientFlow',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: ClientFlowPalette.background,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: ClientFlowPalette.background,
          foregroundColor: ClientFlowPalette.deepest,
          centerTitle: false,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: ClientFlowPalette.surface,
          indicatorColor: ClientFlowPalette.accent.withOpacity(0.25),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? ClientFlowPalette.deepest
                  : ClientFlowPalette.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? ClientFlowPalette.deepest
                  : ClientFlowPalette.muted,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ClientFlowPalette.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: ClientFlowPalette.surfaceBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: ClientFlowPalette.surfaceBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: ClientFlowPalette.accent, width: 1.4),
          ),
          labelStyle: const TextStyle(color: ClientFlowPalette.muted),
          hintStyle: const TextStyle(color: ClientFlowPalette.muted),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: ClientFlowPalette.accent,
            foregroundColor: ClientFlowPalette.deepest,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: ClientFlowPalette.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: SplashGate(
        api: ClientFlowApi(baseUrl: clientFlowApiBaseUrl),
      ),
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.api});

  final ClientFlowApi api;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return HomeShell(api: widget.api);
    }

    return SplashScreen(
      onReady: () {
        if (mounted) {
          setState(() {
            _ready = true;
          });
        }
      },
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
  late final ChatHubClient _hub;

  @override
  void initState() {
    super.initState();
    _hub = ChatHubClient(baseUrl: clientFlowApiBaseUrl);
  }

  @override
  void dispose() {
    _hub.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(api: widget.api),
      ClientsScreen(api: widget.api, hub: _hub),
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
