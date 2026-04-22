abstract final class AuthFormValidators {
  static const minimumPasswordLength = 6;

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Please enter your email';
    }

    final parts = email.split('@');
    final isValid =
        !email.contains(RegExp(r'\s')) &&
        parts.length == 2 &&
        parts.every((part) => part.isNotEmpty);

    if (!isValid) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? password(String? value, {required bool isSignUp}) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (isSignUp && value.length < minimumPasswordLength) {
      return 'Password must be at least $minimumPasswordLength characters';
    }

    return null;
  }
}
