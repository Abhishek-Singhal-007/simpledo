// lib/screens/edit_task_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../models/subtask_model.dart';
import 'package:intl/intl.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;
  final Function(TaskModel) onSave;

  const EditTaskScreen({super.key, required this.task, required this.onSave});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  late String category;
  late String priority;
  late bool isCompleted;
  DateTime? dueDate;
  String? time;

  late List<SubTask> subtasks;
  final TextEditingController subtaskController = TextEditingController();

  final categories = ["Work", "Personal", "Shopping", "Study", "Other"];
  final priorities = ["High", "Medium", "Low"];

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(
      text: widget.task.description ?? "",
    );

    category = widget.task.category;
    priority = widget.task.priority;
    isCompleted = widget.task.completed;

    dueDate = widget.task.dueDate;
    time = widget.task.time;

    subtasks = List.from(widget.task.subtasks ?? []);
  }

  Color _priorityColor(String p) {
    switch (p) {
      case "High":
        return const Color(0xFFFF595E);
      case "Medium":
        return const Color(0xFFFFCA3A);
      default:
        return const Color(0xFF4CC9F0);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat("yyyy-MM-dd").format(date);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => dueDate = date);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: time != null
          ? TimeOfDay(
              hour: int.parse(time!.split(":")[0]),
              minute: int.parse(time!.split(":")[1]),
            )
          : TimeOfDay.now(),
    );

    if (t != null) {
      setState(() {
        time =
            "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  void _addSubtask() {
    final text = subtaskController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      subtasks.add(SubTask(title: text));
      subtaskController.clear();
    });
  }

  void _toggleSubtask(int index, bool? v) {
    setState(() => subtasks[index].completed = v ?? false);
  }

  void _deleteSubtask(int index) {
    setState(() => subtasks.removeAt(index));
  }

  Future<void> _saveTask() async {
    widget.task.title = titleController.text.trim();
    widget.task.description = descriptionController.text.trim();

    widget.task.category = category;
    widget.task.priority = priority;

    widget.task.completed = isCompleted;

    widget.task.dueDate = dueDate;
    widget.task.time = time;

    widget.task.subtasks = subtasks;

    await widget.task.save();
    widget.onSave(widget.task);

    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Delete Task", style: TextStyle(color: Colors.red)),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await widget.task.delete();
              Navigator.pop(context);
              Navigator.pop(context, "delete");
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _header(String txt) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      txt,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Edit Task"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 12),
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) {
                return AlertDialog(
                  backgroundColor: theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  title: Text(
                    "Save Changes?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  content: Text(
                    "Are you sure you want to save these changes?",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  actions: [
                    // CANCEL BUTTON
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // CONFIRM SAVE BUTTON
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // close dialog
                        _saveTask(); // this saves and closes screen
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            elevation: 3,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                15,
              ), // your rectangular-rounded style
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check, size: 22),
              SizedBox(width: 8),
              Text(
                "Save",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            _header("Title"),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.cardColor.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 20),

            // DESCRIPTION
            _header("Description"),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.cardColor.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 20),

            // PRIORITY
            _header("Priority"),
            Wrap(
              spacing: 12,
              children: priorities.map((p) {
                final selected = priority == p;
                final color = _priorityColor(p);

                return GestureDetector(
                  onTap: () => setState(() => priority = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? color : Colors.white24,
                        width: 1.3,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 10, color: color),
                        const SizedBox(width: 8),
                        Text(
                          p,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // CATEGORY
            _header("Category"),
            Wrap(
              spacing: 12,
              children: categories.map((c) {
                final selected = category == c;

                return GestureDetector(
                  onTap: () => setState(() => category = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? theme.colorScheme.primary
                            : Colors.white24,
                      ),
                    ),
                    child: Text(
                      c,
                      style: TextStyle(
                        color: selected
                            ? theme.colorScheme.primary
                            : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // DATE
            _header("Due Date"),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white70),
                    const SizedBox(width: 10),
                    Text(
                      dueDate == null ? "Pick a date" : _formatDate(dueDate!),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // TIME
            _header("Time"),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white70),
                    const SizedBox(width: 10),
                    Text(
                      time ?? "Pick time",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // COMPLETED SWITCH
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _header("Mark as Completed"),
                Switch(
                  value: isCompleted,
                  activeColor: Colors.greenAccent,
                  onChanged: (v) => setState(() => isCompleted = v),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // SUBTASKS AREA
            _header("Subtasks"),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: subtaskController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Add subtask...",
                      filled: true,
                      fillColor: theme.cardColor.withOpacity(0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: _addSubtask,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // SUBTASK LIST
            ...subtasks.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;

              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Checkbox(
                  value: s.completed,
                  onChanged: (v) => _toggleSubtask(i, v),
                ),
                title: Text(
                  s.title,
                  style: TextStyle(
                    decoration: s.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteSubtask(i),
                ),
              );
            }),

            const SizedBox(height: 40),

            // DELETE BUTTON
            Center(
              child: TextButton.icon(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                label: const Text(
                  "Delete Task",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
