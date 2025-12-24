import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../data/exercise_database.dart';
import '../features/workout/presentation/cubits/workout_cubit.dart';

class EditWorkoutPage extends StatefulWidget {
  final Workout workout;

  const EditWorkoutPage({super.key, required this.workout});

  @override
  State<EditWorkoutPage> createState() => _EditWorkoutPageState();
}

class _EditWorkoutPageState extends State<EditWorkoutPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late List<WorkoutExercise> _exercises;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workout.name);
    _descriptionController =
        TextEditingController(text: widget.workout.description ?? '');
    _exercises = List.from(widget.workout.exercises);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addExercise() async {
    final result = await showModalBottomSheet<WorkoutExercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ExercisePickerSheet(),
    );

    if (result != null) {
      setState(() => _exercises.add(result));
    }
  }

  void _editExercise(int index) async {
    final workoutExercise = _exercises[index];
    final result = await showModalBottomSheet<WorkoutExercise?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditExerciseSheet(
        workoutExercise: workoutExercise,
        onDelete: () {
          Navigator.pop(context);
          setState(() => _exercises.removeAt(index));
        },
      ),
    );

    if (result != null) {
      setState(() => _exercises[index] = result);
    }
  }

  void _saveWorkout() {
    final cs = Theme.of(context).colorScheme;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a workout name',
            style: TextStyle(color: cs.secondary),
          ),
          backgroundColor: cs.inversePrimary,
        ),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please add at least one exercise',
            style: TextStyle(color: cs.secondary),
          ),
          backgroundColor: cs.inversePrimary,
        ),
      );
      return;
    }

    final editedWorkout = widget.workout.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      exercises: _exercises,
    );

    context.read<WorkoutCubit>().saveEditedWorkout(widget.workout, editedWorkout);

    // Pop back to the workout list
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final padding = MediaQuery.of(context).padding;
    final isPreset = !widget.workout.isCustom;

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
                            Icons.close_rounded,
                            color: cs.inversePrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _saveWorkout();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: cs.inversePrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: cs.secondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Edit Workout',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: cs.inversePrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (isPreset) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Editing will save as a custom workout',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Form
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Name field
                _InputField(
                  controller: _nameController,
                  label: 'Workout Name',
                  hint: 'e.g. Morning Push Day',
                ),
                const SizedBox(height: 16),

                // Description field
                _InputField(
                  controller: _descriptionController,
                  label: 'Description (optional)',
                  hint: 'e.g. Chest, shoulders, and triceps',
                  maxLines: 2,
                ),
                const SizedBox(height: 28),

                // Exercises section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CardHeader(
                      title: 'Exercises',
                      icon: Icons.fitness_center_rounded,
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _addExercise();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: cs.inversePrimary.withAlpha(26),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: cs.inversePrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: cs.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_exercises.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: cs.secondary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: cs.outline.withAlpha(26),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            size: 32,
                            color: cs.primary.withAlpha(128),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No exercises added',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _exercises.length,
                    onReorder: (oldIndex, newIndex) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _exercises.removeAt(oldIndex);
                        _exercises.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final workoutExercise = _exercises[index];
                      return _ExerciseListItem(
                        key: ValueKey('${workoutExercise.exercise.id}_$index'),
                        index: index + 1,
                        workoutExercise: workoutExercise,
                        onTap: () => _editExercise(index),
                      );
                    },
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: cs.primary.withAlpha(153),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cs.secondary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outline.withAlpha(26)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: cs.inversePrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: cs.primary.withAlpha(102)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
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

class _ExerciseListItem extends StatelessWidget {
  final int index;
  final WorkoutExercise workoutExercise;
  final VoidCallback onTap;

  const _ExerciseListItem({
    super.key,
    required this.index,
    required this.workoutExercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.secondary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.inversePrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.secondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workoutExercise.exercise.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.inversePrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Chip(label: '${workoutExercise.sets} sets'),
                      _Chip(label: '${workoutExercise.reps} reps'),
                      if (workoutExercise.weight != null)
                        _Chip(label: '${workoutExercise.weight!.toInt()} lbs'),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ReorderableDragStartListener(
                index: index - 1,
                child: Icon(
                  Icons.drag_handle_rounded,
                  color: cs.primary.withAlpha(100),
                  size: 18,
                ),
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: cs.inversePrimary,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// Exercise picker that lets user set sets/reps before adding
class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet();

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  String _searchQuery = '';
  MuscleGroup? _selectedMuscle;

  List<Exercise> get _filteredExercises {
    return exerciseDatabase.where((exercise) {
      final matchesSearch =
          exercise.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesMuscle =
          _selectedMuscle == null || exercise.primaryMuscle == _selectedMuscle;
      return matchesSearch && matchesMuscle;
    }).toList();
  }

  void _selectExercise(Exercise exercise) async {
    final result = await showModalBottomSheet<WorkoutExercise>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SetSetsRepsSheet(exercise: exercise),
    );

    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outline.withAlpha(100),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Exercise',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: cs.inversePrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.close_rounded, color: cs.primary, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: cs.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    style: TextStyle(
                      color: cs.inversePrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      hintStyle: TextStyle(
                        color: cs.primary.withAlpha(100),
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: cs.primary.withAlpha(100),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(height: 16),
                // Filter chips
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _selectedMuscle == null,
                        onTap: () => setState(() => _selectedMuscle = null),
                      ),
                      const SizedBox(width: 6),
                      ...MuscleGroup.values.map((muscle) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _FilterChip(
                              label: muscle.displayName,
                              isSelected: _selectedMuscle == muscle,
                              onTap: () => setState(() => _selectedMuscle =
                                  _selectedMuscle == muscle ? null : muscle),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Exercise list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: _filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = _filteredExercises[index];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _selectExercise(exercise);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: cs.secondary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: cs.inversePrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _MiniChip(label: exercise.primaryMuscle.displayName),
                                  const SizedBox(width: 6),
                                  _MiniChip(label: exercise.equipment.displayName),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cs.inversePrimary.withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: cs.inversePrimary,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;

  const _MiniChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: cs.primary,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.inversePrimary : cs.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? cs.secondary : cs.primary,
          ),
        ),
      ),
    );
  }
}

// Sheet to set sets/reps before adding exercise
class _SetSetsRepsSheet extends StatefulWidget {
  final Exercise exercise;

  const _SetSetsRepsSheet({required this.exercise});

  @override
  State<_SetSetsRepsSheet> createState() => _SetSetsRepsSheetState();
}

class _SetSetsRepsSheetState extends State<_SetSetsRepsSheet> {
  int _sets = 3;
  int _reps = 10;
  int _weight = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomPadding),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outline.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.exercise.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: cs.inversePrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.exercise.primaryMuscle.displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 24),
            _buildCounterRow('Sets', _sets, (v) => setState(() => _sets = v), 1),
            _buildCounterRow('Reps', _reps, (v) => setState(() => _reps = v), 1),
            _buildCounterRow('Weight', _weight, (v) => setState(() => _weight = v), 0, step: 5),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(
                  context,
                  WorkoutExercise(
                    exercise: widget.exercise,
                    sets: _sets,
                    reps: _reps,
                    weight: _weight > 0 ? _weight.toDouble() : null,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: cs.inversePrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Add Exercise',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

  Widget _buildCounterRow(String label, int value, ValueChanged<int> onChanged, int min, {int step = 1}) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: cs.inversePrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: value > min
                ? () {
                    HapticFeedback.lightImpact();
                    onChanged(value - step);
                  }
                : null,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: value > min ? cs.inversePrimary : cs.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.remove_rounded,
                size: 16,
                color: value > min ? cs.secondary : cs.primary.withAlpha(60),
              ),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.inversePrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(value + step);
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cs.inversePrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 16,
                color: cs.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditExerciseSheet extends StatefulWidget {
  final WorkoutExercise workoutExercise;
  final VoidCallback onDelete;

  const _EditExerciseSheet({
    required this.workoutExercise,
    required this.onDelete,
  });

  @override
  State<_EditExerciseSheet> createState() => _EditExerciseSheetState();
}

class _EditExerciseSheetState extends State<_EditExerciseSheet> {
  late int _sets;
  late int _reps;
  late int _weight;

  @override
  void initState() {
    super.initState();
    _sets = widget.workoutExercise.sets;
    _reps = widget.workoutExercise.reps;
    _weight = widget.workoutExercise.weight?.toInt() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomPadding),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outline.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.workoutExercise.exercise.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: cs.inversePrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.workoutExercise.exercise.primaryMuscle.displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 24),
            _buildCounterRow('Sets', _sets, (v) => setState(() => _sets = v), 1),
            _buildCounterRow('Reps', _reps, (v) => setState(() => _reps = v), 1),
            _buildCounterRow('Weight', _weight, (v) => setState(() => _weight = v), 0, step: 5),
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onDelete();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red.withAlpha(200),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(
                        context,
                        widget.workoutExercise.copyWith(
                          sets: _sets,
                          reps: _reps,
                          weight: _weight > 0 ? _weight.toDouble() : null,
                          clearWeight: _weight == 0,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: cs.inversePrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: cs.secondary,
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
    );
  }

  Widget _buildCounterRow(String label, int value, ValueChanged<int> onChanged, int min, {int step = 1}) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: cs.inversePrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: value > min
                ? () {
                    HapticFeedback.lightImpact();
                    onChanged(value - step);
                  }
                : null,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: value > min ? cs.inversePrimary : cs.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.remove_rounded,
                size: 16,
                color: value > min ? cs.secondary : cs.primary.withAlpha(60),
              ),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.inversePrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(value + step);
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cs.inversePrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 16,
                color: cs.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
