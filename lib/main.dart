import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hundy_p/home.dart';

import 'firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load env vars
  await dotenv.load();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup Firebase Messaging
  await setupFirebaseMessaging();


  runApp(const HundyPApp());
}

class HundyPApp extends StatelessWidget {
  const HundyPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hundy P',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFF0E9D6), // Cream (calm and uplifting)
          onPrimary: Color(0xFF034067), // Deep blue for contrast
          secondary: Color(0xFFFFD700), // Soft yellow (happy and warm)
          onSecondary: Color(0xFF805C00), // Deep golden brown for readability
          error: Color(0xFFE57373), // Soft red (friendly for errors)
          onError: Color(0xFF8A1C1C), // Deep red for contrast
          surface: Color(0xFF8BC6EC), // Light blue
          onSurface: Color(0xFF3D405B), // Neutral dark gray for text
          background: Color(0xFFFFFFFF), // Light background
          onBackground: Color(0xFF000000), // Black for text
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF1A1A2E), // Deep navy blue (calm and neutral)
          onPrimary: Color(0xFFF0E9D6), // Cream for contrast
          secondary: Color(0xFFFFA726), // Warm orange (uplifting and happy)
          onSecondary: Color(0xFF1A1A2E), // Deep navy for contrast
          error: Color(0xFFEF5350), // Muted red
          onError: Color(0xFF1E1E1E), // Very dark gray for contrast on error elements
          surface: Color(0xFF2A2D34), // Dark gray (calming surface color)
          onSurface: Color(0xFFF0E9D6), // Cream for readability on dark surfaces
          background: Color(0xFF121212), // Very dark gray (standard dark background)
          onBackground: Color(0xFFF5EEDC), // Soft cream for text on background
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, // Automatically switch based on system preference
      home: const HundyPMain(title: 'Hundy P`d?'),
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
    HomePage(title: "Hundy P?"),
    Center(
      child: Text("TODO: Leaderboard"),
    ),
    Center(
      child: Text("TODO: Profile"),
    ),
  ];

  void _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navPages[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => _changeTab(index),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.portrait),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
