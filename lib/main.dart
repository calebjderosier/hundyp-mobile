import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hundy_p/authenticate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hundy_p/home.dart';

import 'firebase/service/messaging_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load env vars
  await dotenv.load();

  // listenToAuthState();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

await  signInWithFirebase();
  // final user = await signInWithGoogleAndFetchPeopleData();
  // if (user != null) {
  //   storeFcmToken(user,'3434');
  // }

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
      themeMode: ThemeMode.system,
      // Automatically switch based on system preference
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
      child: Text("TODO: Chat Room"),
    ),
    Center(
      child: Text("TODO: Ledger"),
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
    );
  }
}
