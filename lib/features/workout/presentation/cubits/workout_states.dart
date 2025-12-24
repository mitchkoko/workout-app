import '../../../../models/workout.dart';

/// Base class for all workout states.
abstract class WorkoutState {}

/// Initial state before any data is loaded.
class WorkoutInitial extends WorkoutState {}

/// Loaded state with workout data.
class WorkoutLoaded extends WorkoutState {
  /// Preset workouts from database.
  final List<Workout> presetWorkouts;

  /// User-created custom workouts.
  final List<Workout> customWorkouts;

  WorkoutLoaded({
    required this.presetWorkouts,
    required this.customWorkouts,
  });

  /// All workouts combined.
  List<Workout> get allWorkouts => [...presetWorkouts, ...customWorkouts];

  /// Get workout by ID.
  Workout? getWorkoutById(String id) {
    try {
      return allWorkouts.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  WorkoutLoaded copyWith({
    List<Workout>? presetWorkouts,
    List<Workout>? customWorkouts,
  }) {
    return WorkoutLoaded(
      presetWorkouts: presetWorkouts ?? this.presetWorkouts,
      customWorkouts: customWorkouts ?? this.customWorkouts,
    );
  }
}
