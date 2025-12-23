import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../data/workout_database.dart' as db;

class WorkoutProvider extends ChangeNotifier {
  final List<Workout> _customWorkouts = [];

  List<Workout> get presetWorkouts => db.presetWorkouts;
  List<Workout> get customWorkouts => List.unmodifiable(_customWorkouts);

  List<Workout> get allWorkouts => [...db.presetWorkouts, ..._customWorkouts];

  void addCustomWorkout(Workout workout) {
    _customWorkouts.add(workout);
    notifyListeners();
  }

  void updateCustomWorkout(String id, Workout workout) {
    final index = _customWorkouts.indexWhere((w) => w.id == id);
    if (index != -1) {
      _customWorkouts[index] = workout;
      notifyListeners();
    }
  }

  /// Saves an edited workout. If it's a preset workout, creates a custom copy.
  /// Returns the new workout (useful for navigation after save).
  Workout saveEditedWorkout(Workout original, Workout edited) {
    if (original.isCustom) {
      // Update existing custom workout
      final index = _customWorkouts.indexWhere((w) => w.id == original.id);
      if (index != -1) {
        _customWorkouts[index] = edited;
        notifyListeners();
        return edited;
      }
    }
    // For preset workouts, create a new custom copy
    final customCopy = edited.copyWith(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      isCustom: true,
    );
    _customWorkouts.insert(0, customCopy);
    notifyListeners();
    return customCopy;
  }

  void deleteCustomWorkout(String id) {
    _customWorkouts.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  Workout? getWorkoutById(String id) {
    try {
      return allWorkouts.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }
}

class WorkoutProviderScope extends InheritedNotifier<WorkoutProvider> {
  const WorkoutProviderScope({
    super.key,
    required WorkoutProvider provider,
    required super.child,
  }) : super(notifier: provider);

  static WorkoutProvider of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<WorkoutProviderScope>();
    return scope!.notifier!;
  }
}
