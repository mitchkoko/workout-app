import '../models/workout.dart';
import '../models/exercise.dart';
import 'exercise_database.dart';

Exercise _getExercise(String id) {
  return exerciseDatabase.firstWhere((e) => e.id == id);
}

final List<Workout> presetWorkouts = [
  // Push Day
  Workout(
    id: 'push_day',
    name: 'Push Day',
    description: 'Chest, shoulders, and triceps',
    exercises: [
      WorkoutExercise(
        exercise: _getExercise('bench_press'),
        sets: 4,
        reps: 8,
        weight: 135,
      ),
      WorkoutExercise(
        exercise: _getExercise('incline_bench_press'),
        sets: 3,
        reps: 10,
        weight: 115,
      ),
      WorkoutExercise(
        exercise: _getExercise('dumbbell_shoulder_press'),
        sets: 3,
        reps: 10,
        weight: 40,
      ),
      WorkoutExercise(
        exercise: _getExercise('lateral_raise'),
        sets: 3,
        reps: 12,
        weight: 15,
      ),
      WorkoutExercise(
        exercise: _getExercise('tricep_pushdown'),
        sets: 3,
        reps: 12,
        weight: 40,
      ),
      WorkoutExercise(
        exercise: _getExercise('overhead_tricep_extension'),
        sets: 3,
        reps: 12,
        weight: 30,
      ),
    ],
  ),

  // Pull Day
  Workout(
    id: 'pull_day',
    name: 'Pull Day',
    description: 'Back and biceps',
    exercises: [
      WorkoutExercise(
        exercise: _getExercise('deadlift'),
        sets: 4,
        reps: 5,
        weight: 225,
      ),
      WorkoutExercise(
        exercise: _getExercise('barbell_row'),
        sets: 4,
        reps: 8,
        weight: 135,
      ),
      WorkoutExercise(
        exercise: _getExercise('lat_pulldown'),
        sets: 3,
        reps: 10,
        weight: 120,
      ),
      WorkoutExercise(
        exercise: _getExercise('seated_cable_row'),
        sets: 3,
        reps: 10,
        weight: 100,
      ),
      WorkoutExercise(
        exercise: _getExercise('barbell_curl'),
        sets: 3,
        reps: 10,
        weight: 65,
      ),
      WorkoutExercise(
        exercise: _getExercise('hammer_curl'),
        sets: 3,
        reps: 10,
        weight: 30,
      ),
    ],
  ),

  // Leg Day
  Workout(
    id: 'leg_day',
    name: 'Leg Day',
    description: 'Quads, hamstrings, glutes, and calves',
    exercises: [
      WorkoutExercise(
        exercise: _getExercise('squat'),
        sets: 4,
        reps: 6,
        weight: 185,
      ),
      WorkoutExercise(
        exercise: _getExercise('leg_press'),
        sets: 3,
        reps: 10,
        weight: 270,
      ),
      WorkoutExercise(
        exercise: _getExercise('romanian_deadlift'),
        sets: 3,
        reps: 10,
        weight: 135,
      ),
      WorkoutExercise(
        exercise: _getExercise('leg_extension'),
        sets: 3,
        reps: 12,
        weight: 90,
      ),
      WorkoutExercise(
        exercise: _getExercise('leg_curl'),
        sets: 3,
        reps: 12,
        weight: 70,
      ),
      WorkoutExercise(
        exercise: _getExercise('standing_calf_raise'),
        sets: 4,
        reps: 15,
        weight: 100,
      ),
    ],
  ),

  // Upper Body
  Workout(
    id: 'upper_body',
    name: 'Upper Body',
    description: 'Full upper body workout',
    exercises: [
      WorkoutExercise(
        exercise: _getExercise('bench_press'),
        sets: 4,
        reps: 8,
        weight: 135,
      ),
      WorkoutExercise(
        exercise: _getExercise('barbell_row'),
        sets: 4,
        reps: 8,
        weight: 135,
      ),
      WorkoutExercise(
        exercise: _getExercise('overhead_press'),
        sets: 3,
        reps: 8,
        weight: 95,
      ),
      WorkoutExercise(
        exercise: _getExercise('lat_pulldown'),
        sets: 3,
        reps: 10,
        weight: 120,
      ),
      WorkoutExercise(
        exercise: _getExercise('dumbbell_curl'),
        sets: 3,
        reps: 10,
        weight: 25,
      ),
      WorkoutExercise(
        exercise: _getExercise('tricep_pushdown'),
        sets: 3,
        reps: 10,
        weight: 40,
      ),
    ],
  ),

  // Lower Body
  Workout(
    id: 'lower_body',
    name: 'Lower Body',
    description: 'Full lower body workout',
    exercises: [
      WorkoutExercise(
        exercise: _getExercise('squat'),
        sets: 4,
        reps: 8,
        weight: 185,
      ),
      WorkoutExercise(
        exercise: _getExercise('romanian_deadlift'),
        sets: 3,
        reps: 10,
        weight: 135,
      ),
      WorkoutExercise(
        exercise: _getExercise('bulgarian_split_squat'),
        sets: 3,
        reps: 10,
        weight: 40,
      ),
      WorkoutExercise(
        exercise: _getExercise('leg_curl'),
        sets: 3,
        reps: 12,
        weight: 70,
      ),
      WorkoutExercise(
        exercise: _getExercise('hip_thrust'),
        sets: 3,
        reps: 10,
        weight: 135,
      ),
      WorkoutExercise(
        exercise: _getExercise('standing_calf_raise'),
        sets: 4,
        reps: 15,
        weight: 100,
      ),
    ],
  ),

  // Full Body
  Workout(
    id: 'full_body',
    name: 'Full Body',
    description: 'Complete full body workout',
    exercises: [
      WorkoutExercise(
        exercise: _getExercise('squat'),
        sets: 3,
        reps: 8,
        weight: 155,
      ),
      WorkoutExercise(
        exercise: _getExercise('bench_press'),
        sets: 3,
        reps: 8,
        weight: 135,
      ),
      WorkoutExercise(
        exercise: _getExercise('barbell_row'),
        sets: 3,
        reps: 8,
        weight: 115,
      ),
      WorkoutExercise(
        exercise: _getExercise('overhead_press'),
        sets: 3,
        reps: 8,
        weight: 85,
      ),
      WorkoutExercise(
        exercise: _getExercise('romanian_deadlift'),
        sets: 3,
        reps: 10,
        weight: 115,
      ),
      WorkoutExercise(
        exercise: _getExercise('plank'),
        sets: 3,
        reps: 45, // seconds
      ),
    ],
  ),

  // Core Workout
  Workout(
    id: 'core_workout',
    name: 'Core Workout',
    description: 'Abdominal and core focus',
    exercises: [
      WorkoutExercise(
        exercise: _getExercise('plank'),
        sets: 3,
        reps: 45, // seconds
      ),
      WorkoutExercise(
        exercise: _getExercise('crunch'),
        sets: 3,
        reps: 20,
      ),
      WorkoutExercise(
        exercise: _getExercise('hanging_leg_raise'),
        sets: 3,
        reps: 12,
      ),
      WorkoutExercise(
        exercise: _getExercise('russian_twist'),
        sets: 3,
        reps: 20,
        weight: 15,
      ),
      WorkoutExercise(
        exercise: _getExercise('mountain_climber'),
        sets: 3,
        reps: 20,
      ),
    ],
  ),

  // Chest & Triceps
  Workout(
    id: 'chest_triceps',
    name: 'Chest & Triceps',
    description: 'Focused chest and triceps workout',
    exercises: [
      WorkoutExercise(
        exercise: _getExercise('bench_press'),
        sets: 4,
        reps: 8,
        weight: 135,
      ),
      WorkoutExercise(
        exercise: _getExercise('incline_bench_press'),
        sets: 3,
        reps: 10,
        weight: 115,
      ),
      WorkoutExercise(
        exercise: _getExercise('dumbbell_fly'),
        sets: 3,
        reps: 12,
        weight: 30,
      ),
      WorkoutExercise(
        exercise: _getExercise('cable_crossover'),
        sets: 3,
        reps: 12,
        weight: 30,
      ),
      WorkoutExercise(
        exercise: _getExercise('close_grip_bench'),
        sets: 3,
        reps: 10,
        weight: 115,
      ),
      WorkoutExercise(
        exercise: _getExercise('skull_crusher'),
        sets: 3,
        reps: 10,
        weight: 50,
      ),
      WorkoutExercise(
        exercise: _getExercise('tricep_pushdown'),
        sets: 3,
        reps: 12,
        weight: 40,
      ),
    ],
  ),

  // Back & Biceps
  Workout(
    id: 'back_biceps',
    name: 'Back & Biceps',
    description: 'Focused back and biceps workout',
    exercises: [
      WorkoutExercise(
        exercise: _getExercise('pull_up'),
        sets: 4,
        reps: 8,
      ),
      WorkoutExercise(
        exercise: _getExercise('barbell_row'),
        sets: 4,
        reps: 8,
        weight: 135,
      ),
      WorkoutExercise(
        exercise: _getExercise('dumbbell_row'),
        sets: 3,
        reps: 10,
        weight: 50,
      ),
      WorkoutExercise(
        exercise: _getExercise('lat_pulldown'),
        sets: 3,
        reps: 10,
        weight: 120,
      ),
      WorkoutExercise(
        exercise: _getExercise('barbell_curl'),
        sets: 3,
        reps: 10,
        weight: 65,
      ),
      WorkoutExercise(
        exercise: _getExercise('incline_curl'),
        sets: 3,
        reps: 10,
        weight: 25,
      ),
      WorkoutExercise(
        exercise: _getExercise('hammer_curl'),
        sets: 3,
        reps: 10,
        weight: 30,
      ),
    ],
  ),
];
