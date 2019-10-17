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
    this._startTime = obj['startTime'];
    this._endTime = obj['endTime'];
    this._appointmentDay = obj['appointmentDay'];
  }

  Appointment.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _startTime = snapshot.value['startTime'];
    _endTime = snapshot.value['endTime'];
    _appointmentDay = snapshot.value['appointmentDay'];
  }
}
