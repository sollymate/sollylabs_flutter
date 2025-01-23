import 'package:supabase_flutter/supabase_flutter.dart';

// Fetch collaborators (already implemented)
Future<List<dynamic>> fetchCollaborators(String projectId) async {
  final response = await Supabase.instance.client.from('project_permissions').select('user_id, role, profiles(username, full_name)').eq('project_id', projectId);

  if (response.isEmpty) {
    return [];
  }

  return response as List<dynamic>;
}

// Edit a collaborator's role
Future<void> editRole(String projectId, String userId, String newRole) async {
  final response = await Supabase.instance.client.from('project_permissions').update({'role': newRole}).match({'project_id': projectId, 'user_id': userId});

  if (response.error != null) {
    throw Exception('Error updating role: ${response.error!.message}');
  }
}

// Delete a collaborator
Future<void> deleteCollaborator(String projectId, String userId) async {
  final response = await Supabase.instance.client.from('project_permissions').delete().match({'project_id': projectId, 'user_id': userId});

  if (response.error != null) {
    throw Exception('Error deleting collaborator: ${response.error!.message}');
  }
}
