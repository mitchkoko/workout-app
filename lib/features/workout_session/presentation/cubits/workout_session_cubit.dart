import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/workout.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repos/workout_session_repo.dart';
import 'workout_session_states.dart';

/// Cubit managing workout session state and operations.
class WorkoutSessionCubit extends Cubit<WorkoutSessionState> {
  final WorkoutSessionRepo repo;

  WorkoutSessionCubit({required this.repo}) : super(WorkoutSessionInitial());

  /// Load session and history from storage.
  Future<void> loadSession() async {
    try {
      emit(WorkoutSessionLoading());

      final activeSession = await repo.getActiveSession();
      final history = await repo.getHistory();

      emit(WorkoutSessionLoaded(
        activeSession: activeSession,
        history: history,
      ));
    } catch (e) {
      emit(WorkoutSessionError('Failed to load session: $e'));
    }
  }

  /// Start a new workout session.
  Future<void> startWorkout(String workoutId, List<WorkoutExercise> exercises) async {
    final currentState = state;
    if (currentState is! WorkoutSessionLoaded) {
      emit(WorkoutSessionError('Cannot start workout: invalid state'));
      return;
    }

    try {
      // Create exercise set completion map
      final exerciseSetCompletion = <String, List<bool>>{};
      for (final exercise in exercises) {
        exerciseSetCompletion[exercise.exercise.id] =
            List.filled(exercise.sets, false);
      }

      final session = WorkoutSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        workoutId: workoutId,
        startedAt: DateTime.now(),
        exerciseSetCompletion: exerciseSetCompletion,
      );

      // Optimistic update
      emit(currentState.copyWith(activeSession: session));

      // Persist
      await repo.saveSession(session);
    } catch (e) {
      emit(currentState);
      emit(WorkoutSessionError('Failed to start workout: $e'));
    }
  }

  /// Complete a specific set for an exercise.
  Future<void> completeSet(String exerciseId, int setIndex) async {
    final currentState = state;
    if (currentState is! WorkoutSessionLoaded) {
      emit(WorkoutSessionError('Cannot complete set: invalid state'));
      return;
    }

    final session = currentState.activeSession;
    if (session == null) {
      emit(WorkoutSessionError('Cannot complete set: no active session'));
      return;
    }

    try {
      // Create updated completion map
      final updatedCompletion =
          Map<String, List<bool>>.from(session.exerciseSetCompletion);

      final sets = updatedCompletion[exerciseId];
      if (sets == null || setIndex >= sets.length) {
        emit(WorkoutSessionError('Invalid set index'));
        return;
      }

      // Create new list with updated value
      updatedCompletion[exerciseId] = List<bool>.from(sets)..[setIndex] = true;

      final updatedSession = session.copyWith(
        exerciseSetCompletion: updatedCompletion,
      );

      // Optimistic update
      emit(currentState.copyWith(activeSession: updatedSession));

      // Persist
      await repo.saveSession(updatedSession);
    } catch (e) {
      emit(currentState);
      emit(WorkoutSessionError('Failed to complete set: $e'));
    }
  }

  /// Uncomplete a specific set for an exercise (undo).
  Future<void> uncompleteSet(String exerciseId, int setIndex) async {
    final currentState = state;
    if (currentState is! WorkoutSessionLoaded) {
      emit(WorkoutSessionError('Cannot uncomplete set: invalid state'));
      return;
    }

    final session = currentState.activeSession;
    if (session == null) {
      emit(WorkoutSessionError('Cannot uncomplete set: no active session'));
      return;
    }

    try {
      // Create updated completion map
      final updatedCompletion =
          Map<String, List<bool>>.from(session.exerciseSetCompletion);

      final sets = updatedCompletion[exerciseId];
      if (sets == null || setIndex >= sets.length) {
        emit(WorkoutSessionError('Invalid set index'));
        return;
      }

      // Create new list with updated value (set to false)
      updatedCompletion[exerciseId] = List<bool>.from(sets)..[setIndex] = false;

      final updatedSession = session.copyWith(
        exerciseSetCompletion: updatedCompletion,
      );

      // Optimistic update
      emit(currentState.copyWith(activeSession: updatedSession));

      // Persist
      await repo.saveSession(updatedSession);
    } catch (e) {
      emit(currentState);
      emit(WorkoutSessionError('Failed to uncomplete set: $e'));
    }
  }

  /// Finish the current workout and add to history.
  /// If [forDate] is provided, the workout will be recorded as completed on that date.
  /// Otherwise, it defaults to today.
  Future<void> finishWorkout({DateTime? forDate}) async {
    final currentState = state;
    if (currentState is! WorkoutSessionLoaded) {
      emit(WorkoutSessionError('Cannot finish workout: invalid state'));
      return;
    }

    final session = currentState.activeSession;
    if (session == null) {
      emit(WorkoutSessionError('Cannot finish workout: no active session'));
      return;
    }

    try {
      final date = forDate ?? DateTime.now();
      final completedDate = DateTime(date.year, date.month, date.day);
      final workoutId = session.workoutId;
      final dateKey = '${completedDate.year}-${completedDate.month.toString().padLeft(2, '0')}-${completedDate.day.toString().padLeft(2, '0')}';

      // Update history with completed workout ID
      final currentWorkouts = currentState.history.completedWorkoutsByDate[dateKey] ?? [];
      final updatedWorkoutsByDate = Map<String, List<String>>.from(
        currentState.history.completedWorkoutsByDate,
      );
      if (!currentWorkouts.contains(workoutId)) {
        updatedWorkoutsByDate[dateKey] = [...currentWorkouts, workoutId];
      }

      final updatedHistory = currentState.history.copyWith(
        completedDates: {...currentState.history.completedDates, completedDate},
        completedWorkoutsByDate: updatedWorkoutsByDate,
      );

      // Optimistic update - clear session and update history
      emit(currentState.copyWith(
        clearActiveSession: true,
        history: updatedHistory,
      ));

      // Persist
      await repo.addCompletedDate(completedDate);
      await repo.addCompletedWorkout(completedDate, workoutId);
      await repo.clearSession();
    } catch (e) {
      emit(currentState);
      emit(WorkoutSessionError('Failed to finish workout: $e'));
    }
  }

  /// Cancel the current workout without adding to history.
  Future<void> cancelWorkout() async {
    final currentState = state;
    if (currentState is! WorkoutSessionLoaded) {
      emit(WorkoutSessionError('Cannot cancel workout: invalid state'));
      return;
    }

    try {
      // Optimistic update
      emit(currentState.copyWith(clearActiveSession: true));

      // Persist
      await repo.clearSession();
    } catch (e) {
      emit(currentState);
      emit(WorkoutSessionError('Failed to cancel workout: $e'));
    }
  }

  /// Reset a completed workout for a specific date (remove from history).
  Future<void> resetWorkoutCompletion(String workoutId, DateTime date) async {
    final currentState = state;
    if (currentState is! WorkoutSessionLoaded) {
      emit(WorkoutSessionError('Cannot reset workout: invalid state'));
      return;
    }

    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final dateKey =
          '${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}';

      // Update history - remove workout from date
      final updatedWorkoutsByDate = Map<String, List<String>>.from(
        currentState.history.completedWorkoutsByDate,
      );

      final dayWorkouts = updatedWorkoutsByDate[dateKey]?.toList() ?? [];
      dayWorkouts.remove(workoutId);

      // Update completed dates if no workouts left for this day
      Set<DateTime> updatedDates = Set.from(currentState.history.completedDates);
      if (dayWorkouts.isEmpty) {
        updatedWorkoutsByDate.remove(dateKey);
        updatedDates = updatedDates.where((d) =>
            !(d.year == normalizedDate.year &&
              d.month == normalizedDate.month &&
              d.day == normalizedDate.day)).toSet();
      } else {
        updatedWorkoutsByDate[dateKey] = dayWorkouts;
      }

      final updatedHistory = currentState.history.copyWith(
        completedDates: updatedDates,
        completedWorkoutsByDate: updatedWorkoutsByDate,
      );

      // Optimistic update
      emit(currentState.copyWith(history: updatedHistory));

      // Persist
      await repo.removeCompletedWorkout(date, workoutId);
    } catch (e) {
      emit(currentState);
      emit(WorkoutSessionError('Failed to reset workout: $e'));
    }
  }

  /// Clear all workout data (history and active session).
  Future<void> clearAllData() async {
    try {
      await repo.clearSession();
      await repo.clearHistory();

      emit(WorkoutSessionLoaded(
        activeSession: null,
        history: WorkoutHistory.empty(),
      ));
    } catch (e) {
      emit(WorkoutSessionError('Failed to clear data: $e'));
    }
  }
}
