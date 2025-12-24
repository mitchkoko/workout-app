import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/workout_session/presentation/cubits/workout_session_cubit.dart';
import '../features/nutrition/presentation/cubits/nutrition_cubit.dart';
import '../features/nutrition/presentation/cubits/nutrition_states.dart';
import '../features/nutrition/domain/entities/nutrition_entry.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final padding = MediaQuery.of(context).padding;

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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: cs.inversePrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Settings List
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Nutrition Goals Section
                _SectionHeader(title: 'Nutrition Goals'),
                const SizedBox(height: 12),
                BlocBuilder<NutritionCubit, NutritionState>(
                  builder: (context, state) {
                    final goals = state is NutritionLoaded
                        ? state.goals
                        : const NutritionGoals();
                    return _NutritionGoalsTile(goals: goals);
                  },
                ),

                const SizedBox(height: 32),
                _SectionHeader(title: 'Data'),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: Icons.fitness_center_rounded,
                  title: 'Clear Workout History',
                  subtitle: 'Remove all completed workout records',
                  onTap: () => _showClearWorkoutDialog(context),
                ),
                const SizedBox(height: 8),

                _SettingsTile(
                  icon: Icons.restaurant_rounded,
                  title: 'Clear Nutrition Data',
                  subtitle: 'Remove all meal and nutrition records',
                  onTap: () => _showClearNutritionDialog(context),
                ),
                const SizedBox(height: 8),

                _SettingsTile(
                  icon: Icons.delete_forever_rounded,
                  title: 'Clear All Data',
                  subtitle: 'Remove all app data and start fresh',
                  isDestructive: true,
                  onTap: () => _showClearAllDialog(context),
                ),

                const SizedBox(height: 32),
                _SectionHeader(title: 'About'),
                const SizedBox(height: 12),

                _InfoTile(
                  title: 'Storage',
                  subtitle: 'Data is stored on device',
                ),
                const SizedBox(height: 8),
                _InfoTile(title: 'Version', subtitle: '1.0.0'),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearWorkoutDialog(BuildContext context) {
    _showConfirmDialog(
      context,
      title: 'Clear Workout History',
      message:
          'This will remove all completed workout records. This action cannot be undone.',
      onConfirm: () {
        context.read<WorkoutSessionCubit>().clearAllData();
        Navigator.pop(context);
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout history cleared')),
        );
      },
    );
  }

  void _showClearNutritionDialog(BuildContext context) {
    _showConfirmDialog(
      context,
      title: 'Clear Nutrition Data',
      message:
          'This will remove all meal and nutrition records. This action cannot be undone.',
      onConfirm: () {
        context.read<NutritionCubit>().clearAllData();
        Navigator.pop(context);
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nutrition data cleared')));
      },
    );
  }

  void _showClearAllDialog(BuildContext context) {
    _showConfirmDialog(
      context,
      title: 'Clear All Data',
      message:
          'This will remove ALL app data including workouts and nutrition. This action cannot be undone.',
      onConfirm: () {
        context.read<WorkoutSessionCubit>().clearAllData();
        context.read<NutritionCubit>().clearAllData();
        Navigator.pop(context);
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('All data cleared')));
      },
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
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
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cs.inversePrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
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
                        onTap: onConfirm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'Clear',
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: isDestructive
                    ? Colors.red.withAlpha(26)
                    : cs.surface.withAlpha(128),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : cs.inversePrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : cs.inversePrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.primary.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.primary.withAlpha(77),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: cs.inversePrimary,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: cs.primary.withAlpha(153)),
          ),
        ],
      ),
    );
  }
}

class _NutritionGoalsTile extends StatelessWidget {
  final NutritionGoals goals;

  const _NutritionGoalsTile({required this.goals});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showEditGoalsSheet(context, goals);
      },
      child: Container(
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Targets',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: cs.inversePrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to customize your nutrition goals',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.primary.withAlpha(153),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.primary.withAlpha(77),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _GoalChip(
                  label: 'Calories',
                  value: '${goals.calories}',
                  unit: 'kcal',
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _GoalChip(
                  label: 'Protein',
                  value: '${goals.protein}',
                  unit: 'g',
                  color: Colors.red.shade400,
                ),
                const SizedBox(width: 8),
                _GoalChip(
                  label: 'Carbs',
                  value: '${goals.carbs}',
                  unit: 'g',
                  color: Colors.blue.shade400,
                ),
                const SizedBox(width: 8),
                _GoalChip(
                  label: 'Fat',
                  value: '${goals.fat}',
                  unit: 'g',
                  color: Colors.amber.shade600,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGoalsSheet(BuildContext context, NutritionGoals goals) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _EditGoalsSheet(initialGoals: goals),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _GoalChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: cs.primary.withAlpha(153),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: color.withAlpha(180),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditGoalsSheet extends StatefulWidget {
  final NutritionGoals initialGoals;

  const _EditGoalsSheet({required this.initialGoals});

  @override
  State<_EditGoalsSheet> createState() => _EditGoalsSheetState();
}

class _EditGoalsSheetState extends State<_EditGoalsSheet> {
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  int _calculatedCalories = 0;

  @override
  void initState() {
    super.initState();
    _proteinController = TextEditingController(
      text: widget.initialGoals.protein.toString(),
    );
    _carbsController = TextEditingController(
      text: widget.initialGoals.carbs.toString(),
    );
    _fatController = TextEditingController(
      text: widget.initialGoals.fat.toString(),
    );

    // Add listeners to recalculate calories
    _proteinController.addListener(_updateCalories);
    _carbsController.addListener(_updateCalories);
    _fatController.addListener(_updateCalories);

    _updateCalories();
  }

  void _updateCalories() {
    final protein = int.tryParse(_proteinController.text) ?? 0;
    final carbs = int.tryParse(_carbsController.text) ?? 0;
    final fat = int.tryParse(_fatController.text) ?? 0;
    setState(() {
      _calculatedCalories = (protein * 4) + (carbs * 4) + (fat * 9);
    });
  }

  @override
  void dispose() {
    _proteinController.removeListener(_updateCalories);
    _carbsController.removeListener(_updateCalories);
    _fatController.removeListener(_updateCalories);
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _saveGoals() {
    final goals = NutritionGoals(
      calories: _calculatedCalories,
      protein: int.tryParse(_proteinController.text) ?? 150,
      carbs: int.tryParse(_carbsController.text) ?? 200,
      fat: int.tryParse(_fatController.text) ?? 65,
    );

    context.read<NutritionCubit>().updateGoals(goals);
    HapticFeedback.mediumImpact();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nutrition goals updated'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Targets',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: cs.inversePrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Calories auto-calculate from macros',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.primary.withAlpha(153),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Auto-calculated Calories Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withAlpha(30),
                    Colors.orange.withAlpha(15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withAlpha(60)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$_calculatedCalories',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'kcal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Macros Row
            Row(
              children: [
                Expanded(
                  child: _GoalInputField(
                    controller: _proteinController,
                    label: 'Protein',
                    unit: 'g',
                    color: Colors.red.shade400,
                    multiplier: 4,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GoalInputField(
                    controller: _carbsController,
                    label: 'Carbs',
                    unit: 'g',
                    color: Colors.blue.shade400,
                    multiplier: 4,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GoalInputField(
                    controller: _fatController,
                    label: 'Fat',
                    unit: 'g',
                    color: Colors.amber.shade600,
                    multiplier: 9,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Save Button
            GestureDetector(
              onTap: _saveGoals,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: cs.inversePrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Save Goals',
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

class _GoalInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String unit;
  final Color color;
  final int? multiplier;

  const _GoalInputField({
    required this.controller,
    required this.label,
    required this.unit,
    required this.color,
    this.multiplier,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.primary.withAlpha(179),
              ),
            ),
            if (multiplier != null)
              Text(
                '×$multiplier kcal',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: color.withAlpha(150),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cs.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(60), width: 1.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.inversePrimary,
            ),
            decoration: InputDecoration(
              suffixText: unit,
              suffixStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: cs.primary.withAlpha(128),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
