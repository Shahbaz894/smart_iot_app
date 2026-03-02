
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_iot_app/src/core/providers/theme_provider.dart';
import 'package:smart_iot_app/src/features/dashboard/services/motor_rtb_services.dart';
import 'package:smart_iot_app/src/features/dashboard/view/motor_screen.dart';



import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase using the CLI-generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final service = MotorRTDBService();
  await service.initMotorStructure();

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
      home: MotorScreen()
    );
  }
}


