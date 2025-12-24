import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../features/workout/presentation/cubits/workout_cubit.dart';
import '../features/workout/presentation/cubits/workout_states.dart';
import '../features/workout_session/presentation/cubits/workout_session_cubit.dart';
import '../features/workout_session/presentation/cubits/workout_session_states.dart';
import '../features/workout_session/presentation/components/unified_calendar.dart';
import 'workout_detail_page.dart';
import 'create_workout_page.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  DateTime _selected = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime _displayedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  static const double _titleHeight = 70.0;
  static const double _weekdayHeaderHeight = 26.0;
  static const double _bottomArrowAreaHeight = 22.0;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void _onPickDay(DateTime date) {
    HapticFeedback.lightImpact();
    setState(() {
      _selected = _dateOnly(date);
      if (_selected.month != _displayedMonth.month ||
          _selected.year != _displayedMonth.year) {
        _displayedMonth = DateTime(_selected.year, _selected.month, 1);
      }
    });
  }

  void _goToday() {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    setState(() {
      _selected = _dateOnly(now);
      _displayedMonth = DateTime(now.year, now.month, 1);
    });
  }

  void _prevDay() {
    HapticFeedback.lightImpact();
    setState(() {
      _selected = _selected.subtract(const Duration(days: 1));
      if (_selected.month != _displayedMonth.month ||
          _selected.year != _displayedMonth.year) {
        _displayedMonth = DateTime(_selected.year, _selected.month, 1);
      }
    });
  }

  void _nextDay() {
    final now = DateTime.now();
    final todayOnly = _dateOnly(now);
    if (_selected.isBefore(todayOnly)) {
      HapticFeedback.lightImpact();
      setState(() {
        _selected = _selected.add(const Duration(days: 1));
        if (_selected.month != _displayedMonth.month ||
            _selected.year != _displayedMonth.year) {
          _displayedMonth = DateTime(_selected.year, _selected.month, 1);
        }
      });
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

    return ColoredBox(
      color: cs.surface,
      child: BlocBuilder<WorkoutCubit, WorkoutState>(
        builder: (context, workoutState) {
          if (workoutState is! WorkoutLoaded) {
            return Center(
              child: CircularProgressIndicator(color: cs.inversePrimary),
            );
          }

          return BlocBuilder<WorkoutSessionCubit, WorkoutSessionState>(
            builder: (context, sessionState) {
              final history = sessionState is WorkoutSessionLoaded
                  ? sessionState.history
                  : null;

              return Stack(
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
                          selected: _selected,
                          displayedMonth: _displayedMonth,
                          onPickDay: _onPickDay,
                          onToday: _goToday,
                          onPrevMonth: _prevMonth,
                          onNextMonth: _nextMonth,
                          onPrevDay: _prevDay,
                          onNextDay: _nextDay,
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
                            if (workoutState.customWorkouts.isNotEmpty) ...[
                              _SectionHeader(title: 'My Workouts'),
                              const SizedBox(height: 16),
                              ...workoutState.customWorkouts.map(
                                (workout) => _WorkoutCard(
                                  workout: workout,
                                  selectedDate: _selected,
                                  isCompletedOnDate:
                                      history?.isWorkoutCompletedOnDate(
                                        workout.id,
                                        _selected,
                                      ) ??
                                      false,
                                ),
                              ),
                              const SizedBox(height: 28),
                            ],
                            _SectionHeader(title: 'Preset Workouts'),
                            const SizedBox(height: 16),
                            ...workoutState.presetWorkouts.map(
                              (workout) => _WorkoutCard(
                                workout: workout,
                                selectedDate: _selected,
                                isCompletedOnDate:
                                    history?.isWorkoutCompletedOnDate(
                                      workout.id,
                                      _selected,
                                    ) ??
                                    false,
                              ),
                            ),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateWorkoutPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
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

class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  final bool isCompletedOnDate;
  final DateTime selectedDate;
  const _WorkoutCard({
    required this.workout,
    required this.selectedDate,
    this.isCompletedOnDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WorkoutDetailPage(workout: workout, selectedDate: selectedDate),
          ),
        );
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isCompletedOnDate ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
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
                  Expanded(
                    child: Text(
                      workout.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isCompletedOnDate
                            ? cs.primary.withAlpha(120)
                            : cs.inversePrimary,
                        decoration: isCompletedOnDate
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: cs.primary.withAlpha(100),
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                  if (isCompletedOnDate)
                    Icon(
                      Icons.check_rounded,
                      color: cs.primary.withAlpha(120),
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: workout.primaryMuscles
                    .map((m) => _Chip(label: m.displayName))
                    .toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 18,
                    color: cs.primary.withAlpha(179),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${workout.exercises.length} exercises',
                    style: TextStyle(
                      color: cs.primary.withAlpha(179),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (isCompletedOnDate)
                    Text(
                      'Done',
                      style: TextStyle(
                        color: cs.primary.withAlpha(150),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    )
                  else
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: cs.primary.withAlpha(77),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface.withAlpha(128),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: cs.primary.withAlpha(204),
          fontWeight: FontWeight.w600,
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
