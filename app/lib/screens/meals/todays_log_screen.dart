import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';

class TodaysLogScreen extends StatefulWidget {
  const TodaysLogScreen({super.key});

  @override
  State<TodaysLogScreen> createState() => _TodaysLogScreenState();
}

class _TodaysLogScreenState extends State<TodaysLogScreen> {
  final _firestoreService = FirestoreService();
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _deleteEntry(String entryId) async {
    await _firestoreService.deleteMealEntry(entryId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal log removed'), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final displayDate = DateFormat('dd MMMM yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Today's Log"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: AppColors.primary),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
                ),
                Text(
                  displayDate,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primary),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: _selectedDate.day == DateTime.now().day &&
                          _selectedDate.month == DateTime.now().month &&
                          _selectedDate.year == DateTime.now().year
                      ? null
                      : () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<MealEntry>>(
              stream: _firestoreService.getMealEntriesStream(dateStr),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                final entries = snapshot.data ?? [];
                if (entries.isEmpty) {
                  return const EmptyState(
                    icon: Icons.receipt_long,
                    title: 'No entries for this day',
                    subtitle: 'Use the dashboard to search and log food items.',
                  );
                }

                // Group entries by Meal Category
                final breakfast = entries.where((e) => e.mealType == 'Breakfast').toList();
                final lunch = entries.where((e) => e.mealType == 'Lunch').toList();
                final dinner = entries.where((e) => e.mealType == 'Dinner').toList();
                final snacks = entries.where((e) => e.mealType == 'Snacks').toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    if (breakfast.isNotEmpty) _buildMealCategorySection('Breakfast', breakfast),
                    if (lunch.isNotEmpty) _buildMealCategorySection('Lunch', lunch),
                    if (dinner.isNotEmpty) _buildMealCategorySection('Dinner', dinner),
                    if (snacks.isNotEmpty) _buildMealCategorySection('Snacks', snacks),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCategorySection(String title, List<MealEntry> list) {
    double totalCalories = list.fold(0.0, (sum, item) => sum + item.calories);
    double totalProtein = list.fold(0.0, (sum, item) => sum + item.protein);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            Text(
              '${totalCalories.toStringAsFixed(0)} kcal • ${totalProtein.toStringAsFixed(0)}g Protein',
              style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: list.map((entry) {
            return Dismissible(
              key: Key(entry.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => _deleteEntry(entry.id),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          entry.imageUrl.isNotEmpty ? entry.imageUrl : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100',
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.foodName,
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${entry.quantity.toStringAsFixed(1)} x ${entry.servingUnit}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.calories.toStringAsFixed(0)} kcal',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          Text(
                            '${entry.protein.toStringAsFixed(0)}g P',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
