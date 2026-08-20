import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:assignment/core/theme/app_colors.dart';
import 'package:assignment/core/theme/theme_provider.dart';
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
    double displayWeight = weightUnit == 'lbs'
        ? profile.weightKg / 0.453592
        : profile.weightKg;
    displayWeight = weightUnit == 'lbs'
        ? displayWeight.roundToDouble().clamp(70.0, 450.0)
        : ((displayWeight * 2).round() / 2.0).clamp(30.0, 200.0);

    final formKey = GlobalKey<FormState>();
    _selectedDate = DateTime.now();
    String selectedUnit = weightUnit;
    double selectedWeightValue = displayWeight;

    final weightController = TextEditingController(
      text: selectedUnit == 'lbs'
          ? selectedWeightValue.toStringAsFixed(0)
          : selectedWeightValue.toStringAsFixed(1),
    );

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
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: const BorderRadius.only(
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
                    Text(
                      'Log Weight Entry',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Weight',
                              prefixIcon: Icon(Icons.monitor_weight_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your weight';
                              }
                              final val = double.tryParse(value.trim());
                              if (val == null || val <= 0) {
                                return 'Please enter a valid weight';
                              }
                              if (selectedUnit == 'kg') {
                                if (val < 30.0 || val > 200.0) {
                                  return 'Weight must be between 30 and 200 kg';
                                }
                              } else {
                                if (val < 70.0 || val > 450.0) {
                                  return 'Weight must be between 70 and 450 lbs';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.fillLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ToggleButtons(
                            isSelected: [selectedUnit == 'kg', selectedUnit == 'lbs'],
                            onPressed: (index) {
                              final newUnit = index == 0 ? 'kg' : 'lbs';
                              if (newUnit == selectedUnit) return;
                              setModalState(() {
                                final text = weightController.text.trim();
                                if (text.isNotEmpty) {
                                  final val = double.tryParse(text);
                                  if (val != null) {
                                    if (newUnit == 'kg' && selectedUnit == 'lbs') {
                                      final inKg = val * 0.453592;
                                      weightController.text = inKg.toStringAsFixed(1);
                                    } else if (newUnit == 'lbs' && selectedUnit == 'kg') {
                                      final inLbs = val / 0.453592;
                                      weightController.text = inLbs.toStringAsFixed(0);
                                    }
                                  }
                                }
                                selectedUnit = newUnit;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            fillColor: AppColors.primary,
                            selectedColor: Colors.white,
                            color: AppColors.textSecondary,
                            renderBorder: false,
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('kg', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('lbs', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                              children: [
                                Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                                const SizedBox(width: 12),
                                Text('Entry Date', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                              ],
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: TextStyle(
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
                          final displayW = double.parse(weightController.text.trim());
                          // Convert to canonical kg before storing
                          final weight = selectedUnit == 'lbs' ? displayW * 0.453592 : displayW;
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
    ref.watch(themeModeProvider); // force rebuild on theme changes
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

    // Determine if all entries are on the same day (for chart formatting)
    final bool allSameDay = chartEntries.isNotEmpty &&
        chartEntries.every((e) =>
            e.date.year == chartEntries.first.date.year &&
            e.date.month == chartEntries.first.date.month &&
            e.date.day == chartEntries.first.date.day);
    final DateFormat chartDateFormat = allSameDay ? DateFormat('h:mm a') : DateFormat('dd/MM');

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

      double interval = 10.0;
      if (weightUnit == 'lbs') {
        if (yRange <= 5) {
          interval = 1.0;
        } else if (yRange <= 15) {
          interval = 2.0;
        } else if (yRange <= 40) {
          interval = 5.0;
        } else if (yRange <= 100) {
          interval = 10.0;
        } else {
          interval = 20.0;
        }
      } else {
        // kg
        if (yRange <= 2) {
          interval = 0.5;
        } else if (yRange <= 6) {
          interval = 1.0;
        } else if (yRange <= 15) {
          interval = 2.0;
        } else if (yRange <= 40) {
          interval = 5.0;
        } else {
          interval = 10.0;
        }
      }

      final double paddedMin = minYVal - (yRange > 0 ? yRange * 0.1 : 2.0);
      final double paddedMax = maxYVal + (yRange > 0 ? yRange * 0.1 : 2.0);

      minYSetting = (paddedMin / interval).floor() * interval;
      maxYSetting = (paddedMax / interval).ceil() * interval;

      if (minYSetting < 0) {
        minYSetting = 0;
      }

      if (minYSetting == maxYSetting) {
        minYSetting -= interval;
        maxYSetting += interval;
        if (minYSetting < 0) minYSetting = 0;
      }

      yIntervalSetting = interval;
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
                      Text(
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
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                'View weight fluctuations and progress trend lines.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Chart Card or Empty State
              if (spots.length >= 2) ...[
                Container(
                  width: double.infinity,
                  height: 200,
                  padding: const EdgeInsets.only(top: 24, bottom: 8, right: 24, left: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.015),
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
                          getTooltipColor: (touchedSpot) => AppColors.primary.withValues(alpha: 0.95),
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((LineBarSpot touchedSpot) {
                              final idx = touchedSpot.x.toInt();
                              String dateStr = '';
                              if (idx >= 0 && idx < chartEntries.length) {
                                final date = chartEntries[idx].date;
                                dateStr = DateFormat('MMM dd, yyyy').format(date);
                              }
                              return LineTooltipItem(
                                '$dateStr\n${touchedSpot.y.toStringAsFixed(1)} ${weightUnit == 'lbs' ? 'lbs' : 'kg'}',
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
                        horizontalInterval: yIntervalSetting,
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
                                    chartDateFormat.format(chartEntries[idx].date),
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
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
                              final label = value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
                              return Text(
                                '$label ${weightUnit == 'lbs' ? 'lbs' : 'kg'}',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
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
                          curveSmoothness: 0.2,
                          preventCurveOverShooting: true,
                          color: AppColors.primary,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                              radius: 6,
                              color: AppColors.primary,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.18),
                                AppColors.primary.withValues(alpha: 0.00),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: listEntries.length,
                    itemBuilder: (context, index) {
                      final entry = listEntries[index];
                      // calculate BMI for that specific weight entry
                      final itemBmi = activeProfile.heightCm > 0
                          ? entry.weightKg / ((activeProfile.heightCm / 100) * (activeProfile.heightCm / 100))
                          : 0.0;

                      final prevEntry = index < listEntries.length - 1 ? listEntries[index + 1] : null;
                      final double? deltaKg = prevEntry != null ? entry.weightKg - prevEntry.weightKg : null;

                      return Dismissible(
                        key: Key(entry.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 16),
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
                          entry: entry,
                          bmi: itemBmi,
                          category: _bmiCategory(itemBmi),
                          isNormal: itemBmi >= 18.5 && itemBmi < 25.0,
                          weightUnit: weightUnit,
                          heightUnit: heightUnit,
                          deltaKg: deltaKg,
                          heightCm: activeProfile.heightCm,
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.trending_up,
                              color: AppColors.primary,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Log your first weight to start tracking trends',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the "+" button in the top right to log a new weight entry.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogCard({
    required WeightEntry entry,
    required double bmi,
    required String category,
    required bool isNormal,
    required String weightUnit,
    required String heightUnit,
    required double? deltaKg,
    required double heightCm,
  }) {
    // Convert to display units
    final displayWeight = weightUnit == 'lbs' ? entry.weightKg / 0.453592 : entry.weightKg;
    final weightLabel = weightUnit == 'lbs' ? 'lbs' : 'kg';

    final Widget deltaWidget;
    if (deltaKg != null && deltaKg.abs() > 0.001) {
      final double displayDelta = weightUnit == 'lbs'
          ? (deltaKg / 0.453592).abs()
          : deltaKg.abs();
      final bool isDown = deltaKg < 0;
      final String deltaText = '${isDown ? '↓' : '↑'} ${displayDelta.toStringAsFixed(1)} $weightLabel';

      deltaWidget = Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: (isDown ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          deltaText,
          style: TextStyle(
            color: isDown ? AppColors.success : AppColors.warning,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      deltaWidget = const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Left column: date / weight / height / delta ──────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date + time
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(entry.date),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('h:mm a').format(entry.date),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // Delta badge on its own line so it never squeezes the date
                if (deltaKg != null && deltaKg.abs() > 0.001)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: deltaWidget,
                  ),
                const SizedBox(height: 6),
                // Weight · Height
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${displayWeight.toStringAsFixed(1)} $weightLabel',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '•',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        heightUnit == 'inches'
                            ? (() {
                                final inchesTotal = heightCm / 2.54;
                                int feet = (inchesTotal / 12).floor();
                                int inches = (inchesTotal % 12).round();
                                if (inches == 12) {
                                  feet += 1;
                                  inches = 0;
                                }
                                return "$feet' $inches\"";
                              })()
                            : '${heightCm.toStringAsFixed(0)} cm',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── Right column: BMI value + category badge ─────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                bmi.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.primaryAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.getBmiColor(bmi).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
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
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
