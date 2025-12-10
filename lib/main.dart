import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/task_model.dart';
import 'screens/home_screen.dart';
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Secure key storage
  const secure = FlutterSecureStorage();
  String? savedKey = await secure.read(key: "hive_key");

  if (savedKey == null) {
    final key = Hive.generateSecureKey();
    await secure.write(key: "hive_key", value: base64UrlEncode(key));
    savedKey = base64UrlEncode(key);
  }

  final keyBytes = base64Url.decode(savedKey);

  Hive.registerAdapter(TaskModelAdapter());

  await Hive.openBox<TaskModel>(
    "tasksBox",
    encryptionCipher: HiveAesCipher(keyBytes),
  );

  // THE FIX IS HERE ↓
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const TodoApp(),
    ),
  );
}

// ---------------- MAIN APP -------------------

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Simple Do",
      theme: themeProvider.theme,   // dynamic theme
      home: const HomeScreen(),
    );
  }
}
