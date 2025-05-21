import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskProvider extends ChangeNotifier {
  String? title;
  String? subjectId;
  DateTime? date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool loading = false;
  DateTime? selectedDate;

  void setTitle(String value) {
    title = value;
    notifyListeners();
  }

  void setSubjectId(String? value) {
    subjectId = value;
    notifyListeners();
  }

  void setDate(DateTime? value) {
    date = value;
  }

  void setStartTime(TimeOfDay? value) {
    startTime = value;
    notifyListeners();
  }

  void setEndTime(TimeOfDay? value) {
    endTime = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  void setSelectedDate(DateTime? value) {
    selectedDate = value;
    notifyListeners();
  }

  void clear() {
    title = null;
    subjectId = null;
    selectedDate = null;
    date = null;
    startTime = null;
    endTime = null;
    loading = false;
    notifyListeners();
  }

  Map<String, dynamic> toMap({required DateTime startDateTime, required DateTime endDateTime}) {
    return {
      'title': title,
      'subjectId': subjectId,
      'startDate': Timestamp.fromDate(startDateTime),
      'endDate': Timestamp.fromDate(endDateTime),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}