import 'package:flutter/cupertino.dart';

@immutable
class DayViewEvent {
  DayViewEvent({
    @required this.startMinuteOfDay,
    @required this.duration,
    @required this.title,
  });

  final int startMinuteOfDay;
  final int duration;

  final String title;
}
