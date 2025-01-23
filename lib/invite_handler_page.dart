import 'package:flutter/material.dart';
import 'package:sollylabs_flutter/pages/account_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InviteHandlerPage extends StatelessWidget {
  final Uri link;

  const InviteHandlerPage({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: handleInviteLink(link), // Function to process the invite link
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Processing Invite')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('Error handling invite: ${snapshot.error}'),
            ),
          );
        } else {
          // Navigate to the main app after processing
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AccountPage()), // Replace with your main page
            );
          });

          return Scaffold(
            appBar: AppBar(title: const Text('Invite Processed')),
            body: const Center(child: Text('You have been added to the project!')),
          );
        }
      },
    );
  }

  Future<void> handleInviteLink(Uri link) async {
    // Process the invite link here (e.g., extract projectId and role)
    final projectId = link.queryParameters['projectId'];
    final role = link.queryParameters['role'];

    if (projectId == null || role == null) {
      throw Exception('Invalid invite link: Missing projectId or role');
    }

    // Example logic for handling the invite link
    // print('Processing invite for projectId: $projectId with role: $role');

    // Add the user to the project_permissions table via Supabase
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in.');
    }

    final response = await Supabase.instance.client.from('project_permissions').insert({
      'project_id': projectId,
      'user_id': user.id,
      'role': role,
    }).select();

    if (response.isEmpty) {
      throw Exception('Failed to assign user to the project.');
    }
  }
}

// class InviteHandlerPage extends StatefulWidget {
//   const InviteHandlerPage({super.key});
//
//   @override
//   State<InviteHandlerPage> createState() => _InviteHandlerPageState();
// }
//
// class _InviteHandlerPageState extends State<InviteHandlerPage> {
//   late final AppLinks _appLinks;
//
//   @override
//   void initState() {
//     super.initState();
//     _setupAppLinks();
//   }
//
//   Future<void> _setupAppLinks() async {
//     _appLinks = AppLinks();
//
//     // Handle runtime deep links
//     _appLinks.uriLinkStream.listen((Uri? deepLink) async {
//       if (deepLink != null) {
//         await _handleInviteLink(deepLink);
//       }
//     });
//
//     // Handle initial deep link
//     if (kIsWeb) {
//       // For web, use Uri.base
//       final Uri initialLink = Uri.base;
//       if (initialLink.queryParameters.containsKey('projectId') && initialLink.queryParameters.containsKey('role')) {
//         await _handleInviteLink(initialLink);
//       }
//     }
//   }
//
//   Future<void> _handleInviteLink(Uri link) async {
//     try {
//       // Parse and process the invite link
//       await handleInviteLink(link);
//
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('You have been added to the project!')),
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error handling invite: $e')),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Welcome')),
//       body: const Center(child: Text('Invite Link Handler')),
//     );
//   }
// }
