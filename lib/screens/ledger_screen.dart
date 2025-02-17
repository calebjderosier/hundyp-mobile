import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Debug',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: currentUser != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current User Details:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text('UID: ${currentUser.uid}'),
            const SizedBox(height: 8),
            Text('Email: ${currentUser.email ?? "No email available"}'),
            const SizedBox(height: 8),
            Text(
              'Display Name: ${currentUser.displayName ?? "No display name available"}',
            ),
            const SizedBox(height: 8),
            Text(
              'Photo URL: ${currentUser.photoURL ?? "No photo URL available"}',
            ),
          ],
        )
            : Center(
          child: Text(
            'No user is currently signed in.',
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
      ),
    );
  }
}
