import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:hundy_p/component/use_platform_sign_in.dart';

/// The scopes required by this application.
const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

class GoogleSignInComponent extends StatefulWidget {
  final void Function(GoogleSignInAccount user)? onSignedIn;

  const GoogleSignInComponent({Key? key, this.onSignedIn}) : super(key: key);

  @override
  State createState() => _GoogleSignInComponentState();
}

class _GoogleSignInComponentState extends State<GoogleSignInComponent> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: scopes,
  );

  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _contactText = '';

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      bool isAuthorized = account != null;

      if (kIsWeb && account != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      }

      setState(() {
        _currentUser = account;
        _isAuthorized = isAuthorized;
      });

      if (isAuthorized && widget.onSignedIn != null) {
        widget.onSignedIn!(account!);
      }

      if (isAuthorized) {
        unawaited(_handleGetContact(account!));
      }
    });

    _googleSignIn.signInSilently();
  }

  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() => _contactText = 'Loading contact info...');

    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );

    if (response.statusCode != 200) {
      setState(() {
        _contactText = 'People API error: ${response.statusCode}';
      });
      print('People API response: ${response.body}');
      return;
    }

    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);

    setState(() {
      _contactText = namedContact != null
          ? 'I see you know $namedContact!'
          : 'No contacts to display.';
    });
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => (contact as Map<Object?, dynamic>)['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;

    if (contact != null) {
      final List<dynamic> names = contact['names'] as List<dynamic>;
      final Map<String, dynamic>? name = names.firstWhere(
        (dynamic name) =>
            (name as Map<Object?, dynamic>)['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;

      return name?['displayName'] as String?;
    }

    return null;
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleAuthorizeScopes() async {
    final bool isAuthorized = await _googleSignIn.requestScopes(scopes);
    setState(() {
      _isAuthorized = isAuthorized;
    });

    if (isAuthorized) {
      unawaited(_handleGetContact(_currentUser!));
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  @override
  Widget build(BuildContext context) {
    final GoogleSignInAccount? user = _currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign In'),
      ),
      body: Center(
        child: user != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListTile(
                    leading: GoogleUserCircleAvatar(identity: user),
                    title: Text(user.displayName ?? ''),
                    subtitle: Text(user.email),
                  ),
                  const Text('Signed in successfully.'),
                  if (_isAuthorized) ...[
                    Text(_contactText),
                    ElevatedButton(
                      onPressed: () => _handleGetContact(user),
                      child: const Text('REFRESH'),
                    ),
                  ],
                  if (!_isAuthorized) ...[
                    const Text(
                        'Additional permissions needed to read your contacts.'),
                    ElevatedButton(
                      onPressed: _handleAuthorizeScopes,
                      child: const Text('REQUEST PERMISSIONS'),
                    ),
                  ],
                  ElevatedButton(
                    onPressed: _handleSignOut,
                    child: const Text('SIGN OUT'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You are not currently signed in.'),
                  buildSignInButton(onPressed: _handleSignIn),
                ],
              ),
      ),
    );
  }
}
