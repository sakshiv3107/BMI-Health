import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment/core/theme/app_colors.dart';
import 'package:assignment/features/auth/auth_provider.dart';
import 'package:assignment/features/profile/providers/profile_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileProvider);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Profile Card Header
              Container(
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        activeProfile?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeProfile?.name ?? 'User Profile',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeProfile?.isPrimary == true ? 'Primary Profile' : 'Sub-Profile',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Preferences Section
              const Text(
                'PREFERENCES',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingItem(
                icon: Icons.square_foot,
                title: 'Weight Units',
                trailing: 'Kilograms (kg)',
              ),
              _buildSettingItem(
                icon: Icons.height,
                title: 'Height Units',
                trailing: 'Centimeters (cm)',
              ),
              _buildSettingItem(
                icon: Icons.notifications_none_outlined,
                title: 'Daily Reminders',
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // App Section
              const Text(
                'APPLICATION',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingItem(
                icon: Icons.verified_user_outlined,
                title: 'Privacy Policy',
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ),
              _buildSettingItem(
                icon: Icons.info_outline,
                title: 'Terms of Service',
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Log Out Button
              ElevatedButton.icon(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        ref.read(authControllerProvider.notifier).signOut();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                ),
                icon: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.logout),
                label: const Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required dynamic trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing is String)
            Text(
              trailing,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            )
          else if (trailing is Widget)
            trailing,
        ],
      ),
    );
  }
}
