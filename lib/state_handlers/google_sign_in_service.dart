import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  // Private constructor
  GoogleSignInService._();

  // Singleton instance
  static final GoogleSignInService _instance = GoogleSignInService._();

  // Getter for the singleton instance
  static GoogleSignInService get instance => _instance;

  // GoogleSignIn instance
  late final GoogleSignIn _googleSignIn;

  // Scopes for Google Sign-In
  final _scopes = [
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  // Track authorization state
  bool _isAuthorized = false;

  // Track the current user
  GoogleSignInAccount? _currentUser;

  // Getter for the GoogleSignIn instance
  GoogleSignIn get googleSignIn => _googleSignIn;

  // Getter for the current user
  GoogleSignInAccount? get currentUser => _currentUser;

  // Getter for the authorization state
  bool get isAuthorized => _isAuthorized;

  // Initialize the GoogleSignIn instance
  void initialize() {
    final webClientId = dotenv.env['FIREBASE_WEB_CLIENT_ID'];

    if (webClientId == null || webClientId.isEmpty) {
      throw Exception(
          "Webclient Key for Google Auth cannot be empty, please set as an env variable");
    }

    _googleSignIn = GoogleSignIn(
      clientId: webClientId,
      scopes: _scopes,
    );

    // Listen for changes in the current user
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      _currentUser = account;

      // Check if the user is authorized (has granted the required scopes)
      if (kIsWeb && account != null) {
        _isAuthorized = await _googleSignIn.canAccessScopes(_scopes);
      } else {
        _isAuthorized = account != null;
      }
    });

    // Attempt silent sign-in
    _googleSignIn.signInSilently();
  }

  // Prompts the user to authorize additional scopes
  Future<void> requestScopes() async {
    if (_currentUser == null) {
      throw Exception("No user is currently signed in.");
    }

    final bool isAuthorized = await _googleSignIn.requestScopes(_scopes);
    _isAuthorized = isAuthorized;

    if (isAuthorized) {
      print("User has authorized the required scopes.");
    } else {
      print("User did not authorize the required scopes.");
    }
  }

  // Sign in the user
  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        _isAuthorized = await _googleSignIn.canAccessScopes(_scopes);
      }
      return _currentUser;
    } catch (e) {
      print("Error during sign-in: $e");
      return null;
    }
  }

  // Sign out the user
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _isAuthorized = false;
      print("User signed out successfully.");
    } catch (e) {
      print("Error during sign-out: $e");
    }
  }
}
