import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repos/workout_session_repo.dart';

/// Local implementation of WorkoutSessionRepo using Hive for persistence.
class LocalWorkoutSessionRepo implements WorkoutSessionRepo {
  // Box names
  static const String _sessionBoxName = 'workout_session';
  static const String _historyBoxName = 'workout_history';

  // Keys
  static const String _activeSessionKey = 'active';
  static const String _completedDatesKey = 'completed_dates';
  static const String _completedWorkoutsKey = 'completed_workouts';

  Box? _sessionBox;
  Box? _historyBox;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize Hive boxes. Must be called before using other methods.
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_sessionBoxName)) {
      _sessionBox = await Hive.openBox(_sessionBoxName);
    } else {
      _sessionBox = Hive.box(_sessionBoxName);
    }

    if (!Hive.isBoxOpen(_historyBoxName)) {
      _historyBox = await Hive.openBox(_historyBoxName);
    } else {
      _historyBox = Hive.box(_historyBoxName);
    }

    _isInitialized = true;
  }

  void _ensureInitialized() {
    if (!_isInitialized || _sessionBox == null || _historyBox == null) {
      throw StateError(
          'LocalWorkoutSessionRepo not initialized. Call initialize() first.');
    }
  }

  // ============================================================
  // SESSION OPERATIONS
  // ============================================================

  @override
  Future<WorkoutSession?> getActiveSession() async {
    _ensureInitialized();

    try {
      final data = _sessionBox!.get(_activeSessionKey);
      if (data == null) return null;

      return WorkoutSession.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveSession(WorkoutSession session) async {
    _ensureInitialized();

    try {
      await _sessionBox!.put(_activeSessionKey, session.toJson());
    } catch (e) {
      throw Exception('Failed to save session: $e');
    }
  }

  @override
  Future<void> clearSession() async {
    _ensureInitialized();

    try {
      await _sessionBox!.delete(_activeSessionKey);
    } catch (e) {
      throw Exception('Failed to clear session: $e');
    }
  }

  // ============================================================
  // HISTORY OPERATIONS
  // ============================================================

  @override
  Future<WorkoutHistory> getHistory() async {
    _ensureInitialized();

    try {
      final datesData = _historyBox!.get(_completedDatesKey);
      final workoutsData = _historyBox!.get(_completedWorkoutsKey);

      final dates = datesData != null
          ? (datesData as List<dynamic>)
              .map((d) => DateTime.parse(d as String))
              .toSet()
          : <DateTime>{};

      final workoutsByDate = <String, List<String>>{};
      if (workoutsData != null) {
        final rawMap = workoutsData as Map<dynamic, dynamic>;
        for (final entry in rawMap.entries) {
          workoutsByDate[entry.key as String] =
              List<String>.from(entry.value as List<dynamic>);
        }
      }

      return WorkoutHistory(
        completedDates: dates,
        completedWorkoutsByDate: workoutsByDate,
      );
    } catch (e) {
      return WorkoutHistory.empty();
    }
  }

  @override
  Future<void> addCompletedDate(DateTime date) async {
    _ensureInitialized();

    try {
      final normalized = DateTime(date.year, date.month, date.day);
      final dateString =
          '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';

      final existing = _historyBox!.get(_completedDatesKey);
      final dates = existing != null
          ? List<String>.from(existing as List<dynamic>)
          : <String>[];

      if (!dates.contains(dateString)) {
        dates.add(dateString);
        await _historyBox!.put(_completedDatesKey, dates);
      }
    } catch (e) {
      throw Exception('Failed to add completed date: $e');
    }
  }

  @override
  Future<void> addCompletedWorkout(DateTime date, String workoutId) async {
    _ensureInitialized();

    try {
      final normalized = DateTime(date.year, date.month, date.day);
      final dateKey =
          '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';

      final existing = _historyBox!.get(_completedWorkoutsKey);
      final workoutsByDate = existing != null
          ? Map<String, List<String>>.from(
              (existing as Map<dynamic, dynamic>).map(
                (key, value) => MapEntry(
                  key as String,
                  List<String>.from(value as List<dynamic>),
                ),
              ),
            )
          : <String, List<String>>{};

      final dayWorkouts = workoutsByDate[dateKey] ?? <String>[];
      if (!dayWorkouts.contains(workoutId)) {
        dayWorkouts.add(workoutId);
        workoutsByDate[dateKey] = dayWorkouts;
        await _historyBox!.put(_completedWorkoutsKey, workoutsByDate);
      }
    } catch (e) {
      throw Exception('Failed to add completed workout: $e');
    }
  }

  @override
  Future<void> removeCompletedWorkout(DateTime date, String workoutId) async {
    _ensureInitialized();

    try {
      final normalized = DateTime(date.year, date.month, date.day);
      final dateKey =
          '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';

      final existing = _historyBox!.get(_completedWorkoutsKey);
      if (existing == null) return;

      final workoutsByDate = Map<String, List<String>>.from(
        (existing as Map<dynamic, dynamic>).map(
          (key, value) => MapEntry(
            key as String,
            List<String>.from(value as List<dynamic>),
          ),
        ),
      );

      final dayWorkouts = workoutsByDate[dateKey];
      if (dayWorkouts != null && dayWorkouts.contains(workoutId)) {
        dayWorkouts.remove(workoutId);

        // If no workouts left for this day, remove the date from completed dates
        if (dayWorkouts.isEmpty) {
          workoutsByDate.remove(dateKey);

          // Also remove from completed dates
          final datesData = _historyBox!.get(_completedDatesKey);
          if (datesData != null) {
            final dates = List<String>.from(datesData as List<dynamic>);
            final dateString =
                '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
            dates.remove(dateString);
            await _historyBox!.put(_completedDatesKey, dates);
          }
        } else {
          workoutsByDate[dateKey] = dayWorkouts;
        }

        await _historyBox!.put(_completedWorkoutsKey, workoutsByDate);
      }
    } catch (e) {
      throw Exception('Failed to remove completed workout: $e');
    }
  }

  @override
  Future<void> clearHistory() async {
    _ensureInitialized();

    try {
      await _historyBox!.delete(_completedDatesKey);
      await _historyBox!.delete(_completedWorkoutsKey);
    } catch (e) {
      throw Exception('Failed to clear history: $e');
    }
  }
}
