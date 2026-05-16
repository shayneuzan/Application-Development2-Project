import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawwalk/screens/admin/admin_dashboard_screen.dart';
import 'package:pawwalk/screens/owner/owner_home_screen.dart';
import 'dart:async';
import '../walker/walker_home_screen.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────
// SPLASH SCREEN
// Shows for 3 seconds then goes to Login
// ─────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //Controls the fade in of the content
  //Starts at 0 (invisible) and goes to 1 (fully visible)
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Fade the content IN after 300ms
    Timer(Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Wait 3 seconds then go to Login
    Timer(Duration(seconds: 3), () {
      checkUserAndNavigate();
    });
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  //All navigation logic lives inside this function
  Future<void> checkUserAndNavigate() async {
    // Wait for Firebase Auth to restore the cached session before reading the user.
    // currentUser is null at startup until the auth state is rehydrated from disk.
    final user = await FirebaseAuth.instance.authStateChanges().first;

    //if user is not logged in go to login screen
    if (user == null) {
      _goTo(LoginScreen());
      return;
    }

    //If user is logged in check their role in firestore
    //check the users collection and look at their doc user id
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    String role = 'owner'; //default role

    //Read the role from the document if it exists
    if (doc.data() != null && doc.data()!['role'] != null) {
      role = doc.data()!['role'];
    }

    switch (role) {
      case 'walker':
        // If email is not verified send them back to login so they can verify first
        if (!user.emailVerified) {
          _goTo(LoginScreen());
        } else {
          _goTo(const WalkerHomeScreen());
        }
        break;
      case 'admin':
        _goTo(const AdminDashboardScreen());
        break;
      default:
        // Pet owner
        // If email is not verified send them back to login so they can verify first
        if (!user.emailVerified) {
          _goTo(LoginScreen());
        } else {
          _goTo(const OwnerHomeScreen());
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E3A5F),

      body: Center(
        //AnimatedOpacity fades the content IN when the screen opens
        //duration controls how long the fade in takes
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(milliseconds: 800),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Paw icon box
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Icon(Icons.pets, size: 65, color: Colors.white),
              ),

              SizedBox(height: 28),

              //App name
              Text(
                'PawWalk',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),

              SizedBox(height: 10),

              //Tagline
              Text(
                'Trusted Dog Walking — Anytime',
                style: TextStyle(fontSize: 14, color: Color(0xFFBFDBFE)),
              ),

              SizedBox(height: 60),

              //Loading spinner
              CircularProgressIndicator(
                color: Color(0xFF2563EB),
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
