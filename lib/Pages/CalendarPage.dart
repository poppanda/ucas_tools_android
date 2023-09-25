import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ucas_tools/Controllers/SettingController.dart';
import 'package:ucas_tools/Spider/spider.dart';
import 'package:ucas_tools/Utils/CalendarPage/appointmentDataSource.dart';
import 'package:ucas_tools/Utils/appointment_db.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../Global.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

bool dateOnlyCompare(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class _CalendarPageState extends State<CalendarPage> {
  static DateFormat courseTimeFormatter = DateFormat('Hm');
  CalendarController calendarController = CalendarController();
  DateTime selectedDate = DateTime.now();
  AppointmentDataSource? appointmentDataSource;
  late Widget extraActions;
  late String formattedDate;
  late bool _showNotes;
  DateTime _titleDate = DateTime.now();

  @override
  void initState() {
    calendarController.addPropertyChangedListener(
      (property) {
        if (property == 'selectedDate' &&
            mounted &&
            calendarController.selectedDate != null) {
          setState(() {
            formattedDate =
                DateFormat.yMMMd().format(calendarController.selectedDate!);
          });
        }
      },
    );
    _showNotes = Get.find<SettingController>().calendarShowNotes.value!;
    switch (Get.find<SettingController>().calendarView.value!) {
      case "day":
        calendarController.view = CalendarView.day;
        break;
      case "week":
        calendarController.view = CalendarView.week;
        break;
      case "month":
        calendarController.view = CalendarView.month;
        break;
      case "schedule":
        calendarController.view = CalendarView.schedule;
        break;
    }
    () async {
      await _getCalendarDataSource();
      setState(() {});
    }();
    extraActions = PopupMenuButton(itemBuilder: (context) {
      return [
        const PopupMenuItem(
          value: "download",
          child: Text("Download Course Data"),
        ),
        PopupMenuItem(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Show notes"),
                  Switch(
                    value: _showNotes,
                    onChanged: (value) {
                      setState(() {
                        _showNotes = value;
                      });
                      this.setState(() {});
                    },
                  ),
                ],
              );
            },
          ),
        )
      ];
    }, onSelected: (value) async {
      if (value == "download") {
        _inputCookieWindow().then(
          (value) {
            if (value != null) {
              FutureBuilder(
                future: _downloadCourseData(value),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return const Text("Done");
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              );
              // _downloadCourseData(value);
              setState(() {});
            }
          },
        );
      } else if (value == "add") {
        Navigator.pushNamed(context, "/addEvent");
      }
    });
    super.initState();
  }

  Future<void> _getCalendarDataSource() async {
    // log("Start getting course data");
    var appointments = await AppointmentDB().getAppointments();
    log("CalendarPage: Got course data");
    appointmentDataSource = AppointmentDataSource(appointments);
  }

  Future<void> _downloadCourseData(String cookie) async {
    List<Appointment> appointments = <Appointment>[];
    var coursesinfo = await getCoursesInfo(cookie);
    var colorIdx = 0;
    for (var courseName in coursesinfo.keys) {
      var color = Colors.primaries[colorIdx];
      colorIdx = (colorIdx + 1) % Colors.primaries.length;
      for (var info in coursesinfo[courseName]!) {
        appointments.add(Appointment(
          subject: courseName,
          startTime: info.startTimeFormatted,
          endTime: info.endTimeFormatted,
          notes: info.location,
          color: color,
        ));
      }
    }
    appointmentDataSource!.appointments!.addAll(appointments);
    appointmentDataSource!
        .notifyListeners(CalendarDataSourceAction.add, appointments);
    AppointmentDB().insertAppointments(appointments);
  }

  Future<String?> _inputCookieWindow() async {
    late TextEditingController cookieController = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Downloaded Course Data"),
          content: TextField(
            controller: cookieController,
            decoration: const InputDecoration(
                hintText: "Cookie of https://jwxkts2.ucas.ac.cn/"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, cookieController.text);
              },
              child: const Text("OK"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget courseAppointmentBuilder(
      CalendarAppointmentDetails calendarAppointmentDetails) {
    final Appointment appointment =
        calendarAppointmentDetails.appointments.first;
    if (calendarController.view == CalendarView.schedule) {
      return Container(
        width: calendarAppointmentDetails.bounds.width,
        height: calendarAppointmentDetails.bounds.height,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: appointment.color,
          borderRadius: BorderRadius.circular(5),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.subject,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              if (appointment.notes != null && _showNotes)
                Text(
                  appointment.notes!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              Text(
                "${courseTimeFormatter.format(appointment.startTime)}-${courseTimeFormatter.format(appointment.endTime)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: calendarAppointmentDetails.bounds.width,
        height: calendarAppointmentDetails.bounds.height,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: appointment.color,
          borderRadius: BorderRadius.circular(5),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                appointment.subject,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              if (appointment.notes != null && _showNotes)
                const Divider(
                  color: Colors.white54,
                  height: 5,
                ),
              if (appointment.notes != null && _showNotes)
                Text(
                  appointment.notes!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              const Divider(
                color: Colors.white54,
                height: 5,
              ),
              Text(
                "${courseTimeFormatter.format(appointment.startTime)}-${courseTimeFormatter.format(appointment.endTime)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Row viewActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 20,
          child: IconButton(
            iconSize: 20,
            onPressed: () {
              calendarController.backward!();
              setState(() {
                _titleDate = calendarController.displayDate!;
              });
            },
            style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
            icon: const Icon(Icons.keyboard_arrow_left),
          ),
        ),
        SizedBox(
          height: 20,
          child: IconButton(
            iconSize: 20,
            onPressed: () {
              calendarController.forward!();
              setState(() {
                _titleDate = calendarController.displayDate!;
              });
            },
            style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
            icon: const Icon(Icons.keyboard_arrow_right),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            setState(() {
              calendarController.view = CalendarView.day;
            });
            Get.find<SettingController>().setCalendarView("day");
          },
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          child: const Text("Day"),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              calendarController.view = CalendarView.week;
            });
            Get.find<SettingController>().setCalendarView("day");
          },
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          child: const Text("Week"),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              calendarController.view = CalendarView.month;
            });
            Get.find<SettingController>().setCalendarView("day");
          },
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          child: const Text("Month"),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              calendarController.view = CalendarView.schedule;
            });
            Get.find<SettingController>().setCalendarView("day");
          },
          style: ButtonStyle(
            padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10)),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          child: const Text("Schedule"),
        ),
      ],
    );
  }

  Row titleBar() {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: subHeadingStyle,
              ),
              if (calendarController.selectedDate != null &&
                  dateOnlyCompare(
                      calendarController.selectedDate!, DateTime.now()))
                Text(
                  "Today",
                  style: headingStyle,
                )
              else
                SizedBox(
                  height: 29,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        calendarController.selectedDate = DateTime.now();
                        calendarController.displayDate = DateTime.now();
                      });
                    },
                    style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(0)),
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text(
                      "Back to today",
                      style: headingStyle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Spacer(),
        extraActions,
      ],
    );
  }

  Widget timeSelector(
    String title,
    DateTime selectedTime,
    Function(DateTime) onTimeChanged,
  ) {
    final f = DateFormat('yyyy-MM-dd HH:mm');
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title),
          TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: const Text("Select Date"),
                      children: [
                        SizedBox(
                          height: 200,
                          child: CupertinoDatePicker(
                            initialDateTime: selectedTime,
                            mode: CupertinoDatePickerMode.dateAndTime,
                            onDateTimeChanged: onTimeChanged,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    );
                  });
            },
            child: Text(f.format(selectedTime)),
          ),
        ],
      ),
    );
  }

  Widget appointmentDialog(DateTime startTime, DateTime endTime) {
    return StatefulBuilder(builder: (context, setState) {
      TextEditingController newEventTitleController = TextEditingController();
      TextEditingController newEventNoteController = TextEditingController();
      return SimpleDialog(
        title: const Text("Add Appointment"),
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextField(
                  controller: newEventTitleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                timeSelector(
                  "Start Time",
                  startTime,
                  (value) {
                    setState(() {
                      startTime = value;
                    });
                  },
                ),
                timeSelector(
                  "End Time",
                  endTime,
                  (value) {
                    setState(() {
                      endTime = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: newEventNoteController,
                  decoration: const InputDecoration(
                    labelText: "Note",
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Appointment appointment = Appointment(
                      subject: newEventTitleController.text == ""
                          ? "New Event"
                          : newEventTitleController.text,
                      startTime: startTime,
                      endTime: endTime,
                      notes: newEventNoteController.text,
                      color: Colors.blue,
                    );
                    AppointmentDB().insertAppointment(appointment);
                    appointmentDataSource!.appointments!.add(appointment);
                    appointmentDataSource!.notifyListeners(
                        CalendarDataSourceAction.add, [appointment]);
                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    formattedDate = DateFormat.yMMMd().format(_titleDate);
    if (appointmentDataSource == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100),
                SizedBox(
                  height: 600,
                  child: SfCalendar(
                    showNavigationArrow: false,
                    showCurrentTimeIndicator: false,
                    dataSource: appointmentDataSource,
                    monthViewSettings: const MonthViewSettings(
                      showAgenda: true,
                      agendaItemHeight: 80,
                      agendaViewHeight: 300,
                    ),
                    scheduleViewSettings: const ScheduleViewSettings(
                      appointmentItemHeight: 80,
                    ),
                    timeSlotViewSettings:
                        const TimeSlotViewSettings(startHour: 6, endHour: 24),
                    controller: calendarController,
                    showTodayButton: false,
                    showWeekNumber: false,
                    showDatePickerButton: false,
                    allowViewNavigation: false,
                    headerHeight: 0,
                    appointmentBuilder: (context, calendarAppointmentDetails) {
                      return courseAppointmentBuilder(
                          calendarAppointmentDetails);
                    },
                    onTap: (details) {
                      if (details.date != null) {
                        setState(() {
                          _titleDate = details.date!;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            height: 100,
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  titleBar(),
                  // Spacer(),
                  viewActions(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          DateTime startTime =
              calendarController.selectedDate ?? DateTime.now();
          DateTime endTime = startTime.add(const Duration(hours: 1));
          showDialog(
              context: context,
              builder: (context) => appointmentDialog(startTime, endTime));
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
