// lib/screens/add_task_screen.dart
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final Function(TaskModel) onSave;

  const AddTaskScreen({super.key, required this.onSave});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  String category = "Work";
  String priority = "Medium";
  DateTime? dueDate;
  TimeOfDay? selectedTime;

  String? get selectedTimeString {
    if (selectedTime == null) return null;
    return "${selectedTime!.hour.toString().padLeft(2,'0')}:${selectedTime!.minute.toString().padLeft(2,'0')}";
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Task")),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveTask,
        child: const Icon(Icons.check),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Title
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Task Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Category & Priority (existing UI)
            // ... your category and priority widgets ...
            // For brevity, keep your current chips or dropdowns here.
            // Example minimal:
            DropdownButtonFormField<String>(
              value: category,
              items: ["Work", "Personal", "Shopping", "Study", "Other"]
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
              decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: priority,
              items: ["High", "Medium", "Low"]
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => priority = v!),
              decoration: const InputDecoration(labelText: "Priority", border: OutlineInputBorder()),
            ),

            const SizedBox(height: 12),

            // Date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 10),
                    Text(
                      dueDate == null
                          ? "Pick Due Date"
                          : "${dueDate!.day}/${dueDate!.month}/${dueDate!.year}",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Time picker
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 10),
                    Text(selectedTimeString ?? "Pick Time"),
                  ],
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => dueDate = date);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) setState(() => selectedTime = t);
  }

  void _saveTask() {
    if (titleController.text.trim().isEmpty) return;
    final model = TaskModel(
      title: titleController.text.trim(),
      category: category,
      priority: priority,
      dueDate: dueDate,
      time: selectedTimeString,
      description: descriptionController.text.trim(),
      subtasks: [], // start empty
    );
    widget.onSave(model);
    Navigator.pop(context);
  }
}
