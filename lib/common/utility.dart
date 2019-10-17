import 'package:bds/common/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utility{
  static String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  static String convertTo24HoursFormat(String twelveHourTime) {
    DateTime date = DateFormat.jm().parse(twelveHourTime);
    return DateFormat(Strings.TIME_FORMAT).format(date);
  }

  static DateTime convertStringToDateTime(String time) {
    var convertedTimeFormat = convertTo24HoursFormat(time);
    var timeOfDay = TimeOfDay(
        hour: int.parse(convertedTimeFormat.split(":")[0]),
        minute: int.parse(convertedTimeFormat.split(":")[1]));

    return DateTime.now()
        .add(Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute));
  }
}