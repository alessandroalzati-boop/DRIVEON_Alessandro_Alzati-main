import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/screens/user_provider.dart'; // <-- CORRETTO
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/main_navigation.dart';
import 'package:flutter_application_1/theme/app_theme.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider()..loadUserData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveON',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: FirebaseAuth.instance.currentUser != null
          ? const MainNavigation()
          : const LoginScreen(),
    );
  }
}