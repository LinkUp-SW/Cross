Map<String, dynamic> validateEmail(String email) {
  if (email.isEmpty) {
    return {"error": true, "message": "Email cannot be empty"};
  }

  // Simple regex for basic email validation
  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegExp.hasMatch(email)) {
    return {"error": true, "message": "Please enter a valid email"};
  }

  return {"error": false, "message": null};
}
