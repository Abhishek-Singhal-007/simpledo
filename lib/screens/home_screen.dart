import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../theme/theme_provider.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskModel> tasks = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  String selectedCategory = "All";
  String selectedPriority = "All";
  String selectedStatus = "All";
  String selectedSort = "Priority";

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // Load tasks from Hive
  void loadTasks() {
    final box = Hive.box<TaskModel>("tasksBox");
    tasks = box.values.toList();
    setState(() {});
  }

  // Save tasks to Hive
  void saveTasks() {
    final box = Hive.box<TaskModel>("tasksBox");
    box.clear();
    for (var task in tasks) {
      box.add(task);
    }
  }

  void addTask(TaskModel task) {
    setState(() {
      tasks.add(task);
      sortTasks();
      saveTasks();
    });
  }

  void updateTask(int index, TaskModel newTask) {
    setState(() {
      tasks[index] = newTask;
      sortTasks();
      saveTasks();
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      saveTasks();
    });
  }

  void toggleComplete(int index) {
    setState(() {
      tasks[index].completed = !tasks[index].completed;
      sortTasks();
      saveTasks();
    });
  }

  // ------------------- SORTING -------------------
  void sortTasks() {
    if (selectedSort == "Priority") {
      const order = {"High": 1, "Medium": 2, "Low": 3};
      tasks.sort((a, b) => order[a.priority]!.compareTo(order[b.priority]!));
    } else if (selectedSort == "A-Z") {
      tasks.sort((a, b) => a.title.compareTo(b.title));
    } else if (selectedSort == "Completed") {
      tasks.sort(
        (a, b) => b.completed.toString().compareTo(a.completed.toString()),
      );
    } else if (selectedSort == "Pending") {
      tasks.sort(
        (a, b) => a.completed.toString().compareTo(b.completed.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Apply filtering
    final filteredTasks = tasks.where((task) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Simple Do"),
        centerTitle: true,

        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTaskScreen(onSave: addTask)),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // ---------------- SEARCH BAR ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search tasks...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),

          // ---------------- FILTER ROW ----------------
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _filterDropdown(
                    "Category",
                    ["All", "Work", "Personal", "Study", "Shopping"],
                    selectedCategory,
                    (val) => setState(() => selectedCategory = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _filterDropdown(
                    "Priority",
                    ["All", "High", "Medium", "Low"],
                    selectedPriority,
                    (val) => setState(() => selectedPriority = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _filterDropdown(
                    "Status",
                    ["All", "Completed", "Pending"],
                    selectedStatus,
                    (val) => setState(() => selectedStatus = val),
                  ),
                ),
              ],
            ),
          ),

          // ---------------- SORT -----------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Text(
                  "Sort by:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedSort,
                  items: ["A-Z", "Priority", "Completed", "Pending"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedSort = val!;
                      sortTasks();
                    });
                  },
                ),
              ],
            ),
          ),

          // ---------------- GLOBAL ACTION ROW ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // LEFT SIDE: DELETE
                Row(
                  children: const [
                    Icon(Icons.arrow_back, size: 16, color: Colors.redAccent),
                    SizedBox(width: 6),
                    Text(
                      "Delete",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),

                // RIGHT SIDE: COMPLETE
                Row(
                  children: [
                    Text(
                      "Complete",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeMode.system == ThemeMode.dark
                            ? Colors.greenAccent
                            : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 16, color: Colors.green),
                  ],
                ),
              ],
            ),
          ),

          // ---------------- TASK LIST ------------------
          Expanded(
            child: ReorderableListView.builder(
              itemCount: filteredTasks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final task = filteredTasks.removeAt(oldIndex);
                  filteredTasks.insert(newIndex, task);
                  tasks = filteredTasks;
                  saveTasks();
                });
              },

              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                final actualIndex = tasks.indexOf(task);

                return Dismissible(
                  key: ValueKey(task),
                  direction: DismissDirection.horizontal,

                  // SWIPE LOGIC
                  confirmDismiss: (dir) async {
                    if (dir == DismissDirection.startToEnd) {
                      toggleComplete(actualIndex);
                      return false;
                    } else {
                      deleteTask(actualIndex);
                      return true;
                    }
                  },

                  background: Container(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),

                  secondaryBackground: Container(
                    color: Colors.red.withOpacity(0.8),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  child: TaskCard(
                    task: task,
                    dragHandle: ReorderableDragStartListener(
                      index: index,
                      child: Icon(
                        Icons.drag_handle,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditTaskScreen(
                            task: task,
                            onSave: (updatedTask) =>
                                updateTask(actualIndex, updatedTask),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Reusable dropdown builder
  Widget _filterDropdown(
    String label,
    List<String> items,
    String value,
    Function(String) onChange,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) => onChange(value!),
      ),
    );
  }
}
