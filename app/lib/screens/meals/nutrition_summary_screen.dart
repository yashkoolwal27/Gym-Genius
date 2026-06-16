import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../widgets/shared_widgets.dart';

class NutritionSummaryScreen extends StatefulWidget {
  const NutritionSummaryScreen({super.key});

  @override
  State<NutritionSummaryScreen> createState() => _NutritionSummaryScreenState();
}

class _NutritionSummaryScreenState extends State<NutritionSummaryScreen> {
  String _selectedTimeframe = 'This Week';

  // Static/Calculated averages for visualization (matches mockup data)
  final double _avgCalories = 1980;
  final double _avgProtein = 112;
  final double _avgWater = 2.1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nutrition Summary'),
        actions: [
          DropdownButton<String>(
            value: _selectedTimeframe,
            dropdownColor: AppColors.cardBg,
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
            items: const [
              DropdownMenuItem(value: 'This Week', child: Text('This Week')),
              DropdownMenuItem(value: 'Last Week', child: Text('Last Week')),
              DropdownMenuItem(value: 'This Month', child: Text('This Month')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedTimeframe = val);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Averages Row
            Row(
              children: [
                Expanded(
                  child: _SummaryStatCard(
                    label: 'Avg Calories',
                    value: '${_avgCalories.round()} kcal',
                    target: '/ 2400',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryStatCard(
                    label: 'Avg Protein',
                    value: '${_avgProtein.round()} g',
                    target: '/ 150',
                    color: AppColors.primaryBright,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryStatCard(
                    label: 'Avg Water',
                    value: '${_avgWater.toStringAsFixed(1)} L',
                    target: '/ 3',
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Calories Trend'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (val) => FlLine(color: AppColors.border, strokeWidth: 1),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                int idx = val.toInt();
                                if (idx >= 0 && idx < days.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(days[idx], style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 6,
                        minY: 1000,
                        maxY: 3000,
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 1800),
                              FlSpot(1, 2100),
                              FlSpot(2, 1950),
                              FlSpot(3, 2450),
                              FlSpot(4, 1780),
                              FlSpot(5, 2200),
                              FlSpot(6, 1980),
                            ],
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primary.withOpacity(0.12),
                            ),
                          ),
                          // Goal baseline target line
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 2400),
                              FlSpot(6, 2400),
                            ],
                            isCurved: false,
                            color: AppColors.error.withOpacity(0.3),
                            barWidth: 2,
                            dashArray: [5, 5],
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Nutrient Distribution'),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 35,
                        sections: [
                          PieChartSectionData(
                            color: AppColors.accent,
                            value: 45,
                            title: '45%',
                            radius: 20,
                            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: AppColors.primary,
                            value: 24,
                            title: '24%',
                            radius: 20,
                            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          PieChartSectionData(
                            color: AppColors.accentOrange,
                            value: 31,
                            title: '31%',
                            radius: 20,
                            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _MacroLegendLabel(label: 'Carbs: 210g (45%)', color: AppColors.accent),
                        SizedBox(height: 10),
                        _MacroLegendLabel(label: 'Protein: 112g (24%)', color: AppColors.primary),
                        SizedBox(height: 10),
                        _MacroLegendLabel(label: 'Fat: 58g (31%)', color: AppColors.accentOrange),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String target;
  final Color color;
  const _SummaryStatCard({required this.label, required this.value, required this.target, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color)),
          const SizedBox(height: 2),
          Text(target, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _MacroLegendLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _MacroLegendLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
