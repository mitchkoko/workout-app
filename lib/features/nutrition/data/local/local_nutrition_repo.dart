import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../domain/entities/nutrition_entry.dart';
import '../../domain/repos/nutrition_repo.dart';

/// Local implementation of NutritionRepo using Hive for persistence.
class LocalNutritionRepo implements NutritionRepo {
  static const String _nutritionBoxName = 'nutrition';

  static const String _entriesKey = 'entries';
  static const String _goalsKey = 'goals';
  static const String _mealsKey = 'meals';

  Box? _box;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_nutritionBoxName)) {
      _box = await Hive.openBox(_nutritionBoxName);
    } else {
      _box = Hive.box(_nutritionBoxName);
    }
    _isInitialized = true;
  }

  void _ensureInitialized() {
    if (!_isInitialized || _box == null) {
      throw StateError('LocalNutritionRepo not initialized. Call initialize() first.');
    }
  }

  // ============================================================
  // ENTRY OPERATIONS
  // ============================================================

  @override
  Future<NutritionEntry?> getEntry(DateTime date) async {
    _ensureInitialized();

    try {
      final dateKey = NutritionEntry.dateKey(date);
      final data = _box!.get(_entriesKey);
      if (data == null) return null;

      final entries = data as Map<dynamic, dynamic>;
      final entryData = entries[dateKey];
      if (entryData == null) return null;

      return NutritionEntry.fromJson(Map<String, dynamic>.from(entryData));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, NutritionEntry>> getAllEntries() async {
    _ensureInitialized();

    try {
      final data = _box!.get(_entriesKey);
      if (data == null) return {};

      final entries = data as Map<dynamic, dynamic>;
      final result = <String, NutritionEntry>{};

      for (final entry in entries.entries) {
        result[entry.key as String] =
            NutritionEntry.fromJson(Map<String, dynamic>.from(entry.value));
      }

      return result;
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> saveEntry(NutritionEntry entry) async {
    _ensureInitialized();

    try {
      final existing = _box!.get(_entriesKey);
      final entries = existing != null
          ? Map<String, dynamic>.from(existing as Map<dynamic, dynamic>)
          : <String, dynamic>{};

      entries[entry.key] = entry.toJson();
      await _box!.put(_entriesKey, entries);
    } catch (e) {
      throw Exception('Failed to save nutrition entry: $e');
    }
  }

  // ============================================================
  // GOALS OPERATIONS
  // ============================================================

  @override
  Future<NutritionGoals> getGoals() async {
    _ensureInitialized();

    try {
      final data = _box!.get(_goalsKey);
      if (data == null) return const NutritionGoals();

      return NutritionGoals.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      return const NutritionGoals();
    }
  }

  @override
  Future<void> saveGoals(NutritionGoals goals) async {
    _ensureInitialized();

    try {
      await _box!.put(_goalsKey, goals.toJson());
    } catch (e) {
      throw Exception('Failed to save nutrition goals: $e');
    }
  }

  // ============================================================
  // MEAL OPERATIONS
  // ============================================================

  @override
  Future<List<MealEntry>> getMeals(DateTime date) async {
    _ensureInitialized();

    try {
      final dateKey = NutritionEntry.dateKey(date);
      final data = _box!.get(_mealsKey);
      if (data == null) return [];

      final allMeals = data as Map<dynamic, dynamic>;
      final dayMeals = allMeals[dateKey];
      if (dayMeals == null) return [];

      return (dayMeals as List<dynamic>)
          .map((m) => MealEntry.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addMeal(MealEntry meal) async {
    _ensureInitialized();

    try {
      final dateKey = NutritionEntry.dateKey(meal.time);
      final existing = _box!.get(_mealsKey);
      final allMeals = existing != null
          ? Map<String, dynamic>.from(existing as Map<dynamic, dynamic>)
          : <String, dynamic>{};

      final dayMeals = allMeals[dateKey] != null
          ? List<Map<String, dynamic>>.from(
              (allMeals[dateKey] as List<dynamic>)
                  .map((m) => Map<String, dynamic>.from(m)),
            )
          : <Map<String, dynamic>>[];

      dayMeals.add(meal.toJson());
      allMeals[dateKey] = dayMeals;
      await _box!.put(_mealsKey, allMeals);

      // Update the daily totals
      await _updateDailyTotals(dateKey, dayMeals);
    } catch (e) {
      throw Exception('Failed to add meal: $e');
    }
  }

  @override
  Future<void> deleteMeal(String mealId, DateTime date) async {
    _ensureInitialized();

    try {
      final dateKey = NutritionEntry.dateKey(date);
      final existing = _box!.get(_mealsKey);
      if (existing == null) return;

      final allMeals = Map<String, dynamic>.from(existing as Map<dynamic, dynamic>);
      final dayMeals = allMeals[dateKey] != null
          ? List<Map<String, dynamic>>.from(
              (allMeals[dateKey] as List<dynamic>)
                  .map((m) => Map<String, dynamic>.from(m)),
            )
          : <Map<String, dynamic>>[];

      dayMeals.removeWhere((m) => m['id'] == mealId);
      allMeals[dateKey] = dayMeals;
      await _box!.put(_mealsKey, allMeals);

      // Update the daily totals
      await _updateDailyTotals(dateKey, dayMeals);
    } catch (e) {
      throw Exception('Failed to delete meal: $e');
    }
  }

  Future<void> _updateDailyTotals(
    String dateKey,
    List<Map<String, dynamic>> meals,
  ) async {
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    for (final meal in meals) {
      totalProtein += meal['protein'] as int? ?? 0;
      totalCarbs += meal['carbs'] as int? ?? 0;
      totalFat += meal['fat'] as int? ?? 0;
    }

    // Calculate calories from macros: P*4 + C*4 + F*9
    final totalCalories = (totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9);

    final entry = NutritionEntry(
      date: DateTime.parse(dateKey),
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
    );

    await saveEntry(entry);
  }

  // ============================================================
  // CLEAR ALL DATA
  // ============================================================

  @override
  Future<void> clearAllData() async {
    _ensureInitialized();

    try {
      await _box!.delete(_entriesKey);
      await _box!.delete(_mealsKey);
      // Keep goals as they represent user preferences
    } catch (e) {
      throw Exception('Failed to clear nutrition data: $e');
    }
  }
}
