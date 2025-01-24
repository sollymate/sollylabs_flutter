import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollylabs_flutter/auth/auth_service.dart';
import 'package:sollylabs_flutter/auth/auth_state.dart';

import 'update_password_after_reset.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String email;
  final bool isResetPassword;

  const OtpPage({
    required this.email,
    this.isResetPassword = false,
    Key? key,
  }) : super(key: key);

  @override
  OtpPageState createState() => OtpPageState();
}

class OtpPageState extends ConsumerState<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter the OTP sent to your email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final authService = ref.read(authServiceProvider);
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    if (widget.isResetPassword) {
                      // Verify OTP for password reset
                      final isVerified = await authService.verifyPasswordResetOtp(
                        email: widget.email,
                        otp: _otpController.text,
                      );
                      if (isVerified) {
                        // Navigate to UpdatePasswordAfterResetPage
                        navigator.push(
                          MaterialPageRoute(
                            builder: (context) => const UpdatePasswordAfterResetPage(),
                          ),
                        );
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Incorrect OTP'),
                          ),
                        );
                      }
                    } else {
                      // Existing OTP verification for sign-in
                      final isVerified = await authService.verifyOtp(
                        email: widget.email,
                        otp: _otpController.text,
                      );
                      if (isVerified) {
                        // Refresh the auth state to trigger AuthGate rebuild
                        ref.refresh(authStateProvider);
                        navigator.pop();
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AccountPage()));
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Incorrect OTP'),
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text(widget.isResetPassword ? 'Verify OTP for Reset' : 'Verify OTP for Sign In'),
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
// import 'update_password_after_reset.dart';
//
// class OtpPage extends ConsumerStatefulWidget {
//   final String email;
//   final bool isResetPassword;
//
//   const OtpPage({
//     required this.email,
//     this.isResetPassword = false,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   OtpPageState createState() => OtpPageState();
// }
//
// class OtpPageState extends ConsumerState<OtpPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _otpController = TextEditingController();
//
//   @override
//   void dispose() {
//     _otpController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Enter OTP'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextFormField(
//                 controller: _otpController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'OTP',
//                   hintText: 'Enter the OTP sent to your email',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the OTP';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final authService = ref.read(authServiceProvider);
//                     final messenger = ScaffoldMessenger.of(context);
//                     final navigator = Navigator.of(context);
//
//                     if (widget.isResetPassword) {
//                       // Verify OTP for password reset
//                       final isVerified = await authService.verifyPasswordResetOtp(
//                         email: widget.email,
//                         otp: _otpController.text,
//                       );
//                       if (isVerified) {
//                         // Navigate to UpdatePasswordAfterResetPage
//                         navigator.push(
//                           MaterialPageRoute(
//                             builder: (context) => const UpdatePasswordAfterResetPage(),
//                           ),
//                         );
//                       } else {
//                         messenger.showSnackBar(
//                           const SnackBar(
//                             content: Text('Incorrect OTP'),
//                           ),
//                         );
//                       }
//                     } else {
//                       // Existing OTP verification for sign-in
//                       final isVerified = await authService.verifyOtp(
//                         email: widget.email,
//                         otp: _otpController.text,
//                       );
//                       if (isVerified) {
//                         navigator.pop();
//                       } else {
//                         messenger.showSnackBar(
//                           const SnackBar(
//                             content: Text('Incorrect OTP'),
//                           ),
//                         );
//                       }
//                     }
//                   }
//                 },
//                 child: Text(widget.isResetPassword ? 'Verify OTP for Reset' : 'Verify OTP for Sign In'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:sollylabs_flutter/auth/auth_service.dart';
// //
// // class OtpPage extends ConsumerStatefulWidget {
// //   final String email;
// //
// //   const OtpPage({
// //     required this.email,
// //     super.key,
// //   });
// //
// //   @override
// //   OtpPageState createState() => OtpPageState();
// // }
// //
// // class OtpPageState extends ConsumerState<OtpPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _otpController = TextEditingController();
// //
// //   @override
// //   void dispose() {
// //     _otpController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Enter OTP'),
// //       ),
// //       body: Form(
// //         key: _formKey,
// //         child: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               TextFormField(
// //                 controller: _otpController,
// //                 keyboardType: TextInputType.number,
// //                 decoration: const InputDecoration(
// //                   labelText: 'OTP',
// //                   hintText: 'Enter the OTP sent to your email',
// //                 ),
// //                 validator: (value) {
// //                   if (value == null || value.isEmpty) {
// //                     return 'Please enter the OTP';
// //                   }
// //                   return null;
// //                 },
// //               ),
// //               const SizedBox(height: 20),
// //               ElevatedButton(
// //                 onPressed: () async {
// //                   if (_formKey.currentState!.validate()) {
// //                     // Verify OTP
// //                     final authService = ref.read(authServiceProvider);
// //                     final isVerified = await authService.verifyOtp(
// //                       email: widget.email, // Access email using widget.email
// //                       otp: _otpController.text,
// //                     );
// //                     if (isVerified) {
// //                       // Close OtpPage on successful verification
// //                       Navigator.of(context).pop();
// //                     } else {
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         const SnackBar(
// //                           content: Text('Incorrect OTP'),
// //                         ),
// //                       );
// //                     }
// //                   }
// //                 },
// //                 child: const Text('Verify OTP'),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // import 'package:flutter/material.dart';
// // // import 'package:sollylabs_flutter/pages/project_list.dart';
// // // import 'package:supabase_flutter/supabase_flutter.dart';
// // //
// // // class OtpPage extends StatefulWidget {
// // //   final String email;
// // //
// // //   const OtpPage({super.key, required this.email});
// // //
// // //   @override
// // //   State<OtpPage> createState() => _OtpPageState();
// // // }
// // //
// // // class _OtpPageState extends State<OtpPage> {
// // //   final TextEditingController _otpController = TextEditingController();
// // //   bool _isLoading = false;
// // //
// // //   Future<void> _verifyOtp() async {
// // //     final otp = _otpController.text.trim();
// // //     if (otp.isEmpty) {
// // //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
// // //       return;
// // //     }
// // //
// // //     setState(() => _isLoading = true);
// // //
// // //     try {
// // //       final response = await Supabase.instance.client.auth.verifyOTP(
// // //         token: otp,
// // //         type: OtpType.magiclink, // OTP type associated with magic links
// // //         email: widget.email,
// // //       );
// // //
// // //       if (response.session != null && mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login successful!')));
// // //         Navigator.push(context, MaterialPageRoute(builder: (context) => const ProjectListPage()));
// // //       } else {
// // //         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
// // //       }
// // //     } catch (e) {
// // //       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
// // //     } finally {
// // //       setState(() {
// // //         _isLoading = false;
// // //       });
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: const Text('Enter OTP')),
// // //       body: Padding(
// // //         padding: const EdgeInsets.all(16.0),
// // //         child: Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: [
// // //             Text('Enter the OTP sent to ${widget.email}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
// // //             const SizedBox(height: 16),
// // //             TextField(controller: _otpController, decoration: const InputDecoration(labelText: 'OTP'), keyboardType: TextInputType.number),
// // //             const SizedBox(height: 24),
// // //             _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _verifyOtp, child: const Text('Verify OTP')),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
