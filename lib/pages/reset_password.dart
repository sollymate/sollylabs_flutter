import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollylabs_flutter/auth/auth_service.dart';
import 'package:sollylabs_flutter/pages/otp_page.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final messenger = ScaffoldMessenger.of(context);
                    final authService = ref.read(authServiceProvider);

                    try {
                      await authService.requestPasswordResetOtp(
                        email: _emailController.text,
                      );
                      // Navigate to OtpPage for OTP verification
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtpPage(email: _emailController.text, isResetPassword: true),
                        ),
                      );
                    } catch (error) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Error: ${error.toString()}'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sollylabs_flutter/auth/auth_service.dart';
//
// class ResetPasswordPage extends ConsumerStatefulWidget {
//   const ResetPasswordPage({Key? key}) : super(key: key);
//
//   @override
//   _ResetPasswordPageState createState() => _ResetPasswordPageState();
// }
//
// class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Reset Password'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   hintText: 'Enter your email address',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final messenger = ScaffoldMessenger.of(context);
//                     final authService = ref.read(authServiceProvider);
//
//                     try {
//                       await authService.requestPasswordReset(
//                         email: _emailController.text,
//                       );
//                       messenger.showSnackBar(
//                         const SnackBar(
//                           content: Text('Password reset link sent! Please check your email.'),
//                         ),
//                       );
//                     } catch (error) {
//                       messenger.showSnackBar(
//                         SnackBar(
//                           content: Text('Error: ${error.toString()}'),
//                         ),
//                       );
//                     }
//                   }
//                 },
//                 child: const Text('Send Reset Link'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
