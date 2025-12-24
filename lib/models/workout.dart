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

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exercise: Exercise.fromJson(Map<String, dynamic>.from(json['exercise'])),
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      weight: json['weight'] as double?,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'isCustom': isCustom,
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => WorkoutExercise.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }
}
