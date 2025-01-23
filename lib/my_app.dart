import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'invite_handler_page.dart';
import 'pages/account_page.dart';
import 'pages/login_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Uri? inviteLink;

  @override
  void initState() {
    super.initState();
    _setupAppLinks();
  }

  Future<void> _setupAppLinks() async {
    final appLinks = AppLinks();

    // Listen for runtime deep links
    appLinks.uriLinkStream.listen((Uri? deepLink) {
      if (deepLink != null) {
        setState(() {
          inviteLink = deepLink;
        });
      }
    });

    // Handle the initial link (web or mobile)
    // Handle initial deep link for web and mobile
    if (kIsWeb) {
      // Use Uri.base for web initial links
      inviteLink = Uri.base;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the user is authenticated
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      // If the user is not logged in, show the LoginPage
      return MaterialApp(
        title: 'Project Invite App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const LoginPage(),
      );
    } else if (inviteLink != null && inviteLink!.queryParameters.containsKey('projectId') && inviteLink!.queryParameters.containsKey('role')) {
      // If an invite link is detected, process it
      return MaterialApp(
        title: 'Project Invite App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: InviteHandlerPage(link: inviteLink!),
      );
    } else {
      // If no invite link, show the AccountPage
      return MaterialApp(
        title: 'Project Invite App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AccountPage(),
      );
    }
  }
}
// import 'package:flutter/material.dart';
//
// import 'invite_handler_page.dart';
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Supabase Flutter',
//       theme: ThemeData.dark().copyWith(primaryColor: Colors.green, textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.green)), elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.green))),
//       home: const InviteHandlerPage(),
//
//       // home: supabase.auth.currentSession == null ? const LoginPage() : const AccountPage(),
//     );
//   }
// }
