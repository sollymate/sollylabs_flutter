import 'package:flutter/material.dart';
import 'package:sollylabs_flutter/utils/invite_user_to_project.dart';

class InviteUserDialog extends StatefulWidget {
  final String projectId;

  const InviteUserDialog({super.key, required this.projectId});

  @override
  State<InviteUserDialog> createState() => _InviteUserDialogState();
}

class _InviteUserDialogState extends State<InviteUserDialog> {
  final _emailController = TextEditingController();
  String _selectedRole = 'viewer';
  final _roles = ['owner', 'admin', 'editor', 'viewer'];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invite User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'User Email'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            items: _roles.map((role) {
              return DropdownMenuItem(value: role, child: Text(role));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedRole = value;
                });
              }
            },
            decoration: const InputDecoration(labelText: 'Role'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _inviteUser,
          child: _isLoading ? const CircularProgressIndicator() : const Text('Send Invite'),
        ),
      ],
    );
  }

  Future<void> _inviteUser() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Call the backend function to send the invite
      await inviteUserToProject(widget.projectId, email, _selectedRole);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitation sent successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending invite: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
