import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:assignment/features/profile/models/user_profile.dart';
import 'package:assignment/features/history/models/weight_entry.dart';

// Provider to manage active profile ID, saved in settings box
final activeProfileIdProvider = StateProvider<String?>((ref) {
  final settingsBox = Hive.box('settings');
  final activeId = settingsBox.get('active_profile_id') as String?;
  return activeId;
});

// Helper function to set the active profile ID and save it in Hive settings box
void setActiveProfileId(WidgetRef ref, String? id) {
  ref.read(activeProfileIdProvider.notifier).state = id;
  final settingsBox = Hive.box('settings');
  settingsBox.put('active_profile_id', id);
}

// Notifier for all user profiles, listens live to Hive box changes
class AllProfilesNotifier extends Notifier<List<UserProfile>> {
  late Box<UserProfile> _box;
  VoidCallback? _listener;

  @override
  List<UserProfile> build() {
    _box = Hive.box<UserProfile>('profiles');

    if (_listener != null) {
      _box.listenable().removeListener(_listener!);
    }

    _listener = () {
      state = _box.values.toList();
    };

    _box.listenable().addListener(_listener!);

    ref.onDispose(() {
      if (_listener != null) {
        _box.listenable().removeListener(_listener!);
      }
    });

    return _box.values.toList();
  }

  Future<UserProfile> addProfile(
    String name,
    double weight,
    double height, {
    String? gender,
    String? weightUnit,
    String? heightUnit,
    String? photoBase64,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final newProfile = UserProfile(
      id: id,
      name: name,
      weightKg: weight,
      heightCm: height,
      gender: gender,
      weightUnit: weightUnit,
      heightUnit: heightUnit,
      photoBase64: photoBase64,
    );
    await _box.put(id, newProfile);
    
    // Create initial weight entry in weight_entries box
    final weightBox = Hive.box<WeightEntry>('weight_entries');
    final entryId = DateTime.now().microsecondsSinceEpoch.toString();
    final initialEntry = WeightEntry(
      id: entryId,
      profileId: id,
      weightKg: weight,
      date: DateTime.now(),
    );
    await weightBox.put(entryId, initialEntry);

    return newProfile;
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _box.put(profile.id, profile);
  }

  Future<void> deleteProfile(String id) async {
    await _box.delete(id);
    
    // Also clean up all weight entries associated with this profile
    final weightBox = Hive.box<WeightEntry>('weight_entries');
    final entriesToDelete = weightBox.values.where((e) => e.profileId == id).map((e) => e.id).toList();
    if (entriesToDelete.isNotEmpty) {
      await weightBox.deleteAll(entriesToDelete);
    }

    // Reset active ID if we deleted the currently active profile
    final activeId = ref.read(activeProfileIdProvider);
    if (activeId == id) {
      final settingsBox = Hive.box('settings');
      settingsBox.delete('active_profile_id');
      ref.read(activeProfileIdProvider.notifier).state = null;
    }
  }
}

final allProfilesProvider = NotifierProvider<AllProfilesNotifier, List<UserProfile>>(() {
  return AllProfilesNotifier();
});

// Derived active profile object provider
final activeProfileProvider = Provider<UserProfile?>((ref) {
  final profiles = ref.watch(allProfilesProvider);
  final activeId = ref.watch(activeProfileIdProvider);

  if (activeId == null) {
    return profiles.isNotEmpty ? profiles.first : null;
  }
  
  final matches = profiles.where((p) => p.id == activeId);
  if (matches.isNotEmpty) {
    return matches.first;
  }

  return profiles.isNotEmpty ? profiles.first : null;
});

// Derived active BMI calculation provider
final currentBmiProvider = Provider<double?>((ref) {
  final activeProfile = ref.watch(activeProfileProvider);
  if (activeProfile == null) return null;
  return activeProfile.bmi;
});

// Notifier for weight history, listens live to Hive box changes
class WeightEntriesNotifier extends Notifier<List<WeightEntry>> {
  late Box<WeightEntry> _box;
  VoidCallback? _listener;

  @override
  List<WeightEntry> build() {
    _box = Hive.box<WeightEntry>('weight_entries');

    if (_listener != null) {
      _box.listenable().removeListener(_listener!);
    }

    _listener = () {
      state = _box.values.toList();
    };

    _box.listenable().addListener(_listener!);

    ref.onDispose(() {
      if (_listener != null) {
        _box.listenable().removeListener(_listener!);
      }
    });

    return _box.values.toList();
  }

  Future<void> addEntry(String profileId, double weightKg, {DateTime? customDate}) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final entry = WeightEntry(
      id: id,
      profileId: profileId,
      weightKg: weightKg,
      date: customDate ?? DateTime.now(),
    );
    await _box.put(id, entry);

    // Sync weight to UserProfile current weight state directly in Hive
    final profilesBox = Hive.box<UserProfile>('profiles');
    final currentProfile = profilesBox.get(profileId);
    if (currentProfile != null) {
      final updated = currentProfile.copyWith(weightKg: weightKg);
      await profilesBox.put(profileId, updated);
    }
  }

  Future<void> deleteEntry(String id) async {
    final entry = _box.get(id);
    if (entry == null) return;
    final profileId = entry.profileId;
    await _box.delete(id);

    // Re-sync user profile current weight to the new most recent weight log directly in Hive
    final remaining = _box.values.where((e) => e.profileId == profileId).toList();
    if (remaining.isNotEmpty) {
      remaining.sort((a, b) => b.date.compareTo(a.date)); // date descending
      final mostRecent = remaining.first;

      final profilesBox = Hive.box<UserProfile>('profiles');
      final currentProfile = profilesBox.get(profileId);
      if (currentProfile != null) {
        final updated = currentProfile.copyWith(weightKg: mostRecent.weightKg);
        await profilesBox.put(profileId, updated);
      }
    }
  }
}

final weightEntriesProvider = NotifierProvider<WeightEntriesNotifier, List<WeightEntry>>(() {
  return WeightEntriesNotifier();
});
