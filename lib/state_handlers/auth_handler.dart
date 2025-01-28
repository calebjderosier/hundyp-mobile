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
    setState(() {
      _isAuthenticated = checkAuthStatus() != null;
    });
  }

  Future<void> _onRetry() async {
    final isAuth = await requestAdditionalScopes();
    setState(() {
      _isAuthenticated = isAuth;
    });
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
            onRetry: _onRetry, // Retry logic passed to ErrorApp
          );
  }
}
