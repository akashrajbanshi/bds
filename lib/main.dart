import 'package:bds/pages/authenticationpage.dart';
import 'package:bds/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString('userID');
  runApp(MaterialApp(
    title: 'BDS',
    initialRoute: '/',
    routes: {
      '/': (context) => (null == userId)
          ? AuthenticationPage()
//          : AuthenticationPage(null, null, null, null, null),
          : HomePage(),
      // Login Page
      '/home': (context) => HomePage(),
      // Home Page
    },
  ));
}
