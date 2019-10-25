import 'dart:async';

import 'package:bds/common/customcolors.dart';
import 'package:bds/common/utility.dart';
import 'package:bds/common/strings.dart';
import 'package:bds/common/validation.dart';
import 'package:bds/model/appointment.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarController _calendarController;
  TextEditingController _startTimeController;
  TextEditingController _endTimeController;

  List<Appointment> appointments;
  StreamSubscription<Event> _onNoteAddedSubscription;
  final notesReference =
      FirebaseDatabase.instance.reference().child(Strings.FIREBASE_APPOINTMENT);

  final _formKey = GlobalKey<FormState>();

  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (null != picked)
      setState(() {
        _selectedStartTime = picked;
        _startTimeController.text = Utility.formatTimeOfDay(picked);
      });
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (null != picked)
      setState(() {
        _selectedEndTime = picked;
        _endTimeController.text = Utility.formatTimeOfDay(picked);
      });
  }

  @override
  void initState() {
    super.initState();
    appointments = new List();
    _onNoteAddedSubscription =
        notesReference.onChildAdded.listen(_onAppointmentAdded);

    _calendarController = CalendarController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _onNoteAddedSubscription.cancel();
    super.dispose();
  }

  void _onAppointmentAdded(Event event) {
    setState(() {
      appointments.add(new Appointment.fromSnapshot(event.snapshot));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CustomColors.cardColor,
      child: TableCalendar(
          calendarController: _calendarController, onDaySelected: _selectDate),
    );
  }

  void _selectDate(DateTime date, List events) {
    var now = DateTime.now();
    var todayDate = DateTime(now.year, now.month, now.day);
    var selectedDay = DateTime(date.year, date.month, date.day);
    if (selectedDay.isAfter(todayDate) || selectedDay == todayDate) {
      appointments.forEach((appointment) {
        if (appointment.appointmentDay == date.toString()) {
          events.add(appointment);
        }
      });
      //showEventLists(events);
      showAddAppointmentDialog(date);
    } else {
      createSnackbar(Strings.DATE_NOTE_VALID_FOR_APPOINTMENT);
    }
  }

  void createSnackbar(String message) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: DefaultTextStyle(
        child: Text(message),
        style: TextStyle(color: Colors.black54),
      ),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          Scaffold.of(context).hideCurrentSnackBar();
        },
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 3.0,
      backgroundColor: Colors.white,
    ));
  }

  void showAddAppointmentDialog(DateTime day) {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                backgroundColor: CustomColors.cardColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Text(Strings.ALERT_TITLE),
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _startTimeController,
                          decoration: InputDecoration(
                              hintText: Strings.START_TIME_HINT_TEXT),
                          onTap: () {
                            _selectStartTime(context);
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return Strings.VALIDATE_EMPTY_START_TIME;
                            } else if (Validation.checkStartTimeToEndTime(
                                value, _endTimeController.text)) {
                              return Strings.VALIDATE_START_TIME_AFTER_END_TIME;
                            }

                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _endTimeController,
                          decoration: InputDecoration(
                              hintText: Strings.END_TIME_HINT_TEXT),
                          onTap: () {
                            _selectEndTime(context);
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return Strings.VALIDATE_EMPTY_END_TIME;
                            } else if (Validation.checkEndTimeToStartTime(
                                value, _startTimeController.text)) {
                              return Strings
                                  .VALIDATE_END_TIME_BEFORE_START_TIME;
                            }

                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: RaisedButton(
                          onPressed: () async {
                            validateAndSave(day);
                          },
                          child: Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }

  void createRecord(
      DatabaseReference databaseReference, Appointment appointment) {
    databaseReference.push().set({
      Strings.FIELD_START_TIME: appointment.startTime,
      Strings.FIELD_END_TIME: appointment.endTime,
      Strings.FIELD_APPOINTMENT_DAY: appointment.appointmentDay,
      Strings.FIELD_USER_ID: appointment.userId
    }).then((_) {
      Navigator.pop(context);
      setState(() {
        _startTimeController.text = '';
        _endTimeController.text = '';
      });
      createSnackbar(Strings.APPOINTMENT_SAVE_TOAST_MSG);
    });
  }

  void validateAndSave(DateTime day) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final form = _formKey.currentState;
    if (form.validate()) {
      final databaseReference = FirebaseDatabase.instance
          .reference()
          .child(Strings.FIREBASE_APPOINTMENT);
      Appointment appointment = Appointment(null, _startTimeController.text,
          _endTimeController.text, day.toString(), prefs.getString('userID'));
      createRecord(databaseReference, appointment);
    }
  }
}
