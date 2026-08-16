import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:assignment/core/theme/app_colors.dart';
import 'package:assignment/core/widgets/bottom_nav_bar.dart';
import 'package:assignment/core/widgets/profile_avatar.dart';
import 'package:assignment/features/auth/auth_provider.dart';
import 'package:assignment/features/profile/providers/profile_providers.dart';
import 'package:assignment/core/theme/theme_provider.dart';

// ─── Preferences providers (persisted in Hive 'settings' box) ────────────────
final notificationsEnabledProvider = StateProvider<bool>((ref) {
  return Hive.box('settings').get('notifications_enabled', defaultValue: true) as bool;
});

final globalWeightUnitProvider = StateProvider<String>((ref) {
  return Hive.box('settings').get('global_weight_unit', defaultValue: 'kg') as String;
});

final globalHeightUnitProvider = StateProvider<String>((ref) {
  return Hive.box('settings').get('global_height_unit', defaultValue: 'cm') as String;
});

// ─── Screen ───────────────────────────────────────────────────────────────────
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileProvider);
    final authState = ref.watch(authControllerProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final weightUnit = ref.watch(globalWeightUnitProvider);
    final heightUnit = ref.watch(globalHeightUnitProvider);
    final themeMode = ref.watch(themeModeProvider);
    final themeModeName = themeMode == ThemeMode.dark
        ? 'Dark'
        : themeMode == ThemeMode.system
            ? 'System'
            : 'Light';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Header ──────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (activeProfile != null)
                    ProfileAvatar(
                      name: activeProfile.name,
                      photoBase64: activeProfile.photoBase64,
                      radius: 20,
                    ),
                ],
              ),
              const SizedBox(height: 28),

              // ── PROFILE Section ─────────────────────────────────────────────
              _sectionLabel('PROFILE'),
              _settingsCard(children: [
                _navRow(
                  icon: Icons.person_outline,
                  iconBg: AppColors.primary,
                  label: 'Edit Personal Information',
                  onTap: activeProfile != null
                      ? () => context.push('/user-details?profileId=${activeProfile.id}')
                      : null,
                ),
                _divider(),
                _navRow(
                  icon: Icons.monitor_weight_outlined,
                  iconBg: const Color(0xFF3D9B8F),
                  label: 'Update Height & Weight',
                  onTap: activeProfile != null
                      ? () => context.push('/user-details?profileId=${activeProfile.id}')
                      : null,
                ),
                _divider(),
                _navRow(
                  icon: Icons.people_outline,
                  iconBg: const Color(0xFF5B7FA6),
                  label: 'Manage Profiles',
                  onTap: () {
                    ref.read(bottomNavIndexProvider.notifier).state = 2;
                  },
                ),
              ]),

              const SizedBox(height: 28),

              // ── PREFERENCES Section ─────────────────────────────────────────
              _sectionLabel('PREFERENCES'),
              _settingsCard(children: [
                // Notifications toggle
                _toggleRow(
                  icon: Icons.notifications_none_outlined,
                  iconBg: const Color(0xFF6C7A8D),
                  label: 'Notifications',
                  value: notificationsEnabled,
                  onChanged: (v) {
                    ref.read(notificationsEnabledProvider.notifier).state = v;
                    Hive.box('settings').put('notifications_enabled', v);
                  },
                ),
                _divider(),
                // Weight Units
                _unitToggleRow(
                  icon: Icons.scale_outlined,
                  iconBg: const Color(0xFF6C7A8D),
                  label: 'Weight Units',
                  options: const ['KG', 'LBS'],
                  selected: weightUnit.toUpperCase(),
                  onSelect: (v) {
                    ref.read(globalWeightUnitProvider.notifier).state = v.toLowerCase();
                    Hive.box('settings').put('global_weight_unit', v.toLowerCase());
                  },
                ),
                _divider(),
                // Height Units
                _unitToggleRow(
                  icon: Icons.height,
                  iconBg: const Color(0xFF6C7A8D),
                  label: 'Height Units',
                  options: const ['CM', 'FT/IN'],
                  selected: heightUnit.toUpperCase() == 'CM' ? 'CM' : 'FT/IN',
                  onSelect: (v) {
                    final stored = v == 'FT/IN' ? 'inches' : 'cm';
                    ref.read(globalHeightUnitProvider.notifier).state = stored;
                    Hive.box('settings').put('global_height_unit', stored);
                  },
                ),
                _divider(),
                // Theme Mode
                _unitToggleRow(
                  icon: Icons.dark_mode_outlined,
                  iconBg: const Color(0xFF6C7A8D),
                  label: 'Theme Mode',
                  options: const ['Light', 'Dark', 'System'],
                  selected: themeModeName,
                  onSelect: (v) {
                    ThemeMode mode;
                    if (v == 'Dark') {
                      mode = ThemeMode.dark;
                    } else if (v == 'System') {
                      mode = ThemeMode.system;
                    } else {
                      mode = ThemeMode.light;
                    }
                    ref.read(themeModeProvider.notifier).setThemeMode(mode);
                  },
                ),
              ]),

              const SizedBox(height: 28),

              // ── ACCOUNT Section ─────────────────────────────────────────────
              _sectionLabel('ACCOUNT'),
              _settingsCard(children: [
                _navRow(
                  icon: Icons.lock_outline,
                  iconBg: const Color(0xFF6C7A8D),
                  label: 'Change Password',
                  onTap: () => _showChangePasswordDialog(context, ref),
                ),
                _divider(),
                _navRow(
                  icon: Icons.shield_outlined,
                  iconBg: const Color(0xFF6C7A8D),
                  label: 'Privacy Policy',
                  trailingIcon: Icons.open_in_new,
                  onTap: () => _showPrivacyPolicyDialog(context),
                ),
              ]),

              const SizedBox(height: 16),

              // ── Log Out ─────────────────────────────────────────────────────
              _logOutCard(
                isLoading: authState.isLoading,
                onTap: () => _confirmLogOut(context, ref),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Section label ──────────────────────────────────────────────────────────
  static Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ─── Card container ─────────────────────────────────────────────────────────
  static Widget _settingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  static Widget _divider() {
    return Divider(height: 1, indent: 60, endIndent: 0, color: AppColors.borderLight);
  }

  // ─── Tappable nav row ───────────────────────────────────────────────────────
  static Widget _navRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    IconData trailingIcon = Icons.chevron_right,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _iconBox(icon, iconBg),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(trailingIcon, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Toggle row (switch) ────────────────────────────────────────────────────
  static Widget _toggleRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _iconBox(icon, iconBg),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  // ─── Unit toggle row (segmented control) ────────────────────────────────────
  static Widget _unitToggleRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _iconBox(icon, iconBg),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Segmented pill group
          Container(
            decoration: BoxDecoration(
              color: AppColors.fillLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: options.map((opt) {
                final isSelected = opt == selected;
                return GestureDetector(
                  onTap: () => onSelect(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Log out card ───────────────────────────────────────────────────────────
  static Widget _logOutCard({required bool isLoading, required VoidCallback onTap}) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.isDarkMode ? const Color(0xFF2C1E1E) : const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.isDarkMode ? Color(0xFF4C2A2A) : Color(0xFFFFDADA),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
                      ),
                    )
                  : const Icon(Icons.logout_rounded, color: AppColors.warning, size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.warning, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Icon box helper ────────────────────────────────────────────────────────
  static Widget _iconBox(IconData icon, Color bg) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: bg, size: 20),
    );
  }

  // ─── Dialogs ─────────────────────────────────────────────────────────────────

  void _confirmLogOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authControllerProvider.notifier).signOut();
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we will send you a password reset link.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                Navigator.pop(ctx);
                await ref.read(authControllerProvider.notifier).sendPasswordResetEmail(email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(
            'BMI Health collects and stores your name, weight, height, and gender locally on your device using secure local storage. No personal health data is transmitted to external servers.\n\n'
            'Your data is used solely to calculate and track your BMI and health metrics within the app. You may delete your profile and all associated data at any time from the Profiles section.\n\n'
            'We do not sell, share, or monetise your health data in any way.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
