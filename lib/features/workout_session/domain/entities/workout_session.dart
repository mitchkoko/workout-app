/// Entity representing an active workout session.
/// Tracks which sets have been completed for each exercise.
class WorkoutSession {
  final String id;
  final String workoutId;
  final DateTime startedAt;
  final DateTime? completedAt;

  /// Maps exercise ID to a list of booleans indicating set completion.
  /// e.g., {'exercise_1': [true, true, false]} means 2 of 3 sets completed.
  final Map<String, List<bool>> exerciseSetCompletion;

  const WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.startedAt,
    this.completedAt,
    required this.exerciseSetCompletion,
  });

  /// Check if a specific exercise is fully complete.
  bool isExerciseComplete(String exerciseId, int totalSets) {
    final sets = exerciseSetCompletion[exerciseId];
    if (sets == null || sets.length != totalSets) return false;
    return sets.every((completed) => completed);
  }

  /// Get number of completed sets for an exercise.
  int getCompletedSets(String exerciseId) {
    final sets = exerciseSetCompletion[exerciseId];
    if (sets == null) return 0;
    return sets.where((completed) => completed).length;
  }

  /// Check if the entire workout session is complete.
  bool get isComplete => completedAt != null;

  /// Check if all exercises in the session are complete.
  bool areAllExercisesComplete(Map<String, int> exerciseTotalSets) {
    for (final entry in exerciseTotalSets.entries) {
      if (!isExerciseComplete(entry.key, entry.value)) {
        return false;
      }
    }
    return true;
  }

  WorkoutSession copyWith({
    String? id,
    String? workoutId,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, List<bool>>? exerciseSetCompletion,
    bool clearCompletedAt = false,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      exerciseSetCompletion: exerciseSetCompletion ?? this.exerciseSetCompletion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'exerciseSetCompletion': exerciseSetCompletion.map(
        (key, value) => MapEntry(key, value),
      ),
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    final rawCompletion = json['exerciseSetCompletion'] as Map<dynamic, dynamic>;
    final exerciseSetCompletion = <String, List<bool>>{};

    for (final entry in rawCompletion.entries) {
      final key = entry.key as String;
      final value = (entry.value as List<dynamic>).cast<bool>();
      exerciseSetCompletion[key] = value;
    }

    return WorkoutSession(
      id: json['id'] as String,
      workoutId: json['workoutId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      exerciseSetCompletion: exerciseSetCompletion,
    );
  }
}

/// Entity representing the history of completed workouts.
/// Stores dates when workouts were completed (for calendar display).
class WorkoutHistory {
  final Set<DateTime> completedDates;

  /// Maps date string (yyyy-MM-dd) to list of completed workout IDs for that day.
  final Map<String, List<String>> completedWorkoutsByDate;

  const WorkoutHistory({
    required this.completedDates,
    this.completedWorkoutsByDate = const {},
  });

  /// Check if a workout was completed on a specific date.
  bool hasWorkoutOnDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return completedDates.any((d) =>
        d.year == normalized.year &&
        d.month == normalized.month &&
        d.day == normalized.day);
  }

  /// Check if a specific workout was completed today.
  bool isWorkoutCompletedToday(String workoutId) {
    final today = DateTime.now();
    final dateKey = _dateKey(today);
    final workouts = completedWorkoutsByDate[dateKey] ?? [];
    return workouts.contains(workoutId);
  }

  /// Check if a specific workout was completed on a given date.
  bool isWorkoutCompletedOnDate(String workoutId, DateTime date) {
    final dateKey = _dateKey(date);
    final workouts = completedWorkoutsByDate[dateKey] ?? [];
    return workouts.contains(workoutId);
  }

  /// Get count of workouts in a specific month.
  int getWorkoutsInMonth(int year, int month) {
    return completedDates
        .where((d) => d.year == year && d.month == month)
        .length;
  }

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  WorkoutHistory copyWith({
    Set<DateTime>? completedDates,
    Map<String, List<String>>? completedWorkoutsByDate,
  }) {
    return WorkoutHistory(
      completedDates: completedDates ?? this.completedDates,
      completedWorkoutsByDate: completedWorkoutsByDate ?? this.completedWorkoutsByDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedDates': completedDates
          .map((d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}')
          .toList(),
      'completedWorkoutsByDate': completedWorkoutsByDate,
    };
  }

  factory WorkoutHistory.fromJson(Map<String, dynamic> json) {
    final rawDates = json['completedDates'] as List<dynamic>? ?? [];
    final dates = rawDates.map((d) => DateTime.parse(d as String)).toSet();

    final rawWorkoutsByDate = json['completedWorkoutsByDate'] as Map<dynamic, dynamic>? ?? {};
    final workoutsByDate = <String, List<String>>{};
    for (final entry in rawWorkoutsByDate.entries) {
      workoutsByDate[entry.key as String] =
          (entry.value as List<dynamic>).cast<String>();
    }

    return WorkoutHistory(
      completedDates: dates,
      completedWorkoutsByDate: workoutsByDate,
    );
  }

  factory WorkoutHistory.empty() {
    return const WorkoutHistory(completedDates: {}, completedWorkoutsByDate: {});
  }
}
