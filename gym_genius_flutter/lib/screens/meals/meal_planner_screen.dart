import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/ai_service.dart';
import '../../widgets/shared_widgets.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meal Planner'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'AI Generator'),
            Tab(text: 'Meal History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MealGeneratorTab(),
          _MealHistoryTab(),
        ],
      ),
    );
  }
}

class _MealGeneratorTab extends StatefulWidget {
  const _MealGeneratorTab();

  @override
  State<_MealGeneratorTab> createState() => _MealGeneratorTabState();
}

class _MealGeneratorTabState extends State<_MealGeneratorTab> {
  final _aiService = AIService();
  final _firestoreService = FirestoreService();

  String _fitnessGoal = 'Weight Loss';
  String _macroPreference = 'High Protein';
  String _mealType = 'Lunch';
  String _foodCategory = 'Proteins';
  bool _isGenerating = false;
  String? _generatedPlan;

  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _generatedPlan = null;
    });
    try {
      final plan = await _aiService.generateMealPlan(
        fitnessGoal: _fitnessGoal,
        macroPreference: _macroPreference,
        mealType: _mealType,
        foodCategory: _foodCategory,
      );
      setState(() => _generatedPlan = plan);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _savePlan() async {
    if (_generatedPlan == null) return;
    await _firestoreService.saveMealPlan(StoredPlan(
      id: const Uuid().v4(),
      generatedPlan: _generatedPlan!,
      createdAt: DateTime.now().toIso8601String(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal plan saved! ✅'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customize Your Meal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                const Text('Fitness Goal', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.fitnessGoals.map((g) => _ChoiceChip(
                    label: g,
                    selected: _fitnessGoal == g,
                    onTap: () => setState(() => _fitnessGoal = g),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Macro Preference', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.macroOptions.map((m) => _ChoiceChip(
                    label: m,
                    selected: _macroPreference == m,
                    onTap: () => setState(() => _macroPreference = m),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Meal Type', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.mealTypes.map((t) => _ChoiceChip(
                    label: t,
                    selected: _mealType == t,
                    onTap: () => setState(() => _mealType = t),
                  )).toList(),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: _isGenerating ? 'Generating...' : 'Generate Meal Plan',
                  onPressed: _isGenerating ? null : _generate,
                  isLoading: _isGenerating,
                  icon: Icons.restaurant_menu,
                ),
              ],
            ),
          ),
          if (_generatedPlan != null) ...[
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your AI Meal Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      IconButton(icon: const Icon(Icons.save_outlined, color: AppColors.primary), onPressed: _savePlan),
                    ],
                  ),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),
                  Text(_generatedPlan!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MealHistoryTab extends StatefulWidget {
  const _MealHistoryTab();

  @override
  State<_MealHistoryTab> createState() => _MealHistoryTabState();
}

class _MealHistoryTabState extends State<_MealHistoryTab> {
  final _firestoreService = FirestoreService();

  void _showAddMealSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddMealSheet(onSaved: () => setState(() {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMealSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Log Meal', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<MealLog>>(
        stream: _firestoreService.getMealLogsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return const EmptyState(
              icon: Icons.restaurant,
              title: 'No meals logged',
              subtitle: 'Start tracking your nutrition today!',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: logs.length,
            itemBuilder: (_, i) => _MealLogCard(log: logs[i], onDelete: () => _firestoreService.deleteMealLog(logs[i].id)),
          );
        },
      ),
    );
  }
}

class _MealLogCard extends StatelessWidget {
  final MealLog log;
  final VoidCallback onDelete;
  const _MealLogCard({required this.log, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.accentOrange.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.restaurant, color: AppColors.accentOrange, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.mealType, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text('${log.date} • ${log.foodCategory}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 18), onPressed: onDelete),
              ],
            ),
            const Divider(color: AppColors.border),
            Text(log.mealDetails, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(log.macronutrients, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMealSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddMealSheet({required this.onSaved});

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  final _firestoreService = FirestoreService();
  final _detailsController = TextEditingController();
  final _macrosController = TextEditingController();
  String _mealType = 'Lunch';
  String _category = 'Proteins';
  bool _isSaving = false;

  Future<void> _save() async {
    if (_detailsController.text.isEmpty) return;
    setState(() => _isSaving = true);
    final log = MealLog(
      id: const Uuid().v4(),
      createdAt: DateTime.now().toIso8601String(),
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      mealType: _mealType,
      macronutrients: _macrosController.text,
      fitnessGoals: 'Maintenance',
      foodCategory: _category,
      mealDetails: _detailsController.text,
    );
    await _firestoreService.addMealLog(log);
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Log New Meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _mealType,
            dropdownColor: AppColors.cardBg,
            decoration: const InputDecoration(labelText: 'Meal Type'),
            items: AppConstants.mealTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _mealType = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _detailsController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'What did you eat?', hintText: 'e.g. Grilled chicken breast with brown rice and broccoli'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _macrosController,
            decoration: const InputDecoration(labelText: 'Macros (Optional)', hintText: 'e.g. 450 kcal, 40g P, 30g C, 12g F'),
          ),
          const SizedBox(height: 24),
          GradientButton(text: 'Save Meal', onPressed: _isSaving ? null : _save, isLoading: _isSaving, icon: Icons.save),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary, fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
        ),
      ),
    );
  }
}
