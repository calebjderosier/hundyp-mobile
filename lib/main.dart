import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hundy_p/authenticate.dart';
import 'package:hundy_p/home.dart';

import 'firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load env vars
  await dotenv.load();

  // listenToAuthState();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // todo - prolly better
  // await signInWithGoogle();
  await signInWithGoogleAndFetchPeopleData();

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
          brightness: Brightness.dark,
          primary: Colors.deepOrange,
          onPrimary: Colors.blueAccent,
          secondary: Colors.deepOrange,
          onSecondary: Colors.orangeAccent,
          error: Colors.redAccent,
          onError: Colors.deepOrange,
          surface: Color.fromARGB(255, 0, 37, 220),
          onSurface: Colors.orangeAccent,
        ),
        useMaterial3: true,
      ),
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
