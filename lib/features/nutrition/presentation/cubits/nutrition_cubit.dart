import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/nutrition_entry.dart';
import '../../domain/repos/nutrition_repo.dart';
import 'nutrition_states.dart';

/// Cubit managing nutrition state and operations.
class NutritionCubit extends Cubit<NutritionState> {
  final NutritionRepo repo;

  NutritionCubit({required this.repo}) : super(NutritionInitial());

  /// Load all nutrition data.
  Future<void> loadNutrition() async {
    try {
      emit(NutritionLoading());

      final entries = await repo.getAllEntries();
      final goals = await repo.getGoals();
      final today = DateTime.now();
      final meals = await repo.getMeals(today);

      emit(NutritionLoaded(
        entries: entries,
        goals: goals,
        selectedDateMeals: meals,
        selectedDate: DateTime(today.year, today.month, today.day),
      ));
    } catch (e) {
      emit(NutritionError('Failed to load nutrition data: $e'));
    }
  }

  /// Select a date to view.
  Future<void> selectDate(DateTime date) async {
    final currentState = state;
    if (currentState is! NutritionLoaded) return;

    try {
      final normalized = DateTime(date.year, date.month, date.day);
      final meals = await repo.getMeals(normalized);

      emit(currentState.copyWith(
        selectedDate: normalized,
        selectedDateMeals: meals,
      ));
    } catch (e) {
      emit(NutritionError('Failed to select date: $e'));
    }
  }

  /// Add a meal.
  Future<void> addMeal(MealEntry meal) async {
    final currentState = state;
    if (currentState is! NutritionLoaded) {
      emit(NutritionError('Cannot add meal: invalid state'));
      return;
    }

    try {
      // Optimistic update
      final updatedMeals = [...currentState.selectedDateMeals, meal];

      // Calculate new totals
      final dateKey = NutritionEntry.dateKey(meal.time);
      final existingEntry = currentState.entries[dateKey];
      final newEntry = NutritionEntry(
        date: meal.time,
        calories: (existingEntry?.calories ?? 0) + meal.calories,
        protein: (existingEntry?.protein ?? 0) + meal.protein,
        carbs: (existingEntry?.carbs ?? 0) + meal.carbs,
        fat: (existingEntry?.fat ?? 0) + meal.fat,
      );

      final updatedEntries = Map<String, NutritionEntry>.from(currentState.entries);
      updatedEntries[dateKey] = newEntry;

      emit(currentState.copyWith(
        entries: updatedEntries,
        selectedDateMeals: updatedMeals,
      ));

      // Persist
      await repo.addMeal(meal);
    } catch (e) {
      emit(currentState);
      emit(NutritionError('Failed to add meal: $e'));
    }
  }

  /// Delete a meal.
  Future<void> deleteMeal(String mealId) async {
    final currentState = state;
    if (currentState is! NutritionLoaded) {
      emit(NutritionError('Cannot delete meal: invalid state'));
      return;
    }

    try {
      final mealToDelete = currentState.selectedDateMeals.firstWhere(
        (m) => m.id == mealId,
      );

      // Optimistic update
      final updatedMeals = currentState.selectedDateMeals
          .where((m) => m.id != mealId)
          .toList();

      // Calculate new totals
      final dateKey = NutritionEntry.dateKey(currentState.selectedDate);
      final existingEntry = currentState.entries[dateKey];
      if (existingEntry != null) {
        final newEntry = existingEntry.copyWith(
          calories: existingEntry.calories - mealToDelete.calories,
          protein: existingEntry.protein - mealToDelete.protein,
          carbs: existingEntry.carbs - mealToDelete.carbs,
          fat: existingEntry.fat - mealToDelete.fat,
        );

        final updatedEntries = Map<String, NutritionEntry>.from(currentState.entries);
        updatedEntries[dateKey] = newEntry;

        emit(currentState.copyWith(
          entries: updatedEntries,
          selectedDateMeals: updatedMeals,
        ));
      } else {
        emit(currentState.copyWith(selectedDateMeals: updatedMeals));
      }

      // Persist
      await repo.deleteMeal(mealId, currentState.selectedDate);
    } catch (e) {
      emit(currentState);
      emit(NutritionError('Failed to delete meal: $e'));
    }
  }

  /// Update nutrition goals.
  Future<void> updateGoals(NutritionGoals goals) async {
    final currentState = state;
    if (currentState is! NutritionLoaded) {
      emit(NutritionError('Cannot update goals: invalid state'));
      return;
    }

    try {
      emit(currentState.copyWith(goals: goals));
      await repo.saveGoals(goals);
    } catch (e) {
      emit(currentState);
      emit(NutritionError('Failed to update goals: $e'));
    }
  }

  /// Clear all nutrition data.
  Future<void> clearAllData() async {
    try {
      await repo.clearAllData();

      final goals = await repo.getGoals();
      final today = DateTime.now();

      emit(NutritionLoaded(
        entries: {},
        goals: goals,
        selectedDateMeals: [],
        selectedDate: DateTime(today.year, today.month, today.day),
      ));
    } catch (e) {
      emit(NutritionError('Failed to clear data: $e'));
    }
  }
}
