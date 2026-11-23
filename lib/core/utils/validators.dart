/// Form validators. Each returns an error message, or null when the value is valid.
class Validators {
  // Letters (including accents like é), spaces, hyphens and apostrophes.
  static final _namePattern = RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ]+([ '\-][A-Za-zÀ-ÖØ-öø-ÿ]+)*$");

  // name@domain.tld: the ending must have at least 2 letters (e.g. .com, .rw).
  static final _emailPattern =
      RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$');

  static final _hasLetter = RegExp(r'[A-Za-z]');
  static final _hasDigit = RegExp(r'\d');
  static final _hasSpace = RegExp(r'\s');

  // Digits, spaces, dashes, dots, brackets and an optional + at the start.
  static final _phonePattern = RegExp(r'^\+?[0-9\s\-().]+$');

  static String? fullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Please enter your full name';
    if (name.length < 2) return 'Name must be at least 2 characters';
    if (name.length > 50) return 'Name must be 50 characters or fewer';
    if (!_namePattern.hasMatch(name)) {
      return 'Name can only contain letters, spaces, hyphens and apostrophes';
    }
    return null;
  }

  /// Checks the email's format. The verification email then proves the inbox is real.
  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your email';
    if (email.length > 254) return 'Email is too long';
    if (email.contains('..') || !_emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// For creating a new password (sign up): must be strong.
  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Please enter a password';
    if (_hasSpace.hasMatch(password)) return 'Password cannot contain spaces';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (password.length > 64) return 'Password must be 64 characters or fewer';
    if (!_hasLetter.hasMatch(password) || !_hasDigit.hasMatch(password)) {
      return 'Password must contain at least one letter and one number';
    }
    return null;
  }

  /// For logging in: only checks that something was typed,
  /// so older accounts are never blocked by the newer password rules.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  /// Optional. Accepts local numbers (0785 247 599) and international ones
  /// (+250 785 247 599, +1 415 555 2671, +44 20 7946 0958), following the
  /// international standard: 7 to 15 digits, country code never starts with 0.
  static String? phone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null; // optional
    if (!_phonePattern.hasMatch(phone)) return 'Phone number can only contain digits';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) return 'Please enter a valid phone number';
    if (phone.startsWith('+') && digits.startsWith('0')) {
      return 'Country code cannot start with 0';
    }
    return null;
  }
}