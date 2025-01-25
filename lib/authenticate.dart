import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<User?> signInWithGoogle() async {
  try {
    final webClientId = dotenv.env['GOOGLE_CLOUD_WEB_CLIENT_ID'];

    if (webClientId == null || webClientId.isEmpty) {
      throw Exception(
          "Webclient Key for Google Auth cannot be empty, please set as an env variable");
    }

    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleSignIn = await GoogleSignIn(
      clientId: webClientId,
      scopes: ['email'],
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


Future<void> signInWithGoogleAndFetchPeopleData() async {
  try {
    final webClientId = dotenv.env['GOOGLE_CLOUD_WEB_CLIENT_ID'];

    if (webClientId == null || webClientId.isEmpty) {
      throw Exception(
          "Web Client ID for Google Auth cannot be empty. Set it in your .env file.");
    }

    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      clientId: webClientId,
      scopes: [
        'email',
        'https://www.googleapis.com/auth/userinfo.profile', // Required for People API
      ],
    ).signIn();

    if (googleUser == null) {
      print('User canceled sign-in.');
      return;
    }

    // Obtain authentication details
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Use the access token to fetch People API data
    final accessToken = googleAuth.accessToken;
    if (accessToken != null) {
      final response = await http.get(
        Uri.parse(
            'https://people.googleapis.com/v1/people/me?personFields=names,emailAddresses'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('User data: $data');
      } else {
        print('Failed to fetch user data. Status code: ${response.statusCode}');
      }
    } else {
      print('Access token is null.');
    }
  } catch (e) {
    print('Error signing in with Google or fetching People API data: $e');
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
