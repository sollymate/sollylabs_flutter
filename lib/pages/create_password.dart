import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollylabs_flutter/auth/auth_service.dart';
import 'package:sollylabs_flutter/auth/auth_state.dart';

class CreatePasswordPage extends ConsumerStatefulWidget {
  const CreatePasswordPage({super.key});

  @override
  CreatePasswordPageState createState() => CreatePasswordPageState();
}

class CreatePasswordPageState extends ConsumerState<CreatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Password'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your new password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your new password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
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

                    // Update password
                    final authService = ref.read(authServiceProvider);
                    final isSuccess = await authService.updateUserPassword(
                      password: _passwordController.text,
                    );

                    if (isSuccess) {
                      // Show success message
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Password updated successfully!'),
                        ),
                      );
                      // Invalidate auth state
                      ref.invalidate(authStateProvider);
                      navigator.pop();
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Failed to update password.'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Create Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
