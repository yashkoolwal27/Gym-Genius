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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final weights = await _firestoreService.getWeightLogs();
      if (mounted) {
        setState(() {
          _weightLogs = weights;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fitness Progress'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Weight Progress'),
                  const SizedBox(height: 16),
                  if (_weightLogs.length < 2)
                    AppCard(
                      child: const EmptyState(
                        icon: Icons.show_chart,
                        title: 'Not enough data',
                        subtitle: 'Log your weight at least twice to see progress.',
                      ),
                    )
                  else
                    AppCard(
                      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
                      child: AspectRatio(
                        aspectRatio: 1.5,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: AppColors.border.withOpacity(0.5),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() < 0 || value.toInt() >= _weightLogs.length) return const Text('');
                                    final date = DateTime.parse(_weightLogs[value.toInt()].date);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        DateFormat('MM/dd').format(date),
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 5,
                                  reservedSize: 42,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}kg',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _weightLogs.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
                                isCurved: true,
                                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                    radius: 4,
                                    color: AppColors.primary,
                                    strokeWidth: 2,
                                    strokeColor: AppColors.background,
                                  ),
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0)],
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
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'History'),
                  const SizedBox(height: 12),
                  if (_weightLogs.isEmpty)
                    const EmptyState(
                      icon: Icons.history,
                      title: 'No logs yet',
                      subtitle: 'Your weight history will appear here.',
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _weightLogs.length,
                      itemBuilder: (context, index) {
                        final log = _weightLogs[_weightLogs.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('MMMM dd, yyyy').format(DateTime.parse(log.date)),
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${log.weight} kg',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
