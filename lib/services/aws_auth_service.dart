import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class AwsAuthService {
  // 1. Sign Up
  Future<String?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userAttributes = {
        AuthUserAttributeKey.name: name,
        AuthUserAttributeKey.email: email,
      };
      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(userAttributes: userAttributes),
      );
      if (result.isSignUpComplete) return "success";
      return "confirm_email";
    } on AuthException catch (e) {
      return e.message;
    }
  }

  // 2. Confirm Email
  Future<bool> confirmEmail(String email, String confirmationCode) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
      return result.isSignUpComplete;
    } catch (e) {
      print("Confirmation Error: $e");
      return false;
    }
  }

  // 3. Login
  Future<String?> login(String email, String password) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
      if (result.isSignedIn) return "success";
      return "Login failed";
    } on AuthException catch (e) {
      return e.message;
    }
  }

  // 4. Logout
  Future<void> logout() async {
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  // 5. Check Current User
  Future<AuthUser?> getCurrentUser() async {
    try {
      return await Amplify.Auth.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  // ✅ 6. Reset Password (Send Code)
  Future<bool> resetPassword(String email) async {
    try {
      await Amplify.Auth.resetPassword(username: email);
      return true;
    } catch (e) {
      print("Reset Password Error: $e");
      return false;
    }
  }

  // ✅ 7. Confirm Password Reset (New Password)
  Future<bool> confirmPasswordReset(
    String email,
    String newPassword,
    String code,
  ) async {
    try {
      await Amplify.Auth.confirmResetPassword(
        username: email,
        newPassword: newPassword,
        confirmationCode: code,
      );
      return true;
    } catch (e) {
      print("Confirm Reset Error: $e");
      return false;
    }
  }
}
