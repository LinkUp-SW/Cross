class ForgotPasswordService {
  Future<void> sendPasswordResetEmail(String email) async {
    // Send password reset email
    await Future.delayed(Duration(seconds: 2));
  }
}