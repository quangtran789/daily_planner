import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String title;
  final String description;
  final String location;
  final String host;
  final DateTime atTime;
  final bool completed;
  final Timestamp timestamp;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.host,
    required this.atTime,
    required this.completed,
    required this.timestamp,
  });
}
