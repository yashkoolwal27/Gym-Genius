import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _firestoreService = FirestoreService();
  List<WeightLog> _weightLogs = [];
  List<WorkoutLog> _workoutLogs = [];
  bool _isLoading = true;
  String _selectedTimeframe = 'Week'; // 'Week', 'Month', 'Year'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final weights = await _firestoreService.getWeightLogs();
      final workouts = await _firestoreService.getWorkoutLogs();
      if (mounted) {
        setState(() {
          _weightLogs = weights;
          _workoutLogs = workouts;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> get _xAxisLabels {
    if (_selectedTimeframe == 'Week') {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else if (_selectedTimeframe == 'Month') {
      return ['W1', 'W2', 'W3', 'W4', 'W5'];
    } else {
      return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    }
  }

  Map<int, double> get _timeframeVolume {
    final Map<int, double> volume = {};
    final now = DateTime.now();

    if (_selectedTimeframe == 'Week') {
      for (int i = 1; i <= 7; i++) volume[i] = 0.0;
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);

      for (final log in _workoutLogs) {
        try {
          final date = DateTime.parse(log.date);
          if (date.isAfter(weekStartDay.subtract(const Duration(days: 1)))) {
            double logVolume = 0.0;
            for (final ex in log.exercises) {
              for (final s in ex.sets) {
                final w = double.tryParse(s.weight) ?? 0.0;
                final r = double.tryParse(s.reps) ?? 0.0;
                logVolume += w * r;
              }
            }
            volume[date.weekday] = (volume[date.weekday] ?? 0.0) + logVolume;
          }
        } catch (_) {}
      }
    } else if (_selectedTimeframe == 'Month') {
      for (int i = 1; i <= 5; i++) volume[i] = 0.0;
      final monthStart = DateTime(now.year, now.month, 1);

      for (final log in _workoutLogs) {
        try {
          final date = DateTime.parse(log.date);
          if (date.isAfter(monthStart.subtract(const Duration(days: 1))) && date.month == now.month && date.year == now.year) {
            double logVolume = 0.0;
            for (final ex in log.exercises) {
              for (final s in ex.sets) {
                final w = double.tryParse(s.weight) ?? 0.0;
                final r = double.tryParse(s.reps) ?? 0.0;
                logVolume += w * r;
              }
            }
            final weekIdx = ((date.day - 1) ~/ 7) + 1;
            volume[weekIdx] = (volume[weekIdx] ?? 0.0) + logVolume;
          }
        } catch (_) {}
      }
    } else {
      for (int i = 1; i <= 12; i++) volume[i] = 0.0;
      for (final log in _workoutLogs) {
        try {
          final date = DateTime.parse(log.date);
          if (date.year == now.year) {
            double logVolume = 0.0;
            for (final ex in log.exercises) {
              for (final s in ex.sets) {
                final w = double.tryParse(s.weight) ?? 0.0;
                final r = double.tryParse(s.reps) ?? 0.0;
                logVolume += w * r;
              }
            }
            volume[date.month] = (volume[date.month] ?? 0.0) + logVolume;
          }
        } catch (_) {}
      }
    }
    return volume;
  }

  Map<int, int> get _timeframeFrequency {
    final Map<int, int> frequency = {};
    final now = DateTime.now();

    if (_selectedTimeframe == 'Week') {
      for (int i = 1; i <= 7; i++) frequency[i] = 0;
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);

      for (final log in _workoutLogs) {
        try {
          final date = DateTime.parse(log.date);
          if (date.isAfter(weekStartDay.subtract(const Duration(days: 1)))) {
            frequency[date.weekday] = (frequency[date.weekday] ?? 0) + 1;
          }
        } catch (_) {}
      }
    } else if (_selectedTimeframe == 'Month') {
      for (int i = 1; i <= 5; i++) frequency[i] = 0;
      final monthStart = DateTime(now.year, now.month, 1);

      for (final log in _workoutLogs) {
        try {
          final date = DateTime.parse(log.date);
          if (date.isAfter(monthStart.subtract(const Duration(days: 1))) && date.month == now.month && date.year == now.year) {
            final weekIdx = ((date.day - 1) ~/ 7) + 1;
            frequency[weekIdx] = (frequency[weekIdx] ?? 0) + 1;
          }
        } catch (_) {}
      }
    } else {
      for (int i = 1; i <= 12; i++) frequency[i] = 0;
      for (final log in _workoutLogs) {
        try {
          final date = DateTime.parse(log.date);
          if (date.year == now.year) {
            frequency[date.month] = (frequency[date.month] ?? 0) + 1;
          }
        } catch (_) {}
      }
    }
    return frequency;
  }

  double get _totalVolumeSelected {
    return _timeframeVolume.values.fold(0.0, (a, b) => a + b);
  }

  int get _totalWorkoutsSelected {
    return _timeframeFrequency.values.fold(0, (a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> timeframes = ['Week', 'Month', 'Year'];
    final frequencyData = _timeframeFrequency;
    final volumeData = _timeframeVolume;

    final maxFreq = frequencyData.values.isEmpty 
        ? 5.0 
        : frequencyData.values.reduce((a, b) => a > b ? a : b).toDouble() + 1.0;

    final formattedVolume = NumberFormat('#,###').format(_totalVolumeSelected);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Progress & Analytics'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeframe ChoiceChips Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: timeframes.map((tf) {
                      final isSelected = _selectedTimeframe == tf;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(tf),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.cardBg,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedTimeframe = tf);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Workout Frequency Bar Chart Section
                  const Text(
                    'Workout Frequency',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_totalWorkoutsSelected workouts this ${_selectedTimeframe.toLowerCase()}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
                    child: AspectRatio(
                      aspectRatio: 1.6,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxFreq,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  final intVal = value.toInt() - 1;
                                  if (intVal >= 0 && intVal < _xAxisLabels.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        _xAxisLabels[intVal],
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  if (value % 1 != 0) return const Text('');
                                  return Text(
                                    '${value.toInt()}',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: frequencyData.entries.map((e) {
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.toDouble(),
                                  gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF651FFF)]),
                                  width: 12,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Volume Line Chart Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Volume (kg)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'This ${_selectedTimeframe.toLowerCase()}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$formattedVolume kg',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                          const Text(
                            '+12.5% vs last period',
                            style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
                    child: AspectRatio(
                      aspectRatio: 1.6,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: AppColors.border.withOpacity(0.3),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  final intVal = value.toInt() - 1;
                                  if (intVal >= 0 && intVal < _xAxisLabels.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        _xAxisLabels[intVal],
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  if (value >= 1000) {
                                    return Text(
                                      '${(value / 1000).toStringAsFixed(1)}k',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
                                    );
                                  }
                                  return Text(
                                    '${value.toInt()}',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: volumeData.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                              isCurved: true,
                              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.0)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }
}
