import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollylabs_flutter/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'project_settings.dart';

Stream<List<Map<String, dynamic>>> getProjectListStream() {
  return supabase.from('project_list').stream(primaryKey: ['id']).order('created_at', ascending: false);
}

final projectListStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) => getProjectListStream());

final projectListProvider = FutureProvider<PostgrestList>((ref) async {
  PostgrestList response = await supabase.from('project_list').select().order('created_at', ascending: false);
  return response;
});

class ProjectListPage extends ConsumerWidget {
  const ProjectListPage({super.key});

  void _showEditProjectDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> project) {
    final projectNameController = TextEditingController(text: project['project_name']);
    final projectInfoController = TextEditingController(text: project['project_info']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: projectNameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
              ),
              TextField(
                controller: projectInfoController,
                decoration: const InputDecoration(labelText: 'Project Info'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateProject(
                  context,
                  ref,
                  project['id'],
                  projectNameController.text.trim(),
                  projectInfoController.text.trim(),
                );
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProject(BuildContext context, WidgetRef ref, String projectId) async {
    try {
      // Perform the delete operation
      final response = await Supabase.instance.client.from('project_list').delete().eq('id', projectId);

      // Supabase delete operations can return null on success; treat it as valid
      if (response == null) {
        // Invalidate the provider to refresh the UI
        ref.invalidate(projectListStreamProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project deleted successfully')),
          );
        }
        return;
      }

      // Handle unexpected non-null responses
      if (response is Map && response.containsKey('error')) {
        throw Exception(response['error']['message']);
      }

      // Safely show success for non-error responses
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project deleted successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting project: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, String projectId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: const Text('Are you sure you want to delete this project? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await _deleteProject(context, ref, projectId);
                if (context.mounted) Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProject(BuildContext context, WidgetRef ref, String projectId, String name, String info) async {
    try {
      final response = await Supabase.instance.client.from('project_list').update({
        'project_name': name,
        'project_info': info,
        'updated_by': Supabase.instance.client.auth.currentUser?.id,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', projectId);

      // Check for errors
      if (response is Map && response.containsKey('error')) {
        throw Exception(response['error']['message']);
      }

      // Invalidate the StreamProvider to refresh the UI
      ref.invalidate(projectListStreamProvider);

      // Safely use context after async
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project updated successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating project: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectListAsync = ref.watch(projectListStreamProvider);
    // final projectListAsync = ref.watch(projectListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Projects'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => _showCreateProjectDialog(context))]),
      body: projectListAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return const Center(child: Text('No projects found.'));
          }
          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return ListTile(
                title: Text(project['project_name']),
                subtitle: Text(project['project_info'] ?? 'No additional info'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProjectSettingsPage(projectId: project['id']),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );

              // return ListTile(
              //   title: Text(project['project_name']),
              //   subtitle: Text(project['project_info'] ?? 'No additional info'),
              //   trailing: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       IconButton(
              //         icon: const Icon(Icons.edit),
              //         onPressed: () => _showEditProjectDialog(context, ref, project),
              //       ),
              //       IconButton(
              //         icon: const Icon(Icons.delete),
              //         color: Colors.red,
              //         onPressed: () => _showDeleteConfirmationDialog(context, ref, project['id']),
              //       ),
              //     ],
              //   ),
              // );

              // return ListTile(
              //   title: Text(project['project_name']),
              //   subtitle: Text(project['project_info'] ?? 'No additional info'),
              //   trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditProjectDialog(context, ref, project)),
              // );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final TextEditingController projectNameController = TextEditingController();
    final TextEditingController projectInfoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: projectNameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                ),
              ),
              TextField(
                controller: projectInfoController,
                decoration: const InputDecoration(
                  labelText: 'Project Info',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final projectName = projectNameController.text.trim();
                final projectInfo = projectInfoController.text.trim();

                if (projectName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Project name is required')),
                  );
                  return;
                }

                await _createProject(projectName, projectInfo);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createProject(String name, String info) async {
    await supabase.from('project_list').insert({
      'project_name': name,
      'project_info': info,
      'created_by': supabase.auth.currentUser?.id,
    });

    // if (response.e) {
    //   throw Exception(response.message);
    // }
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sollylabs_flutter/main.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// // Riverpod provider for project list
// final projectListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
//   PostgrestList response = await supabase.from('project_list').select('*').order('created_at', ascending: false);
//
//   if (response.isNotEmpty) {
//     return List<Map<String, dynamic>>.from(response);
//   } else {
//     return [];
//   }
// });
//
// class ProjectListPage extends ConsumerWidget {
//   const ProjectListPage({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final projectListAsync = ref.watch(projectListProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Projects'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               // Navigate to the Add Project Page
//             },
//           ),
//         ],
//       ),
//       body: projectListAsync.when(
//         data: (projects) {
//           if (projects.isEmpty) {
//             return const Center(
//               child: Text('No projects found.'),
//             );
//           }
//           return ListView.builder(
//             itemCount: projects.length,
//             itemBuilder: (context, index) {
//               final project = projects[index];
//               return ListTile(
//                 title: Text(project['project_name']),
//                 subtitle: Text(project['project_info'] ?? 'No additional info'),
//                 onTap: () {
//                   // Navigate to the Edit Project Page
//                 },
//               );
//             },
//           );
//         },
//         loading: () => const Center(
//           child: CircularProgressIndicator(),
//         ),
//         error: (error, stackTrace) => Center(
//           child: Text('Error: ${error.toString()}'),
//         ),
//       ),
//     );
//   }
// }
