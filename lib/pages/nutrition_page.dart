import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/nutrition/presentation/cubits/nutrition_cubit.dart';
import '../features/nutrition/presentation/cubits/nutrition_states.dart';
import '../features/nutrition/domain/entities/nutrition_entry.dart';
import '../features/workout_session/presentation/components/unified_calendar.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  DateTime _displayedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  static const double _titleHeight = 70.0;
  static const double _weekdayHeaderHeight = 26.0;
  static const double _bottomArrowAreaHeight = 22.0;

  void _goToday() {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    context.read<NutritionCubit>().selectDate(today);
    setState(() {
      _displayedMonth = DateTime(now.year, now.month, 1);
    });
  }

  void _prevDay(DateTime selected) {
    HapticFeedback.lightImpact();
    final newDate = selected.subtract(const Duration(days: 1));
    context.read<NutritionCubit>().selectDate(newDate);
    if (newDate.month != _displayedMonth.month ||
        newDate.year != _displayedMonth.year) {
      setState(() {
        _displayedMonth = DateTime(newDate.year, newDate.month, 1);
      });
    }
  }

  void _nextDay(DateTime selected) {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    if (selected.isBefore(todayOnly)) {
      HapticFeedback.lightImpact();
      final newDate = selected.add(const Duration(days: 1));
      context.read<NutritionCubit>().selectDate(newDate);
      if (newDate.month != _displayedMonth.month ||
          newDate.year != _displayedMonth.year) {
        setState(() {
          _displayedMonth = DateTime(newDate.year, newDate.month, 1);
        });
      }
    }
  }

  void _prevMonth() {
    HapticFeedback.lightImpact();
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    if (next.isBefore(DateTime(now.year, now.month + 1, 1))) {
      HapticFeedback.lightImpact();
      setState(() => _displayedMonth = next);
    }
  }

  void _onPickDay(DateTime date) {
    HapticFeedback.lightImpact();
    context.read<NutritionCubit>().selectDate(date);
    if (date.month != _displayedMonth.month ||
        date.year != _displayedMonth.year) {
      setState(() {
        _displayedMonth = DateTime(date.year, date.month, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    final topPad = media.padding.top;
    final width = media.size.width;

    const gridHPad = 16.0;
    final cellWidth = (width - (gridHPad * 2)) / 7.0;
    final expandedGridHeight = cellWidth * 6;
    final collapsedStripHeight = cellWidth;

    final minExtentHeight =
        topPad +
        _titleHeight +
        _weekdayHeaderHeight +
        collapsedStripHeight +
        _bottomArrowAreaHeight +
        8;
    final maxExtentHeight =
        topPad +
        _titleHeight +
        _weekdayHeaderHeight +
        expandedGridHeight +
        _bottomArrowAreaHeight +
        8;

    return BlocBuilder<NutritionCubit, NutritionState>(
      builder: (context, nutritionState) {
        if (nutritionState is! NutritionLoaded) {
          return ColoredBox(
            color: cs.surface,
            child: Center(
              child: CircularProgressIndicator(color: cs.inversePrimary),
            ),
          );
        }

        final selected = nutritionState.selectedDate;
        final entry = nutritionState.selectedEntry;
        final goals = nutritionState.goals;
        final meals = nutritionState.selectedDateMeals;

        return ColoredBox(
          color: cs.surface,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: UnifiedCalendarHeader(
                      minExtentHeight: minExtentHeight,
                      maxExtentHeight: maxExtentHeight,
                      selected: selected,
                      displayedMonth: _displayedMonth,
                      onPickDay: _onPickDay,
                      onToday: _goToday,
                      onPrevMonth: _prevMonth,
                      onNextMonth: _nextMonth,
                      onPrevDay: () => _prevDay(selected),
                      onNextDay: () => _nextDay(selected),
                      cellSize: cellWidth,
                      gridHPad: gridHPad,
                      expandedGridHeight: expandedGridHeight,
                      collapsedStripHeight: collapsedStripHeight,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Calories Card
                        _MacroCard(
                          title: 'Calories',
                          current: entry.calories,
                          goal: goals.calories,
                          unit: 'kcal',
                          color: Colors.green,
                          icon: Icons.local_fire_department_rounded,
                        ),
                        const SizedBox(height: 16),

                        // Macros Row
                        Row(
                          children: [
                            Expanded(
                              child: _MacroMiniCard(
                                title: 'Protein',
                                current: entry.protein,
                                goal: goals.protein,
                                unit: 'g',
                                color: Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MacroMiniCard(
                                title: 'Carbs',
                                current: entry.carbs,
                                goal: goals.carbs,
                                unit: 'g',
                                color: Colors.blue.shade400,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MacroMiniCard(
                                title: 'Fat',
                                current: entry.fat,
                                goal: goals.fat,
                                unit: 'g',
                                color: Colors.amber.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Meals Section
                        _SectionHeader(title: 'Meals'),
                        const SizedBox(height: 16),
                        if (meals.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.restaurant_rounded,
                                    size: 48,
                                    color: cs.primary.withAlpha(77),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No meals logged',
                                    style: TextStyle(
                                      color: cs.primary.withAlpha(128),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...meals.map((meal) => _MealCard(meal: meal)),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: _AddButton(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showAddMealDialog(context, selected);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMealDialog(BuildContext context, DateTime selectedDate) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddMealSheet(selectedDate: selectedDate),
    );
  }
}

class _AddMealSheet extends StatefulWidget {
  final DateTime selectedDate;
  const _AddMealSheet({required this.selectedDate});

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  final _nameController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  int get _calculatedCalories {
    final protein = int.tryParse(_proteinController.text) ?? 0;
    final carbs = int.tryParse(_carbsController.text) ?? 0;
    final fat = int.tryParse(_fatController.text) ?? 0;
    return (protein * 4) + (carbs * 4) + (fat * 9);
  }

  void _addMeal() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final meal = MealEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      protein: int.tryParse(_proteinController.text) ?? 0,
      carbs: int.tryParse(_carbsController.text) ?? 0,
      fat: int.tryParse(_fatController.text) ?? 0,
      time: widget.selectedDate,
    );

    context.read<NutritionCubit>().addMeal(meal);
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Meal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: cs.inversePrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Name Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Meal Name',
                filled: true,
                fillColor: cs.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Macros Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _proteinController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Protein (g)',
                      filled: true,
                      fillColor: cs.secondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _carbsController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Carbs (g)',
                      filled: true,
                      fillColor: cs.secondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _fatController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Fat (g)',
                      filled: true,
                      fillColor: cs.secondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Auto-calculated calories display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Calories',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$_calculatedCalories kcal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.inversePrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Add Button
            GestureDetector(
              onTap: _addMeal,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: cs.inversePrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Add Meal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String title;
  final int current;
  final int goal;
  final String unit;
  final Color color;
  final IconData icon;

  const _MacroCard({
    required this.title,
    required this.current,
    required this.goal,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.primary.withAlpha(179),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$current',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: cs.inversePrimary,
                        ),
                      ),
                      Text(
                        ' / $goal $unit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: cs.primary.withAlpha(128),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: cs.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroMiniCard extends StatelessWidget {
  final String title;
  final int current;
  final int goal;
  final String unit;
  final Color color;

  const _MacroMiniCard({
    required this.title,
    required this.current,
    required this.goal,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.primary.withAlpha(179),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$current$unit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: cs.inversePrimary,
            ),
          ),
          Text(
            '/ $goal$unit',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: cs.primary.withAlpha(128),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: cs.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.primary.withAlpha(128),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealEntry meal;

  const _MealCard({required this.meal});

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    HapticFeedback.lightImpact();

    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withAlpha(102),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cs.secondary,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(26),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Delete Meal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cs.inversePrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Remove "${meal.name}" from today\'s log?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: cs.primary),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(meal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(230),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      confirmDismiss: (_) => _showDeleteConfirmation(context),
      onDismissed: (_) {
        context.read<NutritionCubit>().deleteMeal(meal.id);
        HapticFeedback.mediumImpact();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surface.withAlpha(128),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.restaurant_rounded,
                color: cs.inversePrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.inversePrimary,
                    ),
                  ),
                  Text(
                    'P:${meal.protein}g  C:${meal.carbs}g  F:${meal.fat}g',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.primary.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${meal.calories} kcal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.inversePrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: cs.inversePrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withAlpha(77),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: cs.secondary, size: 28),
      ),
    );
  }
}
