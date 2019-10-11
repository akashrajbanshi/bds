import 'package:bds/pages/homepage.dart';
import 'package:flutter/material.dart';

void main() => runApp(BDS());

class BDS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BDS',
      home: HomePage(),
    );
  }
}
