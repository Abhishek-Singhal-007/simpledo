import 'package:hive/hive.dart';

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

  TaskModel({
    required this.title,
    required this.category,
    required this.priority,
    this.completed = false,
    this.dueDate,
  });
}
