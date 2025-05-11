import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pravasa/screens/community_screen.dart';
import 'package:pravasa/screens/register.dart';
import 'firebase_options.dart';

import '/screens/ welcome_screen.dart';
import 'screens/ai_planner_screen.dart';
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TravelBuddyApp());
}

class TravelBuddyApp extends StatelessWidget {
  const TravelBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const LoginPage(),  // 👈 start with login
      routes: {
        '/aiPlanner': (context) => const AIPlannerScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/register': (context) => const RegisterPage(),
        '/community': (context) => const CommunityScreen(),
      },
    );
  }
}
