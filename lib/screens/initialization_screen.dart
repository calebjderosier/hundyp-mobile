import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hundy_p/authenticate.dart';
import 'package:hundy_p/firebase/logging/firebase_logging.dart';
import 'package:hundy_p/firebase/service/messaging_service.dart';
import 'package:hundy_p/firebase_options.dart';
import 'package:hundy_p/main.dart';
import 'package:hundy_p/screens/error_screen.dart';
import 'package:hundy_p/state_handlers/auth_handler.dart';

class InitializationApp extends StatefulWidget {
  const InitializationApp({Key? key}) : super(key: key);

  @override
  InitializationAppState createState() => InitializationAppState();
}

class InitializationAppState extends State<InitializationApp> {
  String _loadingMessage = 'Starting up...';
  bool _isLoading = true;
  bool _hasError = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  String? _stackTrace;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('Step: Loading environment variables...');
      setState(() => _loadingMessage = 'v0.69.4');
      await dotenv.load(fileName: 'dotenv');

      print('Step: Initializing Firebase...');
      // setState(() => _loadingMessage = 'Initializing Backend...');
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);

      setupLogging();

      setState(() => _loadingMessage = 'Auth');
      print('Step: Authenticating...');
      // setState(() => _loadingMessage = 'Authenticating...');
      await setupAuthPersistence();
      final user = checkAuthStatus();
      _isAuthenticated = user != null;

      if (_isAuthenticated) {
        print('Step: Setting up Firebase Messaging...');
        setState(() => _loadingMessage = 'Set up messaging: $_isAuthenticated');
        await setupFirebaseMessaging();
      }

      if (!_isAuthenticated && !kIsWeb) {
        print('Step: Attempting mobile sign-in...');
        setState(() => _loadingMessage = 'Signing in');
        await signInWithFirebase();
        _isAuthenticated = checkAuthStatus() != null;
      }
    } catch (e, stackTrace) {
      print('Error during initialization: $e');
      print('Stack trace: $stackTrace');
      if (!_isAuthenticated) {
        logError(e: e, stackTrace: stackTrace, fatal: true);
        _hasError = true;
        _errorMessage = e.toString();
        _stackTrace = stackTrace.toString();
      }
    } finally {
      print('Step: Finalizing Initialization...');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  _loadingMessage,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_hasError) {
      return MaterialApp(
        home: ErrorScreen(
          errorMessage: _errorMessage ?? 'An error occurred.',
          stackTrace: _stackTrace ?? 'No stack trace available.',
        ),
      );
    }

    return _isAuthenticated
        ? const HundyPApp()
        : const AuthHandler(); // Transition to user-driven authentication
  }
}
