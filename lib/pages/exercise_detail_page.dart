import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

class ExerciseDetailPage extends StatefulWidget {
  final Exercise exercise;
  final WorkoutExercise? workoutExercise;

  const ExerciseDetailPage({
    super.key,
    required this.exercise,
    this.workoutExercise,
  });

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  late List<bool> _completedSets;

  @override
  void initState() {
    super.initState();
    final sets = widget.workoutExercise?.sets ?? 0;
    _completedSets = List.filled(sets, false);
  }

  void _completeSet(int index) {
    setState(() {
      _completedSets[index] = true;
    });
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final padding = MediaQuery.of(context).padding;
    final hasWorkout = widget.workoutExercise != null;
    final completedCount = _completedSets.where((c) => c).length;

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
                  // Back button
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
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    widget.exercise.name,
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
                        label: widget.exercise.primaryMuscle.displayName,
                        isPrimary: true,
                      ),
                      _InfoPill(
                        icon: Icons.sports_gymnastics_rounded,
                        label: widget.exercise.equipment.displayName,
                      ),
                      if (hasWorkout) ...[
                        _InfoPill(
                          icon: Icons.layers_rounded,
                          label: '${widget.workoutExercise!.sets} sets',
                        ),
                        _InfoPill(
                          icon: Icons.repeat_rounded,
                          label: '${widget.workoutExercise!.reps} reps',
                        ),
                        if (widget.workoutExercise!.weight != null)
                          _InfoPill(
                            icon: Icons.fitness_center_rounded,
                            label: '${widget.workoutExercise!.weight!.toInt()} lbs',
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
                if (hasWorkout) ...[
                  _ContentCard(
                    title: 'Sets',
                    icon: Icons.check_circle_outline_rounded,
                    trailing: Text(
                      '$completedCount/${widget.workoutExercise!.sets}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: completedCount == widget.workoutExercise!.sets
                            ? Colors.green
                            : cs.primary,
                      ),
                    ),
                    child: Column(
                      children: List.generate(
                        widget.workoutExercise!.sets,
                        (index) => Padding(
                          padding: EdgeInsets.only(
                            bottom: index < widget.workoutExercise!.sets - 1
                                ? 12
                                : 0,
                          ),
                          child: _SlideToComplete(
                            setNumber: index + 1,
                            reps: widget.workoutExercise!.reps,
                            isCompleted: _completedSets[index],
                            onComplete: () => _completeSet(index),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Secondary muscles
                if (widget.exercise.secondaryMuscles.isNotEmpty) ...[
                  _ContentCard(
                    title: 'Secondary Muscles',
                    icon: Icons.view_list_rounded,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.exercise.secondaryMuscles
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
                    widget.exercise.instructions,
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
      ),
    );
  }
}

class _SlideToComplete extends StatefulWidget {
  final int setNumber;
  final int reps;
  final bool isCompleted;
  final VoidCallback onComplete;

  const _SlideToComplete({
    required this.setNumber,
    required this.reps,
    required this.isCompleted,
    required this.onComplete,
  });

  @override
  State<_SlideToComplete> createState() => _SlideToCompleteState();
}

class _SlideToCompleteState extends State<_SlideToComplete>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (widget.isCompleted) return;

    setState(() {
      _dragPosition += details.delta.dx;
      _dragPosition = _dragPosition.clamp(0, maxWidth - 64);
    });
  }

  void _onDragEnd(double maxWidth) {
    if (widget.isCompleted) return;

    final threshold = maxWidth - 64 - 20;
    if (_dragPosition >= threshold) {
      widget.onComplete();
    } else {
      _animation = Tween<double>(begin: _dragPosition, end: 0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );
      _animationController.forward(from: 0).then((_) {
        setState(() => _dragPosition = 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 56,
          decoration: BoxDecoration(
            color: widget.isCompleted
                ? Colors.green.withAlpha(26)
                : cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isCompleted
                  ? Colors.green.withAlpha(77)
                  : cs.outline.withAlpha(26),
            ),
          ),
          child: Stack(
            children: [
              // Background text with reps
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: widget.isCompleted ? 0 : 1,
                  child: Text(
                    'Slide to complete ${widget.reps} reps',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: cs.primary.withAlpha(102),
                    ),
                  ),
                ),
              ),

              // Completed checkmark
              if (widget.isCompleted)
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Set ${widget.setNumber} Complete',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

              // Slider thumb
              if (!widget.isCompleted)
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final pos = _animationController.isAnimating
                        ? _animation.value
                        : _dragPosition;

                    return Positioned(
                      left: 4 + pos,
                      top: 4,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) =>
                            _onDragUpdate(details, maxWidth),
                        onHorizontalDragEnd: (_) => _onDragEnd(maxWidth),
                        child: Container(
                          width: 56,
                          height: 48,
                          decoration: BoxDecoration(
                            color: cs.inversePrimary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: cs.shadow.withAlpha(51),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Set ${widget.setNumber}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: cs.secondary,
                              ),
                            ),
                          ),
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
          Icon(
            icon,
            size: 15,
            color: isPrimary ? cs.secondary : cs.primary,
          ),
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
  final Widget? trailing;

  const _ContentCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
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
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.inversePrimary.withAlpha(12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: cs.inversePrimary.withAlpha(180),
        ),
      ),
    );
  }
}
