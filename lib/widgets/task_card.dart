import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final Widget dragHandle;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.dragHandle,
  });

  Color _priorityColor(String p) {
    switch (p) {
      case "High":
        return const Color(0xFFFF595E); // neon red
      case "Medium":
        return const Color(0xFFFFCA3A); // amber
      default:
        return const Color(0xFF4CC9F0); // neon blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.cardColor;
    final isCompleted = task.completed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: _priorityColor(task.priority),
            width: 4,
          ),
        ),
      ),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: _priorityColor(task.priority).withOpacity(0.2),

        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---------------- LEFT MAIN CONTENT ----------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // TITLE ROW
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              decoration:
                                  isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // CATEGORY + PRIORITY BADGES
                    Row(
                      children: [
                        // CATEGORY CHIP
                        _chip(
                          context,
                          label: task.category,
                          color: Colors.white.withOpacity(0.1),
                          textColor: theme.colorScheme.primary,
                        ),

                        const SizedBox(width: 10),

                        // PRIORITY CHIP
                        _chip(
                          context,
                          label: task.priority,
                          color: _priorityColor(task.priority).withOpacity(0.15),
                          textColor: _priorityColor(task.priority),
                          icon: Icons.circle,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // DUE DATE ROW
                    if (task.dueDate != null)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 15, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            "${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ---------------- RIGHT SIDE: COMPLETED + DRAG ----------------
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (task.completed)
                    Icon(Icons.check_circle,
                        color: Colors.greenAccent.shade400, size: 28),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 32,
                    width: 32,
                    child: dragHandle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------- REUSABLE CHIP ----------------------
  Widget _chip(
    BuildContext context, {
    required String label,
    required Color color,
    required Color textColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
