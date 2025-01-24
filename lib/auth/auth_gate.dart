import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sollylabs_flutter/pages/account_page.dart';
import 'package:sollylabs_flutter/pages/create_password.dart';
import 'package:sollylabs_flutter/pages/login_page.dart';

import 'auth_state.dart';

class AuthGate extends ConsumerWidget {
  AuthGate({Key? key}) : super(key: key); // Remove const

  final _log = Logger('AuthGate');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (user) {
        _log.info('User: $user'); // Log user data
        if (user != null) {
          final hasPassword = user.appMetadata['password_set'] ?? false;
          _log.info('Has Password: $hasPassword'); // Log password_set status

          if (hasPassword) {
            return const AccountPage();
          } else {
            return const CreatePasswordPage();
          }
        } else {
          return const LoginPage();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sollylabs_flutter/pages/account_page.dart';
// import 'package:sollylabs_flutter/pages/create_password.dart';
// import 'package:sollylabs_flutter/pages/login_page.dart';
//
// import 'auth_state.dart';
//
// class AuthGate extends ConsumerWidget {
//   const AuthGate({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authStateProvider);
//     return authState.when(
//       data: (user) {
//         if (user != null) {
//           final hasPassword = user.appMetadata['password_set'] ?? false;
//
//           if (hasPassword) {
//             return const AccountPage();
//           } else {
//             return const CreatePasswordPage(); // Navigate to CreatePasswordPage
//           }
//         } else {
//           return const LoginPage(); // Go to LoginPage if not logged in
//         }
//       },
//       loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
//       error: (error, stackTrace) => Scaffold(body: Center(child: Text('Error: $error'))),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sollylabs_flutter/auth/auth_service.dart';
// import 'package:sollylabs_flutter/auth/auth_state.dart';
//
// import '../pages/account_page.dart';
//
// class AuthGate extends ConsumerStatefulWidget {
//   const AuthGate({super.key}); // Correct: Using super parameter
//
//   @override
//   AuthGateState createState() => AuthGateState();
// }
//
// class AuthGateState extends ConsumerState<AuthGate> {
//   final _emailController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//
//   // --- Variables for Password Authentication ---
//   bool _showPasswordFields = false;
//   final _passwordController = TextEditingController();
//
//   var _isLoading = false;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _signIn() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     // Using the messenger before the async gap
//     final messenger = ScaffoldMessenger.of(context);
//
//     // Store the value of mounted locally
//     final navigator = Navigator.of(context);
//
//     await showDialog(
//       context: context,
//       barrierDismissible: false, // Prevent user from dismissing the dialog
//       builder: (context) => AlertDialog(
//         title: const Text('Sign in'),
//         content: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextFormField(
//                   key: const Key('emailField'),
//                   controller: _emailController,
//                   decoration: const InputDecoration(labelText: 'Email'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) return 'Please enter your email';
//                     return null;
//                   },
//                 ),
//               ),
//
//               // --- Toggle Button ---
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Use Password Instead?"),
//                     Switch(value: _showPasswordFields, onChanged: (value) => setState(() => _showPasswordFields = value)),
//                   ],
//                 ),
//               ),
//
//               // --- Conditional Password Fields ---
//               if (_showPasswordFields) ...[
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: TextFormField(
//                     key: const Key('passwordField'),
//                     controller: _passwordController,
//                     decoration: const InputDecoration(labelText: 'Password'),
//                     obscureText: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) return 'Please enter your password';
//                       return null;
//                     },
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => navigator.pop(), child: const Text('Cancel')),
//           TextButton(
//             key: const Key('signInButton'),
//             onPressed: () async {
//               if (_formKey.currentState!.validate()) {
//                 final authService = ref.read(authServiceProvider);
//                 bool isSuccess = false;
//
//                 if (_showPasswordFields) {
//                   // Handle password sign-in
//                   isSuccess = await authService.signInWithPassword(email: _emailController.text, password: _passwordController.text);
//                   if (!isSuccess) messenger.showSnackBar(const SnackBar(content: Text("Incorrect email or password")));
//                 } else {
//                   // Handle existing OTP sign-in
//                   isSuccess = await authService.signInWithOtp(email: _emailController.text);
//                   if (!isSuccess) messenger.showSnackBar(const SnackBar(content: Text("Failed to send verification code")));
//                 }
//
//                 if (isSuccess) navigator.pop();
//               }
//             },
//             child: const Text('Sign In'),
//           )
//         ],
//       ),
//     );
//
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authStateProvider);
//     return authState.when(
//       data: (user) {
//         if (user != null) {
//           return const AccountPage(); // Correct page
//         } else {
//           return Scaffold(
//             appBar: AppBar(title: const Text('Solly Labs')),
//             body: Center(
//               child: _isLoading
//                   ? const CircularProgressIndicator() // Loader
//                   : ElevatedButton(key: const Key('signInWithEmailButton'), onPressed: _signIn, child: const Text('Sign in')),
//             ),
//           );
//         }
//       },
//       loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
//       error: (error, stackTrace) => Scaffold(body: Center(child: Text('Error: $error'))),
//     );
//   }
// }
