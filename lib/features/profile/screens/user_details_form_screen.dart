import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:assignment/core/theme/app_colors.dart';
import 'package:assignment/features/profile/providers/profile_providers.dart';

// ─── Unit enums ───────────────────────────────────────────────────────────────
enum _WeightUnit { kg, lbs }
enum _HeightUnit { cm, inches }
enum _Gender { male, female, other }

// ─── Conversion helpers ───────────────────────────────────────────────────────
double _toKg(double v, _WeightUnit u) => u == _WeightUnit.lbs ? v * 0.453592 : v;
double _fromKg(double kg, _WeightUnit u) =>
    u == _WeightUnit.lbs ? kg / 0.453592 : kg;

double _toCm(double v, _HeightUnit u) => u == _HeightUnit.inches ? v * 2.54 : v;
double _fromCm(double cm, _HeightUnit u) =>
    u == _HeightUnit.inches ? cm / 2.54 : cm;

String _genderString(_Gender g) {
  switch (g) {
    case _Gender.male:
      return 'male';
    case _Gender.female:
      return 'female';
    case _Gender.other:
      return 'other';
  }
}

_Gender? _genderFromString(String? s) {
  switch (s) {
    case 'male':
      return _Gender.male;
    case 'female':
      return _Gender.female;
    case 'other':
      return _Gender.other;
    default:
      return null;
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class UserDetailsFormScreen extends ConsumerStatefulWidget {
  final String? profileId;

  const UserDetailsFormScreen({super.key, this.profileId});

  @override
  ConsumerState<UserDetailsFormScreen> createState() =>
      _UserDetailsFormScreenState();
}

class _UserDetailsFormScreenState extends ConsumerState<UserDetailsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  bool _isLoading = false;
  bool _isEditMode = false;

  _WeightUnit _weightUnit = _WeightUnit.kg;
  _HeightUnit _heightUnit = _HeightUnit.cm;
  _Gender? _gender;
  bool _genderTouched = false;

  // Profile photo (held as base64 so it works on web + mobile)
  String? _pickedPhotoBase64;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.profileId != null;

    String initialName = '';
    double initialWeightKg = 0;
    double initialHeightCm = 0;

    if (_isEditMode) {
      final profiles = ref.read(allProfilesProvider);
      final match = profiles.where((p) => p.id == widget.profileId);
      if (match.isNotEmpty) {
        final profile = match.first;
        initialName = profile.name;
        initialWeightKg = profile.weightKg;
        initialHeightCm = profile.heightCm;

        // Restore saved units
        if (profile.weightUnit == 'lbs') _weightUnit = _WeightUnit.lbs;
        if (profile.heightUnit == 'inches') _heightUnit = _HeightUnit.inches;
        _gender = _genderFromString(profile.gender);
        _pickedPhotoBase64 = profile.photoBase64;
      }
    }

    _nameController = TextEditingController(text: initialName);

    // Show value in the user's chosen unit
    _weightController = TextEditingController(
      text: initialWeightKg > 0
          ? _fmt(_fromKg(initialWeightKg, _weightUnit))
          : '',
    );
    _heightController = TextEditingController(
      text: initialHeightCm > 0
          ? _fmt(_fromCm(initialHeightCm, _heightUnit))
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // Format double: strip trailing zeros
  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  // Called when weight unit toggle changes
  void _onWeightUnitChanged(_WeightUnit newUnit) {
    final raw = double.tryParse(_weightController.text);
    setState(() {
      if (raw != null && raw > 0) {
        final inKg = _toKg(raw, _weightUnit);
        _weightController.text = _fmt(_fromKg(inKg, newUnit));
      }
      _weightUnit = newUnit;
    });
  }

  // Called when height unit toggle changes
  void _onHeightUnitChanged(_HeightUnit newUnit) {
    final raw = double.tryParse(_heightController.text);
    setState(() {
      if (raw != null && raw > 0) {
        final inCm = _toCm(raw, _heightUnit);
        _heightController.text = _fmt(_fromCm(inCm, newUnit));
      }
      _heightUnit = newUnit;
    });
  }

  // ─── Pick photo ─────────────────────────────────────────────────────────────
  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      // Show source chooser on mobile; web only supports gallery
      ImageSource? source;
      if (Theme.of(context).platform == TargetPlatform.android ||
          Theme.of(context).platform == TargetPlatform.iOS) {
        source = await _showSourceDialog();
        if (source == null) return;
      } else {
        source = ImageSource.gallery;
      }

      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 60,  // compress to keep Hive entry small
        maxWidth: 400,
        maxHeight: 400,
      );

      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      final base64Str = base64Encode(bytes);

      setState(() => _pickedPhotoBase64 = base64Str);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image: $e'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  Future<ImageSource?> _showSourceDialog() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── Submit ─────────────────────────────────────────────────────────────────
  void _submit() async {
    setState(() => _genderTouched = true);

    if (!_formKey.currentState!.validate()) return;
    if (_gender == null) return; // gender error shown via setState

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final weightRaw = double.parse(_weightController.text);
    final heightRaw = double.parse(_heightController.text);

    // Convert to canonical units (kg, cm)
    final weightKg = _toKg(weightRaw, _weightUnit);
    final heightCm = _toCm(heightRaw, _heightUnit);

    try {
      if (_isEditMode) {
        final profiles = ref.read(allProfilesProvider);
        final profile = profiles.firstWhere((p) => p.id == widget.profileId);
        final weightChanged = (profile.weightKg - weightKg).abs() > 0.01;
        final heightChanged = (profile.heightCm - heightCm).abs() > 0.01;

        final updatedProfile = profile.copyWith(
          name: name,
          weightKg: weightKg,
          heightCm: heightCm,
          gender: _genderString(_gender!),
          weightUnit: _weightUnit == _WeightUnit.lbs ? 'lbs' : 'kg',
          heightUnit: _heightUnit == _HeightUnit.inches ? 'inches' : 'cm',
          photoBase64: _pickedPhotoBase64,
        );

        // Read notifiers synchronously BEFORE async gaps to prevent disposed WidgetRef errors
        final profilesNotifier = ref.read(allProfilesProvider.notifier);
        final weightEntriesNotifier = ref.read(weightEntriesProvider.notifier);

        await profilesNotifier.updateProfile(updatedProfile);

        if (weightChanged || heightChanged) {
          await weightEntriesNotifier.addEntry(profile.id, weightKg);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppColors.primary,
            ),
          );
          context.pop();
        }
      } else {
        final newProfile = await ref.read(allProfilesProvider.notifier).addProfile(
              name,
              weightKg,
              heightCm,
            );

        // Patch gender, units, and photo onto new profile
        final withExtras = newProfile.copyWith(
          gender: _genderString(_gender!),
          weightUnit: _weightUnit == _WeightUnit.lbs ? 'lbs' : 'kg',
          heightUnit: _heightUnit == _HeightUnit.inches ? 'inches' : 'cm',
          photoBase64: _pickedPhotoBase64,
        );
        await ref.read(allProfilesProvider.notifier).updateProfile(withExtras);

        setActiveProfileId(ref, newProfile.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile for "$name" set up successfully!'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── UI helpers ─────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  /// A pill-shaped toggle: [leftLabel] | [rightLabel]
  Widget _buildUnitToggle<T>({
    required T current,
    required T leftValue,
    required T rightValue,
    required String leftLabel,
    required String rightLabel,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.fillLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _togglePill(leftLabel, current == leftValue, () => onChanged(leftValue)),
          _togglePill(rightLabel, current == rightValue, () => onChanged(rightValue)),
        ],
      ),
    );
  }

  Widget _togglePill(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    final showError = _genderTouched && _gender == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('GENDER'),
        Row(
          children: [
            _Gender.male,
            _Gender.female,
            _Gender.other,
          ].map((g) => _genderChip(g)).toList().fold<List<Widget>>(
            [],
            (acc, w) => [...acc, if (acc.isNotEmpty) const SizedBox(width: 10), w],
          ).toList(),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Please select a gender',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _genderChip(_Gender g) {
    final selected = _gender == g;
    String label;
    IconData icon;
    switch (g) {
      case _Gender.male:
        label = 'Male';
        icon = Icons.male;
        break;
      case _Gender.female:
        label = 'Female';
        icon = Icons.female;
        break;
      case _Gender.other:
        label = 'Other';
        icon = Icons.transgender;
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _gender = g;
          _genderTouched = true;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.fillLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.borderLight,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final weightHint =
        _weightUnit == _WeightUnit.kg ? 'e.g. 70.5' : 'e.g. 155.5';
    final heightHint =
        _heightUnit == _HeightUnit.cm ? 'e.g. 175' : 'e.g. 68.9';
    final weightLabel =
        _weightUnit == _WeightUnit.kg ? 'Weight (kg)' : 'Weight (lbs)';
    final heightLabel =
        _heightUnit == _HeightUnit.cm ? 'Height (cm)' : 'Height (inches)';

    // Sensible numeric ranges (in display unit)
    final weightMin = _weightUnit == _WeightUnit.kg ? 10.0 : 22.0;
    final weightMax = _weightUnit == _WeightUnit.kg ? 500.0 : 1100.0;
    final heightMin = _heightUnit == _HeightUnit.cm ? 50.0 : 19.7;
    final heightMax = _heightUnit == _HeightUnit.cm ? 300.0 : 118.1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _isEditMode
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
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
                  // ── Header ──────────────────────────────────────────────
                  if (!_isEditMode) ...[
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
                  ],

                  Text(
                    _isEditMode ? 'Update Profile Details' : 'Set Up Your Profile',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isEditMode
                        ? 'Modify the details for this profile.'
                        : 'Welcome to BMI Health! Enter your details below to create a new health tracking profile.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // ── Form Card ────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Profile Photo ──────────────────────────────────
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  // Avatar display
                                  GestureDetector(
                                    onTap: _pickPhoto,
                                    child: _pickedPhotoBase64 != null && _pickedPhotoBase64!.isNotEmpty
                                        ? CircleAvatar(
                                            radius: 52,
                                            backgroundImage: MemoryImage(
                                              base64Decode(_pickedPhotoBase64!),
                                            ),
                                            backgroundColor: AppColors.primaryLight,
                                          )
                                        : CircleAvatar(
                                            radius: 52,
                                            backgroundColor: AppColors.primaryLight,
                                            child: Icon(
                                              Icons.person_outline,
                                              size: 48,
                                              color: AppColors.primary.withOpacity(0.5),
                                            ),
                                          ),
                                  ),
                                  // Camera badge
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _pickPhoto,
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Remove photo button
                                  if (_pickedPhotoBase64 != null && _pickedPhotoBase64!.isNotEmpty)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => setState(() => _pickedPhotoBase64 = null),
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color: AppColors.warning,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _pickedPhotoBase64 != null ? 'Tap photo to change' : 'Add Profile Photo',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Name ──────────────────────────────────────────
                        _buildSectionLabel('FULL NAME'),
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline),
                            hintText: 'e.g. John Doe',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter a name';
                            }
                            if (v.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),


                        // ── Gender ────────────────────────────────────────
                        _buildGenderSelector(),
                        const SizedBox(height: 24),

                        // ── Weight ────────────────────────────────────────
                        Row(
                          children: [
                            Expanded(child: _buildSectionLabel('WEIGHT')),
                            _buildUnitToggle<_WeightUnit>(
                              current: _weightUnit,
                              leftValue: _WeightUnit.kg,
                              rightValue: _WeightUnit.lbs,
                              leftLabel: 'KG',
                              rightLabel: 'LBS',
                              onChanged: _onWeightUnitChanged,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.monitor_weight_outlined),
                            hintText: weightHint,
                            suffixText: _weightUnit == _WeightUnit.kg ? 'kg' : 'lbs',
                            labelText: weightLabel,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please enter your weight';
                            }
                            final val = double.tryParse(v);
                            if (val == null) {
                              return 'Enter a valid number';
                            }
                            if (val < weightMin || val > weightMax) {
                              return 'Weight must be between ${weightMin.toStringAsFixed(0)} and ${weightMax.toStringAsFixed(0)} ${_weightUnit == _WeightUnit.kg ? "kg" : "lbs"}';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // ── Height ────────────────────────────────────────
                        Row(
                          children: [
                            Expanded(child: _buildSectionLabel('HEIGHT')),
                            _buildUnitToggle<_HeightUnit>(
                              current: _heightUnit,
                              leftValue: _HeightUnit.cm,
                              rightValue: _HeightUnit.inches,
                              leftLabel: 'CM',
                              rightLabel: 'IN',
                              onChanged: _onHeightUnitChanged,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _heightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.height),
                            hintText: heightHint,
                            suffixText: _heightUnit == _HeightUnit.cm ? 'cm' : 'in',
                            labelText: heightLabel,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please enter your height';
                            }
                            final val = double.tryParse(v);
                            if (val == null) {
                              return 'Enter a valid number';
                            }
                            if (val < heightMin || val > heightMax) {
                              return 'Height must be between ${heightMin.toStringAsFixed(1)} and ${heightMax.toStringAsFixed(1)} ${_heightUnit == _HeightUnit.cm ? "cm" : "in"}';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Submit Button ─────────────────────────────────────────
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
                            children: [
                              Text(_isEditMode ? 'Save Changes' : 'Complete Setup'),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
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

