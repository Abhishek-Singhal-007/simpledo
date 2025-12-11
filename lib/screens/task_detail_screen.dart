// lib/screens/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../models/subtask_model.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  final ValueChanged<TaskModel>? onUpdate;
  final VoidCallback? onDelete;

  const TaskDetailScreen({
    super.key,
    required this.task,
    this.onUpdate,
    this.onDelete,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late List<SubTask> subtasks;
  final TextEditingController subtaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    subtasks = List<SubTask>.from(widget.task.subtasks ?? []);
  }

  @override
  void dispose() {
    subtaskController.dispose();
    super.dispose();
  }

  // ==================== HELPERS ====================

  Color _priorityColor(String priority) {
    switch (priority) {
      case "High":
        return const Color(0xFFFF595E);
      case "Medium":
        return const Color(0xFFFFCA3A);
      default:
        return const Color(0xFF8BE9FD);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // ==================== PERSISTENCE ====================

  Future<void> _persistTask() async {
    widget.task.subtasks = subtasks;
    await widget.task.save();
    widget.onUpdate?.call(widget.task);
    setState(() {});
  }

  // ==================== DATE & TIME PICKERS ====================

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.task.dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      widget.task.dueDate = date;
      await widget.task.save();
      widget.onUpdate?.call(widget.task);
      setState(() {});
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: widget.task.time != null
          ? TimeOfDay(
              hour: int.parse(widget.task.time!.split(":")[0]),
              minute: int.parse(widget.task.time!.split(":")[1]),
            )
          : TimeOfDay.now(),
    );

    if (t != null) {
      final formatted =
          "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
      widget.task.time = formatted;
      await widget.task.save();
      widget.onUpdate?.call(widget.task);
      setState(() {});
    }
  }

  // ==================== SUBTASK ACTIONS ====================

  void _addSubtask() {
    final text = subtaskController.text.trim();
    if (text.isEmpty) return;
    final s = SubTask(title: text);
    subtasks.add(s);
    subtaskController.clear();
    _persistTask();
  }

  void _toggleSubtask(int idx, bool? value) {
    subtasks[idx].completed = value ?? false;
    _persistTask();
  }

  void _deleteSubtask(int idx) {
    subtasks.removeAt(idx);
    _persistTask();
  }

  // ==================== TASK ACTIONS ====================

  Future<void> _toggleTaskCompletion() async {
    widget.task.completed = !widget.task.completed;
    await widget.task.save();
    widget.onUpdate?.call(widget.task);
    setState(() {});
  }

  Future<void> _navigateToEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTaskScreen(
          task: widget.task,
          onSave: (updated) async {
            // Task is already updated in Hive
          },
        ),
      ),
    );
    setState(() {
      subtasks = List.from(widget.task.subtasks ?? []);
    });
    widget.onUpdate?.call(widget.task);
  }

  void _showDeleteConfirmation() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF2d3142) 
                  : const Color(0xFF37445a),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Delete icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Delete Task?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  "Are you sure you want to delete this task?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: isDark
                              ? const Color(0xFF3d4759)
                              : const Color(0xFF4a5568),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Delete button
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          Navigator.pop(context); // Close dialog
                          await widget.task.delete();
                          widget.onDelete?.call();
                          if (mounted) {
                            Navigator.pop(context); // Close detail screen
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFFFF595E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Delete",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== UI BUILDERS ====================

  Widget _buildAppBar(ThemeData theme, bool isDark) {
    return SliverAppBar(
      floating: true,
      elevation: 0,
      backgroundColor: isDark 
          ? const Color(0xFF1a1d2e) 
          : Colors.grey.shade50,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF262938)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        // Delete button
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _showDeleteConfirmation,
          ),
        ),
        const SizedBox(width: 8),

        // Edit button
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF4FC3F7).withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF4FC3F7)),
            onPressed: _navigateToEdit,
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildPriorityAndCategory(ThemeData theme, bool isDark) {
    return Row(
      children: [
        // Priority chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _priorityColor(widget.task.priority).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _priorityColor(widget.task.priority).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${widget.task.priority.toUpperCase()} PRIORITY",
                style: TextStyle(
                  color: _priorityColor(widget.task.priority),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Category chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF262938)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
            ),
          ),
          child: Text(
            widget.task.category.toUpperCase(),
            style: TextStyle(
              color: isDark 
                  ? Colors.white.withOpacity(0.7)
                  : Colors.black87,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      widget.task.title,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildDateTimeCards(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.calendar_today_outlined,
            label: "DATE",
            value: widget.task.dueDate != null
                ? _formatDate(widget.task.dueDate!)
                : "No date",
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.access_time_outlined,
            label: "TIME",
            value: widget.task.time ?? "No time",
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF262938) 
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.08 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: const Color(0xFF4FC3F7),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black45,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF262938) 
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.08 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.task.description != null && widget.task.description!.isNotEmpty
                ? widget.task.description!
                : "No description",
            style: TextStyle(
              fontSize: 14,
              color: isDark 
                  ? Colors.white.withOpacity(0.8)
                  : Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtasksSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.checklist_outlined,
              size: 20,
              color: isDark ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 8),
            Text(
              "Subtasks",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildAddSubtaskField(isDark),
        const SizedBox(height: 16),
        _buildSubtasksList(isDark),
      ],
    );
  }

  Widget _buildAddSubtaskField(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF262938) 
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.08 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: subtaskController,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: "Add a subtask...",
                hintStyle: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black38,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: (_) => _addSubtask(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF4FC3F7),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FC3F7).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _addSubtask,
          ),
        ),
      ],
    );
  }

  Widget _buildSubtasksList(bool isDark) {
    if (subtasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            "No subtasks yet",
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.4)
                  : Colors.black38,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: subtasks.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        return _buildSubtaskItem(i, s, isDark);
      }).toList(),
    );
  }

  Widget _buildSubtaskItem(int index, SubTask subtask, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF262938) 
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: subtask.completed,
            onChanged: (v) => _toggleSubtask(index, v),
            activeColor: const Color(0xFF4FC3F7),
            side: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.3)
                  : Colors.black.withOpacity(0.2),
              width: 2,
            ),
          ),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                color: subtask.completed
                    ? (isDark 
                        ? Colors.white.withOpacity(0.4)
                        : Colors.black38)
                    : (isDark ? Colors.white : Colors.black87),
                fontSize: 14,
                decoration:
                    subtask.completed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.red.withOpacity(0.7),
              size: 20,
            ),
            onPressed: () => _deleteSubtask(index),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkCompleteButton() {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          onPressed: _toggleTaskCompletion,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: widget.task.completed
                ? const Color(0xFF4CAF50).withOpacity(0.15)
                : const Color(0xFF4FC3F7).withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: widget.task.completed
                    ? const Color(0xFF4CAF50).withOpacity(0.3)
                    : const Color(0xFF4FC3F7).withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.task.completed
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: widget.task.completed
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF4FC3F7),
              ),
              const SizedBox(width: 10),
              Text(
                widget.task.completed ? "Completed" : "Mark as Complete",
                style: TextStyle(
                  color: widget.task.completed
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF4FC3F7),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== MAIN BUILD ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1a1d2e) 
          : Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(theme, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriorityAndCategory(theme, isDark),
                  const SizedBox(height: 20),
                  _buildTitle(isDark),
                  const SizedBox(height: 20),
                  _buildDateTimeCards(theme, isDark),
                  const SizedBox(height: 20),
                  _buildDescription(isDark),
                  const SizedBox(height: 20),
                  _buildSubtasksSection(isDark),
                  const SizedBox(height: 24),
                  _buildMarkCompleteButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}