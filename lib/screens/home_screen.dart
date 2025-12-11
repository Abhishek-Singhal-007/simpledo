// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../theme/theme_provider.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskModel> tasks = [];
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  String selectedCategory = "All";
  String selectedPriority = "All";
  String selectedStatus = "All";

  // Accordion state: only one open at a time
  bool upcomingOpen = false;
  bool completedOpen = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ==================== DATA MANAGEMENT ====================

  void _loadTasks() {
    final box = Hive.box<TaskModel>("tasksBox");
    tasks = box.values.toList();
    setState(() {});
  }

  void _saveTasks() {
    final box = Hive.box<TaskModel>("tasksBox");
    box.clear();
    for (var t in tasks) {
      box.add(t);
    }
  }

  void _addTask(TaskModel t) {
    setState(() {
      tasks.add(t);
      _saveTasks();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      _saveTasks();
    });
  }

  void _toggleComplete(int index) {
    setState(() {
      tasks[index].completed = !tasks[index].completed;
      _saveTasks();
    });
  }

  // ==================== HELPERS ====================

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

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

  // ==================== FILTER LOGIC ====================

  List<TaskModel> _getFilteredTasks() {
    return tasks.where((task) {
      if (!task.title.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      if (selectedCategory != "All" && task.category != selectedCategory) {
        return false;
      }
      if (selectedPriority != "All" && task.priority != selectedPriority) {
        return false;
      }
      if (selectedStatus == "Completed" && !task.completed) return false;
      if (selectedStatus == "Pending" && task.completed) return false;
      return true;
    }).toList();
  }

  List<TaskModel> _getTodayTasks(List<TaskModel> filtered) {
    return filtered
        .where((t) =>
            t.dueDate != null && _isToday(t.dueDate!) && !t.completed)
        .toList();
  }

  List<TaskModel> _getUpcomingTasks(List<TaskModel> filtered) {
    return filtered
        .where((t) =>
            t.dueDate != null &&
            t.dueDate!.isAfter(DateTime.now()) &&
            !_isToday(t.dueDate!) &&
            !t.completed)
        .toList();
  }

  List<TaskModel> _getCompletedTasks(List<TaskModel> filtered) {
    return filtered.where((t) => t.completed).toList();
  }

  // ==================== NAVIGATION ====================

  Future<void> _navigateToAddTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(onSave: _addTask),
      ),
    );
    _loadTasks();
  }

  Future<void> _navigateToAnalytics() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AnalyticsScreen(),
      ),
    );
  }

  Future<void> _navigateToTaskDetail(TaskModel task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          task: task,
          onUpdate: (updated) => _loadTasks(),
          onDelete: () {
            final idx = tasks.indexOf(task);
            if (idx >= 0) _deleteTask(idx);
          },
        ),
      ),
    );
    _loadTasks();
  }

  // ==================== DIALOG ====================

  Future<bool> _showDeleteConfirmation() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: isDark ? theme.cardColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Delete Task?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            "This action cannot be undone.",
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.7)
                  : Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  // ==================== UI BUILDERS ====================

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.person,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),

        // Title
        Text(
          "My Tasks",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),

        // Actions
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.bar_chart_rounded,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              onPressed: _navigateToAnalytics,
            ),
            IconButton(
              onPressed: () => context.read<ThemeProvider>().toggleTheme(),
              icon: Icon(
                context.watch<ThemeProvider>().isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.08 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              onChanged: (v) => setState(() => searchQuery = v),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: "Search tasks...",
                hintStyle: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black38,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Quick add button
        InkWell(
          onTap: _navigateToAddTask,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.08 : 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.add,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(ThemeData theme, bool isDark) {
    final categories = ["All", "Work", "Personal", "Study", "Shopping", "Other"];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 4 : 0,
              right: 8,
            ),
            child: GestureDetector(
              onTap: () => setState(() => selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? theme.cardColor : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.1)),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwipeInstruction(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.arrow_back,
                size: 16,
                color: Colors.red.shade400,
              ),
              const SizedBox(width: 8),
              Text(
                "Swipe left to delete",
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "Swipe right to complete",
                style: TextStyle(
                  color: Colors.green.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: Colors.green.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required bool isDark,
    String? title,
    String? subtitle,
    required List<Widget> children,
    bool skipHeader = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.08 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!skipHeader && title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle ?? "",
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black45,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildAccordionHeader({
    required ThemeData theme,
    required bool isDark,
    required String title,
    required String subtitle,
    required bool open,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.06 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            Icon(
              open ? Icons.expand_less : Icons.expand_more,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTile({
    required TaskModel task,
    required ThemeData theme,
    required bool isDark,
    bool isCompleted = false,
  }) {
    final actualIndex = tasks.indexOf(task);

    return Dismissible(
      key: ValueKey(task),
      direction: DismissDirection.horizontal,
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          // Swipe right - complete
          _toggleComplete(actualIndex);
          return false;
        } else {
          // Swipe left - delete
          final confirmed = await _showDeleteConfirmation();
          if (confirmed) {
            _deleteTask(actualIndex);
            return true;
          }
          return false;
        }
      },
      background: Container(
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: GestureDetector(
        onTap: () => _navigateToTaskDetail(task),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isCompleted
                ? (isDark
                    ? Colors.green.withOpacity(0.1)
                    : Colors.green.withOpacity(0.08))
                : (isDark ? theme.cardColor : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.06),
            ),
          ),
          child: Row(
            children: [
              Icon(
                task.completed ? Icons.check_circle : Icons.circle_outlined,
                color: task.completed
                    ? Colors.green.shade400
                    : theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildInfoChip(
                          icon: Icons.calendar_today,
                          label: task.dueDate != null
                              ? "${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}"
                              : "No date",
                          isDark: isDark,
                        ),
                        _buildInfoChip(
                          icon: Icons.access_time,
                          label: task.time ?? "No time",
                          isDark: isDark,
                        ),
                        _buildCategoryChip(task.category, isDark),
                        _buildPriorityChip(task.priority, isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark
                ? Colors.white.withOpacity(0.6)
                : Colors.black54,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? Colors.white.withOpacity(0.6)
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4FC3F7).withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF4FC3F7),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority, bool isDark) {
    final color = _priorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          "No tasks",
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? Colors.white.withOpacity(0.4)
                : Colors.black38,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTaskList({
    required List<TaskModel> tasks,
    required ThemeData theme,
    required bool isDark,
    bool isCompleted = false,
  }) {
    if (tasks.isEmpty) {
      return [_buildEmptyState(isDark)];
    }

    return tasks
        .map((task) => _buildTaskTile(
              task: task,
              theme: theme,
              isDark: isDark,
              isCompleted: isCompleted,
            ))
        .toList();
  }

  // ==================== MAIN BUILD ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filtered = _getFilteredTasks();
    final today = _getTodayTasks(filtered);
    final upcoming = _getUpcomingTasks(filtered);
    final completed = _getCompletedTasks(filtered);

    return Scaffold(
      backgroundColor: isDark
          ? theme.scaffoldBackgroundColor
          : Colors.grey.shade100,
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
        onPressed: _navigateToAddTask,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, isDark),
              const SizedBox(height: 20),
              _buildSearchBar(theme, isDark),
              const SizedBox(height: 18),
              _buildCategoryChips(theme, isDark),
              const SizedBox(height: 16),
              _buildSwipeInstruction(isDark),
              const SizedBox(height: 20),

              // Today's Tasks (always visible)
              _buildSectionCard(
                theme: theme,
                isDark: isDark,
                title: "Today's Tasks",
                subtitle: "${today.length} tasks",
                children: _buildTaskList(
                  tasks: today,
                  theme: theme,
                  isDark: isDark,
                ),
              ),

              const SizedBox(height: 18),

              // Upcoming (accordion)
              _buildAccordionHeader(
                theme: theme,
                isDark: isDark,
                title: "Upcoming",
                subtitle: "${upcoming.length} tasks",
                open: upcomingOpen,
                onTap: () {
                  setState(() {
                    upcomingOpen = !upcomingOpen;
                    if (upcomingOpen) completedOpen = false;
                  });
                },
              ),
              if (upcomingOpen) ...[
                const SizedBox(height: 12),
                _buildSectionCard(
                  theme: theme,
                  isDark: isDark,
                  skipHeader: true,
                  children: _buildTaskList(
                    tasks: upcoming,
                    theme: theme,
                    isDark: isDark,
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Completed (accordion)
              _buildAccordionHeader(
                theme: theme,
                isDark: isDark,
                title: "Completed",
                subtitle: "${completed.length} tasks",
                open: completedOpen,
                onTap: () {
                  setState(() {
                    completedOpen = !completedOpen;
                    if (completedOpen) upcomingOpen = false;
                  });
                },
              ),
              if (completedOpen) ...[
                const SizedBox(height: 12),
                _buildSectionCard(
                  theme: theme,
                  isDark: isDark,
                  skipHeader: true,
                  children: _buildTaskList(
                    tasks: completed,
                    theme: theme,
                    isDark: isDark,
                    isCompleted: true,
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}