import 'package:flutter/material.dart';

import 'auth/auth_gate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Flutter',
      theme: ThemeData.dark().copyWith(primaryColor: Colors.green, textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.green)), elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.green))),
      home: AuthGate(), // Start with the AuthGate
      // home: supabase.auth.currentSession == null ? const LoginPage() : const AccountPage(),
    );
  }
}
