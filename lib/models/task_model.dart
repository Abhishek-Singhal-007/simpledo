// lib/models/task_model.dart
import 'package:hive/hive.dart';
import 'subtask_model.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
class TaskModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String category;

  @HiveField(2)
  String priority;

  @HiveField(3)
  bool completed;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  String? description;

  @HiveField(6)
  String? time; // "HH:mm"

  @HiveField(7)
  List<SubTask>? subtasks;

  @HiveField(8)
  DateTime createdAt;

  TaskModel({
    required this.title,
    required this.category,
    required this.priority,
    this.completed = false,
    this.dueDate,
    this.description,
    this.time,
    List<SubTask>? subtasks,
    DateTime? createdAt,
  })  : subtasks = subtasks ?? [],
        createdAt = createdAt ?? DateTime.now();
}
