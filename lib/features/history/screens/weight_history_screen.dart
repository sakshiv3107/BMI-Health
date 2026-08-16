import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment/core/theme/app_colors.dart';
import 'package:assignment/features/profile/providers/profile_providers.dart';

class WeightHistoryScreen extends ConsumerWidget {
  const WeightHistoryScreen({super.key});

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal Weight';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileProvider);

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
              const SizedBox(height: 24),
              Text(
                'Weight Log for ${activeProfile?.name ?? "User"}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'View your historical weight records and BMI trends.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: activeProfile == null
                    ? const Center(child: Text('No active profile'))
                    : ListView(
                        children: [
                          _buildLogCard(
                            date: 'Today',
                            weight: activeProfile.weightKg,
                            height: activeProfile.heightCm,
                            bmi: activeProfile.bmi,
                            category: activeProfile.bmiCategory,
                            isNormal: activeProfile.isNormalWeight,
                          ),
                          _buildLogCard(
                            date: '2 weeks ago',
                            weight: activeProfile.weightKg + 1.5,
                            height: activeProfile.heightCm,
                            bmi: (activeProfile.weightKg + 1.5) / ((activeProfile.heightCm / 100) * (activeProfile.heightCm / 100)),
                            category: _bmiCategory((activeProfile.weightKg + 1.5) / ((activeProfile.heightCm / 100) * (activeProfile.heightCm / 100))),
                            isNormal: ((activeProfile.weightKg + 1.5) / ((activeProfile.heightCm / 100) * (activeProfile.heightCm / 100))) >= 18.5 && ((activeProfile.weightKg + 1.5) / ((activeProfile.heightCm / 100) * (activeProfile.heightCm / 100))) < 25.0,
                          ),
                          _buildLogCard(
                            date: '1 month ago',
                            weight: activeProfile.weightKg + 3.0,
                            height: activeProfile.heightCm,
                            bmi: (activeProfile.weightKg + 3.0) / ((activeProfile.heightCm / 100) * (activeProfile.heightCm / 100)),
                            category: _bmiCategory((activeProfile.weightKg + 3.0) / ((activeProfile.heightCm / 100) * (activeProfile.heightCm / 100))),
                            isNormal: ((activeProfile.weightKg + 3.0) / ((activeProfile.heightCm / 100) * (activeProfile.heightCm / 100))) >= 18.5 && ((activeProfile.weightKg + 3.0) / ((activeProfile.heightCm / 100) * (activeProfile.heightCm / 100))) < 25.0,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogCard({
    required String date,
    required double weight,
    required double height,
    required double bmi,
    required String category,
    required bool isNormal,
  }) {
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
                    '${weight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•  ${height.toStringAsFixed(0)} cm',
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
                      color: isNormal ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    category,
                    style: TextStyle(
                      color: isNormal ? AppColors.success : AppColors.warning,
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
