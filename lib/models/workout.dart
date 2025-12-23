import 'exercise.dart';

class WorkoutExercise {
  final Exercise exercise;
  final int sets;
  final int reps;
  final double? weight; // Optional weight in lbs

  const WorkoutExercise({
    required this.exercise,
    required this.sets,
    required this.reps,
    this.weight,
  });

  WorkoutExercise copyWith({
    Exercise? exercise,
    int? sets,
    int? reps,
    double? weight,
    bool clearWeight = false,
  }) {
    return WorkoutExercise(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: clearWeight ? null : (weight ?? this.weight),
    );
  }
}

class Workout {
  final String id;
  final String name;
  final String? description;
  final List<WorkoutExercise> exercises;
  final bool isCustom;

  const Workout({
    required this.id,
    required this.name,
    this.description,
    required this.exercises,
    this.isCustom = false,
  });

  Workout copyWith({
    String? id,
    String? name,
    String? description,
    List<WorkoutExercise>? exercises,
    bool? isCustom,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  int get totalSets =>
      exercises.fold(0, (sum, exercise) => sum + exercise.sets);

  /// Returns unique primary muscle groups from all exercises
  List<MuscleGroup> get primaryMuscles {
    final muscles = exercises.map((e) => e.exercise.primaryMuscle).toSet();
    return muscles.toList();
  }
}
