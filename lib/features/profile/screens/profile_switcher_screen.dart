import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment/core/theme/app_colors.dart';
import 'package:assignment/features/profile/providers/profile_providers.dart';
import 'package:assignment/features/profile/models/profile.dart';

class ProfileSwitcherScreen extends ConsumerWidget {
  const ProfileSwitcherScreen({super.key});

  void _showAddProfileBottomSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isPrimaryFlag = false;

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
                      'Create New Profile',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Enter a profile name';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Initial Weight (kg)',
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: isPrimaryFlag,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setModalState(() {
                              isPrimaryFlag = val ?? false;
                            });
                          },
                        ),
                        const Text(
                          'Set as primary profile',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final name = nameController.text.trim();
                          final weight = double.parse(weightController.text);
                          final height = double.parse(heightController.text);
                          
                          final newProfile = await ref.read(allProfilesProvider.notifier).addProfile(
                            name,
                            weight,
                            height,
                            isPrimary: isPrimaryFlag,
                          );

                          // Set the newly created profile as active
                          ref.read(activeProfileProvider.notifier).setActiveProfile(newProfile.id);

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Profile for "$name" created successfully!'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Create Profile'),
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

  void _showProfileOptions(BuildContext context, WidgetRef ref, Profile profile, Profile? activeProfile) {
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
              if (activeProfile?.id != profile.id)
                ListTile(
                  leading: const Icon(Icons.swap_horiz, color: AppColors.primary),
                  title: const Text('Switch to this profile'),
                  onTap: () {
                    ref.read(activeProfileProvider.notifier).setActiveProfile(profile.id);
                    Navigator.pop(context);
                  },
                ),
              if (!profile.isPrimary)
                ListTile(
                  leading: const Icon(Icons.star_outline, color: AppColors.primary),
                  title: const Text('Set as primary profile'),
                  onTap: () {
                    ref.read(allProfilesProvider.notifier).setPrimary(profile.id);
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.warning),
                title: const Text('Delete profile', style: TextStyle(color: AppColors.warning)),
                onTap: () {
                  // Confirm deletion
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Profile'),
                      content: Text('Are you sure you want to delete "${profile.name}"? This action cannot be undone.'),
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

    final primaryProfiles = profiles.where((p) => p.isPrimary).toList();
    final otherProfiles = profiles.where((p) => !p.isPrimary).toList();

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
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        activeProfile != null ? activeProfile.name.substring(0,1).toUpperCase() : 'P',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

              // Primary Profile Section
              const Text(
                'PRIMARY PROFILE',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              if (primaryProfiles.isNotEmpty)
                _buildProfileCard(
                  context: context,
                  ref: ref,
                  profile: primaryProfiles.first,
                  isActive: activeProfile?.id == primaryProfiles.first.id,
                  isPrimaryCard: true,
                  activeProfile: activeProfile,
                )
              else
                const Text('No primary profile set'),

              const SizedBox(height: 24),

              // Other Profiles Section
              const Text(
                'OTHER PROFILES',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              if (otherProfiles.isNotEmpty)
                ...otherProfiles.map(
                  (p) => _buildProfileCard(
                    context: context,
                    ref: ref,
                    profile: p,
                    isActive: activeProfile?.id == p.id,
                    isPrimaryCard: false,
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
                      'No other profiles added yet. Tap Add Profile below to create one.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Add Profile Button
              ElevatedButton.icon(
                onPressed: () => _showAddProfileBottomSheet(context, ref),
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
    required Profile profile,
    required bool isActive,
    required bool isPrimaryCard,
    required Profile? activeProfile,
  }) {
    return GestureDetector(
      onLongPress: () => _showProfileOptions(context, ref, profile, activeProfile),
      onTap: () {
        ref.read(activeProfileProvider.notifier).setActiveProfile(profile.id);
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
          color: isPrimaryCard ? AppColors.primaryLight : AppColors.cardBg,
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
                // Profile Avatar Ring
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Text(
                      profile.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                      // Dot + BMI + Weight Metrics
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: profile.isNormalWeight ? AppColors.success : AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'BMI: ${profile.bmi.toStringAsFixed(1)} (${profile.bmiCategory})',
                            style: TextStyle(
                              color: profile.isNormalWeight ? AppColors.success : AppColors.warning,
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
            
            // Badge / Icon Top-Right
            Positioned(
              top: 0,
              right: 0,
              child: isPrimaryCard
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Primary',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.swap_horiz, color: AppColors.primary, size: 22),
                          onPressed: () {
                            ref.read(activeProfileProvider.notifier).setActiveProfile(profile.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Switched to profile: ${profile.name}'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
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
