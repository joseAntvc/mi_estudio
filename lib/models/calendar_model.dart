import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarModel extends CalendarDataSource {
  CalendarModel(List<Appointment> appointments) {
    this.appointments = appointments;
  }
}

class CalendarAppointment extends Appointment {
  final String taskId;
  final IconData subjectIcon;

  CalendarAppointment(this.subjectIcon, 
  {
    required this.taskId,
    required super.startTime,
    required super.endTime,
    required super.subject,
    required super.color,
  });
}