/// Entity representing a daily nutrition entry.
class NutritionEntry {
  final DateTime date;
  final int calories;
  final int protein; // grams
  final int carbs; // grams
  final int fat; // grams

  const NutritionEntry({
    required this.date,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  NutritionEntry copyWith({
    DateTime? date,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return NutritionEntry(
      date: date ?? this.date,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  static String dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get key => dateKey(date);

  Map<String, dynamic> toJson() {
    return {
      'date': key,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory NutritionEntry.fromJson(Map<String, dynamic> json) {
    return NutritionEntry(
      date: DateTime.parse(json['date'] as String),
      calories: json['calories'] as int? ?? 0,
      protein: json['protein'] as int? ?? 0,
      carbs: json['carbs'] as int? ?? 0,
      fat: json['fat'] as int? ?? 0,
    );
  }

  factory NutritionEntry.empty(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return NutritionEntry(date: normalized);
  }
}

/// Entity representing nutrition goals.
class NutritionGoals {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const NutritionGoals({
    this.calories = 2000,
    this.protein = 150,
    this.carbs = 200,
    this.fat = 65,
  });

  NutritionGoals copyWith({
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return NutritionGoals(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory NutritionGoals.fromJson(Map<String, dynamic> json) {
    return NutritionGoals(
      calories: json['calories'] as int? ?? 2000,
      protein: json['protein'] as int? ?? 150,
      carbs: json['carbs'] as int? ?? 200,
      fat: json['fat'] as int? ?? 65,
    );
  }
}

/// Entity representing a meal entry.
class MealEntry {
  final String id;
  final String name;
  final int protein;
  final int carbs;
  final int fat;
  final DateTime time;

  const MealEntry({
    required this.id,
    required this.name,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    required this.time,
  });

  /// Auto-calculate calories from macros
  /// Protein: 4 cal/g, Carbs: 4 cal/g, Fat: 9 cal/g
  int get calories => (protein * 4) + (carbs * 4) + (fat * 9);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'time': time.toIso8601String(),
    };
  }

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      protein: json['protein'] as int? ?? 0,
      carbs: json['carbs'] as int? ?? 0,
      fat: json['fat'] as int? ?? 0,
      time: DateTime.parse(json['time'] as String),
    );
  }
}
