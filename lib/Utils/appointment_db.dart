import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AppointmentDB {
  static const String _tableAppointmentName = "appointments";
  static const String _columnStartTime = "starttime";
  static const String _columnEndTime = "endtime";
  static const String _columnId = 'id';
  static const String _columnSubject = "subject";
  static const String _columnColor = "color";
  static const String _columnAllDay = "allDay";
  static const String _columnNote = "note";
  static Database? _database;
  static AppointmentDB? _instance;
  AppointmentDB._internal();

  factory AppointmentDB() {
    _instance ??= AppointmentDB._internal();
    return _instance!;
  }

  Map<String, dynamic> _toMap(Appointment appointment) {
    return {
      _columnSubject: appointment.subject,
      _columnStartTime: appointment.startTime.toString(),
      _columnEndTime: appointment.endTime.toString(),
      _columnColor: appointment.color.value.toRadixString(16),
      _columnAllDay: appointment.isAllDay ? 1 : 0,
      _columnNote: appointment.notes,
    };
  }

  Future<Database> _getDB() async {
    if (_database == null) {
      final String path = join(await getDatabasesPath(), 'appointment.db');
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
          CREATE TABLE $_tableAppointmentName(
            $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_columnSubject TEXT,
            $_columnStartTime TEXT,
            $_columnEndTime TEXT,
            $_columnColor TEXT,
            $_columnAllDay INTEGER,
            $_columnNote TEXT
          )
        ''');
        },
      );
    }
    return _database!;
  }

  Future<List<Appointment>> getAppointments() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps =
        await db.query(_tableAppointmentName);
    return List.generate(
      maps.length,
      (i) => Appointment(
        subject: maps[i][_columnSubject],
        startTime: DateTime.parse(maps[i][_columnStartTime]),
        endTime: DateTime.parse(maps[i][_columnEndTime]),
        color: Color(int.parse(maps[i][_columnColor], radix: 16)),
        isAllDay: maps[i][_columnAllDay] == 0 ? false : true,
        notes: maps[i][_columnNote]
      ),
    );
  }

  Future<void> insertAppointments(List<Appointment> appointments) async {
    final db = await _getDB();
    final batch = db.batch();
    for (final appointment in appointments) {
      batch.insert(
        _tableAppointmentName,
        _toMap(appointment),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<void> insertAppointment(Appointment appointment) async {
    final db = await _getDB();
    await db.insert(
      _tableAppointmentName,
      _toMap(appointment),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
