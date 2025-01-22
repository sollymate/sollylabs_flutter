import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'pages/account_page.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env.staging');
  String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  usePathUrlStrategy();
  runApp(const ProviderScope(child: MyApp()));
  // runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Flutter',
      theme: ThemeData.dark().copyWith(primaryColor: Colors.green, textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.green)), elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.green))),
      home: supabase.auth.currentSession == null ? const LoginPage() : const AccountPage(),
    );
  }
}

extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Theme.of(this).colorScheme.error : Theme.of(this).snackBarTheme.backgroundColor));
  }
}
