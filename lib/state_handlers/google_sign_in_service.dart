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

  // Getter for the GoogleSignIn instance
  GoogleSignIn get googleSignIn => _googleSignIn;

  // Initialize the GoogleSignIn instance
  void initialize() {
    final webClientId = dotenv.env['FIREBASE_WEB_CLIENT_ID'];

    if (webClientId == null || webClientId.isEmpty) {
      throw Exception(
          "Webclient Key for Google Auth cannot be empty, please set as an env variable");
    }

    var scopes = [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ];

    _googleSignIn = GoogleSignIn(
      clientId: webClientId,
      scopes: scopes,
    );
  }
}
