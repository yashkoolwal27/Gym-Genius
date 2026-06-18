import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/ai_service.dart';
import '../../widgets/shared_widgets.dart';

class AdminDbScreen extends StatefulWidget {
  const AdminDbScreen({super.key});

  @override
  State<AdminDbScreen> createState() => _AdminDbScreenState();
}

class _AdminDbScreenState extends State<AdminDbScreen> with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  final _aiService = AIService();
  late TabController _tabController;
  final _aiQueryController = TextEditingController();
  bool _isAiGenerating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _aiQueryController.dispose();
    super.dispose();
  }

  Future<void> _generateFoodWithGemini() async {
    final query = _aiQueryController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isAiGenerating = true);

    try {
      final generatedFood = await _aiService.generateFoodItemFromQuery(query);
      
      if (mounted) {
        _aiQueryController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gemini successfully generated food details! Previewing... 🤖'),
            backgroundColor: AppColors.success,
          ),
        );
        _showEditFoodDialog(generatedFood, null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate food: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAiGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Database Portal', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'PENDING REVIEWS', icon: Icon(Icons.rate_review_rounded, size: 20)),
            Tab(text: 'DATABASE LOGS & FOODS', icon: Icon(Icons.receipt_long_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingReviewsTab(),
          _buildDatabaseLogsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Food', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showEditFoodDialog(null, null),
      ),
    );
  }

  Widget _buildPendingReviewsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getPendingReviewsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading reviews: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
        }
        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.done_all_rounded, color: AppColors.primary, size: 64),
                SizedBox(height: 16),
                Text('No pending food reviews!', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('All community submissions are resolved.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            final reviewId = review['reviewId'] as String;
            final submittedBy = review['submittedBy'] as String;
            final foodData = Map<String, dynamic>.from(review['food'] ?? {});
            final food = FoodItem.fromMap(foodData);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (food.imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              food.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: AppColors.border,
                                child: const Icon(Icons.restaurant_rounded, color: AppColors.textSecondary),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.restaurant_rounded, color: AppColors.textSecondary),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Serving Size: ${food.servingSize}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Submitted by: $submittedBy',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMacroIndicator('Cal', food.calories, AppColors.accent),
                        _buildMacroIndicator('Prot', food.protein, AppColors.primary),
                        _buildMacroIndicator('Carb', food.carbs, AppColors.warning),
                        _buildMacroIndicator('Fat', food.fat, AppColors.error),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showRejectDialog(reviewId),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.error),
                              foregroundColor: AppColors.error,
                              minimumSize: const Size(0, 40),
                            ),
                            child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showEditFoodDialog(food, reviewId),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              foregroundColor: AppColors.primary,
                              minimumSize: const Size(0, 40),
                            ),
                            child: const Text('Edit & Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _approveReviewDirectly(reviewId, food),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(0, 40),
                            ),
                            child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDatabaseLogsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gemini AI Auto-Generator Box
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.blue, Colors.purpleAccent, Colors.pinkAccent],
                      ).createShader(bounds),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ADD WITH GEMINI AI',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Describe the food item you want to add, and Gemini will automatically generate all macro/micronutrients, serving measures, and image URL.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _aiQueryController,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: "e.g., 'Add standard single egg omelette'",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isAiGenerating ? null : _generateFoodWithGemini,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      child: _isAiGenerating
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Icon(Icons.arrow_forward_rounded, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'ADMIN CREATED/APPROVED FOODS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<FoodItem>>(
            stream: _firestoreService.getAdminFoodsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              final foods = snapshot.data ?? [];
              if (foods.isEmpty) {
                return const AppCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Text('No admin-created foods yet.', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  ),
                );
              }
              return Column(
                children: foods.map((food) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        subtitle: Text('${food.calories.toStringAsFixed(0)} kcal | ${food.servingSize}', style: const TextStyle(color: AppColors.textSecondary)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                              onPressed: () => _showEditFoodDialog(food, null),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                              onPressed: () => _deleteAdminFood(food.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'AUDIT TRAIL LOGS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firestoreService.getAdminLogsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              final logs = snapshot.data ?? [];
              if (logs.isEmpty) {
                return const AppCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Text('No audit logs recorded.', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  ),
                );
              }
              return Column(
                children: logs.map((log) {
                  final action = log['action'] ?? '';
                  final foodId = log['foodId'] ?? '';
                  final details = log['details'] as Map<dynamic, dynamic>? ?? {};
                  final timestamp = log['timestamp'] as dynamic;
                  String dateStr = '';
                  if (timestamp != null && timestamp is Timestamp) {
                    dateStr = timestamp.toDate().toLocal().toString().substring(0, 16);
                  }

                  IconData logIcon = Icons.info_rounded;
                  Color logColor = AppColors.textSecondary;
                  String logText = '';

                  switch (action) {
                    case 'food_approve':
                      logIcon = Icons.check_circle_rounded;
                      logColor = AppColors.success;
                      logText = 'Approved Review: ${details['approvedName'] ?? foodId}';
                      break;
                    case 'food_reject':
                      logIcon = Icons.cancel_rounded;
                      logColor = AppColors.error;
                      logText = 'Rejected Review: $foodId (${details['reason'] ?? 'no reason'})';
                      break;
                    case 'food_create':
                      logIcon = Icons.add_circle_rounded;
                      logColor = AppColors.primary;
                      logText = 'Created Food: ${details['name'] ?? foodId}';
                      break;
                    case 'food_edit':
                      logIcon = Icons.edit_rounded;
                      logColor = AppColors.warning;
                      logText = 'Edited Food: ${details['name'] ?? foodId}';
                      break;
                    case 'food_delete':
                      logIcon = Icons.delete_rounded;
                      logColor = AppColors.error;
                      logText = 'Deleted Food: $foodId';
                      break;
                    default:
                      logText = 'Action: $action on $foodId';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(logIcon, color: logColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(logText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                                if (dateStr.isNotEmpty)
                                  Text(dateStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMacroIndicator(String label, double val, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          val.toStringAsFixed(0),
          style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Future<void> _approveReviewDirectly(String reviewId, FoodItem food) async {
    try {
      await _firestoreService.approveFoodReview(reviewId, food);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food item approved & published! ✅'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _deleteAdminFood(String foodId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Delete Food Item?'),
        content: const Text('This will permanently delete this food item from foods_master and admin_foods. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.deleteAdminFood(foodId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Food item deleted successfully!'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  Future<void> _showRejectDialog(String reviewId) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Reject Submission'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Enter reason (e.g., duplicate, incorrect macros)',
            fillColor: AppColors.background,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reject', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirm == true && reasonController.text.trim().isNotEmpty) {
      try {
        await _firestoreService.rejectFoodReview(reviewId, reasonController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submission rejected.'), backgroundColor: AppColors.error),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error rejecting: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  // Double-purpose dialog: creates a new food OR edits an existing one
  Future<void> _showEditFoodDialog(FoodItem? existingFood, String? reviewId) async {
    final nameCtrl = TextEditingController(text: existingFood?.name ?? '');
    final servingSizeCtrl = TextEditingController(text: existingFood?.servingSize ?? '100g');
    final caloriesCtrl = TextEditingController(text: existingFood?.calories.toStringAsFixed(0) ?? '0');
    final proteinCtrl = TextEditingController(text: existingFood?.protein.toStringAsFixed(1) ?? '0.0');
    final carbsCtrl = TextEditingController(text: existingFood?.carbs.toStringAsFixed(1) ?? '0.0');
    final fatCtrl = TextEditingController(text: existingFood?.fat.toStringAsFixed(1) ?? '0.0');
    final fiberCtrl = TextEditingController(text: existingFood?.fiber.toStringAsFixed(1) ?? '0.0');
    final sugarCtrl = TextEditingController(text: existingFood?.sugar.toStringAsFixed(1) ?? '0.0');
    final sodiumCtrl = TextEditingController(text: existingFood?.sodium.toStringAsFixed(1) ?? '0.0');
    final imageCtrl = TextEditingController(text: existingFood?.imageUrl ?? '');

    List<ServingMeasure> servings = List.from(existingFood?.servings ?? []);
    if (servings.isEmpty) {
      servings.add(ServingMeasure(name: '100g', grams: 100.0, multiplier: 1.0));
    }

    final isEditMode = existingFood != null;
    File? dialogPickedImage;
    final picker = ImagePicker();
    bool isDialogSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              maxChildSize: 0.95,
              minChildSize: 0.7,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEditMode ? 'Edit Food Details' : 'Create Food Item',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Food Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: servingSizeCtrl,
                        decoration: const InputDecoration(labelText: 'Default Serving Size Label (e.g. 100g)'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: caloriesCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: proteinCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Protein (g)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: carbsCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Carbs (g)'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: fatCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Fat (g)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: fiberCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Fiber (g)'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: sugarCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Sugar (g)'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: sodiumCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Sodium (mg)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: imageCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Image URL (Optional)',
                                hintText: 'https://...',
                              ),
                              onChanged: (val) {
                                setModalState(() {});
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: isDialogSaving
                                ? null
                                : () async {
                                    final source = await showModalBottomSheet<ImageSource>(
                                      context: context,
                                      backgroundColor: AppColors.cardBg,
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                      builder: (context) => SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Text(
                                                'Select Image Source',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                              ),
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                                              title: const Text('Take Photo (Camera)', style: TextStyle(color: AppColors.textPrimary)),
                                              onTap: () => Navigator.pop(context, ImageSource.camera),
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                                              title: const Text('Choose from Gallery', style: TextStyle(color: AppColors.textPrimary)),
                                              onTap: () => Navigator.pop(context, ImageSource.gallery),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );

                                    if (source != null) {
                                      try {
                                        final pickedFile = await picker.pickImage(
                                          source: source,
                                          maxWidth: 1024,
                                          maxHeight: 1024,
                                          imageQuality: 85,
                                        );
                                        if (pickedFile != null) {
                                          setModalState(() {
                                            dialogPickedImage = File(pickedFile.path);
                                          });
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error picking image: $e'), backgroundColor: AppColors.error),
                                          );
                                        }
                                      }
                                    }
                                  },
                            child: Container(
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: dialogPickedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(dialogPickedImage!, fit: BoxFit.cover),
                                    )
                                  : (imageCtrl.text.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            imageCtrl.text,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.add_a_photo_rounded, color: AppColors.primary),
                                          ),
                                        )
                                      : const Icon(Icons.add_a_photo_rounded, color: AppColors.primary)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'SERVING MEASURES (SCALING OPTIONS)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          ...List.generate(servings.length, (index) {
                            final measure = servings[index];
                            final nameController = TextEditingController(text: measure.name);
                            final gramsController = TextEditingController(text: measure.grams.toStringAsFixed(0));
                            final multiplierController = TextEditingController(text: measure.multiplier.toStringAsFixed(2));

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: nameController,
                                      decoration: const InputDecoration(hintText: 'e.g. 1 Cup', contentPadding: EdgeInsets.all(6)),
                                      onChanged: (val) {
                                        servings[index] = ServingMeasure(
                                          name: val,
                                          grams: servings[index].grams,
                                          multiplier: servings[index].multiplier,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: gramsController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(hintText: 'Grams', contentPadding: EdgeInsets.all(6)),
                                      onChanged: (val) {
                                        final g = double.tryParse(val) ?? 0.0;
                                        servings[index] = ServingMeasure(
                                          name: servings[index].name,
                                          grams: g,
                                          multiplier: servings[index].multiplier,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: multiplierController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(hintText: 'Mult.', contentPadding: EdgeInsets.all(6)),
                                      onChanged: (val) {
                                        final m = double.tryParse(val) ?? 1.0;
                                        servings[index] = ServingMeasure(
                                          name: servings[index].name,
                                          grams: servings[index].grams,
                                          multiplier: m,
                                        );
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_rounded, color: AppColors.error),
                                    onPressed: () {
                                      setModalState(() {
                                        servings.removeAt(index);
                                      });
                                    },
                                  )
                                ],
                              ),
                            );
                          }),
                          TextButton.icon(
                            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                            label: const Text('Add Serving Measure', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              setModalState(() {
                                servings.add(ServingMeasure(name: '', grams: 0.0, multiplier: 1.0));
                              });
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isDialogSaving
                            ? null
                            : () async {
                                final foodId = existingFood?.id ?? 'admin_${DateTime.now().millisecondsSinceEpoch}';
                                setModalState(() {
                                  isDialogSaving = true;
                                });

                                String finalImageUrl = imageCtrl.text.trim();
                                if (dialogPickedImage != null) {
                                  try {
                                    finalImageUrl = await _firestoreService.uploadFoodImage(foodId, dialogPickedImage!);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to upload image: $e'), backgroundColor: AppColors.error),
                                      );
                                    }
                                    setModalState(() {
                                      isDialogSaving = false;
                                    });
                                    return;
                                  }
                                }

                                final food = FoodItem(
                                  id: foodId,
                                  name: nameCtrl.text.trim(),
                                  servingSize: servingSizeCtrl.text.trim(),
                                  calories: double.tryParse(caloriesCtrl.text) ?? 0.0,
                                  protein: double.tryParse(proteinCtrl.text) ?? 0.0,
                                  carbs: double.tryParse(carbsCtrl.text) ?? 0.0,
                                  fat: double.tryParse(fatCtrl.text) ?? 0.0,
                                  fiber: double.tryParse(fiberCtrl.text) ?? 0.0,
                                  sugar: double.tryParse(sugarCtrl.text) ?? 0.0,
                                  sodium: double.tryParse(sodiumCtrl.text) ?? 0.0,
                                  imageUrl: finalImageUrl,
                                  lastUpdated: DateTime.now().toIso8601String(),
                                  servings: servings.where((s) => s.name.isNotEmpty).toList(),
                                );

                                try {
                                  if (reviewId != null) {
                                    // Approval flow from community submission
                                    await _firestoreService.approveFoodReview(reviewId, food);
                                  } else {
                                    // Direct Admin Create or Edit flow
                                    if (isEditMode) {
                                      await _firestoreService.editAdminFood(food);
                                    } else {
                                      await _firestoreService.addAdminCreatedFood(food);
                                    }
                                  }
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isEditMode ? 'Food updated successfully! ✅' : 'Food created and published! ✅'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error saving food: $e'), backgroundColor: AppColors.error),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setModalState(() {
                                      isDialogSaving = false;
                                    });
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: isDialogSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : Text(
                                reviewId != null ? 'Approve with Changes' : (isEditMode ? 'Save Changes' : 'Publish Food'),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
