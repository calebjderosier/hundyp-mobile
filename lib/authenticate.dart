import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<User?> signInWithFirebase() async {
  try {
    final webClientId = dotenv.env['FIREBASE_WEB_CLIENT_ID'];

    if (webClientId == null || webClientId.isEmpty) {
      throw Exception(
          "Webclient Key for Google Auth cannot be empty, please set as an env variable");
    }

    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleSignIn = await GoogleSignIn(
      clientId: webClientId,
      scopes: [
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
        // Required for People API
      ],
    ).signIn();

    if (googleSignIn == null) {
      // The user canceled the sign-in
      print('cancelled sign in');
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleSignIn.authentication;

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

    print('Signed in with Firebase as $userCredential');
    // Return the signed-in user
    return userCredential.user;
  } catch (e) {
    print('Error signing in with Google: $e');
    return null;
  }
}

Future<GoogleSignInAccount?> signInWithGoogleAndFetchPeopleData() async {
  try {
    final webClientId = dotenv.env['FIREBASE_WEB_CLIENT_ID'];

    if (webClientId == null || webClientId.isEmpty) {
      throw Exception(
          "Web Client ID for Google Auth cannot be empty. Set it in your .env file.");
    }

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: webClientId,
      scopes: [
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ],
    );

    // Check if a user is already signed in
    GoogleSignInAccount? googleUser = googleSignIn.currentUser;

    if (googleUser == null) {
      // If not signed in, trigger the sign-in flow
      googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('User canceled sign-in.');
        return null;
      }
    }

    print('got user $googleUser');
    return googleUser;
  } catch (e) {
    print('Error signing in with Google or fetching People API data: $e');
    return null;
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
