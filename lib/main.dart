import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/splash_screen.dart';

import 'package:pawwalk/screens/walker/request_screen.dart';
import 'package:pawwalk/screens/walker/schedule_screen.dart';
import 'package:pawwalk/screens/walker/walker_profile_edit_screen.dart';
import 'package:pawwalk/screens/walker/earnings_screen.dart';
import 'package:pawwalk/screens/walker/walker_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/walker-home': (context) => const WalkerHomeScreen(),
        '/walker-requests': (context) => const RequestScreen(),
        '/walker-schedule': (context) => const ScheduleScreen(),
        '/walker-earnings': (context) => const EarningsScreen(),
        '/walker-profile': (context) => const ProfileEditScreen(),
      },
      home: SplashScreen(),
    );
  }
}