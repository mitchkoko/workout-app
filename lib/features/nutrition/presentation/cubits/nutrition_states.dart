import '../../domain/entities/nutrition_entry.dart';

/// Base class for all nutrition states.
abstract class NutritionState {}

/// Initial state before any data is loaded.
class NutritionInitial extends NutritionState {}

/// Loading state while fetching data.
class NutritionLoading extends NutritionState {}

/// Loaded state with nutrition data.
class NutritionLoaded extends NutritionState {
  /// All nutrition entries by date key.
  final Map<String, NutritionEntry> entries;

  /// User's nutrition goals.
  final NutritionGoals goals;

  /// Meals for the selected date.
  final List<MealEntry> selectedDateMeals;

  /// Currently selected date.
  final DateTime selectedDate;

  NutritionLoaded({
    required this.entries,
    required this.goals,
    required this.selectedDateMeals,
    required this.selectedDate,
  });

  /// Get entry for a specific date.
  NutritionEntry? getEntry(DateTime date) {
    final dateKey = NutritionEntry.dateKey(date);
    return entries[dateKey];
  }

  /// Get calories progress for a date (0.0 to 1.0+).
  double getCaloriesProgress(DateTime date) {
    final entry = getEntry(date);
    if (entry == null || goals.calories == 0) return 0.0;
    return entry.calories / goals.calories;
  }

  /// Get entry for the selected date.
  NutritionEntry get selectedEntry {
    return getEntry(selectedDate) ?? NutritionEntry.empty(selectedDate);
  }

  NutritionLoaded copyWith({
    Map<String, NutritionEntry>? entries,
    NutritionGoals? goals,
    List<MealEntry>? selectedDateMeals,
    DateTime? selectedDate,
  }) {
    return NutritionLoaded(
      entries: entries ?? this.entries,
      goals: goals ?? this.goals,
      selectedDateMeals: selectedDateMeals ?? this.selectedDateMeals,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

/// Error state with message.
class NutritionError extends NutritionState {
  final String message;

  NutritionError(this.message);
}
