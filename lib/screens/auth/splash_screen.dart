import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawwalk/screens/walker/earnings_screen.dart';
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

  //Navigate with a fade animation to the next screen
  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(//lets you customize the animation instead of direct screen switch
        transitionDuration: Duration(milliseconds: 800), //fades in the to next screen over 800 ms
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
              opacity: animation,
              child: child
          );
        },
      ),
    );
  }

  //All navigation logic lives inside this function
  Future<void> checkUserAndNavigate() async {
    //get the currently logged in user
    final user = FirebaseAuth.instance.currentUser;

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
        // TODO: Replace with WalkerHomeScreen() when built
        _goTo(const WalkerHomeScreen());
        break;
      case 'admin':
        // TODO: Replace with AdminDashboardScreen() when built
        _goTo(const LoginScreen());
        break;
      default:
        // Pet owner
        // TODO: Replace with OwnerHomeScreen() when built
        _goTo(const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Dark navy background
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
