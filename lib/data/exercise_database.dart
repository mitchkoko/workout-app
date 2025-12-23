import '../models/exercise.dart';

final List<Exercise> exerciseDatabase = [
  // CHEST EXERCISES
  const Exercise(
    id: 'bench_press',
    name: 'Barbell Bench Press',
    primaryMuscle: MuscleGroup.chest,
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    equipment: Equipment.barbell,
    instructions:
        'Lie on a flat bench, grip the barbell slightly wider than shoulder-width. Lower the bar to your mid-chest, then press back up to full arm extension.',
  ),
  const Exercise(
    id: 'incline_bench_press',
    name: 'Incline Bench Press',
    primaryMuscle: MuscleGroup.chest,
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    equipment: Equipment.barbell,
    instructions:
        'Set bench to 30-45 degree incline. Lower the bar to your upper chest, then press back up.',
  ),
  const Exercise(
    id: 'dumbbell_press',
    name: 'Dumbbell Chest Press',
    primaryMuscle: MuscleGroup.chest,
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    equipment: Equipment.dumbbell,
    instructions:
        'Lie on a flat bench holding dumbbells at chest level. Press the weights up until arms are extended, then lower back down.',
  ),
  const Exercise(
    id: 'dumbbell_fly',
    name: 'Dumbbell Fly',
    primaryMuscle: MuscleGroup.chest,
    equipment: Equipment.dumbbell,
    instructions:
        'Lie on a flat bench with dumbbells above your chest, palms facing each other. Lower the weights in an arc until you feel a stretch, then bring them back together.',
  ),
  const Exercise(
    id: 'cable_crossover',
    name: 'Cable Crossover',
    primaryMuscle: MuscleGroup.chest,
    equipment: Equipment.cable,
    instructions:
        'Stand between two cable stations with handles set high. Pull the handles down and together in front of your body, squeezing your chest.',
  ),
  const Exercise(
    id: 'push_up',
    name: 'Push-Up',
    primaryMuscle: MuscleGroup.chest,
    secondaryMuscles: [
      MuscleGroup.triceps,
      MuscleGroup.shoulders,
      MuscleGroup.core,
    ],
    equipment: Equipment.bodyweight,
    instructions:
        'Start in a plank position with hands slightly wider than shoulders. Lower your body until chest nearly touches the floor, then push back up.',
  ),
  const Exercise(
    id: 'chest_dip',
    name: 'Chest Dip',
    primaryMuscle: MuscleGroup.chest,
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    equipment: Equipment.bodyweight,
    instructions:
        'Grip parallel bars and lean forward slightly. Lower your body until you feel a stretch in your chest, then push back up.',
  ),

  // BACK EXERCISES
  const Exercise(
    id: 'deadlift',
    name: 'Deadlift',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscles: [
      MuscleGroup.hamstrings,
      MuscleGroup.glutes,
      MuscleGroup.core,
    ],
    equipment: Equipment.barbell,
    instructions:
        'Stand with feet hip-width apart, barbell over mid-foot. Hinge at hips, grip the bar, and lift by driving through your heels and extending hips and knees.',
  ),
  const Exercise(
    id: 'barbell_row',
    name: 'Barbell Row',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscles: [MuscleGroup.biceps],
    equipment: Equipment.barbell,
    instructions:
        'Hinge forward at the hips, keeping back flat. Pull the barbell to your lower chest, squeezing your shoulder blades together, then lower.',
  ),
  const Exercise(
    id: 'pull_up',
    name: 'Pull-Up',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscles: [MuscleGroup.biceps],
    equipment: Equipment.pullupBar,
    instructions:
        'Hang from a bar with overhand grip, hands wider than shoulders. Pull yourself up until chin is over the bar, then lower with control.',
  ),
  const Exercise(
    id: 'lat_pulldown',
    name: 'Lat Pulldown',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscles: [MuscleGroup.biceps],
    equipment: Equipment.cable,
    instructions:
        'Sit at a lat pulldown machine, grip the bar wide. Pull the bar down to your upper chest, squeezing your lats, then return with control.',
  ),
  const Exercise(
    id: 'dumbbell_row',
    name: 'Dumbbell Row',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscles: [MuscleGroup.biceps],
    equipment: Equipment.dumbbell,
    instructions:
        'Place one knee and hand on a bench, hold a dumbbell in the other hand. Pull the weight to your hip, then lower.',
  ),
  const Exercise(
    id: 'seated_cable_row',
    name: 'Seated Cable Row',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscles: [MuscleGroup.biceps],
    equipment: Equipment.cable,
    instructions:
        'Sit at a cable row machine with feet on the platform. Pull the handle to your midsection, squeezing your back, then extend arms.',
  ),
  const Exercise(
    id: 't_bar_row',
    name: 'T-Bar Row',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscles: [MuscleGroup.biceps],
    equipment: Equipment.barbell,
    instructions:
        'Straddle the T-bar, grip the handles, and hinge forward. Pull the weight to your chest, then lower with control.',
  ),

  // SHOULDER EXERCISES
  const Exercise(
    id: 'overhead_press',
    name: 'Overhead Press',
    primaryMuscle: MuscleGroup.shoulders,
    secondaryMuscles: [MuscleGroup.triceps],
    equipment: Equipment.barbell,
    instructions:
        'Stand with barbell at shoulder level. Press the weight overhead until arms are fully extended, then lower back to shoulders.',
  ),
  const Exercise(
    id: 'dumbbell_shoulder_press',
    name: 'Dumbbell Shoulder Press',
    primaryMuscle: MuscleGroup.shoulders,
    secondaryMuscles: [MuscleGroup.triceps],
    equipment: Equipment.dumbbell,
    instructions:
        'Sit or stand holding dumbbells at shoulder height. Press the weights overhead, then lower back down.',
  ),
  const Exercise(
    id: 'lateral_raise',
    name: 'Lateral Raise',
    primaryMuscle: MuscleGroup.shoulders,
    equipment: Equipment.dumbbell,
    instructions:
        'Stand with dumbbells at your sides. Raise your arms out to the sides until parallel to the floor, then lower.',
  ),
  const Exercise(
    id: 'front_raise',
    name: 'Front Raise',
    primaryMuscle: MuscleGroup.shoulders,
    equipment: Equipment.dumbbell,
    instructions:
        'Stand holding dumbbells in front of your thighs. Raise one or both arms forward to shoulder height, then lower.',
  ),
  const Exercise(
    id: 'rear_delt_fly',
    name: 'Rear Delt Fly',
    primaryMuscle: MuscleGroup.shoulders,
    equipment: Equipment.dumbbell,
    instructions:
        'Bend forward at the hips, arms hanging down. Raise the dumbbells out to the sides, squeezing your rear delts, then lower.',
  ),
  const Exercise(
    id: 'face_pull',
    name: 'Face Pull',
    primaryMuscle: MuscleGroup.shoulders,
    secondaryMuscles: [MuscleGroup.back],
    equipment: Equipment.cable,
    instructions:
        'Set cable to face height with rope attachment. Pull the rope towards your face, separating the ends, then return.',
  ),
  const Exercise(
    id: 'arnold_press',
    name: 'Arnold Press',
    primaryMuscle: MuscleGroup.shoulders,
    secondaryMuscles: [MuscleGroup.triceps],
    equipment: Equipment.dumbbell,
    instructions:
        'Start with dumbbells in front of shoulders, palms facing you. Rotate palms outward as you press overhead, then reverse.',
  ),

  // BICEPS EXERCISES
  const Exercise(
    id: 'barbell_curl',
    name: 'Barbell Curl',
    primaryMuscle: MuscleGroup.biceps,
    equipment: Equipment.barbell,
    instructions:
        'Stand holding a barbell with underhand grip. Curl the weight up to shoulder level, then lower with control.',
  ),
  const Exercise(
    id: 'dumbbell_curl',
    name: 'Dumbbell Curl',
    primaryMuscle: MuscleGroup.biceps,
    equipment: Equipment.dumbbell,
    instructions:
        'Stand holding dumbbells at your sides, palms forward. Curl the weights up, then lower with control.',
  ),
  const Exercise(
    id: 'hammer_curl',
    name: 'Hammer Curl',
    primaryMuscle: MuscleGroup.biceps,
    secondaryMuscles: [MuscleGroup.forearms],
    equipment: Equipment.dumbbell,
    instructions:
        'Stand holding dumbbells with palms facing each other. Curl the weights up while maintaining the neutral grip, then lower.',
  ),
  const Exercise(
    id: 'preacher_curl',
    name: 'Preacher Curl',
    primaryMuscle: MuscleGroup.biceps,
    equipment: Equipment.ezBar,
    instructions:
        'Sit at a preacher bench with arms over the pad. Curl the weight up, then lower with control.',
  ),
  const Exercise(
    id: 'incline_curl',
    name: 'Incline Dumbbell Curl',
    primaryMuscle: MuscleGroup.biceps,
    equipment: Equipment.dumbbell,
    instructions:
        'Lie on an incline bench holding dumbbells, arms hanging down. Curl the weights up, then lower.',
  ),
  const Exercise(
    id: 'cable_curl',
    name: 'Cable Curl',
    primaryMuscle: MuscleGroup.biceps,
    equipment: Equipment.cable,
    instructions:
        'Stand at a low cable with bar attachment. Curl the weight up to shoulder level, then lower with control.',
  ),

  // TRICEPS EXERCISES
  const Exercise(
    id: 'tricep_pushdown',
    name: 'Tricep Pushdown',
    primaryMuscle: MuscleGroup.triceps,
    equipment: Equipment.cable,
    instructions:
        'Stand at a high cable with bar or rope attachment. Push the weight down until arms are straight, then return.',
  ),
  const Exercise(
    id: 'skull_crusher',
    name: 'Skull Crusher',
    primaryMuscle: MuscleGroup.triceps,
    equipment: Equipment.ezBar,
    instructions:
        'Lie on a bench holding an EZ bar above your chest. Lower the weight towards your forehead by bending elbows, then extend.',
  ),
  const Exercise(
    id: 'overhead_tricep_extension',
    name: 'Overhead Tricep Extension',
    primaryMuscle: MuscleGroup.triceps,
    equipment: Equipment.dumbbell,
    instructions:
        'Hold a dumbbell overhead with both hands. Lower the weight behind your head by bending elbows, then extend.',
  ),
  const Exercise(
    id: 'close_grip_bench',
    name: 'Close Grip Bench Press',
    primaryMuscle: MuscleGroup.triceps,
    secondaryMuscles: [MuscleGroup.chest],
    equipment: Equipment.barbell,
    instructions:
        'Lie on a bench, grip barbell with hands shoulder-width apart. Lower to chest and press back up.',
  ),
  const Exercise(
    id: 'tricep_dip',
    name: 'Tricep Dip',
    primaryMuscle: MuscleGroup.triceps,
    secondaryMuscles: [MuscleGroup.chest, MuscleGroup.shoulders],
    equipment: Equipment.bodyweight,
    instructions:
        'Grip parallel bars with body upright. Lower yourself by bending elbows, then push back up.',
  ),
  const Exercise(
    id: 'kickback',
    name: 'Tricep Kickback',
    primaryMuscle: MuscleGroup.triceps,
    equipment: Equipment.dumbbell,
    instructions:
        'Hinge forward, upper arm parallel to floor. Extend your forearm back until arm is straight, then lower.',
  ),

  // QUAD EXERCISES
  const Exercise(
    id: 'squat',
    name: 'Barbell Squat',
    primaryMuscle: MuscleGroup.quads,
    secondaryMuscles: [
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
      MuscleGroup.core,
    ],
    equipment: Equipment.barbell,
    instructions:
        'Place barbell on upper back. Squat down by bending knees and hips until thighs are parallel, then stand back up.',
  ),
  const Exercise(
    id: 'front_squat',
    name: 'Front Squat',
    primaryMuscle: MuscleGroup.quads,
    secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.core],
    equipment: Equipment.barbell,
    instructions:
        'Hold barbell across front shoulders. Squat down keeping torso upright, then stand back up.',
  ),
  const Exercise(
    id: 'leg_press',
    name: 'Leg Press',
    primaryMuscle: MuscleGroup.quads,
    secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
    equipment: Equipment.machine,
    instructions:
        'Sit in leg press machine with feet shoulder-width on platform. Lower the weight by bending knees, then press back up.',
  ),
  const Exercise(
    id: 'leg_extension',
    name: 'Leg Extension',
    primaryMuscle: MuscleGroup.quads,
    equipment: Equipment.machine,
    instructions:
        'Sit in the machine with ankles behind the pad. Extend your legs until straight, then lower with control.',
  ),
  const Exercise(
    id: 'lunge',
    name: 'Lunge',
    primaryMuscle: MuscleGroup.quads,
    secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
    equipment: Equipment.bodyweight,
    instructions:
        'Step forward into a lunge position, lowering until both knees are at 90 degrees. Push back to starting position.',
  ),
  const Exercise(
    id: 'goblet_squat',
    name: 'Goblet Squat',
    primaryMuscle: MuscleGroup.quads,
    secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.core],
    equipment: Equipment.dumbbell,
    instructions:
        'Hold a dumbbell at chest level. Squat down keeping chest up, then stand back up.',
  ),
  const Exercise(
    id: 'bulgarian_split_squat',
    name: 'Bulgarian Split Squat',
    primaryMuscle: MuscleGroup.quads,
    secondaryMuscles: [MuscleGroup.glutes],
    equipment: Equipment.dumbbell,
    instructions:
        'Place rear foot on bench behind you. Lower into a lunge until front thigh is parallel, then push back up.',
  ),

  // HAMSTRING EXERCISES
  const Exercise(
    id: 'romanian_deadlift',
    name: 'Romanian Deadlift',
    primaryMuscle: MuscleGroup.hamstrings,
    secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.back],
    equipment: Equipment.barbell,
    instructions:
        'Stand holding barbell at hip level. Hinge at hips, lowering the bar along your legs while keeping them nearly straight. Return to standing.',
  ),
  const Exercise(
    id: 'leg_curl',
    name: 'Leg Curl',
    primaryMuscle: MuscleGroup.hamstrings,
    equipment: Equipment.machine,
    instructions:
        'Lie face down on leg curl machine. Curl your heels towards your glutes, then lower with control.',
  ),
  const Exercise(
    id: 'stiff_leg_deadlift',
    name: 'Stiff Leg Deadlift',
    primaryMuscle: MuscleGroup.hamstrings,
    secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.back],
    equipment: Equipment.barbell,
    instructions:
        'Stand holding barbell with legs straight. Hinge forward at hips until you feel a stretch, then return.',
  ),
  const Exercise(
    id: 'good_morning',
    name: 'Good Morning',
    primaryMuscle: MuscleGroup.hamstrings,
    secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.back],
    equipment: Equipment.barbell,
    instructions:
        'Place barbell on upper back. Hinge forward at hips, keeping back flat, then return to standing.',
  ),

  // GLUTE EXERCISES
  const Exercise(
    id: 'hip_thrust',
    name: 'Hip Thrust',
    primaryMuscle: MuscleGroup.glutes,
    secondaryMuscles: [MuscleGroup.hamstrings],
    equipment: Equipment.barbell,
    instructions:
        'Sit with upper back against bench, barbell over hips. Drive hips up by squeezing glutes, then lower.',
  ),
  const Exercise(
    id: 'glute_bridge',
    name: 'Glute Bridge',
    primaryMuscle: MuscleGroup.glutes,
    secondaryMuscles: [MuscleGroup.hamstrings],
    equipment: Equipment.bodyweight,
    instructions:
        'Lie on your back with knees bent, feet flat. Lift hips by squeezing glutes, then lower.',
  ),
  const Exercise(
    id: 'cable_kickback',
    name: 'Cable Kickback',
    primaryMuscle: MuscleGroup.glutes,
    equipment: Equipment.cable,
    instructions:
        'Attach ankle strap to low cable. Kick your leg straight back, squeezing glutes, then return.',
  ),
  const Exercise(
    id: 'sumo_deadlift',
    name: 'Sumo Deadlift',
    primaryMuscle: MuscleGroup.glutes,
    secondaryMuscles: [
      MuscleGroup.quads,
      MuscleGroup.hamstrings,
      MuscleGroup.back,
    ],
    equipment: Equipment.barbell,
    instructions:
        'Stand with wide stance, toes pointed out. Grip bar between legs and lift by driving hips forward.',
  ),

  // CALF EXERCISES
  const Exercise(
    id: 'standing_calf_raise',
    name: 'Standing Calf Raise',
    primaryMuscle: MuscleGroup.calves,
    equipment: Equipment.machine,
    instructions:
        'Stand on calf raise machine with shoulders under pads. Rise onto toes, then lower heels below platform.',
  ),
  const Exercise(
    id: 'seated_calf_raise',
    name: 'Seated Calf Raise',
    primaryMuscle: MuscleGroup.calves,
    equipment: Equipment.machine,
    instructions:
        'Sit in calf raise machine with pad on thighs. Rise onto toes, then lower with control.',
  ),

  // CORE EXERCISES
  const Exercise(
    id: 'plank',
    name: 'Plank',
    primaryMuscle: MuscleGroup.core,
    equipment: Equipment.bodyweight,
    instructions:
        'Hold a push-up position with forearms on the ground. Keep body straight and hold position.',
  ),
  const Exercise(
    id: 'crunch',
    name: 'Crunch',
    primaryMuscle: MuscleGroup.core,
    equipment: Equipment.bodyweight,
    instructions:
        'Lie on your back with knees bent. Curl your shoulders off the floor, then lower.',
  ),
  const Exercise(
    id: 'hanging_leg_raise',
    name: 'Hanging Leg Raise',
    primaryMuscle: MuscleGroup.core,
    equipment: Equipment.pullupBar,
    instructions:
        'Hang from a bar with arms extended. Raise legs until parallel to floor, then lower with control.',
  ),
  const Exercise(
    id: 'cable_crunch',
    name: 'Cable Crunch',
    primaryMuscle: MuscleGroup.core,
    equipment: Equipment.cable,
    instructions:
        'Kneel at a high cable with rope attachment. Crunch down, bringing elbows towards knees, then return.',
  ),
  const Exercise(
    id: 'russian_twist',
    name: 'Russian Twist',
    primaryMuscle: MuscleGroup.core,
    equipment: Equipment.bodyweight,
    instructions:
        'Sit with knees bent, lean back slightly. Rotate your torso side to side, touching the floor on each side.',
  ),
  const Exercise(
    id: 'ab_wheel_rollout',
    name: 'Ab Wheel Rollout',
    primaryMuscle: MuscleGroup.core,
    equipment: Equipment.bodyweight,
    instructions:
        'Kneel holding an ab wheel. Roll forward extending your body, then pull back to starting position.',
  ),
  const Exercise(
    id: 'mountain_climber',
    name: 'Mountain Climber',
    primaryMuscle: MuscleGroup.core,
    secondaryMuscles: [MuscleGroup.shoulders],
    equipment: Equipment.bodyweight,
    instructions:
        'Start in push-up position. Alternate driving knees towards chest in a running motion.',
  ),
];
