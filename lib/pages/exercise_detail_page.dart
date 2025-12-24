import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../features/workout_session/presentation/cubits/workout_session_cubit.dart';
import '../features/workout_session/presentation/cubits/workout_session_states.dart';

class ExerciseDetailPage extends StatelessWidget {
  final Exercise exercise;
  final WorkoutExercise? workoutExercise;

  const ExerciseDetailPage({
    super.key,
    required this.exercise,
    this.workoutExercise,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final padding = MediaQuery.of(context).padding;
    final hasWorkout = workoutExercise != null;

    return Scaffold(
      backgroundColor: cs.surface,
      body: BlocBuilder<WorkoutSessionCubit, WorkoutSessionState>(
        builder: (context, sessionState) {
          int completedCount = 0;
          List<bool> completedSets = [];

          if (hasWorkout && sessionState is WorkoutSessionLoaded) {
            final sets = workoutExercise!.sets;
            completedSets = List.generate(
              sets,
              (i) => sessionState.isSetCompleted(exercise.id, i),
            );
            completedCount = completedSets.where((c) => c).length;
          } else if (hasWorkout) {
            completedSets = List.filled(workoutExercise!.sets, false);
          }

          final allSetsComplete =
              hasWorkout && completedCount == workoutExercise!.sets;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(24, padding.top + 16, 24, 28),
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
                      // Back button with completion indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context, allSetsComplete);
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
                          if (hasWorkout)
                            _CompletionRing(
                              completed: completedCount,
                              total: workoutExercise!.sets,
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        exercise.name,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: cs.inversePrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Info pills
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _InfoPill(
                            icon: Icons.fitness_center_rounded,
                            label: exercise.primaryMuscle.displayName,
                            isPrimary: true,
                          ),
                          _InfoPill(
                            icon: Icons.sports_gymnastics_rounded,
                            label: exercise.equipment.displayName,
                          ),
                          if (hasWorkout) ...[
                            _InfoPill(
                              icon: Icons.layers_rounded,
                              label: '${workoutExercise!.sets} sets',
                            ),
                            _InfoPill(
                              icon: Icons.repeat_rounded,
                              label: '${workoutExercise!.reps} reps',
                            ),
                            if (workoutExercise!.weight != null)
                              _InfoPill(
                                icon: Icons.fitness_center_rounded,
                                label:
                                    '${workoutExercise!.weight!.toInt()} lbs',
                              ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Sets completion section
                    if (hasWorkout &&
                        sessionState is WorkoutSessionLoaded &&
                        sessionState.activeSession != null) ...[
                      _SetsSection(
                        workoutExercise: workoutExercise!,
                        completedSets: completedSets,
                        completedCount: completedCount,
                        exerciseId: exercise.id,
                      ),
                      const SizedBox(height: 16),
                    ] else if (hasWorkout) ...[
                      _SetsSection(
                        workoutExercise: workoutExercise!,
                        completedSets: List.filled(
                          workoutExercise!.sets,
                          false,
                        ),
                        completedCount: 0,
                        exerciseId: exercise.id,
                        isPreview: true,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Secondary muscles
                    if (exercise.secondaryMuscles.isNotEmpty) ...[
                      _ContentCard(
                        title: 'Secondary Muscles',
                        icon: Icons.view_list_rounded,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: exercise.secondaryMuscles
                              .map((m) => _MuscleChip(label: m.displayName))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Instructions
                    _ContentCard(
                      title: 'Instructions',
                      icon: Icons.description_rounded,
                      child: Text(
                        exercise.instructions,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: cs.inversePrimary,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompletionRing extends StatelessWidget {
  final int completed;
  final int total;

  const _CompletionRing({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = total > 0 ? completed / total : 0.0;
    final isComplete = completed == total && total > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2.5,
                  backgroundColor: cs.outline.withAlpha(30),
                  valueColor: AlwaysStoppedAnimation(
                    isComplete ? Colors.green : cs.inversePrimary,
                  ),
                ),
                if (isComplete)
                  Icon(Icons.check_rounded, size: 12, color: Colors.green),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$completed/$total',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isComplete ? Colors.green : cs.inversePrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SetsSection extends StatelessWidget {
  final WorkoutExercise workoutExercise;
  final List<bool> completedSets;
  final int completedCount;
  final String exerciseId;
  final bool isPreview;

  const _SetsSection({
    required this.workoutExercise,
    required this.completedSets,
    required this.completedCount,
    required this.exerciseId,
    this.isPreview = false,
  });

  void _showExerciseCelebration(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);

    navigator.push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.black.withAlpha(200),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (dialogContext, animation, secondaryAnimation) {
          return _ExerciseCelebrationScreen(
            exerciseName: workoutExercise.exercise.name,
            totalSets: workoutExercise.sets,
            totalReps: workoutExercise.sets * workoutExercise.reps,
            onComplete: () {
              navigator.pop();
              Navigator.pop(context, true);
            },
          );
        },
        transitionsBuilder: (context, anim, secondaryAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final allComplete = completedCount == workoutExercise.sets;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: allComplete ? Colors.green.withAlpha(20) : cs.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  allComplete
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 14,
                  color: allComplete ? Colors.green : cs.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'SETS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: cs.primary.withAlpha(153),
                ),
              ),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: allComplete ? Colors.green.withAlpha(20) : cs.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$completedCount/${workoutExercise.sets}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: allComplete ? Colors.green : cs.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Sets list
          ...List.generate(workoutExercise.sets, (index) {
            final isLastSet = index == workoutExercise.sets - 1;
            final isLastSetBeingCompleted = isLastSet && !completedSets[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < workoutExercise.sets - 1 ? 10 : 0,
              ),
              child: _SlideToComplete(
                setNumber: index + 1,
                reps: workoutExercise.reps,
                weight: workoutExercise.weight,
                isCompleted: completedSets[index],
                isPreview: isPreview,
                onComplete: () {
                  if (isPreview) return;
                  context.read<WorkoutSessionCubit>().completeSet(
                    exerciseId,
                    index,
                  );

                  if (isLastSetBeingCompleted) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (context.mounted) {
                        _showExerciseCelebration(context);
                      }
                    });
                  }
                },
                onUncomplete: isPreview
                    ? null
                    : () {
                        context.read<WorkoutSessionCubit>().uncompleteSet(
                          exerciseId,
                          index,
                        );
                      },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ExerciseCelebrationScreen extends StatefulWidget {
  final String exerciseName;
  final int totalSets;
  final int totalReps;
  final VoidCallback onComplete;

  const _ExerciseCelebrationScreen({
    required this.exerciseName,
    required this.totalSets,
    required this.totalReps,
    required this.onComplete,
  });

  @override
  State<_ExerciseCelebrationScreen> createState() =>
      _ExerciseCelebrationScreenState();
}

class _ExerciseCelebrationScreenState extends State<_ExerciseCelebrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    HapticFeedback.heavyImpact();
    _mainController.forward();
    _pulseController.repeat(reverse: true);

    // Auto-dismiss after delay
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onComplete,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_mainController, _pulseController]),
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated checkmark
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withAlpha(80),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Title
                    Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Text(
                        'EXERCISE DONE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Exercise name
                    Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 1.2),
                      child: Text(
                        widget.exerciseName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withAlpha(230),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats row
                    Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 1.4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StatBadge(
                            value: '${widget.totalSets}',
                            label: 'sets',
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            width: 1,
                            height: 30,
                            color: Colors.white.withAlpha(40),
                          ),
                          _StatBadge(
                            value: '${widget.totalReps}',
                            label: 'reps',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;

  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withAlpha(150),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _SlideToComplete extends StatefulWidget {
  final int setNumber;
  final int reps;
  final double? weight;
  final bool isCompleted;
  final bool isPreview;
  final VoidCallback onComplete;
  final VoidCallback? onUncomplete;

  const _SlideToComplete({
    required this.setNumber,
    required this.reps,
    this.weight,
    required this.isCompleted,
    this.isPreview = false,
    required this.onComplete,
    this.onUncomplete,
  });

  @override
  State<_SlideToComplete> createState() => _SlideToCompleteState();
}

class _SlideToCompleteState extends State<_SlideToComplete>
    with TickerProviderStateMixin {
  double _dragPosition = 0;
  double _lastHapticProgress = 0;
  late AnimationController _snapBackController;
  late AnimationController _successController;
  late Animation<double> _snapBackAnimation;
  late Animation<double> _successScale;
  late Animation<double> _successOpacity;
  bool _isAnimatingSuccess = false;

  static const double _thumbWidth = 52;
  static const double _thumbPadding = 4;
  static const double _completeThreshold = 0.85;

  @override
  void initState() {
    super.initState();
    _snapBackController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _snapBackAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _snapBackController, curve: Curves.elasticOut),
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _successScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _successOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(_SlideToComplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted && !oldWidget.isCompleted) {
      _playSuccessAnimation();
    }
  }

  void _playSuccessAnimation() {
    _isAnimatingSuccess = true;
    _successController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() => _isAnimatingSuccess = false);
      }
    });
  }

  @override
  void dispose() {
    _snapBackController.dispose();
    _successController.dispose();
    super.dispose();
  }

  double _getProgress(double maxSlideDistance) {
    if (maxSlideDistance <= 0) return 0;
    return (_dragPosition / maxSlideDistance).clamp(0.0, 1.0);
  }

  void _onDragUpdate(DragUpdateDetails details, double maxSlideDistance) {
    if (widget.isCompleted || widget.isPreview) return;

    setState(() {
      _dragPosition += details.delta.dx;
      _dragPosition = _dragPosition.clamp(0, maxSlideDistance);
    });

    // Progressive haptic feedback
    final progress = _getProgress(maxSlideDistance);
    if (progress - _lastHapticProgress >= 0.15) {
      HapticFeedback.selectionClick();
      _lastHapticProgress = progress;
    }
  }

  void _onDragEnd(double maxSlideDistance) {
    if (widget.isCompleted || widget.isPreview) return;

    final progress = _getProgress(maxSlideDistance);
    _lastHapticProgress = 0;

    if (progress >= _completeThreshold) {
      HapticFeedback.heavyImpact();
      widget.onComplete();
      setState(() => _dragPosition = 0);
    } else {
      _snapBackAnimation = Tween<double>(begin: _dragPosition, end: 0).animate(
        CurvedAnimation(parent: _snapBackController, curve: Curves.elasticOut),
      );
      _snapBackController.forward(from: 0).then((_) {
        if (mounted) setState(() => _dragPosition = 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxSlideDistance = maxWidth - _thumbWidth - (_thumbPadding * 2);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: 60,
          decoration: BoxDecoration(
            color: widget.isCompleted ? Colors.green.withAlpha(15) : cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isCompleted
                  ? Colors.green.withAlpha(40)
                  : cs.outline.withAlpha(20),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Progress fill
              if (!widget.isCompleted)
                AnimatedBuilder(
                  animation: _snapBackAnimation,
                  builder: (context, child) {
                    final pos = _snapBackController.isAnimating
                        ? _snapBackAnimation.value
                        : _dragPosition;
                    final progress = maxSlideDistance > 0
                        ? (pos / maxSlideDistance).clamp(0.0, 1.0)
                        : 0.0;

                    return Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress * 0.95 + 0.05,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  cs.inversePrimary.withAlpha(
                                    (progress * 25).round(),
                                  ),
                                  cs.inversePrimary.withAlpha(
                                    (progress * 15).round(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Background content - set info
              if (!widget.isCompleted)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 70, right: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _snapBackAnimation,
                            builder: (context, child) {
                              final pos = _snapBackController.isAnimating
                                  ? _snapBackAnimation.value
                                  : _dragPosition;
                              final progress = maxSlideDistance > 0
                                  ? (pos / maxSlideDistance).clamp(0.0, 1.0)
                                  : 0.0;

                              return Opacity(
                                opacity: (1 - progress * 1.5).clamp(0.0, 1.0),
                                child: child,
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  '${widget.reps} reps',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: cs.inversePrimary,
                                  ),
                                ),
                                if (widget.weight != null) ...[
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    width: 3,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: cs.primary.withAlpha(100),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Text(
                                    '${widget.weight!.toInt()} lbs',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: cs.primary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _snapBackAnimation,
                          builder: (context, child) {
                            final pos = _snapBackController.isAnimating
                                ? _snapBackAnimation.value
                                : _dragPosition;
                            final progress = maxSlideDistance > 0
                                ? (pos / maxSlideDistance).clamp(0.0, 1.0)
                                : 0.0;

                            return Opacity(
                              opacity: (1 - progress * 2).clamp(0.0, 1.0),
                              child: child,
                            );
                          },
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: cs.primary.withAlpha(60),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Completed state
              if (widget.isCompleted)
                GestureDetector(
                  onTap: () {
                    if (widget.onUncomplete != null) {
                      HapticFeedback.lightImpact();
                      widget.onUncomplete!();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedBuilder(
                    animation: _successController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isAnimatingSuccess ? _successScale.value : 1.0,
                        child: Opacity(
                          opacity: _isAnimatingSuccess
                              ? _successOpacity.value
                              : 1.0,
                          child: child,
                        ),
                      );
                    },
                    child: SizedBox.expand(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            // Checkmark with ring
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha(20),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.green.withAlpha(60),
                                  width: 1.5,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  color: Colors.green,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Set ${widget.setNumber}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green.shade700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '${widget.reps} reps${widget.weight != null ? ' · ${widget.weight!.toInt()} lbs' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green.withAlpha(180),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.onUncomplete != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withAlpha(15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.undo_rounded,
                                      color: Colors.green.withAlpha(150),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Undo',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.withAlpha(150),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Slider thumb
              if (!widget.isCompleted)
                AnimatedBuilder(
                  animation: _snapBackAnimation,
                  builder: (context, child) {
                    final pos = _snapBackController.isAnimating
                        ? _snapBackAnimation.value
                        : _dragPosition;

                    return Positioned(
                      left: _thumbPadding + pos,
                      top: _thumbPadding,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) =>
                            _onDragUpdate(details, maxSlideDistance),
                        onHorizontalDragEnd: (_) =>
                            _onDragEnd(maxSlideDistance),
                        child: _SliderThumb(
                          setNumber: widget.setNumber,
                          progress: _getProgress(maxSlideDistance),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SliderThumb extends StatelessWidget {
  final int setNumber;
  final double progress;

  const _SliderThumb({required this.setNumber, required this.progress});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Interpolate color based on progress
    final thumbColor = Color.lerp(
      cs.inversePrimary,
      Colors.green,
      progress > 0.7 ? (progress - 0.7) / 0.3 : 0,
    )!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: _SlideToCompleteState._thumbWidth,
      height: 60 - (_SlideToCompleteState._thumbPadding * 2),
      decoration: BoxDecoration(
        color: thumbColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: thumbColor.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$setNumber',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: cs.secondary,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          // Animated chevrons
          Transform.translate(
            offset: Offset(progress * 3, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: cs.secondary.withAlpha(progress > 0.5 ? 255 : 150),
                ),
                Transform.translate(
                  offset: const Offset(-8, 0),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: cs.secondary.withAlpha(
                      progress > 0.3
                          ? (progress * 255).round().clamp(100, 255)
                          : 80,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;

  const _InfoPill({
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isPrimary ? cs.inversePrimary : cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: isPrimary ? cs.secondary : cs.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
              color: isPrimary ? cs.secondary : cs.inversePrimary,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ContentCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 14, color: cs.primary),
              ),
              const SizedBox(width: 10),
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
          ),
          const SizedBox(height: 18),
          child,
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.inversePrimary.withAlpha(12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: cs.inversePrimary.withAlpha(180),
        ),
      ),
    );
  }
}
