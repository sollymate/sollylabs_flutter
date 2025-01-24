import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollylabs_flutter/auth/auth_service.dart';
import 'package:sollylabs_flutter/pages/otp_page.dart';

class SignInDialog extends ConsumerStatefulWidget {
  const SignInDialog({super.key});

  @override
  SignInDialogState createState() => SignInDialogState();
}

class SignInDialogState extends ConsumerState<SignInDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController(); // New: OTP Controller
  bool _showPasswordFields = false;
  bool _showOtpFields = false; // New: Flag for OTP fields

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    // _otpController.dispose(); // No longer needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sign In'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                key: const Key('emailField'),
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Use Password Instead?"),
                  Switch(
                    value: _showPasswordFields,
                    onChanged: (value) {
                      setState(() {
                        _showPasswordFields = value;
                        // Hide OTP fields if switching to password
                        if (_showPasswordFields) {
                          _showOtpFields = false;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            // --- Conditional Password Fields ---
            if (_showPasswordFields) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  key: const Key('passwordField'),
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
            ],
            // --- OTP Fields ---
            if (_showOtpFields) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  key: const Key('otpField'), // Add a key for the OTP field
                  controller: _otpController,
                  decoration: const InputDecoration(labelText: 'OTP'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the OTP';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const Key('signInButton'),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final authService = ref.read(authServiceProvider);
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              if (_showPasswordFields) {
                // Handle password sign-in
                final isSuccess = await authService.signInWithPassword(
                  email: _emailController.text,
                  password: _passwordController.text,
                );
                if (!isSuccess) {
                  messenger.showSnackBar(const SnackBar(
                    content: Text("Incorrect email or password"),
                  ));
                } else {
                  navigator.pop(); // Close dialog on success
                }
              } else {
                // Initiate OTP flow and navigate to OtpPage
                final isSent = await authService.signInWithOtp(
                  email: _emailController.text,
                );
                if (isSent) {
                  // Navigate to OtpPage
                  navigator.push(
                    MaterialPageRoute(
                      builder: (context) => OtpPage(email: _emailController.text),
                    ),
                  );
                } else {
                  messenger.showSnackBar(const SnackBar(
                    content: Text("Failed to send OTP"),
                  ));
                }
              }
            }
          },
          child: const Text('Sign In'),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sollylabs_flutter/auth/auth_service.dart';
//
// class SignInDialog extends ConsumerStatefulWidget {
//   const SignInDialog({super.key});
//
//   @override
//   SignInDialogState createState() => SignInDialogState();
// }
//
// class SignInDialogState extends ConsumerState<SignInDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _showPasswordFields = false;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Sign In'),
//       content: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextFormField(
//                 key: const Key('emailField'),
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: 'Email'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("Use Password Instead?"),
//                   Switch(
//                     value: _showPasswordFields,
//                     onChanged: (value) {
//                       setState(() {
//                         _showPasswordFields = value;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             if (_showPasswordFields) ...[
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: TextFormField(
//                   key: const Key('passwordField'),
//                   controller: _passwordController,
//                   decoration: const InputDecoration(labelText: 'Password'),
//                   obscureText: true,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your password';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           key: const Key('signInButton'),
//           onPressed: () async {
//             if (_formKey.currentState!.validate()) {
//               final authService = ref.read(authServiceProvider);
//               final navigator = Navigator.of(context);
//               final messenger = ScaffoldMessenger.of(context);
//               bool isSuccess = false;
//
//               if (_showPasswordFields) {
//                 isSuccess = await authService.signInWithPassword(
//                   email: _emailController.text,
//                   password: _passwordController.text,
//                 );
//                 if (!isSuccess) {
//                   messenger.showSnackBar(const SnackBar(
//                     content: Text("Incorrect email or password"),
//                   ));
//                 }
//               } else {
//                 isSuccess = await authService.signInWithOtp(
//                   email: _emailController.text,
//                 );
//                 if (!isSuccess) {
//                   messenger.showSnackBar(const SnackBar(
//                     content: Text("Failed to send verification code"),
//                   ));
//                 }
//               }
//
//               if (isSuccess) {
//                 navigator.pop();
//               }
//             }
//           },
//           child: const Text('Sign In'),
//         )
//       ],
//     );
//   }
// }
