import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/workout.dart';
import '../../../../data/workout_database.dart' as db;
import '../../domain/repos/workout_repo.dart';
import 'workout_states.dart';

/// Cubit managing workout state and operations.
class WorkoutCubit extends Cubit<WorkoutState> {
  final WorkoutRepo? repo;

  WorkoutCubit({this.repo}) : super(WorkoutInitial());

  /// Load initial workout data.
  Future<void> loadWorkouts() async {
    List<Workout> customWorkouts = [];

    // Load persisted custom workouts if repo is available
    if (repo != null) {
      try {
        customWorkouts = await repo!.getCustomWorkouts();
      } catch (e) {
        // If loading fails, continue with empty list
      }
    }

    emit(WorkoutLoaded(
      presetWorkouts: db.presetWorkouts,
      customWorkouts: customWorkouts,
    ));
  }

  /// Add a custom workout.
  Future<void> addCustomWorkout(Workout workout) async {
    final currentState = state;
    if (currentState is! WorkoutLoaded) return;

    final newCustomWorkouts = [...currentState.customWorkouts, workout];
    emit(currentState.copyWith(customWorkouts: newCustomWorkouts));

    // Persist to storage
    if (repo != null) {
      await repo!.saveCustomWorkout(workout);
    }
  }

  /// Update an existing custom workout.
  Future<void> updateCustomWorkout(String id, Workout workout) async {
    final currentState = state;
    if (currentState is! WorkoutLoaded) return;

    final index = currentState.customWorkouts.indexWhere((w) => w.id == id);
    if (index != -1) {
      final updated = List<Workout>.from(currentState.customWorkouts);
      updated[index] = workout;
      emit(currentState.copyWith(customWorkouts: updated));

      // Persist to storage
      if (repo != null) {
        await repo!.updateCustomWorkout(workout);
      }
    }
  }

  /// Saves an edited workout. If it's a preset workout, creates a custom copy.
  /// Returns the new workout (useful for navigation after save).
  Future<Workout> saveEditedWorkout(Workout original, Workout edited) async {
    final currentState = state;
    if (currentState is! WorkoutLoaded) return edited;

    if (original.isCustom) {
      // Update existing custom workout
      final index = currentState.customWorkouts.indexWhere((w) => w.id == original.id);
      if (index != -1) {
        final updated = List<Workout>.from(currentState.customWorkouts);
        updated[index] = edited;
        emit(currentState.copyWith(customWorkouts: updated));

        // Persist to storage
        if (repo != null) {
          await repo!.updateCustomWorkout(edited);
        }
        return edited;
      }
    }

    // For preset workouts, create a new custom copy
    final customCopy = edited.copyWith(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      isCustom: true,
    );
    emit(currentState.copyWith(
      customWorkouts: [customCopy, ...currentState.customWorkouts],
    ));

    // Persist to storage
    if (repo != null) {
      await repo!.saveCustomWorkout(customCopy);
    }
    return customCopy;
  }

  /// Delete a custom workout.
  Future<void> deleteCustomWorkout(String id) async {
    final currentState = state;
    if (currentState is! WorkoutLoaded) return;

    emit(currentState.copyWith(
      customWorkouts: currentState.customWorkouts.where((w) => w.id != id).toList(),
    ));

    // Persist to storage
    if (repo != null) {
      await repo!.deleteCustomWorkout(id);
    }
  }

  /// Get workout by ID.
  Workout? getWorkoutById(String id) {
    final currentState = state;
    if (currentState is! WorkoutLoaded) return null;
    return currentState.getWorkoutById(id);
  }
}
