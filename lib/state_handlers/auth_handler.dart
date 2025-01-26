import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hundy_p/authenticate.dart';
import 'package:hundy_p/main.dart';
import 'package:hundy_p/screens/unauthenticated_home.dart';

class AuthHandler extends StatefulWidget {
  const AuthHandler({Key? key}) : super(key: key);

  @override
  _AuthHandlerState createState() => _AuthHandlerState();
}

class _AuthHandlerState extends State<AuthHandler> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
      } else {
        // Attempt sign-in
        final signedInUser = await signInWithFirebase();
        setState(() {
          _isAuthenticated = signedInUser != null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking auth status: $e');
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _isAuthenticated
        ? const HundyPMain(title: 'Hundy P') // Main app if authenticated
        : UnauthenticatedApp(
            onRetry: _checkAuthStatus, // Retry logic passed to ErrorApp
          );
  }
}
