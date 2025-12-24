import '../entities/workout_session.dart';

/// Abstract repository interface for workout session operations.
/// Implementations can use local storage (Hive) or remote APIs.
abstract class WorkoutSessionRepo {
  // Session operations
  Future<WorkoutSession?> getActiveSession();
  Future<void> saveSession(WorkoutSession session);
  Future<void> clearSession();

  // History operations
  Future<WorkoutHistory> getHistory();
  Future<void> addCompletedDate(DateTime date);
  Future<void> addCompletedWorkout(DateTime date, String workoutId);
  Future<void> removeCompletedWorkout(DateTime date, String workoutId);
  Future<void> clearHistory();
}
