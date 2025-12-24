enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  core,
  quads,
  hamstrings,
  glutes,
  calves,
  fullBody,
}

enum Equipment {
  barbell,
  dumbbell,
  cable,
  machine,
  bodyweight,
  kettlebell,
  resistanceBand,
  ezBar,
  smithMachine,
  pullupBar,
  bench,
}

class Exercise {
  final String id;
  final String name;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final Equipment equipment;
  final String instructions;

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    required this.equipment,
    required this.instructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryMuscle': primaryMuscle.name,
      'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
      'equipment': equipment.name,
      'instructions': instructions,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      primaryMuscle: MuscleGroup.values.firstWhere(
        (m) => m.name == json['primaryMuscle'],
      ),
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>)
          .map((m) => MuscleGroup.values.firstWhere((mg) => mg.name == m))
          .toList(),
      equipment: Equipment.values.firstWhere(
        (e) => e.name == json['equipment'],
      ),
      instructions: json['instructions'] as String,
    );
  }
}

extension MuscleGroupExtension on MuscleGroup {
  String get displayName {
    switch (this) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.quads:
        return 'Quads';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.fullBody:
        return 'Full Body';
    }
  }
}

extension EquipmentExtension on Equipment {
  String get displayName {
    switch (this) {
      case Equipment.barbell:
        return 'Barbell';
      case Equipment.dumbbell:
        return 'Dumbbell';
      case Equipment.cable:
        return 'Cable';
      case Equipment.machine:
        return 'Machine';
      case Equipment.bodyweight:
        return 'Bodyweight';
      case Equipment.kettlebell:
        return 'Kettlebell';
      case Equipment.resistanceBand:
        return 'Resistance Band';
      case Equipment.ezBar:
        return 'EZ Bar';
      case Equipment.smithMachine:
        return 'Smith Machine';
      case Equipment.pullupBar:
        return 'Pull-up Bar';
      case Equipment.bench:
        return 'Bench';
    }
  }
}
