import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bds/common/customcolors.dart';
import 'package:bds/common/customicon.dart';
import 'package:bds/common/socialicon.dart';
import 'package:bds/common/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationPage extends StatefulWidget {
  /*FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = new GoogleSignIn();
  FacebookLogin _facebookSignIn = new FacebookLogin();
  FirebaseMessaging _fcm = FirebaseMessaging();
  Firestore _firestore = Firestore.instance;

  AuthenticationPage(
      FirebaseAuth auth,
      GoogleSignIn googleSignIn,
      FacebookLogin facebookSignIn,
      FirebaseMessaging fcm,
      Firestore firestore) {
    this._auth = auth;
    this._googleSignIn = googleSignIn;
    this._facebookSignIn = facebookSignIn;
    this._fcm = fcm;
    this._firestore = firestore;
  }


  @override
  createState() => new _AuthenticationPageState(
      _auth, _googleSignIn, _facebookSignIn, _fcm, _firestore);*/

  @override
  createState() => new _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = new GoogleSignIn();
  FacebookLogin _facebookSignIn = new FacebookLogin();
  FirebaseMessaging _fcm = FirebaseMessaging();
  Firestore _firestore = Firestore.instance;

  TextEditingController _emailController;
  TextEditingController _passwordController;

  final GlobalKey<ScaffoldState> _authScaffoldKey =
      new GlobalKey<ScaffoldState>();

//  _AuthenticationPageState(this._auth, this._googleSignIn, this._facebookSignIn,
//      this._fcm, this._firestore);

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
      _authScaffoldKey.currentState.showSnackBar(new SnackBar(
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            _authScaffoldKey.currentState.hideCurrentSnackBar();
          },
        ),
        content: DefaultTextStyle(
          child: Row(
            children: <Widget>[
              Padding(
                child: IconTheme(
                  data: IconThemeData(color: Colors.deepOrange),
                  child: Icon(Icons.error),
                ),
                padding: EdgeInsets.only(right: 2.0),
              ),
              Text(e.message.toString()),
            ],
          ),
          style: TextStyle(color: Colors.deepOrange, fontSize: 11),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 2.0,
        backgroundColor: Colors.white,
      ));
    });
    if (null != result.user) {
      await setCurrentUserFromSharedPreference(result);
    }
  }

  void signIn(String email, String password) async {
    AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    if (null != result.user) {
      await setCurrentUserFromSharedPreference(result);
      Navigator.pushNamed(context, '/home');
    }
  }

  void signInWithFacebook() async {
    final FacebookLoginResult result =
        await _facebookSignIn.logIn(['email', 'public_profile']);

    if (result.status == FacebookLoginStatus.loggedIn) {
      FacebookAccessToken myToken = result.accessToken;
      AuthCredential credential =
          FacebookAuthProvider.getCredential(accessToken: myToken.token);

      var authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (null != authResult) {
        await setCurrentUserFromSharedPreference(authResult);
        Navigator.pushNamed(context, '/home');
      }
    }
  }

  Future setCurrentUserFromSharedPreference(AuthResult result) async {
    _saveDeviceToken(result);
    Navigator.pushNamed(context, '/home');
  }

  _saveDeviceToken(AuthResult result) async {
    await updateSPAndFS(result);
  }

  Future updateSPAndFS(AuthResult result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = result.user.displayName;
    String email = result.user.email;
    String mobile = result.user.phoneNumber;
    String photoUrl = result.user.photoUrl;

    prefs.setString('userID', result.user.uid);
    prefs.setString('username', username);
    prefs.setString('email', email);
    prefs.setString('mobile', mobile);
    prefs.setString('photoUrl', photoUrl);

    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      var tokens = _firestore.collection('users').document(result.user.uid);

      await tokens.setData({
        'username': username,
        'email': email,
        'mobile': mobile,
        'photoUrl': photoUrl,
        'tokenID': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
      }).whenComplete(() => prefs.setString('tokenID', fcmToken));
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

    if (null != authResult) {
      updateSPAndFS(authResult);
      Navigator.pushNamed(context, '/home');
    }
  }

  Future<Null> signOut() async {
    // Sign out with firebase
    await _auth.signOut().then((_) {
      _googleSignIn.signOut();
      _facebookSignIn.logOut();
    });
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 70.0,
        child: Image.asset(
          'assets/logo.png',
          color: CustomColors.appBarColor,
          filterQuality: FilterQuality.high,
        ),
      ),
    );

    final email = TextField(
      key: Key('email'),
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
      key: Key('password'),
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
      key: Key('loginButton'),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          signUpWithEmail(_emailController.text, _passwordController.text);
        },
        padding: EdgeInsets.all(10),
        color: CustomColors.buttonColor,
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
        SizedBox(height: 28.0),
        email,
        SizedBox(height: 8.0),
        password,
        SizedBox(height: 24.0),
        loginButton,
      ],
    );

    final forgotLabel = FlatButton(
      key: Key('forgotLabel'),
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
        key: Key('googleButton'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          signInWithGoogle();
        },
        padding: EdgeInsets.all(10),
        color: CustomColors.buttonColor,
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
        key: Key('facebookButton'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          signInWithFacebook();
        },
        padding: EdgeInsets.all(10),
        color: CustomColors.buttonColor,
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
      key: _authScaffoldKey,
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
