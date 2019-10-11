import 'package:bds/common/bdsfab.dart';
import 'package:bds/common/strings.dart';
import 'package:bds/pages/table.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'carousel.dart';
import 'clean.dart';

class HomePage extends StatefulWidget {
  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.appTitle),
      ),
      floatingActionButton: BDSFab(),
    );
  }
}
