import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollylabs_flutter/auth/auth_service.dart';

import 'otp_page.dart';
import 'reset_password.dart';

class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({super.key});

  @override
  SignInFormState createState() => SignInFormState();
}

class SignInFormState extends ConsumerState<SignInForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late TabController _tabController;
  bool _showPassword = false; // New state variable for password visibility

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
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
                if (_tabController.index == 1) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextFormField(
                      key: const Key('passwordField'),
                      controller: _passwordController,
                      obscureText: !_showPassword, // Toggle obscureText
                      decoration: InputDecoration(labelText: 'Password', suffixIcon: IconButton(icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _showPassword = !_showPassword))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
                if (_tabController.index == 1) // Show only on the password tab
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetPasswordPage()));
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
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Sign in with OTP'),
              Tab(text: 'Sign in with Password'),
            ],
            onTap: (index) {
              setState(() {});
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            key: const Key('signInButton'),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final authService = ref.read(authServiceProvider);
                final messenger = ScaffoldMessenger.of(context);
                bool isSuccess = false;

                if (_tabController.index == 1) {
                  // Handle password sign-in
                  isSuccess = await authService.signInWithPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  if (!isSuccess) {
                    messenger.showSnackBar(const SnackBar(
                      content: Text("Incorrect email or password"),
                    ));
                  }
                } else {
                  // Handle existing OTP sign-in
                  isSuccess = await authService.signInWithOtp(
                    email: _emailController.text,
                  );
                  if (!isSuccess) {
                    messenger.showSnackBar(const SnackBar(
                      content: Text("Failed to send verification code"),
                    ));
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpPage(email: _emailController.text),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sollylabs_flutter/auth/auth_service.dart';
//
// import 'otp_page.dart';
//
// class SignInForm extends ConsumerStatefulWidget {
//   const SignInForm({super.key});
//
//   @override
//   SignInFormState createState() => SignInFormState();
// }
//
// class SignInFormState extends ConsumerState<SignInForm> with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 TabBar(
//                   controller: _tabController,
//                   tabs: const [
//                     Tab(text: 'Sign in with OTP'),
//                     Tab(text: 'Sign in with Password'),
//                   ],
//                   onTap: (index) {
//                     setState(() {});
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   key: const Key('emailField'),
//                   controller: _emailController,
//                   decoration: const InputDecoration(labelText: 'Email'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     return null;
//                   },
//                 ),
//                 if (_tabController.index == 1) ...[
//                   Padding(
//                     padding: const EdgeInsets.only(top: 16.0),
//                     child: TextFormField(
//                       key: const Key('passwordField'),
//                       controller: _passwordController,
//                       decoration: const InputDecoration(labelText: 'Password'),
//                       obscureText: true,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your password';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             key: const Key('signInButton'),
//             onPressed: () async {
//               if (_formKey.currentState!.validate()) {
//                 final authService = ref.read(authServiceProvider);
//                 final messenger = ScaffoldMessenger.of(context);
//                 bool isSuccess = false;
//
//                 if (_tabController.index == 1) {
//                   // Handle password sign-in
//                   isSuccess = await authService.signInWithPassword(
//                     email: _emailController.text,
//                     password: _passwordController.text,
//                   );
//                   if (!isSuccess) {
//                     messenger.showSnackBar(const SnackBar(
//                       content: Text("Incorrect email or password"),
//                     ));
//                   }
//                 } else {
//                   // Handle existing OTP sign-in
//                   isSuccess = await authService.signInWithOtp(
//                     email: _emailController.text,
//                   );
//                   if (!isSuccess) {
//                     messenger.showSnackBar(const SnackBar(
//                       content: Text("Failed to send verification code"),
//                     ));
//                   } else {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => OtpPage(email: _emailController.text),
//                       ),
//                     );
//                   }
//                 }
//               }
//             },
//             child: const Text('Sign In'),
//           ),
//         ],
//       ),
//     );
//   }
// }
