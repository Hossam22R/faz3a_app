class Validators {
  Validators._();

  static bool isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  static bool isValidIraqiPhone(String value) {
    return RegExp(r'^(?:\+964|0)7[0-9]{9}$').hasMatch(value);
  }

  static String? requiredField(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
