// lib/models/subtask_model.dart
import 'package:hive/hive.dart';

part 'subtask_model.g.dart';

@HiveType(typeId: 2)
class SubTask {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool completed;

  SubTask({
    required this.title,
    this.completed = false,
  });
}
