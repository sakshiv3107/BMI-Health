class Profile {
  final String id;
  final String name;
  final double weightKg;
  final double heightCm;
  final bool isPrimary;

  Profile({
    required this.id,
    required this.name,
    required this.weightKg,
    required this.heightCm,
    this.isPrimary = false,
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

  // Check if BMI is normal or not
  bool get isNormalWeight => bmi >= 18.5 && bmi < 25.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'isPrimary': isPrimary,
    };
  }

  factory Profile.fromMap(Map<dynamic, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      name: map['name'] as String,
      weightKg: (map['weightKg'] as num).toDouble(),
      heightCm: (map['heightCm'] as num).toDouble(),
      isPrimary: map['isPrimary'] as bool? ?? false,
    );
  }

  Profile copyWith({
    String? id,
    String? name,
    double? weightKg,
    double? heightCm,
    bool? isPrimary,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
