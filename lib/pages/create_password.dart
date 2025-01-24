import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollylabs_flutter/auth/auth_service.dart';
import 'package:sollylabs_flutter/auth/auth_state.dart'; // Import authStateProvider

class CreatePasswordPage extends ConsumerStatefulWidget {
  const CreatePasswordPage({Key? key}) : super(key: key);

  @override
  _CreatePasswordPageState createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends ConsumerState<CreatePasswordPage> {
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
              // ... (TextFormFields for password and confirm password - no changes)
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

                      // Refresh the auth state and navigate
                      ref.refresh(authStateProvider);
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
