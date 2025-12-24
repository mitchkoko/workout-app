import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../features/workout/presentation/cubits/workout_cubit.dart';
import '../features/workout_session/presentation/cubits/workout_session_cubit.dart';
import '../features/workout_session/presentation/cubits/workout_session_states.dart';
import 'exercise_detail_page.dart';
import 'edit_workout_page.dart';

class WorkoutDetailPage extends StatefulWidget {
  final Workout workout;
  final DateTime selectedDate;

  const WorkoutDetailPage({
    super.key,
    required this.workout,
    required this.selectedDate,
  });

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  bool _hasAutoCompleted = false;

  /// Build a map of exercise ID to total sets for checking completion.
  Map<String, int> get _exerciseTotalSets {
    return {
      for (final we in widget.workout.exercises)
        we.exercise.id: we.sets,
    };
  }

  void _checkAndAutoComplete(BuildContext context, WorkoutSessionLoaded state) {
    if (_hasAutoCompleted) return;

    final hasActiveSession = state.hasActiveSessionForWorkout(widget.workout.id);
    if (!hasActiveSession) return;

    final allComplete = state.areAllExercisesComplete(_exerciseTotalSets);
    if (allComplete) {
      _hasAutoCompleted = true;

      // Capture everything needed before async gap
      final cubit = context.read<WorkoutSessionCubit>();
      final navigator = Navigator.of(context, rootNavigator: true);
      final selectedDate = widget.selectedDate;

      // Brief delay for UI to update, then show celebration
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          cubit.finishWorkout(forDate: selectedDate);
          _showCelebration(navigator);
        }
      });
    }
  }

  void _showCelebration(NavigatorState navigator) {
    HapticFeedback.heavyImpact();

    navigator.push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.black.withAlpha(230),
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (dialogContext, animation, secondaryAnimation) {
          return _CelebrationScreen(
            workoutName: widget.workout.name,
            exerciseCount: widget.workout.exercises.length,
            onComplete: () {
              // Pop the celebration screen, then navigate back to first route
              navigator.popUntil((route) => route.isFirst);
            },
          );
        },
        transitionsBuilder: (context, anim, secondaryAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.elasticOut),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final padding = MediaQuery.of(context).padding;

    return BlocConsumer<WorkoutSessionCubit, WorkoutSessionState>(
      listener: (context, state) {
        // Completion is now handled after ExerciseDetailPage navigation returns
        // to avoid race conditions with competing navigation events
      },
      builder: (context, sessionState) {
        final hasActiveSession = sessionState is WorkoutSessionLoaded &&
            sessionState.hasActiveSessionForWorkout(widget.workout.id);

        // Check if workout was already completed on the selected date
        final isCompletedOnDate = sessionState is WorkoutSessionLoaded &&
            sessionState.history.isWorkoutCompletedOnDate(
              widget.workout.id,
              widget.selectedDate,
            );

        return Scaffold(
          backgroundColor: cs.surface,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(24, padding.top + 16, 24, 24),
                  decoration: BoxDecoration(
                    color: cs.secondary,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withAlpha(10),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: cs.inversePrimary,
                                size: 20,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditWorkoutPage(workout: widget.workout),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: cs.surface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.edit_rounded,
                                    color: cs.inversePrimary,
                                    size: 20,
                                  ),
                                ),
                              ),
                              if (widget.workout.isCustom) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _showDeleteDialog(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: cs.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      color: cs.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        widget.workout.name,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: cs.inversePrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Muscle group chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.workout.primaryMuscles
                            .map((muscle) =>
                                _MuscleChip(label: muscle.displayName))
                            .toList(),
                      ),
                      const SizedBox(height: 20),

                      // Progress indicator
                      Builder(
                        builder: (context) {
                          final totalExercises = widget.workout.exercises.length;
                          int completedExercises = 0;

                          if (isCompletedOnDate && !hasActiveSession) {
                            completedExercises = totalExercises;
                          } else if (sessionState is WorkoutSessionLoaded &&
                              hasActiveSession) {
                            for (final we in widget.workout.exercises) {
                              if (sessionState.isExerciseComplete(
                                  we.exercise.id, we.sets)) {
                                completedExercises++;
                              }
                            }
                          }

                          final progress = totalExercises > 0
                              ? completedExercises / totalExercises
                              : 0.0;
                          final isComplete = completedExercises == totalExercises &&
                              totalExercises > 0;

                          return _ProgressCard(
                            completed: completedExercises,
                            total: totalExercises,
                            progress: progress,
                            isComplete: isComplete,
                            showResetOption: isCompletedOnDate && !hasActiveSession,
                            onReset: () => _showResetDialog(context),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Exercise list
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _CardHeader(title: 'Exercises', icon: Icons.list_rounded),
                    const SizedBox(height: 16),
                    ...widget.workout.exercises.map(
                      (workoutExercise) {
                        // Get completion state
                        bool isComplete = false;
                        int completedSets = 0;

                        // If workout was completed on selected date, show all as complete
                        if (isCompletedOnDate && !hasActiveSession) {
                          isComplete = true;
                          completedSets = workoutExercise.sets;
                        } else if (sessionState is WorkoutSessionLoaded &&
                            hasActiveSession) {
                          isComplete = sessionState.isExerciseComplete(
                            workoutExercise.exercise.id,
                            workoutExercise.sets,
                          );
                          completedSets = sessionState.getCompletedSets(
                            workoutExercise.exercise.id,
                          );
                        }

                        return _ExerciseItem(
                          workout: widget.workout,
                          workoutExercise: workoutExercise,
                          isCompleted: isComplete,
                          completedSets: completedSets,
                          showProgress: hasActiveSession,
                          isReadOnly: isCompletedOnDate && !hasActiveSession,
                          onExerciseCompleted: () {
                            // Check if workout is now complete after exercise returns
                            final cubit = context.read<WorkoutSessionCubit>();
                            final state = cubit.state;
                            if (state is WorkoutSessionLoaded) {
                              _checkAndAutoComplete(context, state);
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResetDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    HapticFeedback.lightImpact();

    showGeneralDialog(
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
                    color: Colors.orange.withAlpha(26),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.restart_alt_rounded,
                    color: Colors.orange,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Reset Workout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cs.inversePrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This will mark the workout as incomplete for this date. You can redo it anytime.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: cs.primary),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          context.read<WorkoutSessionCubit>().resetWorkoutCompletion(
                                widget.workout.id,
                                widget.selectedDate,
                              );
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'Reset',
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

  void _showDeleteDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    HapticFeedback.lightImpact();

    showGeneralDialog(
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
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Delete Workout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cs.inversePrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete "${widget.workout.name}"?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: cs.primary),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          context.read<WorkoutCubit>().deleteCustomWorkout(widget.workout.id);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
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
}

class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final double progress;
  final bool isComplete;
  final bool showResetOption;
  final VoidCallback? onReset;

  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
    required this.isComplete,
    this.showResetOption = false,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progressColor = isComplete ? Colors.green : cs.inversePrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Progress circle
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: cs.secondary,
                  valueColor: AlwaysStoppedAnimation(progressColor),
                ),
                if (isComplete)
                  Icon(Icons.check_rounded, color: Colors.green, size: 20)
                else
                  Text(
                    '$completed',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: cs.inversePrimary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isComplete ? 'Complete!' : '$completed of $total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isComplete ? Colors.green : cs.inversePrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isComplete ? 'All exercises done' : 'exercises completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.primary.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
          // Reset button for completed workouts
          if (showResetOption && onReset != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onReset!();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.orange.withAlpha(50),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.restart_alt_rounded,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _CardHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.primary.withAlpha(128)),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: cs.primary.withAlpha(153),
          ),
        ),
      ],
    );
  }
}

class _ExerciseItem extends StatelessWidget {
  final Workout workout;
  final WorkoutExercise workoutExercise;
  final bool isCompleted;
  final int completedSets;
  final bool showProgress;
  final bool isReadOnly;
  final VoidCallback? onExerciseCompleted;

  const _ExerciseItem({
    required this.workout,
    required this.workoutExercise,
    this.isCompleted = false,
    this.completedSets = 0,
    this.showProgress = false,
    this.isReadOnly = false,
    this.onExerciseCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final exercise = workoutExercise.exercise;

    return GestureDetector(
      onTap: isReadOnly
          ? null
          : () {
              HapticFeedback.lightImpact();

              // Auto-start session if not already started
              final cubit = context.read<WorkoutSessionCubit>();
              final state = cubit.state;
              if (state is WorkoutSessionLoaded) {
                final hasSession = state.hasActiveSessionForWorkout(workout.id);
                if (!hasSession) {
                  cubit.startWorkout(workout.id, workout.exercises);
                }
              }

              Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseDetailPage(
                    exercise: exercise,
                    workoutExercise: workoutExercise,
                  ),
                ),
              ).then((exerciseCompleted) {
                if (exerciseCompleted == true) {
                  onExerciseCompleted?.call();
                }
              });
            },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isCompleted ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: cs.secondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Completion indicator
              if (isCompleted) ...[
                Icon(
                  Icons.check_rounded,
                  color: cs.primary.withAlpha(120),
                  size: 18,
                ),
                const SizedBox(width: 12),
              ],

              // Exercise info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? cs.primary.withAlpha(120)
                            : cs.inversePrimary,
                        letterSpacing: -0.3,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: cs.primary.withAlpha(100),
                        decorationThickness: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Chips in single row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _InfoChip(
                            label: exercise.primaryMuscle.displayName,
                            isHighlighted: true,
                          ),
                          const SizedBox(width: 6),
                          _InfoChip(label: '${workoutExercise.sets} sets'),
                          const SizedBox(width: 6),
                          _InfoChip(label: '${workoutExercise.reps} reps'),
                          if (workoutExercise.weight != null) ...[
                            const SizedBox(width: 6),
                            _InfoChip(
                                label: '${workoutExercise.weight!.toInt()} lbs'),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Progress indicator or arrow
              if (showProgress && !isCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$completedSets/${workoutExercise.sets}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: cs.primary.withAlpha(80),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MuscleChip extends StatelessWidget {
  final String label;

  const _MuscleChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.inversePrimary.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: cs.inversePrimary.withAlpha(204),
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final bool isHighlighted;

  const _InfoChip({
    required this.label,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlighted ? cs.inversePrimary.withAlpha(18) : cs.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
          color: isHighlighted ? cs.inversePrimary : cs.primary,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class _CelebrationScreen extends StatefulWidget {
  final String workoutName;
  final int exerciseCount;
  final VoidCallback onComplete;

  const _CelebrationScreen({
    required this.workoutName,
    required this.exerciseCount,
    required this.onComplete,
  });

  @override
  State<_CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<_CelebrationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Auto-dismiss after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Checkmark circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withAlpha(100),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'WORKOUT COMPLETE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.workoutName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(200),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.exerciseCount} exercises completed',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(150),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
