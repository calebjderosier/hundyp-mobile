import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onHundyPPress() async {
    _controller.forward(from: 0.0);

    try {
      // Retrieve the Firebase token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $fcmToken');
    } catch (e) {
      print('Error retrieving FCM token: $e');
    }
  }

  Future<void> _getAndPrintFcmToken() async {
    try {
      // Retrieve the Firebase token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $fcmToken');
    } catch (e) {
      print('Error retrieving FCM token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              );
            },
            child: ElevatedButton(
              onPressed: _onHundyPPress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: const Size(200, 200),
                shape: const CircleBorder(),
                elevation: 10,
              ),
              child: const Text(
                'Hundy P',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Colors.black,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
