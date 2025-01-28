import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hundy_p/firebase/service/messaging_service.dart';
import 'package:hundy_p/state_handlers/snackbar_handler.dart';

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

    // Show a dialog for user input
    final description = await showDialog<String>(
      context: context,
      builder: (context) {
        String? inputText;
        return AlertDialog(
          title: const Text('Fuck ya! What\'d you do?'),
          content: TextField(
            onChanged: (value) {
              inputText = value;
            },
            decoration: const InputDecoration(
              hintText: '(Optional) enter a description...',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // Dismiss with no input
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(inputText); // Return the input
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );

    // Call the Cloud Function with the user's input
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('sendNotification')
          .call({
        'displayName': FirebaseAuth.instance.currentUser!.displayName,
        'message': description,
        'uid': FirebaseAuth.instance.currentUser!.uid,
        // only temporary, just to restrict who has access to the app
        'email': FirebaseAuth.instance.currentUser!.email,
      });

      // Success toast
      SnackBarHandler().showSnackBar(
        message: 'Notification sent successfully! 🎉',
      );
      print('Result: ${result.data}');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Positioned absolute at the top
        if (requestNotificationPermission() ==
            NotificationPermissionStatus.denied)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.amber,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Please allow notifications. You need to see when your friends Hundy P.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Changed text color to black
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8.0),
                  // Add spacing between text and button
                  TextButton(
                    onPressed: explicitlyRequestNotiPermission,
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Colors.blue, // Optional: set button text color
                    ),
                    child: const Text('Enable'),
                  ),
                ],
              ),
            ),
          ),
        Center(
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
                  child: Text(
                    'Hundy P',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Theme.of(context).colorScheme.onPrimary,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
