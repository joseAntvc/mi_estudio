import 'dart:ui';

class CalendarModel {
  final String title;
  final DateTime from;
  final DateTime to;
  final String? categoryId;
  final Color color;
  final String? description;

  CalendarModel({
    required this.title,
    required this.from,
    required this.to,
    this.categoryId,
    required this.color,
    this.description,
  });
}