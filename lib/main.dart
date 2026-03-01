
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_iot_app/src/core/providers/theme_provider.dart';

import 'package:smart_iot_app/src/features/dashboard/view/sensor_dashboard.dart';
import 'package:smart_iot_app/src/features/dashboard/view/switch_control_screen.dart';

import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase using the CLI-generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeMode,
      home: IoTControlScreen()
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'Current Theme: ${themeMode == ThemeMode.light ? "Light" : "Dark"}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(themeProvider.notifier).toggleTheme();
        },
        child: const Icon(Icons.brightness_6),
      ),
    );
  }
}
