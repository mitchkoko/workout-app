import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/themes/light_mode.dart';
import 'core/themes/dark_mode.dart';
import 'pages/workout_list_page.dart';
import 'providers/workout_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const WorkoutTrackerApp());
}

class WorkoutTrackerApp extends StatefulWidget {
  const WorkoutTrackerApp({super.key});

  @override
  State<WorkoutTrackerApp> createState() => _WorkoutTrackerAppState();
}

class _WorkoutTrackerAppState extends State<WorkoutTrackerApp> {
  final _workoutProvider = WorkoutProvider();

  @override
  Widget build(BuildContext context) {
    return WorkoutProviderScope(
      provider: _workoutProvider,
      child: MaterialApp(
        title: 'Workout Tracker',
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: darkMode,
        themeMode: ThemeMode.system,
        home: const WorkoutListPage(),
      ),
    );
  }
}
