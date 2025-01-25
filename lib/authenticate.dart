import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<User?> signInWithGoogle() async {
  try {
    final webClientId = dotenv.env['GOOGLE_CLOUD_WEB_CLIENT_ID'];

    if (webClientId == null || webClientId.isEmpty) {
      throw Exception(
          "Webclient Key for Google Auth cannot be empty, please set as an env variable");
    }

    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      clientId: webClientId,
      scopes: ['email'],
    ).signIn();

    if (googleUser == null) {
      // The user canceled the sign-in
      print('cancelled sign in');
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print('credential $credential');

    // Sign in to Firebase with the Google user credentials
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    print('userCredential.user $userCredential');
    // Return the signed-in user
    return userCredential.user;
  } catch (e) {
    print('Error signing in with Google: $e');
    return null;
  }
}

void listenToAuthState() {
  FirebaseAuth.instance
      .authStateChanges()
      .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
}
