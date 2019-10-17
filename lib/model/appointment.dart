import 'package:bds/common/strings.dart';
import 'package:firebase_database/firebase_database.dart';

class Appointment {
  String _id;
  String _startTime;
  String _endTime;
  String _appointmentDay;

  Appointment(this._id, this._startTime, this._endTime, this._appointmentDay);

  String get id => _id;

  String get startTime => _startTime;

  String get endTime => _endTime;

  String get appointmentDay => _appointmentDay;

  Appointment.map(dynamic obj) {
    this._id = obj['id'];
    this._startTime = obj[Strings.FIELD_START_TIME];
    this._endTime = obj[Strings.FIELD_END_TIME];
    this._appointmentDay = obj[Strings.FIELD_APPOINTMENT_DAY];
  }

  Appointment.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _startTime = snapshot.value[Strings.FIELD_START_TIME];
    _endTime = snapshot.value[Strings.FIELD_END_TIME];
    _appointmentDay = snapshot.value[Strings.FIELD_APPOINTMENT_DAY];
  }
}
