import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment/core/theme/app_colors.dart';
import 'package:assignment/core/widgets/bmi_progress_ring.dart';
import 'package:assignment/core/widgets/bottom_nav_bar.dart';
import 'package:assignment/features/profile/providers/profile_providers.dart';
import 'package:assignment/features/profile/models/profile.dart';

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

  void _showUpdateDataBottomSheet(BuildContext context, WidgetRef ref, Profile profile) {
    final weightController = TextEditingController(text: profile.weightKg.toString());
    final heightController = TextEditingController(text: profile.heightCm.toString());
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
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
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
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    prefixIcon: Icon(Icons.height),
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
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newWeight = double.parse(weightController.text);
                      final newHeight = double.parse(heightController.text);
                      ref.read(allProfilesProvider.notifier).updateProfile(
                            profile.id,
                            weight: newWeight,
                            height: newHeight,
                          );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Body metrics updated successfully!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
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

    if (activeProfile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final greeting = _getTimeOfDayGreeting();
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
                      // Navigate to Profiles tab
                      ref.read(bottomNavIndexProvider.notifier).state = 2;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.person, color: AppColors.primary, size: 20),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
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
                    Text(
                      activeProfile.bmi.toStringAsFixed(1),
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
                            color: activeProfile.isNormalWeight
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          activeProfile.bmiCategory,
                          style: TextStyle(
                            color: activeProfile.isNormalWeight
                                ? AppColors.success
                                : AppColors.warning,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    BmiProgressRing(bmi: activeProfile.bmi, size: 180),
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
                                activeProfile.weightKg.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'kg',
                                style: TextStyle(
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
                                activeProfile.heightCm.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'cm',
                                style: TextStyle(
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
              const SizedBox(height: 24),

              // Full Width Update Button
              ElevatedButton.icon(
                onPressed: () => _showUpdateDataBottomSheet(context, ref, activeProfile),
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
