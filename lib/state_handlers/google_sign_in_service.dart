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
  final _scopes = [
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  bool _isAuthorized = false;
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
  }



  // Prompts the user to authorize `scopes`.
  //
  // This action is **required** in platforms that don't perform Authentication
  // and Authorization at the same time (like the web).
  //
  // On the web, this must be called from an user interaction (button click).
  // #docregion RequestScopes
// todo - might need to do this for the ppl api
  Future<void> _handleAuthorizeScopes() async {
    print('do we eneda do this');
    final bool isAuthorized = await _googleSignIn.requestScopes(_scopes);
    // #enddocregion RequestScopes
    _isAuthorized = isAuthorized;
    // #docregion RequestScopes
    if (isAuthorized) {
      print('isAuthorized $isAuthorized');
    }
      // unawaited(_handleGetContact(_currentUser!));
    }
    // #enddocregion RequestScopes
  //
  //   Future<void> _handleGetContact(GoogleSignInAccount user) async {
  //     setState(() {
  //       _contactText = 'Loading contact info...';
  //     });
  //     final http.Response response = await http.get(
  //       Uri.parse('https://people.googleapis.com/v1/people/me/connections'
  //           '?requestMask.includeField=person.names'),
  //       headers: await user.authHeaders,
  //     );
  //     if (response.statusCode != 200) {
  //       setState(() {
  //         _contactText = 'People API gave a ${response.statusCode} '
  //             'response. Check logs for details.';
  //       });
  //       print('People API ${response.statusCode} response: ${response.body}');
  //       return;
  //     }
  //     final Map<String, dynamic> data =
  //     json.decode(response.body) as Map<String, dynamic>;
  //     final String? namedContact = _pickFirstNamedContact(data);
  //     setState(() {
  //       if (namedContact != null) {
  //         _contactText = 'I see you know $namedContact!';
  //       } else {
  //         _contactText = 'No contacts to display.';
  //       }
  //     });
  //   }
  // }
}
