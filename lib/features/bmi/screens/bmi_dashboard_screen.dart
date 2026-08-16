import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:assignment/core/theme/app_colors.dart';
import 'package:assignment/core/widgets/bmi_progress_ring.dart';
import 'package:assignment/core/widgets/bottom_nav_bar.dart';
import 'package:assignment/core/widgets/profile_avatar.dart';
import 'package:assignment/features/profile/providers/profile_providers.dart';
import 'package:assignment/features/profile/models/user_profile.dart';
import 'package:assignment/features/settings/screens/settings_screen.dart';

class BmiDashboardScreen extends ConsumerWidget {
  const BmiDashboardScreen({super.key});

  String _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getMotivationalMessage(String category) {
    switch (category) {
      case 'Underweight':
        return 'You are currently below the healthy weight range. Consuming nutrient-dense foods and strength training can help.';
      case 'Normal Weight':
        return 'You\'re in the healthy weight range for your height. Keep up the great work!';
      case 'Overweight':
        return 'You are slightly above the healthy weight range. Small lifestyle changes like regular walks can make a difference.';
      case 'Obese':
        return 'Prioritize your cardiovascular health. A combination of daily movement and consulting a nutritionist is recommended.';
      default:
        return 'Track your body mass index regularly to maintain healthy physical progress.';
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();

    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    final timeStr = '$displayHour:$displayMinute $period';

    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final daysDiff = today.difference(targetDate).inDays;

    if (daysDiff <= 0) {
      return 'today at $timeStr';
    } else if (daysDiff == 1) {
      return 'yesterday at $timeStr';
    } else if (daysDiff < 7) {
      return '$daysDiff days ago';
    } else {
      final weeks = (daysDiff / 7).floor();
      if (weeks == 1) {
        return '1 week ago';
      } else {
        return '$weeks weeks ago';
      }
    }
  }

  void _showUpdateDataBottomSheet(BuildContext context, WidgetRef ref, UserProfile profile, String weightUnit, String heightUnit) {
    // Convert stored kg/cm to display unit
    final displayWeight = weightUnit == 'lbs'
        ? profile.weightKg / 0.453592
        : profile.weightKg;
    final displayHeight = heightUnit == 'inches'
        ? profile.heightCm / 2.54
        : profile.heightCm;

    final weightController = TextEditingController(
      text: displayWeight.toStringAsFixed(1),
    );
    final heightController = TextEditingController(
      text: displayHeight.toStringAsFixed(1),
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                  'Update Body Data',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Updating data for ${profile.name}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
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
                TextFormField(
                  controller: heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Height (${heightUnit == 'inches' ? 'in' : 'cm'})',
                    prefixIcon: const Icon(Icons.height),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter height';
                    final val = double.tryParse(value);
                    if (val == null || val <= 0) return 'Enter a valid height';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final displayW = double.parse(weightController.text);
                      final displayH = double.parse(heightController.text);
                      // Convert back to canonical kg / cm
                      final newWeight = weightUnit == 'lbs' ? displayW * 0.453592 : displayW;
                      final newHeight = heightUnit == 'inches' ? displayH * 2.54 : displayH;
                      final weightChanged = (profile.weightKg - newWeight).abs() > 0.01;
                      final heightChanged = (profile.heightCm - newHeight).abs() > 0.01;

                      final updatedProfile = profile.copyWith(
                        weightKg: newWeight,
                        heightCm: newHeight,
                      );

                      // Read notifiers synchronously BEFORE async gaps to prevent disposed WidgetRef errors
                      final profilesNotifier = ref.read(allProfilesProvider.notifier);
                      final weightEntriesNotifier = ref.read(weightEntriesProvider.notifier);

                      await profilesNotifier.updateProfile(updatedProfile);

                      if (weightChanged || heightChanged) {
                        await weightEntriesNotifier.addEntry(profile.id, newWeight);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Body metrics updated successfully!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileProvider);
    final weightUnit = ref.watch(globalWeightUnitProvider);
    final heightUnit = ref.watch(globalHeightUnitProvider);
    final weightEntries = ref.watch(weightEntriesProvider);

    DateTime? lastUpdate;
    if (activeProfile != null) {
      final profileEntries = weightEntries
          .where((e) => e.profileId == activeProfile.id)
          .toList();
      if (profileEntries.isNotEmpty) {
        profileEntries.sort((a, b) => b.date.compareTo(a.date));
        lastUpdate = profileEntries.first.date;
      }
    }

    if (activeProfile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.account_box_outlined,
                    color: AppColors.primary,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Profile Setup Yet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete your profile setup to start tracking your BMI and weight history.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.push('/user-details'),
                    child: const Text('Complete Your Profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final greeting = _getTimeOfDayGreeting();
    final bmi = ref.watch(currentBmiProvider) ?? 0.0;
    final message = _getMotivationalMessage(activeProfile.bmiCategory);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
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
                          Icons.analytics_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Home',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(bottomNavIndexProvider.notifier).state = 2;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ProfileAvatar(
                        name: activeProfile.name,
                        photoBase64: activeProfile.photoBase64,
                        radius: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Welcome Back Text
              Text(
                '$greeting, ${activeProfile.name}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ready to check your progress?',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Large White BMI Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'YOUR BMI',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: bmi),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        const double minBmi = 15.0;
                        const double maxBmi = 35.0;
                        final double targetFraction = ((bmi - minBmi) / (maxBmi - minBmi)).clamp(0.0, 1.0);
                        final double animatedFraction = bmi > 0 ? targetFraction * (value / bmi) : 0.0;

                        return Column(
                          children: [
                            Text(
                              value.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.primaryAccent,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Status Badge (normal/overweight colored indicators)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.getBmiColor(bmi),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  activeProfile.bmiCategory,
                                  style: TextStyle(
                                    color: AppColors.getBmiColor(bmi),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            BmiProgressRing(
                              bmi: value,
                              size: 180,
                              ringFraction: animatedFraction,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      message,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Height and Weight Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.monitor_weight_outlined,
                                  color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Weight',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                weightUnit == 'lbs'
                                    ? (activeProfile.weightKg / 0.453592).toStringAsFixed(1)
                                    : activeProfile.weightKg.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                weightUnit == 'lbs' ? 'lbs' : 'kg',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.height, color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Height',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                heightUnit == 'inches'
                                    ? (activeProfile.heightCm / 2.54).toStringAsFixed(1)
                                    : activeProfile.heightCm.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                heightUnit == 'inches' ? 'in' : 'cm',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (lastUpdate != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Updated ${_formatRelativeTime(lastUpdate)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Full Width Update Button
              ElevatedButton.icon(
                onPressed: () => _showUpdateDataBottomSheet(context, ref, activeProfile, weightUnit, heightUnit),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: const Text('Update Body Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
