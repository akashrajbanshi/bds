import 'package:bds/common/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utility {
  static String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  static String formatDateTime(DateTime dateTime) {
    final dt = DateTime(dateTime.year, dateTime.month, dateTime.day,
        dateTime.hour, dateTime.minute);
    final format = DateFormat("yyyy-MM-dd hh:mm:ss.sss'Z'");
    return format.format(dt);
  }

  static String convertTo24HoursFormat(String twelveHourTime) {
    DateTime date = DateFormat.jm().parse(twelveHourTime);
    return DateFormat(Strings.TIME_FORMAT).format(date);
  }

  static DateTime convertTimeStringToDateTime(String time) {
    var convertedTimeFormat = convertTo24HoursFormat(time);
    var timeOfDay = TimeOfDay(
        hour: int.parse(convertedTimeFormat.split(":")[0]),
        minute: int.parse(convertedTimeFormat.split(":")[1]));

    return DateTime.now()
        .add(Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute));
  }

  static TimeOfDay convertTimeStringToTimeOfDay(String time) {
    var convertedTimeFormat = convertTo24HoursFormat(time);
    return TimeOfDay(
        hour: int.parse(convertedTimeFormat.split(":")[0]),
        minute: int.parse(convertedTimeFormat.split(":")[1]));
  }

  static int convertTimeStringToMinutes(String time1, time2) {
    DateTime d1 = convertTimeStringToDateTime(time1);
    DateTime d2 = convertTimeStringToDateTime(time2);
    return d2.difference(d1).inMinutes;
  }

  static int convertStartTimeToHourForDayView(String time) {
    var convertedTimeFormat = convertTo24HoursFormat(time);
    return int.parse(convertedTimeFormat.split(":")[0]) * 60 +
        int.parse(convertedTimeFormat.split(":")[1]);
  }
}
