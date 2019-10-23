import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bds/common/customicon.dart';
import 'package:bds/common/socialicon.dart';
import 'package:bds/common/styles.dart';
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
  final FacebookLogin _facebookSignIn = new FacebookLogin();

  TextEditingController _emailController;
  TextEditingController _passwordController;

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void signUpWithEmail(email, password) async {
    AuthResult result = await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .catchError((e) {
      scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: DefaultTextStyle(
          child: Text(e.message.toString()),
          style: TextStyle(color: Colors.black54),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 2.0,
        backgroundColor: Colors.white,
      ));
    });
  }

  void signIn(String email, String password) async {
    AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  void signInWithFacebook() async {
    final FacebookLoginResult result =
        await _facebookSignIn.logIn(['email', 'public_profile']);

    if (result.status == FacebookLoginStatus.loggedIn) {
      FacebookAccessToken myToken = result.accessToken;
      AuthCredential credential =
          FacebookAuthProvider.getCredential(accessToken: myToken.token);

      var user = await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

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
  }

  Future<Null> signOut() async {
    // Sign out with firebase
    await _auth.signOut().then((_) {
      //_googleSignIn.signOut();
      _facebookSignIn.logOut();
    });
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/logo.png'),
      ),
    );

    final email = TextField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: _emailController,
      maxLines: 1,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 20.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.0)),
      ),
    );

    final password = TextField(
      autofocus: false,
      maxLines: 1,
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 20.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          signUpWithEmail(_emailController.text, _passwordController.text);
        },
        padding: EdgeInsets.all(10),
        color: Colors.lightBlueAccent,
        child: Row(
          children: <Widget>[
            SocialIcon(iconData: CustomIcons.email),
            Expanded(
              child: Text('Log In With Email',
                  textAlign: TextAlign.center, style: Style.button(context)),
            )
          ],
        ),
      ),
    );

    final emailAndPasswordForm = Column(
      children: <Widget>[
        SizedBox(height: 48.0),
        email,
        SizedBox(height: 8.0),
        password,
        SizedBox(height: 24.0),
        loginButton,
      ],
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );

    Widget horizontalLine() => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            width: 100.0,
            height: 1.5,
            color: Colors.black.withOpacity(0.6),
          ),
        );
    final separator = Container(
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[horizontalLine(), Text('Or'), horizontalLine()],
        ),
      ),
    );

    final googleButton = Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          signInWithGoogle();
        },
        padding: EdgeInsets.all(10),
        color: Colors.lightBlueAccent,
        child: Row(
          children: <Widget>[
            SocialIcon(iconData: CustomIcons.google),
            Expanded(
              child: Text('Log In With Google',
                  textAlign: TextAlign.center, style: Style.button(context)),
            )
          ],
        ),
      ),
    );

    final facebookButton = Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          signInWithFacebook();
        },
        padding: EdgeInsets.all(10),
        color: Colors.lightBlueAccent,
        child: Row(
          children: <Widget>[
            SocialIcon(iconData: CustomIcons.facebook),
            Expanded(
              child: Text('Log In With Facebook',
                  textAlign: TextAlign.center, style: Style.button(context)),
            )
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            emailAndPasswordForm,
            forgotLabel,
            separator,
            googleButton,
            facebookButton
          ],
        ),
      ),
    );
  }
}
