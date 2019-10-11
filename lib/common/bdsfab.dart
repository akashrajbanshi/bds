import 'package:bds/common/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel, WeekdayFormat;

class BDSFab extends StatefulWidget {
  @override
  createState() => _BDSFabState();

  const BDSFab({
    Key key,
  }) : super(key: key);
}

class _BDSFabState extends State<BDSFab> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return _getFAB();
  }

  Widget _getFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        _showFormDialog();
      },
      label: Text(Strings.fabToolTip),
      tooltip: Strings.fabToolTip,
      icon: Icon(Icons.add, color: Colors.amber),
      backgroundColor: Colors.black54,
      heroTag: Strings.fabToolTip,
    );
  }

  void _showFormDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(actions: <Widget>[
            CalendarCarousel<Event>(
              onDayPressed: (DateTime date, List<Event> events) {
                //take an action with date and its events
              },
              thisMonthDayBorderColor: Colors.transparent,
              selectedDayButtonColor: Colors.white,
              selectedDayBorderColor: Colors.white,
              selectedDayTextStyle: TextStyle(color: Colors.blue),
              weekendTextStyle: TextStyle(color: Colors.white),
              daysTextStyle: TextStyle(color: Colors.white),
              inactiveDaysTextStyle: TextStyle(color: Colors.blue.shade900),
              nextDaysTextStyle: TextStyle(color: Colors.grey),
              prevDaysTextStyle: TextStyle(color: Colors.grey),
              weekdayTextStyle: TextStyle(color: Colors.white),
              weekDayFormat: WeekdayFormat.narrow,
              firstDayOfWeek: 1,
              showHeader: true,
              isScrollable: true,
              weekFormat: false,
              height: MediaQuery.of(context).size.height,
              selectedDateTime: DateTime(2019, 8, 14),
              daysHaveCircularBorder: true,
              // null for not rendering any border, true for circular border, false for rectangular border
              customGridViewPhysics: NeverScrollableScrollPhysics(),
            ),
          ]);
        });
  }
}
