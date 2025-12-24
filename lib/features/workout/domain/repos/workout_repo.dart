import '../../../../models/workout.dart';

/// Abstract repository interface for custom workout operations.
abstract class WorkoutRepo {
  Future<List<Workout>> getCustomWorkouts();
  Future<void> saveCustomWorkout(Workout workout);
  Future<void> updateCustomWorkout(Workout workout);
  Future<void> deleteCustomWorkout(String id);
  Future<void> saveAllCustomWorkouts(List<Workout> workouts);
}
