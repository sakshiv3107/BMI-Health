String? validateWeight(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Weight is required';
  }
  final weight = double.tryParse(value);
  if (weight == null || weight <= 0) {
    return 'Please enter a valid weight greater than 0';
  }
  return null;
}

String? validateHeight(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Height is required';
  }
  final height = double.tryParse(value);
  if (height == null || height <= 0) {
    return 'Please enter a valid height greater than 0';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
}
