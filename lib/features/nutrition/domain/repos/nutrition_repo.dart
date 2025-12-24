import '../entities/nutrition_entry.dart';

/// Abstract repository interface for nutrition operations.
abstract class NutritionRepo {
  // Entry operations
  Future<NutritionEntry?> getEntry(DateTime date);
  Future<Map<String, NutritionEntry>> getAllEntries();
  Future<void> saveEntry(NutritionEntry entry);

  // Goals operations
  Future<NutritionGoals> getGoals();
  Future<void> saveGoals(NutritionGoals goals);

  // Meal operations
  Future<List<MealEntry>> getMeals(DateTime date);
  Future<void> addMeal(MealEntry meal);
  Future<void> deleteMeal(String mealId, DateTime date);

  // Clear all data
  Future<void> clearAllData();
}
