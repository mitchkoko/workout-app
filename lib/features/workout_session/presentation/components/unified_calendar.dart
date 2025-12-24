import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../cubits/workout_session_cubit.dart';
import '../cubits/workout_session_states.dart';
import '../../domain/entities/workout_session.dart';
import '../../../nutrition/presentation/cubits/nutrition_cubit.dart';
import '../../../nutrition/presentation/cubits/nutrition_states.dart';

/// Unified calendar header used by both Workouts and Nutrition pages.
/// Shows workout glow + nutrition green-ness on all day chips.
class UnifiedCalendarHeader extends SliverPersistentHeaderDelegate {
  UnifiedCalendarHeader({
    required this.minExtentHeight,
    required this.maxExtentHeight,
    required this.selected,
    required this.displayedMonth,
    required this.onPickDay,
    required this.onToday,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onPrevDay,
    required this.onNextDay,
    required this.cellSize,
    required this.gridHPad,
    required this.expandedGridHeight,
    required this.collapsedStripHeight,
  });

  final double minExtentHeight, maxExtentHeight;
  final DateTime selected, displayedMonth;
  final ValueChanged<DateTime> onPickDay;
  final VoidCallback onToday, onPrevMonth, onNextMonth, onPrevDay, onNextDay;
  final double cellSize, gridHPad, expandedGridHeight, collapsedStripHeight;

  @override
  double get minExtent => minExtentHeight;
  @override
  double get maxExtent => maxExtentHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final cs = Theme.of(context).colorScheme;
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final expandedOpacity = (1.0 - t * 3.0).clamp(0.0, 1.0);
    final collapsedOpacity = (t * 3.0 - 2.0).clamp(0.0, 1.0);

    return BlocBuilder<WorkoutSessionCubit, WorkoutSessionState>(
      builder: (context, workoutState) {
        final history = workoutState is WorkoutSessionLoaded
            ? workoutState.history
            : WorkoutHistory.empty();

        return BlocBuilder<NutritionCubit, NutritionState>(
          builder: (context, nutritionState) {
            final nutritionLoaded = nutritionState is NutritionLoaded
                ? nutritionState
                : null;

            return Container(
              decoration: BoxDecoration(
                color: cs.secondary,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    // Expanded View
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: maxExtentHeight,
                      child: Opacity(
                        opacity: expandedOpacity,
                        child: IgnorePointer(
                          ignoring: t > 0.1,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeaderTitle(context, isExpanded: true),
                              _buildWeekdayHeaders(context),
                              const SizedBox(height: 2),
                              SizedBox(
                                height: expandedGridHeight,
                                child: _UnifiedMonthGrid(
                                  month: displayedMonth,
                                  selected: selected,
                                  history: history,
                                  nutritionState: nutritionLoaded,
                                  onPickDay: onPickDay,
                                  cs: cs,
                                  gridHPad: gridHPad,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Collapsed View
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: minExtentHeight,
                      child: Opacity(
                        opacity: collapsedOpacity,
                        child: IgnorePointer(
                          ignoring: t < 0.9,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeaderTitle(context, isExpanded: false),
                              _buildWeekdayHeaders(context),
                              const SizedBox(height: 2),
                              SizedBox(
                                height: collapsedStripHeight,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: gridHPad,
                                  ),
                                  child: _UnifiedWeekStrip(
                                    selected: selected,
                                    history: history,
                                    nutritionState: nutritionLoaded,
                                    onPickDay: onPickDay,
                                    cs: cs,
                                    cellSize: cellSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Arrow indicator
                    Positioned(
                      bottom: 6,
                      left: 0,
                      right: 0,
                      child: Transform.rotate(
                        angle: (1.0 - t) * 3.14159,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: cs.primary.withAlpha(128),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeaderTitle(BuildContext context, {required bool isExpanded}) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final isToday =
        selected.year == now.year &&
        selected.month == now.month &&
        selected.day == now.day;

    VoidCallback? onLeftTap, onRightTap;
    bool isLeftEnabled = true, isRightEnabled = false;

    if (isExpanded) {
      onLeftTap = onPrevMonth;
      onRightTap = onNextMonth;
      final nextMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month + 1,
        1,
      );
      isRightEnabled = nextMonth.isBefore(DateTime(now.year, now.month + 1, 1));
    } else {
      onLeftTap = onPrevDay;
      onRightTap = onNextDay;
      isRightEnabled = !selected
          .add(const Duration(days: 1))
          .isAfter(todayOnly);
    }

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Scaffold.of(context).openDrawer();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.menu_rounded,
                color: cs.inversePrimary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(displayedMonth),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: cs.inversePrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: isLeftEnabled ? onLeftTap : null,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isLeftEnabled ? cs.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: isLeftEnabled
                        ? cs.primary
                        : cs.primary.withAlpha(77),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: isRightEnabled ? onRightTap : null,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isRightEnabled ? cs.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: isRightEnabled
                        ? cs.primary
                        : cs.primary.withAlpha(51),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onToday,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.transparent : cs.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.refresh,
                    size: 20,
                    color: isToday ? cs.primary.withAlpha(51) : cs.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 26,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: gridHPad),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA']
              .map(
                (d) => SizedBox(
                  width: cellSize,
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.primary.withAlpha(153),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(UnifiedCalendarHeader old) => true;
}

class _UnifiedMonthGrid extends StatelessWidget {
  final DateTime month, selected;
  final WorkoutHistory history;
  final NutritionLoaded? nutritionState;
  final ValueChanged<DateTime> onPickDay;
  final ColorScheme cs;
  final double gridHPad;

  const _UnifiedMonthGrid({
    required this.month,
    required this.selected,
    required this.history,
    required this.nutritionState,
    required this.onPickDay,
    required this.cs,
    required this.gridHPad,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final today = DateTime.now();

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: gridHPad),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final dayOffset = index - firstWeekday;
        if (dayOffset < 0 || dayOffset >= daysInMonth) return const SizedBox();

        final d = dayOffset + 1;
        final date = DateTime(month.year, month.month, d);
        final isDisabled = date.isAfter(
          DateTime(today.year, today.month, today.day),
        );
        final isSelected =
            date.year == selected.year &&
            date.month == selected.month &&
            date.day == selected.day;
        final hasWorkout = history.hasWorkoutOnDate(date);
        final nutritionProgress =
            nutritionState?.getCaloriesProgress(date) ?? 0.0;

        return Center(
          child: GestureDetector(
            onTap: isDisabled ? null : () => onPickDay(date),
            child: _UnifiedDayChip(
              day: d,
              isSelected: isSelected,
              isDisabled: isDisabled,
              hasWorkout: hasWorkout,
              nutritionProgress: nutritionProgress,
              cs: cs,
            ),
          ),
        );
      },
    );
  }
}

class _UnifiedWeekStrip extends StatelessWidget {
  final DateTime selected;
  final WorkoutHistory history;
  final NutritionLoaded? nutritionState;
  final ValueChanged<DateTime> onPickDay;
  final ColorScheme cs;
  final double cellSize;

  const _UnifiedWeekStrip({
    required this.selected,
    required this.history,
    required this.nutritionState,
    required this.onPickDay,
    required this.cs,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    final startOfWeek = selected.subtract(Duration(days: selected.weekday % 7));
    final today = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final date = startOfWeek.add(Duration(days: i));
        final isDisabled = date.isAfter(
          DateTime(today.year, today.month, today.day),
        );
        final isSelected =
            date.year == selected.year &&
            date.month == selected.month &&
            date.day == selected.day;
        final hasWorkout = history.hasWorkoutOnDate(date);
        final nutritionProgress =
            nutritionState?.getCaloriesProgress(date) ?? 0.0;

        return SizedBox(
          width: cellSize,
          height: cellSize,
          child: Center(
            child: GestureDetector(
              onTap: isDisabled ? null : () => onPickDay(date),
              child: _UnifiedDayChip(
                day: date.day,
                isSelected: isSelected,
                isDisabled: isDisabled,
                hasWorkout: hasWorkout,
                nutritionProgress: nutritionProgress,
                cs: cs,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Day chip showing:
/// - Green-ness based on nutrition progress (% of calories goal)
/// - AvatarGlow effect if workout was completed that day
/// - Subtle border for selected day
class _UnifiedDayChip extends StatelessWidget {
  final int day;
  final bool isSelected, isDisabled, hasWorkout;
  final double nutritionProgress;
  final ColorScheme cs;

  const _UnifiedDayChip({
    required this.day,
    required this.isSelected,
    required this.isDisabled,
    required this.hasWorkout,
    required this.nutritionProgress,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Border? border;

    // Green-ness from nutrition progress
    if (nutritionProgress > 0) {
      final intensity = nutritionProgress.clamp(0.0, 1.0);
      final alpha = (60 + (intensity * 140)).toInt();
      bgColor = Colors.green.withAlpha(alpha);
      textColor = Colors.white;
    } else {
      bgColor = Colors.transparent;
      textColor = isDisabled ? cs.primary.withAlpha(77) : cs.inversePrimary;
    }

    // Selected day border
    if (isSelected) {
      border = Border.all(color: cs.primary.withAlpha(100), width: 1.5);
    }

    final dayWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: border,
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected || hasWorkout || nutritionProgress > 0.3
                ? FontWeight.w700
                : FontWeight.w500,
            color: hasWorkout || nutritionProgress > 0
                ? Colors.white
                : textColor,
          ),
        ),
      ),
    );

    // Wrap with AvatarGlow if workout completed
    if (hasWorkout) {
      return AvatarGlow(
        glowColor: Colors.green,
        glowRadiusFactor: 0.4,
        child: dayWidget,
      );
    }

    return dayWidget;
  }
}
