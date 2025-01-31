import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollylabs_flutter/utils/project_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'edit_role_dialog.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => InviteUserDialog(projectId: projectId),
              );
            },
          ),
        ],
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
                                // ref.refresh(collaboratorsProvider(projectId));
                                ref.invalidate(collaboratorsProvider(projectId));
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
                            ref.invalidate(collaboratorsProvider(projectId));
                            // ref.refresh(collaboratorsProvider(projectId));
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
}

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
      // Generate a sign-up magic link for the user
      await Supabase.instance.client.auth.signInWithOtp(email: email);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Magic link sent successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle any exceptions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending magic link: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// Future<void> _inviteUser() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   final email = _emailController.text.trim();
  //
  //   if (email.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please enter an email address.')),
  //     );
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     return;
  //   }
  //
  //   try {
  //     await inviteUserToProject(widget.projectId, email, _selectedRole);
  //
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Invitation sent successfully!')),
  //       );
  //       Navigator.of(context).pop();
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error sending invite: $e')),
  //       );
  //     }
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// import 'edit_role_dialog.dart';
// import 'invite_user_dialog.dart';
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
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_add),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (_) => InviteUserDialog(projectId: projectId),
//               );
//             },
//           ),
//         ],
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
//                                     SnackBar(content: Text('Error: ${e.toString()}')),
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
//                                 SnackBar(content: Text('Error: ${e.toString()}')),
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
//     final response = await Supabase.instance.client.from('project_permissions').update({'role': newRole}).eq('project_id', projectId).eq('user_id', userId).select();
//
//     if (response == null || response.isEmpty) {
//       throw Exception('No rows were updated. Ensure the project retains an owner.');
//     }
//   }
//
//   Future<void> deleteCollaborator(String projectId, String userId) async {
//     final response = await Supabase.instance.client.from('project_permissions').delete().match({'project_id': projectId, 'user_id': userId}).select();
//
//     if (response == null || response.isEmpty) {
//       throw Exception('Failed to delete collaborator. Ensure the project retains an owner.');
//     }
//   }
// }

// Role Editing Dialog
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
