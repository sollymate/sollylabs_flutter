import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollylabs_flutter/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final projectListProvider = FutureProvider<PostgrestList>((ref) async {
  PostgrestList response = await supabase.from('project_list').select().order('created_at', ascending: false);
  return response;
});

class ProjectListPage extends ConsumerWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectListAsync = ref.watch(projectListProvider);

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
              );
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
