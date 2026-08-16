double calculateBMI(double weightKg, double heightCm) {
  if (heightCm <= 0) return 0.0;
  final heightM = heightCm / 100;
  return weightKg / (heightM * heightM);
}

String bmiCategory(double bmi) {
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25.0) return 'Normal';
  if (bmi < 30.0) return 'Overweight';
  return 'Obese';
}
