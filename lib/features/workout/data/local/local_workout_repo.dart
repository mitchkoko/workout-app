import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../../../models/workout.dart';
import '../../domain/repos/workout_repo.dart';

/// Local implementation of WorkoutRepo using Hive for persistence.
class LocalWorkoutRepo implements WorkoutRepo {
  static const String _boxName = 'custom_workouts';
  static const String _workoutsKey = 'workouts';

  Box? _box;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize Hive box. Must be called before using other methods.
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
    _isInitialized = true;
  }

  void _ensureInitialized() {
    if (!_isInitialized || _box == null) {
      throw StateError(
          'LocalWorkoutRepo not initialized. Call initialize() first.');
    }
  }

  @override
  Future<List<Workout>> getCustomWorkouts() async {
    _ensureInitialized();

    try {
      final data = _box!.get(_workoutsKey);
      if (data == null) return [];

      final List<dynamic> workoutsList = data as List<dynamic>;
      return workoutsList
          .map((w) => Workout.fromJson(Map<String, dynamic>.from(w)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveCustomWorkout(Workout workout) async {
    _ensureInitialized();

    try {
      final existing = await getCustomWorkouts();
      final updated = [...existing, workout];
      await _saveWorkouts(updated);
    } catch (e) {
      throw Exception('Failed to save custom workout: $e');
    }
  }

  @override
  Future<void> updateCustomWorkout(Workout workout) async {
    _ensureInitialized();

    try {
      final existing = await getCustomWorkouts();
      final index = existing.indexWhere((w) => w.id == workout.id);
      if (index != -1) {
        existing[index] = workout;
        await _saveWorkouts(existing);
      }
    } catch (e) {
      throw Exception('Failed to update custom workout: $e');
    }
  }

  @override
  Future<void> deleteCustomWorkout(String id) async {
    _ensureInitialized();

    try {
      final existing = await getCustomWorkouts();
      final updated = existing.where((w) => w.id != id).toList();
      await _saveWorkouts(updated);
    } catch (e) {
      throw Exception('Failed to delete custom workout: $e');
    }
  }

  @override
  Future<void> saveAllCustomWorkouts(List<Workout> workouts) async {
    _ensureInitialized();
    await _saveWorkouts(workouts);
  }

  Future<void> _saveWorkouts(List<Workout> workouts) async {
    final jsonList = workouts.map((w) => w.toJson()).toList();
    await _box!.put(_workoutsKey, jsonList);
  }
}
