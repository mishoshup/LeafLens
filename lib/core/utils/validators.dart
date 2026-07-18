/// Shared form field validators.
class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Validates an email field. Returns an error message, or null if valid.
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Enter your email';
    if (!_emailPattern.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
