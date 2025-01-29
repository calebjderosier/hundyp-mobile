import 'package:flutter/material.dart';

class UnauthenticatedApp extends StatelessWidget {
  final VoidCallback onRetry;

  const UnauthenticatedApp({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You need to sign in to continue.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  minimumSize: const Size(150, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Log in',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
