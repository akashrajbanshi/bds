import 'dart:async';

import 'package:bds/arguments/eventdaycalendararguments.dart';
import 'package:bds/common/customcolors.dart';
import 'package:bds/common/strings.dart';
import 'package:bds/common/utility.dart';
import 'package:bds/common/validation.dart';
import 'package:bds/common/weekdaytostring.dart';
import 'package:bds/model/appointment.dart';
import 'package:bds/model/dayviewevent.dart';
import 'package:calendar_views/calendar_views.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventDayCalendarPage extends StatefulWidget {
  final EventDayCalendarArguments arguments;

  EventDayCalendarPage({this.arguments});

  @override
  createState() => EventDayCalendarPageState(arguments);
}

class EventDayCalendarPageState extends State<EventDayCalendarPage> {
  final GlobalKey<ScaffoldState> _eventCalendarScaffoldKey =
  new GlobalKey<ScaffoldState>();
  final EventDayCalendarArguments arguments;

  EventDayCalendarPageState(this.arguments);

  TextEditingController _startTimeController;
  TextEditingController _endTimeController;

  List<Appointment> appointments;
  List<Appointment> _eventList = List<Appointment>();

  DateTime selectedDate;
  StreamSubscription<Event> _onNoteAddedSubscription;
  final notesReference =
  FirebaseDatabase.instance.reference().child(Strings.FIREBASE_APPOINTMENT);

  List<DayViewEvent> _dayViewEventList = List<DayViewEvent>();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    appointments = new List();
    _onNoteAddedSubscription =
        notesReference.onChildAdded.listen(_onAppointmentAdded);

    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _onNoteAddedSubscription.cancel();
    super.dispose();
  }

  void _onAppointmentAdded(Event event) {
    setState(() {
      appointments.add(new Appointment.fromSnapshot(event.snapshot));
      _selectDate();
    });
  }

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

  void _selectDate() {
    filterAppointment(arguments.date);
    selectedDate = arguments.date;
  }

  void filterAppointment(date) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    _eventList.clear();
    _dayViewEventList.clear();
    //filter appointmentDay

    appointments.forEach((event) {
      if (event.appointmentDay == date.toString() &&
          event.userId == sp.getString("userID")) {
        _eventList.add(event);
        _dayViewEventList.add(DayViewEvent(
            startMinuteOfDay:
            Utility.convertStartTimeToHourForDayView(event.startTime),
            duration: Utility.convertTimeStringToMinutes(
                event.startTime, event.endTime),
            title: ''));
      }
    });
    _eventList.sort();
  }

  void createSnackbar(String message) {
    _eventCalendarScaffoldKey.currentState.showSnackBar(new SnackBar(
      content: DefaultTextStyle(
        child: Row(
          children: <Widget>[
            Padding(
              child: IconTheme(
                data: IconThemeData(color: Colors.deepOrange),
                child: Icon(Icons.error),
              ),
              padding: EdgeInsets.only(right: 2.0),
            ),
            Text(message),
          ],
        ),
        style: TextStyle(color: Colors.deepOrange, fontSize: 12),
      ),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          _eventCalendarScaffoldKey.currentState.hideCurrentSnackBar();
        },
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 3.0,
      backgroundColor: Colors.white,
    ));
  }

  void createSnackbarSuccess(String message) {
    _eventCalendarScaffoldKey.currentState.showSnackBar(new SnackBar(
      content: DefaultTextStyle(
        child: Row(
          children: <Widget>[
            Padding(
              child: IconTheme(
                data: IconThemeData(color: Colors.green),
                child: Icon(Icons.check_circle),
              ),
              padding: EdgeInsets.only(right: 2.0),
            ),
            Text(message),
          ],
        ),
        style: TextStyle(color: Colors.black, fontSize: 12),
      ),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          _eventCalendarScaffoldKey.currentState.hideCurrentSnackBar();
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
                        padding: const EdgeInsets.all(4.0),
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
                            } else if (_endTimeController.text.isNotEmpty &&
                                Validation.checkStartTimeToEndTime(
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
                            } else if (_startTimeController.text.isNotEmpty &&
                                Validation.checkEndTimeToStartTime(
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

  void createRecord(DatabaseReference databaseReference,
      Appointment appointment) {
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
      createSnackbarSuccess(Strings.APPOINTMENT_SAVE_TOAST_MSG);
      setState(() {
        filterAppointment(appointment.appointmentDay);
      });
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

  List<StartDurationItem> _getEventsOfDay(DateTime day) {
    return _dayViewEventList
        .map(
          (event) =>
      new StartDurationItem(
        startMinuteOfDay: event.startMinuteOfDay,
        duration: event.duration,
        builder: (context, itemPosition, itemSize) =>
            _eventBuilder(
              context,
              itemPosition,
              itemSize,
              event,
            ),
      ),
    )
        .toList();
  }

  Positioned _eventBuilder(BuildContext context,
      ItemPosition itemPosition,
      ItemSize itemSize,
      DayViewEvent event,) {
    return new Positioned(
      top: itemPosition.top,
      left: itemPosition.left,
      width: itemSize.width,
      height: itemSize.height,
      child: new Container(
        margin: new EdgeInsets.only(left: 1.0, right: 1.0, bottom: 1.0),
        padding: new EdgeInsets.all(3.0),
        color: CustomColors.appBarColor,
        child: new Text("${event.startMinuteOfDay}"),
      ),
    );
  }

  Widget _headerItemBuilder(BuildContext context, DateTime day) {
    return new Container(
      color: CustomColors.backgroundColor,
      padding: new EdgeInsets.all(1.0),
      child: new Column(
        children: <Widget>[
          new Text(
            "${weekdayToAbbreviatedString(day.weekday)}",
            style: new TextStyle(fontWeight: FontWeight.bold),
          ),
          new Text("${day.day}"),
        ],
      ),
    );
  }

  String _minuteOfDayToHourMinuteString(int minuteOfDay) {
    return "${(minuteOfDay ~/ 60).toString().padLeft(2, "0")}"
        ":"
        "${(minuteOfDay % 60).toString().padLeft(2, "0")}";
  }

  Positioned _generatedTimeIndicatorBuilder(BuildContext context,
      ItemPosition itemPosition,
      ItemSize itemSize,
      int minuteOfDay,) {
    return new Positioned(
      top: itemPosition.top,
      left: itemPosition.left,
      width: itemSize.width,
      height: itemSize.height,
      child: new Container(
        child: new Center(
          child: new Text(_minuteOfDayToHourMinuteString(minuteOfDay)),
        ),
      ),
    );
  }

  Positioned _generatedSupportLineBuilder(BuildContext context,
      ItemPosition itemPosition,
      double itemWidth,
      int minuteOfDay,) {
    return new Positioned(
      top: itemPosition.top,
      left: itemPosition.left,
      width: itemWidth,
      child: new Container(
        height: 0.7,
        color: Colors.grey[700],
      ),
    );
  }

  Positioned _generatedDaySeparatorBuilder(BuildContext context,
      ItemPosition itemPosition,
      ItemSize itemSize,
      int daySeparatorNumber,) {
    return new Positioned(
      top: itemPosition.top,
      left: itemPosition.left,
      width: itemSize.width,
      height: itemSize.height,
      child: new Center(
        child: new Container(
          width: 0.7,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _selectDate();
    return Scaffold(
        key: _eventCalendarScaffoldKey,
        body: DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: AppBar(
                  bottom: TabBar(
                    tabs: [
                      Tab(
                        icon: Icon(Icons.list),
                        text: 'List View',
                      ),
                      Tab(
                        icon: Icon(Icons.insert_chart),
                        text: 'Chart View',
                      )
                    ],
                  ),
                  title: Text(Strings.DAY_VIEW_APP_BAR),
                  backgroundColor: CustomColors.appBarColor,
                ),
                body: TabBarView(
                  children: [
                    Container(
                      color: CustomColors.backgroundColor,
                      child: RefreshIndicator(
                        onRefresh: _refreshEvents,
                        child: ListView.builder(
                            itemCount: _eventList.length,
                            itemBuilder: (context, index) {
                              if (_eventList.length > 0) {
                                return Card(
                                  color: CustomColors.cardColor,
                                  child: ListTile(
                                    title: Text(_eventList[index].startTime +
                                        " - " +
                                        _eventList[index].endTime),
                                  ),
                                );
                              } else {
                                return Container(
                                  child: Center(
                                    child: Text('No Items to display'),
                                  ),
                                );
                              }
                            }),
                      ),
                    ),
                    Container(
                      color: CustomColors.backgroundColor,
                      child: RefreshIndicator(
                        onRefresh: _refreshEvents,
                        child: DayViewEssentials(
                          properties: DayViewProperties(days: [selectedDate]),
                          child: Column(
                            children: <Widget>[
                              Container(
                                color: CustomColors.buttonColor,
                                child: new DayViewDaysHeader(
                                  headerItemBuilder: _headerItemBuilder,
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: DayViewSchedule(
                                    heightPerMinute: 1.0,
                                    components: <ScheduleComponent>[
                                      new TimeIndicationComponent
                                          .intervalGenerated(
                                        generatedTimeIndicatorBuilder:
                                        _generatedTimeIndicatorBuilder,
                                      ),
                                      new SupportLineComponent
                                          .intervalGenerated(
                                        generatedSupportLineBuilder:
                                        _generatedSupportLineBuilder,
                                      ),
                                      new DaySeparationComponent(
                                        generatedDaySeparatorBuilder:
                                        _generatedDaySeparatorBuilder,
                                      ),
                                      new EventViewComponent(
                                        getEventsOfDay: _getEventsOfDay,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ))),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            var now = DateTime.now();
            var todayDate = DateTime(now.year, now.month, now.day);
            var selectedDay = DateTime(
                arguments.date.year, arguments.date.month, arguments.date.day);
            if (selectedDay.isAfter(todayDate) || selectedDay == todayDate) {
              showAddAppointmentDialog(arguments.date);
            } else {
              createSnackbar(Strings.DATE_NOTE_VALID_FOR_APPOINTMENT);
            }
          },
          child: Icon(
            Icons.add,
          ),
          elevation: 3.0,
          backgroundColor: CustomColors.appBarColor,
        ));
  }

  Future<void> _refreshEvents() async
  {

  }
}
