import 'package:flutter/foundation.dart';
import 'package:sollylabs_flutter/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> inviteUserToProject(String projectId, String email, String role) async {
  try {
    // Invite the user via Supabase Admin API
    // final UserResponse res = await Supabase.instance.client.auth.admin.inviteUserByEmail(email);
    final UserResponse res = await supabase.auth.admin.inviteUserByEmail(
      email,
      redirectTo: kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
    );

    // Retrieve the user ID from the response
    final User? user = res.user;
    if (user == null) {
      throw Exception('User invitation failed: No user returned from Supabase.');
    }

    // Insert the user into the project_permissions table
    final response = await Supabase.instance.client.from('project_permissions').insert({
      'project_id': projectId,
      'user_id': user.id,
      'role': role,
    }).select(); // Ensure a response is returned

    if (response.isEmpty) {
      throw Exception('Failed to assign role to user: No response from Supabase.');
    }

    // print('User invited successfully and added to project_permissions: $response');
  } catch (e) {
    throw Exception('Error inviting user: ${e.toString()}');
  }
}
