import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'my_app.dart';

Future<void> main() async {
  String supabaseUrl = 'https://xxrsdsxpunwytsfizujp.supabase.co';
  String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4cnNkc3hwdW53eXRzZml6dWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc0NTQ5NjgsImV4cCI6MjA1MzAzMDk2OH0.39sq7-uHSVPcKN6fzGzLOPt4pUXi3bnn-F-eT6UFLfw';

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  if (kIsWeb) {
    usePathUrlStrategy();
  }
  runApp(const ProviderScope(child: MyApp()));
  // runApp(const MyApp());
}

final supabase = Supabase.instance.client;

extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Theme.of(this).colorScheme.error : Theme.of(this).snackBarTheme.backgroundColor));
  }
}
