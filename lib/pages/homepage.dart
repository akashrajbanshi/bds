import 'package:bds/common/customcolors.dart';
import 'package:bds/common/strings.dart';
import 'package:bds/pages/calendarpage.dart';
import 'package:bds/pages/messagepage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class HomePage extends StatefulWidget {
  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> screens = [CalendarPage(), MessagePage()];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: CustomColors.backgroundColor,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          leading: Container(
            child: Image.asset('assets/logo.png',color: Colors.white),
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
