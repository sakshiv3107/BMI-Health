import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:assignment/core/theme/app_colors.dart';
import 'package:assignment/features/profile/providers/profile_providers.dart';
import 'package:assignment/features/history/models/weight_entry.dart';
import 'package:assignment/features/profile/models/user_profile.dart';
import 'package:assignment/features/settings/screens/settings_screen.dart';

class WeightHistoryScreen extends ConsumerStatefulWidget {
  const WeightHistoryScreen({super.key});

  @override
  ConsumerState<WeightHistoryScreen> createState() => _WeightHistoryScreenState();
}

class _WeightHistoryScreenState extends ConsumerState<WeightHistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal Weight';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  void _showLogWeightBottomSheet(BuildContext context, UserProfile profile, String weightUnit) {
    // show pre-filled value in display unit
    final displayWeight = weightUnit == 'lbs'
        ? profile.weightKg / 0.453592
        : profile.weightKg;
    final weightController = TextEditingController(text: displayWeight.toStringAsFixed(1));
    final formKey = GlobalKey<FormState>();
    _selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Log Weight Entry',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Weight (${weightUnit == 'lbs' ? 'lbs' : 'kg'})',
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter weight';
                    final val = double.tryParse(value);
                    if (val == null || val <= 0) return 'Enter a valid weight';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setModalState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.fillLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                            SizedBox(width: 12),
                            Text('Entry Date', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                          ],
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final displayW = double.parse(weightController.text);
                      // Convert to canonical kg before storing
                      final weight = weightUnit == 'lbs' ? displayW * 0.453592 : displayW;
                      await ref.read(weightEntriesProvider.notifier).addEntry(
                            profile.id,
                            weight,
                            customDate: _selectedDate,
                          );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Weight logged successfully!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Log Entry'),
                ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileProvider);
    final allEntries = ref.watch(weightEntriesProvider);
    final weightUnit = ref.watch(globalWeightUnitProvider);
    final heightUnit = ref.watch(globalHeightUnitProvider);

    if (activeProfile == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please complete your profile setup first.'),
        ),
      );
    }

    // Filter and sort weight entries for the active profile
    final activeEntries = allEntries.where((e) => e.profileId == activeProfile.id).toList();
    
    // Sort ascending for chart (chronological left to right)
    final chartEntries = List<WeightEntry>.from(activeEntries)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Sort descending for list (newest first at top)
    final listEntries = List<WeightEntry>.from(activeEntries)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Create spots for line chart — convert to display unit
    final spots = <FlSpot>[];
    for (int i = 0; i < chartEntries.length; i++) {
      final displayW = weightUnit == 'lbs'
          ? chartEntries[i].weightKg / 0.453592
          : chartEntries[i].weightKg;
      spots.add(FlSpot(i.toDouble(), displayW));
    }

    double minYSetting = 0.0;
    double maxYSetting = 100.0;
    double yIntervalSetting = 20.0;

    if (spots.isNotEmpty) {
      final yValues = spots.map((s) => s.y).toList();
      final minYVal = yValues.reduce((a, b) => a < b ? a : b);
      final maxYVal = yValues.reduce((a, b) => a > b ? a : b);
      final yRange = maxYVal - minYVal;
      final buffer = yRange > 0 ? (yRange * 0.18).clamp(3.0, 15.0) : 5.0;
      minYSetting = (minYVal - buffer).floorToDouble();
      maxYSetting = (maxYVal + buffer).ceilToDouble();
      yIntervalSetting = ((maxYSetting - minYSetting) / 4).clamp(1.0, 100.0);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'History',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primary, size: 28),
                    onPressed: () => _showLogWeightBottomSheet(context, activeProfile, weightUnit),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Weight Log for ${activeProfile.name}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'View weight fluctuations and progress trend lines.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Line Chart Card
              if (spots.length >= 2)
                Container(
                  height: 200,
                  padding: const EdgeInsets.only(top: 24, bottom: 8, right: 24, left: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.015),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: LineChart(
                    LineChartData(
                      minY: minYSetting,
                      maxY: maxYSetting,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) => AppColors.primary.withOpacity(0.9),
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((LineBarSpot touchedSpot) {
                              return LineTooltipItem(
                                '${touchedSpot.y.toStringAsFixed(1)} ${weightUnit == 'lbs' ? 'lbs' : 'kg'}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey[200]!,
                          strokeWidth: 1,
                          dashArray: const [5, 5],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: 1.0,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx >= 0 && idx < chartEntries.length) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    DateFormat('dd/MM').format(chartEntries[idx].date),
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: yIntervalSetting,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toStringAsFixed(0)} ${weightUnit == 'lbs' ? 'lbs' : 'kg'}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                              );
                            },
                            reservedSize: 48,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.35,
                          preventCurveOverShooting: true,
                          color: AppColors.primary,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                              radius: 5,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: AppColors.primary,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.18),
                                AppColors.primary.withOpacity(0.00),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const Center(
                    child: Text(
                      'Log weight at least twice to render a trend chart.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Entries List
              Expanded(
                child: listEntries.isNotEmpty
                    ? ListView.builder(
                        itemCount: listEntries.length,
                        itemBuilder: (context, index) {
                          final entry = listEntries[index];
                          // calculate BMI for that specific weight entry
                          final itemBmi = activeProfile.heightCm > 0
                              ? entry.weightKg / ((activeProfile.heightCm / 100) * (activeProfile.heightCm / 100))
                              : 0.0;

                          return Dismissible(
                            key: Key(entry.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              ref.read(weightEntriesProvider.notifier).deleteEntry(entry.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Weight entry deleted')),
                              );
                            },
                            child: _buildLogCard(
                              date: DateFormat('MMM dd, yyyy  •  hh:mm a').format(entry.date),
                              weightKg: entry.weightKg,
                              heightCm: activeProfile.heightCm,
                              bmi: itemBmi,
                              category: _bmiCategory(itemBmi),
                              isNormal: itemBmi >= 18.5 && itemBmi < 25.0,
                              weightUnit: weightUnit,
                              heightUnit: heightUnit,
                            ),
                          );
                        },
                      )
                    : const Center(child: Text('No logged entries. Tap "+" above to log weight.')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogCard({
    required String date,
    required double weightKg,
    required double heightCm,
    required double bmi,
    required String category,
    required bool isNormal,
    required String weightUnit,
    required String heightUnit,
  }) {
    // Convert to display units
    final displayWeight = weightUnit == 'lbs' ? weightKg / 0.453592 : weightKg;
    final displayHeight = heightUnit == 'inches' ? heightCm / 2.54 : heightCm;
    final weightLabel = weightUnit == 'lbs' ? 'lbs' : 'kg';
    final heightLabel = heightUnit == 'inches' ? 'in' : 'cm';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '${displayWeight.toStringAsFixed(1)} $weightLabel',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•  ${displayHeight.toStringAsFixed(heightUnit == 'inches' ? 1 : 0)} $heightLabel',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'BMI: ${bmi.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: AppColors.primaryAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.getBmiColor(bmi),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    category,
                    style: TextStyle(
                      color: AppColors.getBmiColor(bmi),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
