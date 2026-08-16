import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:assignment/core/theme/app_colors.dart';
import 'package:assignment/core/widgets/bottom_nav_bar.dart';
import 'package:assignment/core/widgets/profile_avatar.dart';
import 'package:assignment/features/profile/providers/profile_providers.dart';
import 'package:assignment/features/profile/models/user_profile.dart';

class ProfileSwitcherScreen extends ConsumerWidget {
  const ProfileSwitcherScreen({super.key});

  void _showProfileOptions(BuildContext context, WidgetRef ref, UserProfile profile, UserProfile? activeProfile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: const BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Options for ${profile.name}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/user-details?profileId=${profile.id}');
                },
              ),
              if (activeProfile?.id != profile.id)
                ListTile(
                  leading: const Icon(Icons.swap_horiz, color: AppColors.primary),
                  title: const Text('Switch to this profile'),
                  onTap: () {
                    setActiveProfileId(ref, profile.id);
                    ref.read(bottomNavIndexProvider.notifier).state = 0; // Nav to dashboard
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.warning),
                title: const Text('Delete profile', style: TextStyle(color: AppColors.warning)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Profile'),
                      content: Text('Are you sure you want to delete "${profile.name}"? This action cannot be undone and will delete all weight entries.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(allProfilesProvider.notifier).deleteProfile(profile.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile deleted.')),
                            );
                          },
                          child: const Text('Delete', style: TextStyle(color: AppColors.warning)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(allProfilesProvider);
    final activeProfile = ref.watch(activeProfileProvider);

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
                          Icons.people_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Profiles',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (activeProfile != null)
                    ProfileAvatar(
                      name: activeProfile.name,
                      photoBase64: activeProfile.photoBase64,
                      radius: 18,
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Title Header
              const Text(
                'Profile Switcher',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track health metrics separately for different family members.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Profiles List Section
              const Text(
                'AVAILABLE PROFILES',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              if (profiles.isNotEmpty)
                ...profiles.map(
                  (p) => _buildProfileCard(
                    context: context,
                    ref: ref,
                    profile: p,
                    isActive: activeProfile?.id == p.id,
                    activeProfile: activeProfile,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const Center(
                    child: Text(
                      'No profiles added yet. Tap Add Profile below to create one.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Add Profile Button
              ElevatedButton.icon(
                onPressed: () => context.push('/user-details'), // No query param -> Create mode
                icon: const Icon(Icons.person_add_outlined, size: 20),
                label: const Text('Add Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required BuildContext context,
    required WidgetRef ref,
    required UserProfile profile,
    required bool isActive,
    required UserProfile? activeProfile,
  }) {
    return GestureDetector(
      onLongPress: () => _showProfileOptions(context, ref, profile, activeProfile),
      onTap: () {
        setActiveProfileId(ref, profile.id);
        ref.read(bottomNavIndexProvider.notifier).state = 0; // Nav to dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to profile: ${profile.name}'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLight : AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isActive ? 0.04 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Profile Avatar
                ProfileAvatar(
                  name: profile.name,
                  photoBase64: profile.photoBase64,
                  radius: 26,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.getBmiColor(profile.bmi),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'BMI: ${profile.bmi.toStringAsFixed(1)} (${profile.bmiCategory})',
                            style: TextStyle(
                              color: AppColors.getBmiColor(profile.bmi),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Weight: ${profile.weightKg.toStringAsFixed(1)} kg   •   Height: ${profile.heightCm.toStringAsFixed(0)} cm',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Options / Switch Icon Top-Right
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isActive) ...[
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.swap_horiz, color: AppColors.primary, size: 22),
                      onPressed: () {
                        setActiveProfileId(ref, profile.id);
                        ref.read(bottomNavIndexProvider.notifier).state = 0; // Redirect to Dashboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Switched to profile: ${profile.name}'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
                    onPressed: () => _showProfileOptions(context, ref, profile, activeProfile),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
