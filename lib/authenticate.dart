import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hundy_p/firebase/service/messaging_service.dart';

User? checkAuthStatus() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return user; // User is already authenticated
  }
  return null; // Return null if an error occurs
}

Future<User?> signInWithFirebase() async {
  try {
    final webClientId = dotenv.env['FIREBASE_WEB_CLIENT_ID'];

    if (webClientId == null || webClientId.isEmpty) {
      throw Exception(
          "Webclient Key for Google Auth cannot be empty, please set as an env variable");
    }

    // Define the scopes required by your app
    var scopes = [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ];

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: webClientId,
      scopes: scopes,
    );

    // Attempt to sign in silently
    GoogleSignInAccount? account = await googleSignIn.signInSilently();
    bool isAuthorized = account != null;

    // On the web, explicitly check authorization
    if (kIsWeb && account != null) {
      isAuthorized = await googleSignIn.canAccessScopes(scopes);
    }

    // If not authorized, return null
    if (!isAuthorized || account == null) {
      print('User is not authorized.');
      return null;
    }

    // Obtain authentication details
    final GoogleSignInAuthentication googleAuth = await account.authentication;

    // Create a new credential for Firebase
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with Firebase using the credential
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final user = userCredential.user;
    if (user == null) {
      print('Firebase sign-in failed.');
      return null;
    }

    // Log a test event for Firebase Analytics
    FirebaseAnalytics.instance.logEvent(name: "user_signed_in", parameters: {
      "method": "Google",
    });

    return user; // Return the signed-in user
  } catch (e) {
    print('Error signing in with Google: $e');
    return null; // Return null if an error occurs
  }
}

Future<void> setupAuthPersistence() async {
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  } else {
    print('Persistence is not supported on iOS/Android. Skipping...');
  }
}

void listenToAuthState() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
}

Future<bool> requestAdditionalScopes() async {
  try {
    final webClientId = dotenv.env['FIREBASE_WEB_CLIENT_ID'];

    if (webClientId == null || webClientId.isEmpty) {
      throw Exception(
          "Webclient Key for Google Auth cannot be empty, please set as an env variable");
    }

    final scopes = [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ];
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: webClientId,
      scopes: scopes,
    );

    final isAuthorized = await googleSignIn.requestScopes(scopes);
    if (isAuthorized) {
      // final user = await signInWithFirebase();
      // print('User signed in: $user');

      // if (user != null) {
        await setupFirebaseMessaging();
        print('Firebase messaging setup complete.');
        await uploadFcmToken();
        print('FCM token uploaded.');
      // }
    }
    return isAuthorized;
  } catch (e) {
    print('Error requesting additional scopes: $e');
    return false;
  }
}
