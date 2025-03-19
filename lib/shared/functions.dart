String? validateEmail(String? value) {
    if (value == null || value.isEmpty || !value.contains("@")) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }




bool containsLetter(String input) {
  return RegExp(r'[a-zA-Z]').hasMatch(input);
}