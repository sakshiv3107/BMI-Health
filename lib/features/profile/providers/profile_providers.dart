import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:assignment/features/profile/models/profile.dart';

// Provider for all profiles list
final allProfilesProvider = NotifierProvider<AllProfilesNotifier, List<Profile>>(() {
  return AllProfilesNotifier();
});

class AllProfilesNotifier extends Notifier<List<Profile>> {
  late Box _box;

  @override
  List<Profile> build() {
    _box = Hive.box('profiles');
    final stored = _box.values;
    
    if (stored.isEmpty) {
      return [];
    }

    return stored.map((e) => Profile.fromMap(Map<dynamic, dynamic>.from(e))).toList();
  }

  Future<Profile> addProfile(String name, double weight, double height, {bool isPrimary = false}) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final newProfile = Profile(
      id: id,
      name: name,
      weightKg: weight,
      heightCm: height,
      isPrimary: isPrimary,
    );

    if (isPrimary) {
      // Clear other primary flags
      state = state.map((p) {
        if (p.isPrimary) {
          final updated = p.copyWith(isPrimary: false);
          _box.put(updated.id, updated.toMap());
          return updated;
        }
        return p;
      }).toList();
    }

    _box.put(newProfile.id, newProfile.toMap());
    state = [...state, newProfile];
    return newProfile;
  }

  Future<void> updateProfile(String id, {String? name, double? weight, double? height, bool? isPrimary}) async {
    state = state.map((p) {
      if (p.id == id) {
        final updated = p.copyWith(
          name: name,
          weightKg: weight,
          heightCm: height,
          isPrimary: isPrimary,
        );
        _box.put(updated.id, updated.toMap());
        return updated;
      }
      
      // If we are setting a new primary, disable it for others
      if (isPrimary == true && p.isPrimary) {
        final updated = p.copyWith(isPrimary: false);
        _box.put(updated.id, updated.toMap());
        return updated;
      }
      return p;
    }).toList();
  }

  Future<void> deleteProfile(String id) async {
    final profileToDelete = state.firstWhere((p) => p.id == id);
    _box.delete(id);
    state = state.where((p) => p.id != id).toList();

    // If we deleted the primary, make the first remaining profile primary
    if (profileToDelete.isPrimary && state.isNotEmpty) {
      final first = state.first;
      await updateProfile(first.id, isPrimary: true);
    }
  }

  Future<void> setPrimary(String id) async {
    state = state.map((p) {
      final updated = p.copyWith(isPrimary: p.id == id);
      _box.put(updated.id, updated.toMap());
      return updated;
    }).toList();
  }
}

// Provider for currently active profile
final activeProfileProvider = NotifierProvider<ActiveProfileNotifier, Profile?>(() {
  return ActiveProfileNotifier();
});

class ActiveProfileNotifier extends Notifier<Profile?> {
  late Box _settingsBox;

  @override
  Profile? build() {
    final profiles = ref.watch(allProfilesProvider);
    if (profiles.isEmpty) return null;

    _settingsBox = Hive.box('settings');
    final activeId = _settingsBox.get('active_profile_id') as String?;

    if (activeId != null) {
      final match = profiles.where((p) => p.id == activeId);
      if (match.isNotEmpty) {
        return match.first;
      }
    }

    // Default to primary, or first if no primary is set
    final primary = profiles.firstWhere((p) => p.isPrimary, orElse: () => profiles.first);
    return primary;
  }

  void setActiveProfile(String id) {
    _settingsBox.put('active_profile_id', id);
    
    // Find in current state and set
    final profiles = ref.read(allProfilesProvider);
    final match = profiles.where((p) => p.id == id);
    if (match.isNotEmpty) {
      state = match.first;
    }
  }
}

// Current BMI provider
final currentBmiProvider = Provider<double>((ref) {
  final activeProfile = ref.watch(activeProfileProvider);
  return activeProfile?.bmi ?? 0.0;
});
