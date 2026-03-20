import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    debugPrint("Firebase initialized successfully.");
  } catch (e) {
    debugPrint("Firebase initialization failed or skipped. Using mock storage. Details: $e");
  }

  runApp(const ProviderScope(child: WomenEmpowermentApp()));
}

class WomenEmpowermentApp extends StatelessWidget {
  const WomenEmpowermentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Women\'s Financial Empowerment',
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
