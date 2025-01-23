import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Define the FutureProvider for fetching collaborators
final collaboratorsProvider = FutureProvider.family<List<dynamic>, String>((ref, projectId) async {
  final response = await Supabase.instance.client.from('project_permissions').select('user_id, role, profiles(username, full_name)').eq('project_id', projectId);

  if (response.isEmpty) {
    return [];
  }
  return response as List<dynamic>;
});

class ProjectSettingsPage extends ConsumerWidget {
  final String projectId;

  const ProjectSettingsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collaboratorsAsyncValue = ref.watch(collaboratorsProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Settings'),
      ),
      body: collaboratorsAsyncValue.when(
        data: (collaborators) {
          if (collaborators.isEmpty) {
            return const Center(child: Text('No collaborators found.'));
          }
          return ListView.builder(
            itemCount: collaborators.length,
            itemBuilder: (context, index) {
              final collaborator = collaborators[index];
              return ListTile(
                title: Text(collaborator['profiles']['username'] ?? 'Unknown User'),
                subtitle: Text('Role: ${collaborator['role']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (_) => EditRoleDialog(
                            currentRole: collaborator['role'],
                            onRoleSelected: (newRole) async {
                              try {
                                await editRole(projectId, collaborator['user_id'], newRole);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Role updated successfully')),
                                  );
                                }
                                ref.refresh(collaboratorsProvider(projectId)); // Refresh collaborators list
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: ${e.toString()}')),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Remove Collaborator'),
                            content: const Text('Are you sure you want to remove this collaborator?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await deleteCollaborator(projectId, collaborator['user_id']);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Collaborator removed successfully')),
                              );
                            }
                            ref.refresh(collaboratorsProvider(projectId)); // Refresh collaborators list
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.toString()}')),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> editRole(String projectId, String userId, String newRole) async {
    final response = await Supabase.instance.client.from('project_permissions').update({'role': newRole}).eq('project_id', projectId).eq('user_id', userId).select();

    if (response == null || response.isEmpty) {
      throw Exception('No rows were updated. Ensure the project retains an owner.');
    }
  }

  Future<void> deleteCollaborator(String projectId, String userId) async {
    final response = await Supabase.instance.client.from('project_permissions').delete().match({'project_id': projectId, 'user_id': userId}).select();

    if (response == null || response.isEmpty) {
      throw Exception('Failed to delete collaborator. Ensure the project retains an owner.');
    }
  }
}

// Role Editing Dialog
class EditRoleDialog extends StatelessWidget {
  final String currentRole;
  final Function(String) onRoleSelected;

  const EditRoleDialog({super.key, required this.currentRole, required this.onRoleSelected});

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

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// // Define the FutureProvider for fetching collaborators
// final collaboratorsProvider = FutureProvider.family<List<dynamic>, String>((ref, projectId) async {
//   final response = await Supabase.instance.client.from('project_permissions').select('user_id, role, profiles(username, full_name)').eq('project_id', projectId);
//
//   if (response.isEmpty) {
//     return [];
//   }
//   return response as List<dynamic>;
// });
//
// class ProjectSettingsPage extends ConsumerWidget {
//   final String projectId;
//
//   const ProjectSettingsPage({super.key, required this.projectId});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final collaboratorsAsyncValue = ref.watch(collaboratorsProvider(projectId));
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Project Settings'),
//       ),
//       body: collaboratorsAsyncValue.when(
//         data: (collaborators) {
//           if (collaborators.isEmpty) {
//             return const Center(child: Text('No collaborators found.'));
//           }
//           return ListView.builder(
//             itemCount: collaborators.length,
//             itemBuilder: (context, index) {
//               final collaborator = collaborators[index];
//               return ListTile(
//                 title: Text(collaborator['profiles']['username'] ?? 'Unknown User'),
//                 subtitle: Text('Role: ${collaborator['role']}'),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.edit),
//                       onPressed: () async {
//                         showDialog(
//                           context: context,
//                           builder: (_) => EditRoleDialog(
//                             currentRole: collaborator['role'],
//                             onRoleSelected: (newRole) async {
//                               try {
//                                 await editRole(projectId, collaborator['user_id'], newRole);
//                                 if (context.mounted) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(content: Text('Role updated successfully')),
//                                   );
//                                 }
//                                 ref.refresh(collaboratorsProvider(projectId)); // Refresh collaborators list
//                               } catch (e) {
//                                 if (context.mounted) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(content: Text('Error: $e')),
//                                   );
//                                 }
//                               }
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () async {
//                         final confirm = await showDialog<bool>(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             title: const Text('Remove Collaborator'),
//                             content: const Text('Are you sure you want to remove this collaborator?'),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.of(context).pop(false),
//                                 child: const Text('Cancel'),
//                               ),
//                               TextButton(
//                                 onPressed: () => Navigator.of(context).pop(true),
//                                 child: const Text('Remove'),
//                               ),
//                             ],
//                           ),
//                         );
//                         if (confirm == true) {
//                           try {
//                             await deleteCollaborator(projectId, collaborator['user_id']);
//                             if (context.mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('Collaborator removed successfully')),
//                               );
//                             }
//                             ref.refresh(collaboratorsProvider(projectId)); // Refresh collaborators list
//                           } catch (e) {
//                             if (context.mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Error: $e')),
//                               );
//                             }
//                           }
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(child: Text('Error: $err')),
//       ),
//     );
//   }
//
//   Future<void> editRole(String projectId, String userId, String newRole) async {
//     try {
//       print('Updating role: projectId=$projectId, userId=$userId, newRole=$newRole');
//
//       final response = await Supabase.instance.client.from('project_permissions').update({'role': newRole}).match({'project_id': projectId, 'user_id': userId}).select();
//
//       print('Supabase response: $response');
//
//       if (response.isEmpty) {
//         throw Exception('No rows were updated. Please check the project or user ID.');
//       }
//     } catch (e) {
//       throw Exception('Error updating role: ${e.toString()}');
//     }
//   }
//
//   Future<void> deleteCollaborator(String projectId, String userId) async {
//     final response = await Supabase.instance.client.from('project_permissions').delete().match({'project_id': projectId, 'user_id': userId});
//
//     if (response.error != null) {
//       throw Exception('Error deleting collaborator: ${response.error!.message}');
//     }
//   }
// }
//
// // Role Editing Dialog
// class EditRoleDialog extends StatelessWidget {
//   final String currentRole;
//   final Function(String) onRoleSelected;
//
//   const EditRoleDialog({super.key, required this.currentRole, required this.onRoleSelected});
//
//   @override
//   Widget build(BuildContext context) {
//     final roles = ['owner', 'admin', 'editor', 'viewer'];
//
//     return AlertDialog(
//       title: const Text('Edit Role'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: roles.map((role) {
//           return RadioListTile<String>(
//             title: Text(role),
//             value: role,
//             groupValue: currentRole,
//             onChanged: (value) {
//               if (value != null) {
//                 onRoleSelected(value);
//                 Navigator.of(context).pop();
//               }
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:sollylabs_flutter/utils/project_utils.dart';
// // import 'package:sollylabs_flutter/widgets/project_widgets.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// //
// // class ProjectSettingsPage extends ConsumerWidget {
// //   final String projectId;
// //
// //   const ProjectSettingsPage({super.key, required this.projectId});
// //
// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Project Settings')),
// //       body: FutureBuilder<List<dynamic>>(
// //         future: fetchCollaborators(projectId),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return const Center(child: CircularProgressIndicator());
// //           }
// //           if (snapshot.hasError) {
// //             return Center(child: Text('Error: ${snapshot.error}'));
// //           }
// //           final collaborators = snapshot.data ?? [];
// //           return ListView.builder(
// //             itemCount: collaborators.length,
// //             itemBuilder: (context, index) {
// //               final collaborator = collaborators[index];
// //               return ListTile(
// //                 title: Text(collaborator['profiles']['username'] ?? 'Unknown User'),
// //                 subtitle: Text('Role: ${collaborator['role']}'),
// //                 trailing: Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     IconButton(
// //                       icon: const Icon(Icons.edit),
// //                       onPressed: () async {
// //                         showDialog(
// //                           context: context,
// //                           builder: (_) => EditRoleDialog(
// //                             currentRole: collaborator['role'],
// //                             onRoleSelected: (newRole) async {
// //                               try {
// //                                 await editRole(projectId, collaborator['user_id'], newRole);
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   const SnackBar(content: Text('Role updated successfully')),
// //                                 );
// //                                 ref.refresh(collaboratorsProvider(projectId));
// //
// //                                 // ref.refresh(fetchCollaborators(projectId)); // Refresh the list
// //                               } catch (e) {
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   SnackBar(content: Text('Error: $e')),
// //                                 );
// //                               }
// //                             },
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.delete, color: Colors.red),
// //                       onPressed: () async {
// //                         final confirm = await showDialog<bool>(
// //                           context: context,
// //                           builder: (context) => AlertDialog(
// //                             title: const Text('Remove Collaborator'),
// //                             content: const Text('Are you sure you want to remove this collaborator?'),
// //                             actions: [
// //                               TextButton(
// //                                 onPressed: () => Navigator.of(context).pop(false),
// //                                 child: const Text('Cancel'),
// //                               ),
// //                               TextButton(
// //                                 onPressed: () => Navigator.of(context).pop(true),
// //                                 child: const Text('Remove'),
// //                               ),
// //                             ],
// //                           ),
// //                         );
// //                         if (confirm == true) {
// //                           try {
// //                             await deleteCollaborator(projectId, collaborator['user_id']);
// //                             ScaffoldMessenger.of(context).showSnackBar(
// //                               const SnackBar(content: Text('Collaborator removed successfully')),
// //                             );
// //                             ref.refresh(collaboratorsProvider(projectId));
// //
// //                             // ref.refresh(fetchCollaborators(projectId)); // Refresh the list
// //                           } catch (e) {
// //                             ScaffoldMessenger.of(context).showSnackBar(
// //                               SnackBar(content: Text('Error: $e')),
// //                             );
// //                           }
// //                         }
// //                       },
// //                     ),
// //                   ],
// //                 ),
// //               );
// //               // return ListTile(
// //               //   title: Text(collaborator['profiles']['username'] ?? 'Unknown User'),
// //               //   subtitle: Text('Role: ${collaborator['role']}'),
// //               //   trailing: Row(
// //               //     mainAxisSize: MainAxisSize.min,
// //               //     children: [
// //               //       IconButton(
// //               //         icon: const Icon(Icons.edit),
// //               //         onPressed: () {
// //               //           // Placeholder for editing role
// //               //         },
// //               //       ),
// //               //       IconButton(
// //               //         icon: const Icon(Icons.delete, color: Colors.red),
// //               //         onPressed: () {
// //               //           // Placeholder for removing collaborator
// //               //         },
// //               //       ),
// //               //     ],
// //               //   ),
// //               // );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   Future<List<dynamic>> fetchCollaborators(String projectId) async {
// //     final response = await Supabase.instance.client.from('project_permissions').select('user_id, role, profiles(username, full_name)').eq('project_id', projectId);
// //
// //     if (response.isEmpty) {
// //       return [];
// //     }
// //
// //     return response as List<dynamic>;
// //   }
// // }
//
// // final collaboratorsProvider = FutureProvider.family<List<dynamic>, String>((ref, projectId) async {
// //   final response = await Supabase.instance.client.from('project_permissions').select('user_id, role, profiles(username, full_name)').eq('project_id', projectId);
// //
// //   if (response.isEmpty) {
// //     return [];
// //   }
// //   return response as List<dynamic>;
// // });
