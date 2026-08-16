import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double weightKg;

  @HiveField(3)
  final double heightCm;

  @HiveField(4)
  final String? gender; // 'male', 'female', 'other'

  @HiveField(5)
  final String? weightUnit; // 'kg', 'lbs'

  @HiveField(6)
  final String? heightUnit; // 'cm', 'inches'

  @HiveField(7)
  final String? photoBase64; // Profile picture stored as base64

  UserProfile({
    required this.id,
    required this.name,
    required this.weightKg,
    required this.heightCm,
    this.gender,
    this.weightUnit,
    this.heightUnit,
    this.photoBase64,
  });

  // Calculate BMI: weight (kg) / height^2 (m^2)
  double get bmi {
    if (heightCm <= 0) return 0.0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  // Get BMI category description
  String get bmiCategory {
    final val = bmi;
    if (val < 18.5) return 'Underweight';
    if (val < 25.0) return 'Normal Weight';
    if (val < 30.0) return 'Overweight';
    return 'Obese';
  }

  // Check if BMI is normal
  bool get isNormalWeight => bmi >= 18.5 && bmi < 25.0;

  UserProfile copyWith({
    String? id,
    String? name,
    double? weightKg,
    double? heightCm,
    String? gender,
    String? weightUnit,
    String? heightUnit,
    String? photoBase64,
    bool clearPhoto = false,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      gender: gender ?? this.gender,
      weightUnit: weightUnit ?? this.weightUnit,
      heightUnit: heightUnit ?? this.heightUnit,
      photoBase64: clearPhoto ? null : (photoBase64 ?? this.photoBase64),
    );
  }
}
