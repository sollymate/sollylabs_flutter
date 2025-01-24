import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollylabs_flutter/auth/auth_service.dart';

import 'reset_password.dart';

class UpdatePasswordPage extends ConsumerStatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  UpdatePasswordPageState createState() => UpdatePasswordPageState();
}

class UpdatePasswordPageState extends ConsumerState<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController(); // Add field for current password
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmNewPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Password'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Forgot Password Link
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResetPasswordPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              // Current Password Field
              TextFormField(
                controller: _currentPasswordController,
                obscureText: !_showCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  hintText: 'Enter your current password',
                  suffixIcon: IconButton(
                    icon: Icon(_showCurrentPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showCurrentPassword = !_showCurrentPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // New Password Field
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter your new password',
                  suffixIcon: IconButton(
                    icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showNewPassword = !_showNewPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  // Add password strength validation if needed
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Confirm New Password Field
              TextFormField(
                controller: _confirmNewPasswordController,
                obscureText: !_showConfirmNewPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  hintText: 'Re-enter your new password',
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmNewPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showConfirmNewPassword = !_showConfirmNewPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    // Verify current password first
                    final authService = ref.read(authServiceProvider);
                    final isCurrentPasswordCorrect = await authService.verifyCurrentPassword(
                      password: _currentPasswordController.text,
                    );

                    if (!isCurrentPasswordCorrect) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Incorrect current password'),
                        ),
                      );
                      return; // Stop execution if current password is wrong
                    }

                    // Update password after current password verification
                    final isSuccess = await authService.updateUserPasswordAfterOtp(
                      password: _newPasswordController.text,
                    );

                    if (isSuccess) {
                      // Show success message
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Password updated successfully!'),
                        ),
                      );

                      // Close UpdatePasswordPage
                      navigator.popUntil((route) => route.isFirst);
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Failed to update password.'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Update Password'),
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
// import 'reset_password.dart';
//
// class UpdatePasswordPage extends ConsumerStatefulWidget {
//   const UpdatePasswordPage({Key? key}) : super(key: key);
//
//   @override
//   _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
// }
//
// class _UpdatePasswordPageState extends ConsumerState<UpdatePasswordPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _newPasswordController = TextEditingController();
//   final _confirmNewPasswordController = TextEditingController();
//   bool _showNewPassword = false;
//   bool _showConfirmNewPassword = false;
//
//   @override
//   void dispose() {
//     _newPasswordController.dispose();
//     _confirmNewPasswordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Update Password'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Forgot Password Link
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const ResetPasswordPage(),
//                       ),
//                     );
//                   },
//                   child: const Text(
//                     'Forgot Password?',
//                     style: TextStyle(
//                       color: Colors.blue,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ),
//               ),
//               TextFormField(
//                 controller: _newPasswordController,
//                 obscureText: !_showNewPassword,
//                 decoration: InputDecoration(
//                   labelText: 'New Password',
//                   hintText: 'Enter your new password',
//                   suffixIcon: IconButton(
//                     icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
//                     onPressed: () {
//                       setState(() {
//                         _showNewPassword = !_showNewPassword;
//                       });
//                     },
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a new password';
//                   }
//                   // Add password strength validation if needed
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _confirmNewPasswordController,
//                 obscureText: !_showConfirmNewPassword,
//                 decoration: InputDecoration(
//                   labelText: 'Confirm New Password',
//                   hintText: 'Re-enter your new password',
//                   suffixIcon: IconButton(
//                     icon: Icon(_showConfirmNewPassword ? Icons.visibility : Icons.visibility_off),
//                     onPressed: () {
//                       setState(() {
//                         _showConfirmNewPassword = !_showConfirmNewPassword;
//                       });
//                     },
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please confirm your new password';
//                   }
//                   if (value != _newPasswordController.text) {
//                     return 'Passwords do not match';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final messenger = ScaffoldMessenger.of(context);
//                     final navigator = Navigator.of(context);
//
//                     // Update password after OTP verification
//                     final authService = ref.read(authServiceProvider);
//                     final isSuccess = await authService.updateUserPasswordAfterOtp(
//                       password: _newPasswordController.text,
//                     );
//
//                     if (isSuccess) {
//                       // Show success message
//                       messenger.showSnackBar(
//                         const SnackBar(
//                           content: Text('Password updated successfully!'),
//                         ),
//                       );
//
//                       // Close UpdatePasswordPage
//                       navigator.popUntil((route) => route.isFirst);
//                     } else {
//                       messenger.showSnackBar(
//                         const SnackBar(
//                           content: Text('Failed to update password.'),
//                         ),
//                       );
//                     }
//                   }
//                 },
//                 child: const Text('Update Password'),
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
// // class UpdatePasswordPage extends ConsumerStatefulWidget {
// //   const UpdatePasswordPage({Key? key}) : super(key: key);
// //
// //   @override
// //   _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
// // }
// //
// // class _UpdatePasswordPageState extends ConsumerState<UpdatePasswordPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _newPasswordController = TextEditingController();
// //   final _confirmNewPasswordController = TextEditingController();
// //
// //   @override
// //   void dispose() {
// //     _newPasswordController.dispose();
// //     _confirmNewPasswordController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Update Password'),
// //       ),
// //       body: Form(
// //         key: _formKey,
// //         child: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               TextFormField(
// //                 controller: _newPasswordController,
// //                 obscureText: true,
// //                 decoration: const InputDecoration(
// //                   labelText: 'New Password',
// //                   hintText: 'Enter your new password',
// //                 ),
// //                 validator: (value) {
// //                   if (value == null || value.isEmpty) {
// //                     return 'Please enter a new password';
// //                   }
// //                   // Add password strength validation if needed
// //                   return null;
// //                 },
// //               ),
// //               const SizedBox(height: 20),
// //               TextFormField(
// //                 controller: _confirmNewPasswordController,
// //                 obscureText: true,
// //                 decoration: const InputDecoration(
// //                   labelText: 'Confirm New Password',
// //                   hintText: 'Re-enter your new password',
// //                 ),
// //                 validator: (value) {
// //                   if (value == null || value.isEmpty) {
// //                     return 'Please confirm your new password';
// //                   }
// //                   if (value != _newPasswordController.text) {
// //                     return 'Passwords do not match';
// //                   }
// //                   return null;
// //                 },
// //               ),
// //               const SizedBox(height: 20),
// //               ElevatedButton(
// //                 onPressed: () async {
// //                   if (_formKey.currentState!.validate()) {
// //                     final messenger = ScaffoldMessenger.of(context);
// //                     final navigator = Navigator.of(context);
// //
// //                     // Update password after OTP verification
// //                     final authService = ref.read(authServiceProvider);
// //                     final isSuccess = await authService.updateUserPasswordAfterOtp(
// //                       password: _newPasswordController.text,
// //                     );
// //
// //                     if (isSuccess) {
// //                       // Show success message
// //                       messenger.showSnackBar(
// //                         const SnackBar(
// //                           content: Text('Password updated successfully!'),
// //                         ),
// //                       );
// //
// //                       // Close UpdatePasswordPage
// //                       navigator.popUntil((route) => route.isFirst);
// //                     } else {
// //                       messenger.showSnackBar(
// //                         const SnackBar(
// //                           content: Text('Failed to update password.'),
// //                         ),
// //                       );
// //                     }
// //                   }
// //                 },
// //                 child: const Text('Update Password'),
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
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:sollylabs_flutter/auth/auth_service.dart';
// // //
// // // class UpdatePasswordPage extends ConsumerStatefulWidget {
// // //   const UpdatePasswordPage({Key? key}) : super(key: key);
// // //
// // //   @override
// // //   _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
// // // }
// // //
// // // class _UpdatePasswordPageState extends ConsumerState<UpdatePasswordPage> {
// // //   final _formKey = GlobalKey<FormState>();
// // //   final _currentPasswordController = TextEditingController();
// // //   final _newPasswordController = TextEditingController();
// // //   final _confirmNewPasswordController = TextEditingController();
// // //   bool _showCurrentPassword = false;
// // //   bool _showNewPassword = false;
// // //   bool _showConfirmNewPassword = false;
// // //
// // //   @override
// // //   void dispose() {
// // //     _currentPasswordController.dispose();
// // //     _newPasswordController.dispose();
// // //     _confirmNewPasswordController.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('Update Password'),
// // //       ),
// // //       body: Form(
// // //         key: _formKey,
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(16.0),
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               TextFormField(
// // //                 controller: _currentPasswordController,
// // //                 obscureText: !_showCurrentPassword,
// // //                 decoration: InputDecoration(
// // //                   labelText: 'Current Password',
// // //                   hintText: 'Enter your current password',
// // //                   suffixIcon: IconButton(
// // //                     icon: Icon(_showCurrentPassword ? Icons.visibility : Icons.visibility_off),
// // //                     onPressed: () {
// // //                       setState(() {
// // //                         _showCurrentPassword = !_showCurrentPassword;
// // //                       });
// // //                     },
// // //                   ),
// // //                 ),
// // //                 validator: (value) {
// // //                   if (value == null || value.isEmpty) {
// // //                     return 'Please enter your current password';
// // //                   }
// // //                   return null;
// // //                 },
// // //               ),
// // //               const SizedBox(height: 20),
// // //               TextFormField(
// // //                 controller: _newPasswordController,
// // //                 obscureText: !_showNewPassword,
// // //                 decoration: InputDecoration(
// // //                   labelText: 'New Password',
// // //                   hintText: 'Enter your new password',
// // //                   suffixIcon: IconButton(
// // //                     icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
// // //                     onPressed: () {
// // //                       setState(() {
// // //                         _showNewPassword = !_showNewPassword;
// // //                       });
// // //                     },
// // //                   ),
// // //                 ),
// // //                 validator: (value) {
// // //                   if (value == null || value.isEmpty) {
// // //                     return 'Please enter a new password';
// // //                   }
// // //                   // Add password strength validation if needed
// // //                   return null;
// // //                 },
// // //               ),
// // //               const SizedBox(height: 20),
// // //               TextFormField(
// // //                 controller: _confirmNewPasswordController,
// // //                 obscureText: !_showConfirmNewPassword,
// // //                 decoration: InputDecoration(
// // //                   labelText: 'Confirm New Password',
// // //                   hintText: 'Re-enter your new password',
// // //                   suffixIcon: IconButton(
// // //                     icon: Icon(_showConfirmNewPassword ? Icons.visibility : Icons.visibility_off),
// // //                     onPressed: () {
// // //                       setState(() {
// // //                         _showConfirmNewPassword = !_showConfirmNewPassword;
// // //                       });
// // //                     },
// // //                   ),
// // //                 ),
// // //                 validator: (value) {
// // //                   if (value == null || value.isEmpty) {
// // //                     return 'Please confirm your new password';
// // //                   }
// // //                   if (value != _newPasswordController.text) {
// // //                     return 'Passwords do not match';
// // //                   }
// // //                   return null;
// // //                 },
// // //               ),
// // //               const SizedBox(height: 20),
// // //               ElevatedButton(
// // //                 onPressed: () async {
// // //                   if (_formKey.currentState!.validate()) {
// // //                     final messenger = ScaffoldMessenger.of(context);
// // //                     final navigator = Navigator.of(context);
// // //
// // //                     // Verify current password first
// // //                     final authService = ref.read(authServiceProvider);
// // //                     final isCurrentPasswordCorrect = await authService.verifyCurrentPassword(
// // //                       password: _currentPasswordController.text,
// // //                     );
// // //
// // //                     if (!isCurrentPasswordCorrect) {
// // //                       messenger.showSnackBar(
// // //                         const SnackBar(
// // //                           content: Text('Incorrect current password'),
// // //                         ),
// // //                       );
// // //                       return; // Stop execution if current password is wrong
// // //                     }
// // //
// // //                     // Update password
// // //                     final isSuccess = await authService.updateUserPassword(
// // //                       password: _newPasswordController.text,
// // //                     );
// // //
// // //                     if (isSuccess) {
// // //                       // Show success message
// // //                       messenger.showSnackBar(
// // //                         const SnackBar(
// // //                           content: Text('Password updated successfully!'),
// // //                         ),
// // //                       );
// // //
// // //                       // Navigate back or to another page
// // //                       navigator.pop(); // Close UpdatePasswordPage
// // //                     } else {
// // //                       messenger.showSnackBar(
// // //                         const SnackBar(
// // //                           content: Text('Failed to update password.'),
// // //                         ),
// // //                       );
// // //                     }
// // //                   }
// // //                 },
// // //                 child: const Text('Update Password'),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:sollylabs_flutter/auth/auth_service.dart';
// // // //
// // // // class UpdatePasswordPage extends ConsumerStatefulWidget {
// // // //   const UpdatePasswordPage({Key? key}) : super(key: key);
// // // //
// // // //   @override
// // // //   _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
// // // // }
// // // //
// // // // class _UpdatePasswordPageState extends ConsumerState<UpdatePasswordPage> {
// // // //   final _formKey = GlobalKey<FormState>();
// // // //   final _currentPasswordController = TextEditingController();
// // // //   final _newPasswordController = TextEditingController();
// // // //   final _confirmNewPasswordController = TextEditingController();
// // // //
// // // //   @override
// // // //   void dispose() {
// // // //     _currentPasswordController.dispose();
// // // //     _newPasswordController.dispose();
// // // //     _confirmNewPasswordController.dispose();
// // // //     super.dispose();
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: const Text('Update Password'),
// // // //       ),
// // // //       body: Form(
// // // //         key: _formKey,
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(16.0),
// // // //           child: Column(
// // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // //             children: [
// // // //               TextFormField(
// // // //                 controller: _currentPasswordController,
// // // //                 obscureText: true,
// // // //                 decoration: const InputDecoration(
// // // //                   labelText: 'Current Password',
// // // //                   hintText: 'Enter your current password',
// // // //                 ),
// // // //                 validator: (value) {
// // // //                   if (value == null || value.isEmpty) {
// // // //                     return 'Please enter your current password';
// // // //                   }
// // // //                   return null;
// // // //                 },
// // // //               ),
// // // //               const SizedBox(height: 20),
// // // //               TextFormField(
// // // //                 controller: _newPasswordController,
// // // //                 obscureText: true,
// // // //                 decoration: const InputDecoration(
// // // //                   labelText: 'New Password',
// // // //                   hintText: 'Enter your new password',
// // // //                 ),
// // // //                 validator: (value) {
// // // //                   if (value == null || value.isEmpty) {
// // // //                     return 'Please enter a new password';
// // // //                   }
// // // //                   // Add password strength validation if needed
// // // //                   return null;
// // // //                 },
// // // //               ),
// // // //               const SizedBox(height: 20),
// // // //               TextFormField(
// // // //                 controller: _confirmNewPasswordController,
// // // //                 obscureText: true,
// // // //                 decoration: const InputDecoration(
// // // //                   labelText: 'Confirm New Password',
// // // //                   hintText: 'Re-enter your new password',
// // // //                 ),
// // // //                 validator: (value) {
// // // //                   if (value == null || value.isEmpty) {
// // // //                     return 'Please confirm your new password';
// // // //                   }
// // // //                   if (value != _newPasswordController.text) {
// // // //                     return 'Passwords do not match';
// // // //                   }
// // // //                   return null;
// // // //                 },
// // // //               ),
// // // //               const SizedBox(height: 20),
// // // //               ElevatedButton(
// // // //                 onPressed: () async {
// // // //                   if (_formKey.currentState!.validate()) {
// // // //                     final messenger = ScaffoldMessenger.of(context);
// // // //                     final navigator = Navigator.of(context);
// // // //
// // // //                     // Verify current password first
// // // //                     final authService = ref.read(authServiceProvider);
// // // //                     final isCurrentPasswordCorrect = await authService.verifyCurrentPassword(
// // // //                       password: _currentPasswordController.text,
// // // //                     );
// // // //
// // // //                     if (!isCurrentPasswordCorrect) {
// // // //                       messenger.showSnackBar(
// // // //                         const SnackBar(
// // // //                           content: Text('Incorrect current password'),
// // // //                         ),
// // // //                       );
// // // //                       return; // Stop execution if current password is wrong
// // // //                     }
// // // //
// // // //                     // Update password
// // // //                     final isSuccess = await authService.updateUserPassword(
// // // //                       password: _newPasswordController.text,
// // // //                     );
// // // //
// // // //                     if (isSuccess) {
// // // //                       // Show success message
// // // //                       messenger.showSnackBar(
// // // //                         const SnackBar(
// // // //                           content: Text('Password updated successfully!'),
// // // //                         ),
// // // //                       );
// // // //
// // // //                       // Navigate back or to another page
// // // //                       navigator.pop(); // Close UpdatePasswordPage
// // // //                     } else {
// // // //                       messenger.showSnackBar(
// // // //                         const SnackBar(
// // // //                           content: Text('Failed to update password.'),
// // // //                         ),
// // // //                       );
// // // //                     }
// // // //                   }
// // // //                 },
// // // //                 child: const Text('Update Password'),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // // import 'package:sollylabs_flutter/auth/auth_service.dart';
// // // // //
// // // // // class UpdatePasswordPage extends ConsumerStatefulWidget {
// // // // //   const UpdatePasswordPage({Key? key}) : super(key: key);
// // // // //
// // // // //   @override
// // // // //   _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
// // // // // }
// // // // //
// // // // // class _UpdatePasswordPageState extends ConsumerState<UpdatePasswordPage> {
// // // // //   final _formKey = GlobalKey<FormState>();
// // // // //   final _passwordController = TextEditingController();
// // // // //   final _confirmPasswordController = TextEditingController();
// // // // //
// // // // //   @override
// // // // //   void dispose() {
// // // // //     _passwordController.dispose();
// // // // //     _confirmPasswordController.dispose();
// // // // //     super.dispose();
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       appBar: AppBar(
// // // // //         title: const Text('Update Password'),
// // // // //       ),
// // // // //       body: Form(
// // // // //         key: _formKey,
// // // // //         child: Padding(
// // // // //           padding: const EdgeInsets.all(16.0),
// // // // //           child: Column(
// // // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // // //             children: [
// // // // //               TextFormField(
// // // // //                 controller: _passwordController,
// // // // //                 obscureText: true,
// // // // //                 decoration: const InputDecoration(
// // // // //                   labelText: 'New Password',
// // // // //                   hintText: 'Enter your new password',
// // // // //                 ),
// // // // //                 validator: (value) {
// // // // //                   if (value == null || value.isEmpty) {
// // // // //                     return 'Please enter a new password';
// // // // //                   }
// // // // //                   // Add password strength validation if needed
// // // // //                   return null;
// // // // //                 },
// // // // //               ),
// // // // //               const SizedBox(height: 20),
// // // // //               TextFormField(
// // // // //                 controller: _confirmPasswordController,
// // // // //                 obscureText: true,
// // // // //                 decoration: const InputDecoration(
// // // // //                   labelText: 'Confirm New Password',
// // // // //                   hintText: 'Re-enter your new password',
// // // // //                 ),
// // // // //                 validator: (value) {
// // // // //                   if (value == null || value.isEmpty) {
// // // // //                     return 'Please confirm your new password';
// // // // //                   }
// // // // //                   if (value != _passwordController.text) {
// // // // //                     return 'Passwords do not match';
// // // // //                   }
// // // // //                   return null;
// // // // //                 },
// // // // //               ),
// // // // //               const SizedBox(height: 20),
// // // // //               ElevatedButton(
// // // // //                 onPressed: () async {
// // // // //                   if (_formKey.currentState!.validate()) {
// // // // //                     final messenger = ScaffoldMessenger.of(context);
// // // // //                     final navigator = Navigator.of(context);
// // // // //
// // // // //                     // Update password
// // // // //                     final authService = ref.read(authServiceProvider);
// // // // //                     final isSuccess = await authService.updateUserPassword(
// // // // //                       password: _passwordController.text,
// // // // //                     );
// // // // //
// // // // //                     if (isSuccess) {
// // // // //                       // Show success message
// // // // //                       messenger.showSnackBar(
// // // // //                         const SnackBar(
// // // // //                           content: Text('Password updated successfully!'),
// // // // //                         ),
// // // // //                       );
// // // // //
// // // // //                       // Navigate back or to another page
// // // // //                       navigator.pop(); // Close UpdatePasswordPage
// // // // //                     } else {
// // // // //                       messenger.showSnackBar(
// // // // //                         const SnackBar(
// // // // //                           content: Text('Failed to update password.'),
// // // // //                         ),
// // // // //                       );
// // // // //                     }
// // // // //                   }
// // // // //                 },
// // // // //                 child: const Text('Update Password'),
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
