import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationPage extends StatefulWidget {
  @override
  createState() => new _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  final FacebookLogin _facebookLogin = FacebookLogin();

  void signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    AuthResult authResult = await _auth.signInWithCredential(credential);
    FirebaseUser user = authResult.user;

    if (user != null) {
      print('SIgned in!');
    }
  }

  Future<Null> signOutWithGoogle() async {
    // Sign out with firebase
    await _auth.signOut().then((_) {
      _googleSignIn.signOut();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('Sign with Google'),
              onPressed: () {
                signInWithGoogle();
              },
            ),
            RaisedButton(
              child: Text('Sign with Facebook'),
              onPressed: () {
                //initiateFacebookLogin();
              },
            ),
            RaisedButton(
              child: Text('Sign out'),
              onPressed: () {
                signOutWithGoogle();
              },
            )
          ],
        ),
      ),
    ));
  }
}
