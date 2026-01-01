class Validators {
  // ---------- EMAIL ----------
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w+$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email format';
    }

    return null;
  }

  // ---------- PHONE ----------
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^[0-9]{8,15}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Invalid phone number';
    }

    return null;
  }

  // ---------- EMAIL OR PHONE ----------
  static String? emailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or phone is required';
    }

    final emailError = email(value);
    final phoneError = phone(value);

    if (emailError != null && phoneError != null) {
      return 'Enter a valid email or phone number';
    }

    return null;
  }

  // ---------- PASSWORD ----------
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // ---------- CONFIRM PASSWORD ----------
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }

    if (value != original) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ---------- NAME ----------
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 3) {
      return 'Name is too short';
    }

    return null;
  }
}
