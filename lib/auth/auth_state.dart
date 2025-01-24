import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((authState) {
    final user = authState.session?.user;
    // Check if the user has set a password
    if (user != null) {
      final hasPassword = user.userMetadata?['password_set'] ?? false;
      user.appMetadata['password_set'] = hasPassword;
    }
    return user;
  });
});

// final authStateProvider = StreamProvider<User?>((ref) {
//   return Supabase.instance.client.auth.onAuthStateChange.map((authState) {
//     return authState.session?.user;
//   });
// });
