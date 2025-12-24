import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'core/themes/light_mode.dart';
import 'core/themes/dark_mode.dart';
import 'pages/main_page.dart';
import 'features/workout/data/local/local_workout_repo.dart';
import 'features/workout/presentation/cubits/workout_cubit.dart';
import 'features/workout_session/data/local/local_workout_session_repo.dart';
import 'features/workout_session/presentation/cubits/workout_session_cubit.dart';
import 'features/nutrition/data/local/local_nutrition_repo.dart';
import 'features/nutrition/presentation/cubits/nutrition_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize repositories
  final workoutRepo = LocalWorkoutRepo();
  await workoutRepo.initialize();

  final workoutSessionRepo = LocalWorkoutSessionRepo();
  await workoutSessionRepo.initialize();

  final nutritionRepo = LocalNutritionRepo();
  await nutritionRepo.initialize();

  runApp(
    WorkoutTrackerApp(
      workoutRepo: workoutRepo,
      workoutSessionRepo: workoutSessionRepo,
      nutritionRepo: nutritionRepo,
    ),
  );
}

class WorkoutTrackerApp extends StatefulWidget {
  final LocalWorkoutRepo workoutRepo;
  final LocalWorkoutSessionRepo workoutSessionRepo;
  final LocalNutritionRepo nutritionRepo;

  const WorkoutTrackerApp({
    super.key,
    required this.workoutRepo,
    required this.workoutSessionRepo,
    required this.nutritionRepo,
  });

  @override
  State<WorkoutTrackerApp> createState() => _WorkoutTrackerAppState();
}

class _WorkoutTrackerAppState extends State<WorkoutTrackerApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              WorkoutCubit(repo: widget.workoutRepo)..loadWorkouts(),
        ),
        BlocProvider(
          create: (context) =>
              WorkoutSessionCubit(repo: widget.workoutSessionRepo)
                ..loadSession(),
        ),
        BlocProvider(
          create: (context) =>
              NutritionCubit(repo: widget.nutritionRepo)..loadNutrition(),
        ),
      ],
      child: MaterialApp(
        title: 'Workout Tracker',
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: darkMode,
        themeMode: ThemeMode.system,
        home: const MainPage(),
      ),
    );
  }
}
