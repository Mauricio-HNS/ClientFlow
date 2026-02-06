import 'package:flutter/material.dart';

import 'api/clientflow_api.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ClientFlowApp());
}

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
        appBarTheme: AppBarTheme(
          backgroundColor: ClientFlowPalette.deep,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
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
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: HomeScreen(
        api: ClientFlowApi(baseUrl: clientFlowApiBaseUrl),
      ),
    );
  }
}

const clientFlowApiBaseUrl = String.fromEnvironment(
  'CLIENTFLOW_API_URL',
  defaultValue: 'http://localhost:5078',
);
