import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<TaskModel> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    tasks = Hive.box<TaskModel>("tasksBox").values.toList();
    setState(() {});
  }

  // ==================== CALCULATIONS ====================

  // Total: ALL tasks (completed + incomplete, including upcoming)
  int get total => tasks.length;

  // Done: Only completed tasks
  int get done => tasks.where((t) => t.completed).length;

  // Left: All incomplete tasks (including today, upcoming, etc.)
  int get left => tasks.where((t) => !t.completed).length;

  // Completion percentage
  double get percent => total == 0 ? 0 : done / total;

  // Priority count: ALL incomplete tasks by priority (today + upcoming)
  Map<String, int> get priorityCount {
    final map = {"High": 0, "Medium": 0, "Low": 0};
    for (final t in tasks) {
      if (!t.completed) {
        // Count ALL incomplete tasks, regardless of due date
        map[t.priority] = (map[t.priority] ?? 0) + 1;
      }
    }
    return map;
  }

  // Category count: ALL tasks by category
  Map<String, int> get categoryCount {
    final map = <String, int>{};
    for (final t in tasks) {
      map[t.category] = (map[t.category] ?? 0) + 1;
    }
    return map;
  }

  // ==================== HELPERS ====================

  Color priorityColor(String p) {
    switch (p) {
      case "High":
        return const Color(0xFFFF595E);
      case "Medium":
        return const Color(0xFFFFCA3A);
      default:
        return const Color(0xFF8BE9FD);
    }
  }

  // ==================== UI BUILDERS ====================

  Widget _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF262938) : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Icons.close,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        "Productivity",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildProgressCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262938) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.08 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular progress ring
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(
                      isDark
                          ? const Color(0xFF2d3142)
                          : Colors.grey.shade200,
                    ),
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation(
                      Color(0xFF4FC3F7),
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Center text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${(percent * 100).round()}%",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      "DONE",
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1,
                        color: isDark
                            ? Colors.white.withOpacity(0.5)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _miniStat(
                theme,
                total,
                "TOTAL",
                isDark ? Colors.white70 : Colors.grey.shade700,
                isDark,
              ),
              _miniStat(
                theme,
                done,
                "DONE",
                const Color(0xFF4CAF50),
                isDark,
              ),
              _miniStat(
                theme,
                left,
                "LEFT",
                const Color(0xFFFF9800),
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(
      ThemeData theme, int value, String label, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          "$value",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 0.5,
            color: isDark
                ? Colors.white.withOpacity(0.4)
                : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySection(ThemeData theme, bool isDark) {
    final p = priorityCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flag_outlined,
              size: 16,
              color: isDark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              "PENDING BY PRIORITY",
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withOpacity(0.5)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _priorityBox(
              theme,
              "HIGH",
              p["High"]!,
              priorityColor("High"),
              isDark,
            ),
            const SizedBox(width: 12),
            _priorityBox(
              theme,
              "MEDIUM",
              p["Medium"]!,
              priorityColor("Medium"),
              isDark,
            ),
            const SizedBox(width: 12),
            _priorityBox(
              theme,
              "LOW",
              p["Low"]!,
              priorityColor("Low"),
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _priorityBox(
    ThemeData theme,
    String label,
    int count,
    Color color,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF262938) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.08 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "$count",
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.5,
                color: isDark
                    ? Colors.white.withOpacity(0.5)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(ThemeData theme, bool isDark) {
    final categories = categoryCount.entries.toList();

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.category_outlined,
              size: 16,
              color: isDark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              "CATEGORY DISTRIBUTION",
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withOpacity(0.5)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262938) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.08 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: categories.asMap().entries.map((entry) {
              final index = entry.key;
              final c = entry.value;
              final isLast = index == categories.length - 1;

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          c.key,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          "${c.value} tasks",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white.withOpacity(0.4)
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : c.value / total,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? const Color(0xFF1a1d2e)
                            : Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF4FC3F7),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ==================== MAIN BUILD ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1a1d2e) : Colors.grey.shade50,
      appBar: _buildAppBar(theme, isDark),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProgressCard(theme, isDark),
          const SizedBox(height: 20),
          _buildPrioritySection(theme, isDark),
          const SizedBox(height: 20),
          _buildCategorySection(theme, isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}