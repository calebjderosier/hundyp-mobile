import 'package:flutter/material.dart';
import 'package:hundy_p/home.dart';

void main() {
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
          background: Color.fromARGB(255, 0, 37, 220),
          onBackground: Colors.orangeAccent,
          surface: Colors.white,
          onSurface: Colors.black,
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
