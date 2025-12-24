import '../../domain/entities/workout_session.dart';

/// Base class for all workout session states.
abstract class WorkoutSessionState {}

/// Initial state before any data is loaded.
class WorkoutSessionInitial extends WorkoutSessionState {}

/// Loading state while fetching data.
class WorkoutSessionLoading extends WorkoutSessionState {}

/// Loaded state with session and history data.
class WorkoutSessionLoaded extends WorkoutSessionState {
  /// Currently active workout session (null if no workout in progress).
  final WorkoutSession? activeSession;

  /// History of completed workout dates.
  final WorkoutHistory history;

  WorkoutSessionLoaded({
    this.activeSession,
    required this.history,
  });

  /// Check if there's an active session for a specific workout.
  bool hasActiveSessionForWorkout(String workoutId) {
    return activeSession?.workoutId == workoutId;
  }

  /// Check if a specific exercise is complete in the active session.
  bool isExerciseComplete(String exerciseId, int totalSets) {
    if (activeSession == null) return false;
    return activeSession!.isExerciseComplete(exerciseId, totalSets);
  }

  /// Get completed sets count for an exercise.
  int getCompletedSets(String exerciseId) {
    if (activeSession == null) return 0;
    return activeSession!.getCompletedSets(exerciseId);
  }

  /// Check if a set is completed.
  bool isSetCompleted(String exerciseId, int setIndex) {
    if (activeSession == null) return false;
    final sets = activeSession!.exerciseSetCompletion[exerciseId];
    if (sets == null || setIndex >= sets.length) return false;
    return sets[setIndex];
  }

  /// Check if a workout was completed on a specific date.
  bool hasWorkoutOnDate(DateTime date) {
    return history.hasWorkoutOnDate(date);
  }

  /// Check if all exercises in the active session are complete.
  bool areAllExercisesComplete(Map<String, int> exerciseTotalSets) {
    if (activeSession == null) return false;
    return activeSession!.areAllExercisesComplete(exerciseTotalSets);
  }

  /// Check if a specific workout was completed today.
  bool isWorkoutCompletedToday(String workoutId) {
    return history.isWorkoutCompletedToday(workoutId);
  }

  WorkoutSessionLoaded copyWith({
    WorkoutSession? activeSession,
    WorkoutHistory? history,
    bool clearActiveSession = false,
  }) {
    return WorkoutSessionLoaded(
      activeSession:
          clearActiveSession ? null : (activeSession ?? this.activeSession),
      history: history ?? this.history,
    );
  }
}

/// Error state with message.
class WorkoutSessionError extends WorkoutSessionState {
  final String message;

  WorkoutSessionError(this.message);
}
