import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment/core/theme/app_colors.dart';
import 'package:assignment/features/profile/providers/profile_providers.dart';

class UserDetailsSetupScreen extends ConsumerStatefulWidget {
  const UserDetailsSetupScreen({super.key});

  @override
  ConsumerState<UserDetailsSetupScreen> createState() => _UserDetailsSetupScreenState();
}

class _UserDetailsSetupScreenState extends ConsumerState<UserDetailsSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final name = _nameController.text.trim();
      final weight = double.parse(_weightController.text);
      final height = double.parse(_heightController.text);

      try {
        final newProfile = await ref.read(allProfilesProvider.notifier).addProfile(
              name,
              weight,
              height,
              isPrimary: true,
            );
        // Set the active profile ID
        ref.read(activeProfileProvider.notifier).setActiveProfile(newProfile.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile for "$name" set up successfully!'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save profile: $e'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App branding logo
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Set Up Your Profile',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome to BMI Health! Enter your initial details below to set up your primary health tracking profile.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Container wrapping fields
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name Input
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Your Name',
                            prefixIcon: Icon(Icons.person_outline),
                            hintText: 'e.g. John Doe',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Weight Input
                        TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Weight (kg)',
                            prefixIcon: Icon(Icons.monitor_weight_outlined),
                            hintText: 'e.g. 70.5',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your weight';
                            }
                            final val = double.tryParse(value);
                            if (val == null || val <= 0) {
                              return 'Please enter a valid weight';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Height Input
                        TextFormField(
                          controller: _heightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Height (cm)',
                            prefixIcon: Icon(Icons.height),
                            hintText: 'e.g. 175',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your height';
                            }
                            final val = double.tryParse(value);
                            if (val == null || val <= 0) {
                              return 'Please enter a valid height';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Setup Complete button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Complete Setup'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
