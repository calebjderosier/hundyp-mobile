import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:hundy_p/screens/authenticated_home.dart';
import 'package:hundy_p/screens/chat_room.dart';
import 'package:hundy_p/screens/error_screen.dart';
import 'package:hundy_p/screens/initialization_screen.dart';
import 'package:hundy_p/screens/ledger_screen.dart';
import 'package:hundy_p/state_handlers/auth_handler.dart';
import 'package:hundy_p/state_handlers/snackbar_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    runApp(MaterialApp(
      home: ErrorScreen(
        errorMessage: details.exceptionAsString(),
        stackTrace: details.stack.toString(),
      ),
    ));
  };

  // Start the app with the loading flow
  runApp(const InitializationApp());
}

class HundyPApp extends StatelessWidget {
  const HundyPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hundy P',
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFF0E9D6),
          // Cream (calm and uplifting)
          onPrimary: Color(0xFF034067),
          // Deep blue for contrast
          secondary: Color(0xFFFFD700),
          // Soft yellow (happy and warm)
          onSecondary: Color(0xFF805C00),
          // Deep golden brown for readability
          error: Color(0xFFE57373),
          // Soft red (friendly for errors)
          onError: Color(0xFF8A1C1C),
          // Deep red for contrast
          surface: Color(0xFF8BC6EC),
          // Light blue
          onSurface: Color(0xFF3D405B), // Neutral dark gray for text
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF617AAB),
          // Deep navy blue (calm and neutral)
          // alt C6CFE1FF
          onPrimary: Color(0xFFF0E9D6),
          // Cream for contrast
          secondary: Color(0xFF1A1A2E),
          // Warm orange (uplifting and happy)
          onSecondary: Color(0xFF1A1A2E),
          // Deep navy for contrast
          error: Color(0xFFEF5350),
          // Muted red
          onError: Color(0xFF1E1E1E),
          // Very dark gray for contrast on error elements
          surface: Color(0xFF1B2452),
          // Dark gray (calming surface color)
          onSurface:
              Color(0xFFF0E9D6), // Cream for readability on dark surfaces
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      // Automatically switch based on system preference
      home: const AuthHandler(),
      builder: (context, child) {
        SnackBarHandler().setContext(context); // Initialize SnackBarService
        return child!;
      },
    );
  }
}

class HundyPMain extends StatefulWidget {
  const HundyPMain({super.key, required this.title});

  final String title;

  @override
  State<HundyPMain> createState() => _HundyPMainState();
}

class _HundyPMainState extends State<HundyPMain> {
  int _selectedTab = 0;

  final List _navPages = const [
    HomePage(title: "Hundy P"),
    ChatRoomPage(),
    LedgerScreen(),
  ];

  void _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: _navPages[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => _changeTab(index),
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.rocket),
            activeIcon: Icon(Icons.rocket,
                color:
                    Theme.of(context).colorScheme.primary), // Active icon color
          ),
          BottomNavigationBarItem(
            label: 'Chat Room',
            icon: Icon(Icons.chat),
            activeIcon:
                Icon(Icons.chat, color: Theme.of(context).colorScheme.primary),
          ),
          BottomNavigationBarItem(
            label: 'Ledger',
            icon: Icon(Icons.portrait),
            activeIcon: Icon(Icons.portrait,
                color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    ));
  }
}
