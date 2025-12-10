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

  Color _priorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.redAccent;
      case "Medium":
        return Colors.orangeAccent;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Material(
        color: theme.cardColor.withOpacity(isDark ? 0.9 : 1),
        borderRadius: BorderRadius.circular(18),
        elevation: isDark ? 1 : 3,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            // enough right padding so the right column has space
            padding: const EdgeInsets.fromLTRB(16, 18, 14, 18),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // <-- CENTER vertically
              children: [
                // -------------------------
                // LEFT: text content
                // -------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top row: title + Complete →
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // CATEGORY + PRIORITY
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(
                                0.15,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              task.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(
                                0.15,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: _priorityColor(task.priority),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  task.priority,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // DATE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // LEFT: due date
                          if (task.dueDate != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            )
                          else
                            const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),

                // -------------------------
                // RIGHT: vertical column (centered)
                // -------------------------
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment:
                      MainAxisAlignment.center, // center vertically
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Tick icon (only visible when completed)
                    if (task.completed)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 26,
                        ),
                      ),

                    // drag handle — ensure it's sized and centered
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(child: dragHandle),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
