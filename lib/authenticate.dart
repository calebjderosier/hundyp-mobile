import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<User?> checkAuthStatus() async {
  final user = FirebaseAuth.instance.currentUser;

  return user ?? await signInWithFirebase();
}

Future<User?> signInWithFirebase() async {
  try {
    final webClientId = dotenv.env['FIREBASE_WEB_CLIENT_ID'];

    if (webClientId == null || webClientId.isEmpty) {
      throw Exception(
          "Webclient Key for Google Auth cannot be empty, please set as an env variable");
    }

    // Trigger the Google Sign-In flow
    var scopes = [
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
        // Required for People API
      ];
    final GoogleSignIn googleSignIn = await GoogleSignIn(
      clientId: webClientId,
      scopes: scopes,
    );

    GoogleSignInAccount? account;

    // native only
    // if (!kIsWeb) {
      account = await googleSignIn.signInSilently();
    // }
    bool isAuthorized = account != null;

    if (kIsWeb && account != null) {
      isAuthorized = await googleSignIn.canAccessScopes(scopes);
    }

    if (kIsWeb && !isAuthorized){
      print('should fail');
      await googleSignIn.requestScopes(scopes);
    }

    if (account == null) {
      // The user canceled the sign-in
      print('cancelled sign in');
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await account.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print('credential $credential');

    // Authenticate with Firebase
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final user = userCredential.user;
    if (user == null) {
      print('Firebase sign-in failed.');
      return null;
    }
    // However, on web...
    if (kIsWeb) {
      isAuthorized = await googleSignIn.canAccessScopes(scopes);
    }

    // Signed in with Firebase
    FirebaseAnalytics.instance.logEvent(name: "test", parameters: {
      "great": "success",
    });

    // Now just return user
    return user;
  } catch (e) {
    print('Error signing in with Google: $e');
    return null;
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
