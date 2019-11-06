import 'package:bds/common/customcolors.dart';
import 'package:bds/common/strings.dart';
import 'package:bds/pages/calendarpage.dart';
import 'package:bds/pages/messagepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings =
        new InitializationSettings(initializationSettingsAndroid, null);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message ${message}');
        // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
        displayNotification(message);
        // _showItemDialog(message);
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );
  }

  Future displayNotification(Map<String, dynamic> message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'channelid', 'flutterfcm', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message['notification']['title'],
      message['notification']['body'],
      platformChannelSpecifics,
      payload: message['data']['message'],
    );
  }

  int _currentIndex = 0;

  final List<Widget> screens = [CalendarPage(), MessagePage()];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: CustomColors.backgroundColor,
        appBar: AppBar(
          leading: Container(
            child: Image.asset('assets/logo.png', color: Colors.white),
            padding: EdgeInsets.all(8),
          ),
          backgroundColor: CustomColors.appBarColor,
          title: Text(Strings.APP_TITLE),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: SizedBox(
          height: 62.0,
          child: CurvedNavigationBar(
            color: CustomColors.navigationColor,
            backgroundColor: CustomColors.backgroundColor,
            onTap: onTabTapped,
            initialIndex: _currentIndex,
            animationDuration: Duration(milliseconds: 300),
            items: [
              Icon(Icons.calendar_today, size: 28),
              Icon(Icons.message, size: 28)
            ],
          ),
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
