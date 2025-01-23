import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> handleInviteLink(Uri inviteLink) async {
  final projectId = inviteLink.queryParameters['projectId'];
  final role = inviteLink.queryParameters['role'];

  if (projectId == null || role == null) {
    throw Exception('Invalid invite link.');
  }

  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    throw Exception('User not logged in.');
  }

  // Assign the user to the project
  final response = await Supabase.instance.client.from('project_permissions').insert({
    'project_id': projectId,
    'user_id': user.id,
    'role': role,
  }).select();

  if (response.isEmpty) {
    throw Exception('Failed to assign user to project.');
  }

  print('User successfully assigned to project: $response');
}
