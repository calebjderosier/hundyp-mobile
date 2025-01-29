import 'package:flutter/material.dart';
import 'package:hundy_p/authenticate.dart';
import 'package:hundy_p/firebase/service/messaging_service.dart';
import 'package:hundy_p/main.dart';
import 'package:hundy_p/screens/unauthenticated_home.dart';

class AuthHandler extends StatefulWidget {
  const AuthHandler({Key? key}) : super(key: key);

  @override
  _AuthHandlerState createState() => _AuthHandlerState();
}

class _AuthHandlerState extends State<AuthHandler> {
  bool _isLoading = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    setState(() {
      _isAuthenticated = checkAuthStatus() != null;
    });
  }

  Future<void> _onRetry() async {
    setState(() => _isLoading = true);
    var user;
    try {
      user = signInWithFirebase();
      await requestAdditionalScopes();
      await setupFirebaseMessaging();
      print('Firebase messaging setup complete.');
      await uploadFcmToken();
    } catch (e) {
      print('nope');
    }
    setState(() {
      _isAuthenticated = user;
    });
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
          home: Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ));
    }

    return _isAuthenticated
        ? const HundyPMain(title: 'Hundy P') // Main app if authenticated
        : UnauthenticatedApp(
            onRetry: _onRetry, // Retry logic passed to ErrorApp
          );
  }
}
