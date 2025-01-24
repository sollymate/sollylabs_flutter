import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollylabs_flutter/pages/sign_in_form.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SignInForm(),
      ),
    );
  }
}

// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Login'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             // Show the sign-in dialog
//             showDialog(context: context, barrierDismissible: false, builder: (context) => const SignInDialog());
//           },
//           child: const Text('Sign In'),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:sollylabs_flutter/main.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// import 'account_page.dart';
// import 'otp_page.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final bool _isLoading = false;
//   bool _redirecting = false;
//   late final TextEditingController _emailController = TextEditingController();
//   late final StreamSubscription<AuthState> _authStateSubscription;
//
//   Future<void> _sendMagicLink(String email) async {
//     try {
//       // await Supabase.instance.client.auth.signInWithOtp(email: email);
//       await supabase.auth.signInWithOtp(
//         email: email,
//         emailRedirectTo: kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
//       );
//       if (mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => OtpPage(email: email)));
//     } catch (e) {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
//     }
//   }
//
//   @override
//   void initState() {
//     _authStateSubscription = supabase.auth.onAuthStateChange.listen(
//       (data) {
//         if (_redirecting) return;
//         final session = data.session;
//         if (session != null) {
//           _redirecting = true;
//           if (mounted) {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(builder: (context) => const AccountPage()),
//             );
//           }
//         }
//       },
//       onError: (error) {
//         if (error is AuthException) {
//           if (mounted) context.showSnackBar(error.message, isError: true);
//         } else {
//           if (mounted) context.showSnackBar('Unexpected error occurred', isError: true);
//         }
//       },
//     );
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _authStateSubscription.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sign In')),
//       body: ListView(
//         padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
//         children: [
//           const Text('Sign in via the magic link with your email below'),
//           const SizedBox(height: 18),
//           TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
//           const SizedBox(height: 18),
//           ElevatedButton(
//             onPressed: _isLoading ? null : () => _sendMagicLink(_emailController.text.trim()),
//             // onPressed: _isLoading ? null : _signIn,
//             child: Text(_isLoading ? 'Sending...' : 'Send Magic Link'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Future<void> _signIn() async {
// //   try {
// //     setState(() => _isLoading = true);
// //     await supabase.auth.signInWithOtp(
// //       email: _emailController.text.trim(),
// //       emailRedirectTo: kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
// //     );
// //     if (mounted) {
// //       context.showSnackBar('Check your email for a login link!');
// //       _emailController.clear();
// //     }
// //   } on AuthException catch (error) {
// //     if (mounted) context.showSnackBar(error.message, isError: true);
// //   } catch (error) {
// //     if (mounted) {
// //       context.showSnackBar('Unexpected error occurred', isError: true);
// //     }
// //   } finally {
// //     if (mounted) {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }
// // }
