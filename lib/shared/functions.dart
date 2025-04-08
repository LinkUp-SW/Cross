String? validateEmail(String? value) {
  final emailRegex = RegExp(
      r"^(?=.{1,254}$)(?=[^@]{1,64}@)[a-zA-Z0-9][a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]*(?:\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:(?=[a-z0-9]{1,63}\.)[a-z0-9](?:[a-z0-9]{0,61}[a-z0-9])?\.)+(?=[a-z0-9]{2,63}$)[a-z0-9]{2,63}$");

      

  if (value == null || value.isEmpty || !emailRegex.hasMatch(value)) {
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
