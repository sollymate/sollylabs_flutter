import 'package:flutter/material.dart';

class EditRoleDialog extends StatelessWidget {
  final String currentRole;
  final Function(String) onRoleSelected;

  const EditRoleDialog({Key? key, required this.currentRole, required this.onRoleSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roles = ['owner', 'admin', 'editor', 'viewer'];

    return AlertDialog(
      title: const Text('Edit Role'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: roles.map((role) {
          return RadioListTile<String>(
            title: Text(role),
            value: role,
            groupValue: currentRole,
            onChanged: (value) {
              if (value != null) {
                onRoleSelected(value);
                Navigator.of(context).pop();
              }
            },
          );
        }).toList(),
      ),
    );
  }
}
