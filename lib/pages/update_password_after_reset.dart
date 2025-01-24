import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollylabs_flutter/auth/auth_service.dart';
import 'package:sollylabs_flutter/auth/auth_state.dart';

class UpdatePasswordAfterResetPage extends ConsumerStatefulWidget {
  const UpdatePasswordAfterResetPage({Key? key}) : super(key: key);

  @override
  _UpdatePasswordAfterResetPageState createState() => _UpdatePasswordAfterResetPageState();
}

class _UpdatePasswordAfterResetPageState extends ConsumerState<UpdatePasswordAfterResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool _showNewPassword = false;
  bool _showConfirmNewPassword = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set New Password'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

                    // Update password (no current password verification)
                    final authService = ref.read(authServiceProvider);
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

                      // Navigate to the app's home page or login page
                      ref.refresh(authStateProvider);
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
                child: const Text('Set New Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
