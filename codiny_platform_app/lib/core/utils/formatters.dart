class Formatters {
  /// Remove spaces and trim
  static String normalize(String value) {
    return value.trim().replaceAll(' ', '');
  }

  /// Normalize phone number (digits only)
  /// Example: "+216 98 123 456" → "98123456"
  static String normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Capitalize first letter of each word
  /// Example: "ali ben salah" → "Ali Ben Salah"
  static String capitalizeName(String value) {
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Lowercase email safely
  static String normalizeEmail(String value) {
    return value.trim().toLowerCase();
  }

  /// Mask phone number for UI
  /// Example: 98123456 → 98****56
  static String maskPhone(String phone) {
    if (phone.length < 6) return phone;
    return phone.substring(0, 2) +
        '****' +
        phone.substring(phone.length - 2);
  }

  /// Format remaining days text
  static String daysLeftText(int days) {
    if (days <= 0) return 'Expired';
    if (days == 1) return '1 day left';
    return '$days days left';
  }
}
