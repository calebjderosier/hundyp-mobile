import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hundy_p/authenticate.dart';
import 'package:hundy_p/firebase/logging/firebase_logging.dart';
import 'package:hundy_p/firebase/service/messaging_service.dart';
import 'package:hundy_p/firebase_options.dart';
import 'package:hundy_p/main.dart';
import 'package:hundy_p/screens/error_screen.dart';

class InitializationApp extends StatefulWidget {
  const InitializationApp({Key? key}) : super(key: key);

  @override
  InitializationAppState createState() => InitializationAppState();
}

class InitializationAppState extends State<InitializationApp> {
  String _loadingMessage = 'Starting up...';
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
      setState(() => _loadingMessage = 'Loading environment variables...');
      await dotenv.load(fileName: 'dotenv');

      setState(() => _loadingMessage = 'Initializing Backend...');
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);

      setupLogging();

      setState(() => _loadingMessage = 'Authenticating...');
      await setupAuthPersistence();
      final user = await checkAuthStatus();

      setState(() => _isAuthenticated = user != null);

      setState(() => _loadingMessage = 'Launching app...!');
      await setupFirebaseMessaging();

      if (_isAuthenticated) {
        runApp(const HundyPApp());
      }
    } catch (e, stackTrace) {
      print('Error during initialization: $e');
      print('Stack trace: $stackTrace');

      // Log error to Firebase Crashlytics
      logError(e: e, stackTrace: stackTrace, fatal: true);
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _stackTrace = stackTrace.toString();
      });
    }
  }

  Future<void> _requestScopes() async {
    try {
      final isAuthorized = await requestAdditionalScopes();
      if (isAuthorized) {
        final user = await checkAuthStatus();
        setState(() => _isAuthenticated = user != null);
        if (_isAuthenticated) {
          runApp(const HundyPApp());
        }
      }
    } catch (e) {
      print('Error requesting scopes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return MaterialApp(
        home: ErrorScreen(
          errorMessage: _errorMessage ?? 'An error occurred.',
          stackTrace: _stackTrace ?? 'No stack trace available.',
        ),
      );
    }

    if (!_isAuthenticated) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('You are not signed in.'),
                ElevatedButton(
                  onPressed: _requestScopes,
                  child: const Text('Request Permissions'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const MaterialApp(
      home: CircularProgressIndicator(),
    );
  }
}
