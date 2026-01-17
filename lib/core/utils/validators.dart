/// Validation utilities for form inputs
class Validators {
  /// Validates Turkish phone number format (90XXXXXXXXXX)
  /// Returns null if valid, error message if invalid
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gerekli';
    }

    // Remove any whitespace or special characters
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it matches the format: 90XXXXXXXXXX (12 digits total)
    if (!RegExp(r'^90\d{10}$').hasMatch(cleanPhone)) {
      return 'Geçerli bir telefon numarası giriniz (90XXXXXXXXXX)';
    }

    return null;
  }

  /// Checks if a string is a valid phone number format
  static bool isPhoneNumber(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    return RegExp(r'^90\d{10}$').hasMatch(cleanValue);
  }

  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }

    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }

    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }

    return null;
  }

  /// Converts phone number to internal email format for Supabase
  /// Example: 905551234567 -> 905551234567@phone.internal
  static String phoneToEmail(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return '$cleanPhone@phone.internal';
  }

  /// Checks if an email is a phone-based internal email
  static bool isPhoneEmail(String email) {
    return email.endsWith('@phone.internal');
  }

  /// Extracts phone number from internal email format
  /// Example: 905551234567@phone.internal -> 905551234567
  static String emailToPhone(String email) {
    if (!isPhoneEmail(email)) return email;
    return email.split('@')[0];
  }
}
