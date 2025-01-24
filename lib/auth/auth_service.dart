import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  final _log = Logger('AuthService');

  Future<bool> signInWithOtp({required String email}) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.supabase.flutter://login-callback/', // Correct redirect URL
      );
      return true;
    } catch (e) {
      _log.severe('Error in signInWithOtp', e);
      return false;
    }
  }

  // Sign in with password
  Future<bool> signInWithPassword({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _log.severe('Error in signInWithPassword', e);
      return false;
    }
  }

  // Sign up with password
  Future<bool> signUpWithPassword({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _log.severe('Error in signUpWithPassword', e);
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      if (response.user != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _log.severe('Error in verifyOtp', e);
      return false;
    }
  }

  Future<bool> updateUserPassword({required String password}) async {
    try {
      final updates = UserAttributes(password: password, data: {'password_set': true}); // Update appMetadata

      final response = await _supabase.auth.updateUser(updates);

      if (response.user != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _log.severe('Error in updateUserPassword', e);
      return false;
    }
  }

  // Verify current password
  Future<bool> verifyCurrentPassword({required String password}) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      // Get the user's current session
      final currentSession = _supabase.auth.currentSession;
      if (currentSession == null) {
        return false;
      }

      // Re-authenticate with the current password
      final response = await _supabase.auth.signInWithPassword(
        email: currentUser.email,
        password: password,
      );

      if (response.user != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _log.severe('Error in verifyCurrentPassword', e);
      return false;
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email, redirectTo: "io.supabase.flutter://");
    } catch (e) {
      _log.severe('Error in requestPasswordReset', e);
      rethrow;
    }
  }

  // Request OTP for password reset
  Future<void> requestPasswordResetOtp({required String email}) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.supabase.flutter://', // Update with your redirect URL if needed
      );
    } catch (e) {
      _log.severe('Error in requestPasswordResetOtp', e);
      rethrow;
    }
  }

  // Verify OTP for password reset
  Future<bool> verifyPasswordResetOtp({required String email, required String otp}) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );
      if (response.user != null) {
        return true;
      }
      return false;
    } catch (e) {
      _log.severe('Error in verifyPasswordResetOtp', e);
      return false;
    }
  }

  // Update user password after OTP verification
  Future<bool> updateUserPasswordAfterOtp({required String password}) async {
    try {
      final updates = UserAttributes(password: password);
      final response = await _supabase.auth.updateUser(updates);
      if (response.user != null) {
        return true;
      }
      return false;
    } catch (e) {
      _log.severe('Error in updateUserPasswordAfterOtp', e);
      return false;
    }
  }
}

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:logging/logging.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// final authServiceProvider = Provider<AuthService>((ref) {
//   return AuthService(Supabase.instance.client);
// });
//
// class AuthService {
//   final SupabaseClient _supabase;
//
//   AuthService(this._supabase);
//
//   final _log = Logger('AuthService');
//
//   Future<bool> signInWithOtp({required String email}) async {
//     try {
//       await _supabase.auth.signInWithOtp(email: email, emailRedirectTo: 'io.supabase.flutter://login-callback/');
//       return true;
//     } catch (e) {
//       _log.severe('Error in signInWithOtp', e);
//       return false;
//     }
//   }
//
//   // Sign in with password
//   Future<bool> signInWithPassword({required String email, required String password}) async {
//     try {
//       final response = await _supabase.auth.signInWithPassword(email: email, password: password);
//
//       if (response.user != null) {
//         return true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       _log.severe('Error in signInWithPassword', e);
//       return false;
//     }
//   }
//
//   // Sign up with password
//   Future<bool> signUpWithPassword({required String email, required String password}) async {
//     try {
//       final response = await _supabase.auth.signUp(email: email, password: password);
//
//       if (response.user != null) {
//         return true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       _log.severe('Error in signUpWithPassword', e);
//       return false;
//     }
//   }
// }
