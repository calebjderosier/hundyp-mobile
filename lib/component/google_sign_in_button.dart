import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

/// The scopes required by this application.
const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

// got from here - https://pub.dev/packages/google_sign_in_web
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
    });

    _googleSignIn.signInSilently();
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
                  if (!_isAuthorized) ...[
                    const Text(
                        'Additional permissions needed to read your profile.'),
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
                  web.renderButton(),
                ],
              ),
      ),
    );
  }
}
