import 'package:bds/animation/slide.dart';
import 'package:bds/arguments/eventdaycalendararguments.dart';
import 'package:bds/common/customcolors.dart';
import 'package:bds/pages/eventdaycalendarpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
            child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Card(
              color: CustomColors.cardColor,
              child: TableCalendar(
                  calendarController: _calendarController,
                  onDaySelected: _selectDate),
            ),
          ),
        )),
      ],
    );
  }

  void _selectDate(DateTime date, List events) {
    var arguments = EventDayCalendarArguments(date: date);

    Navigator.push(
      context,
      SlideLeftRoute(page: EventDayCalendarPage(arguments: arguments)),
    );
  }
}
