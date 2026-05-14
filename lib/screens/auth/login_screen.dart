import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawwalk/screens/walker/walker_home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'email_verification_screen.dart';
import 'package:pawwalk/screens/owner/owner_home_screen.dart';
import 'package:pawwalk/screens/admin/admin_dashboard_screen.dart';

// ─────────────────────────────────────────────────────────
// LOGIN SCREEN
// User enters email + password
// App reads their role from Firestore and routes them
// ─────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //Controllers hold what the user types
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  //default state variables
  bool _isSigningIn = false;
  bool _hidePassword = true;
  String _errorMessage = '';

  //main login function
  Future<void> _login() async {

    // Basic checks before doing anything
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }

    // Show spinner, clear error
    setState(() {
      _isSigningIn  = true;
      _errorMessage = '';
    });

    try {

      // Sign in with Firebase Auth
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email:    _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Force a token refresh so emailVerified reflects the true current state.
      // Without this, a user who just verified their email still shows as unverified.
      await result.user!.reload();
      final freshUser = FirebaseAuth.instance.currentUser!;

      // Get the user's role and status from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(freshUser.uid)
          .get();

      String role   = 'owner';  // default
      String status = 'active'; // default
      if (doc.data() != null) {
        role   = doc.data()!['role']   ?? 'owner';
        status = doc.data()!['status'] ?? 'active';
      }

      // If the account is suspended sign them out immediately
      if (status == 'suspended') {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Your account has been suspended. Contact support.';
          _isSigningIn  = false;
        });
        return;
      }

      if (!mounted) return;

      // Route to the right screen based on role
      switch (role) {
        case 'walker':
          if (freshUser.emailVerified) {
            _goTo(WalkerHomeScreen());
          } else {
            // Only send verification email if not already sent recently — avoids rate limit errors
            try {
              await freshUser.sendEmailVerification();
            } catch (_) {}
            if (!mounted) return;
            _goTo(EmailVerificationScreen(destination: WalkerHomeScreen()));
          }
          break;
        case 'admin':
          _goTo(AdminDashboardScreen());
          break;
        default:
          // Pet owner
          if (freshUser.emailVerified) {
            _goTo(OwnerHomeScreen());
          } else {
            try {
              await freshUser.sendEmailVerification();
            } catch (_) {}
            if (!mounted) return;
            _goTo(EmailVerificationScreen(destination: OwnerHomeScreen()));
          }
      }

    } on FirebaseAuthException catch (e) {
      // Show a specific message based on the Firebase error code
      String message;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password. Please try again.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please wait a moment and try again.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled. Contact support.';
          break;
        case 'network-request-failed':
          message = 'No internet connection. Please check your network.';
          break;
        default:
          message = 'Sign in failed: ${e.message}';
      }
      if (!mounted) return;
      setState(() {
        _errorMessage = message;
        _isSigningIn  = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isSigningIn  = false;
      });
    }
  }


  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Color(0xFFF0F4FF),

      //safeArea keeps UI inside the safe visible screen
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              SizedBox(height: 60),

              //Logo + Title
              Center(
                child: Column(
                  children: [

                    //Blue box with paw icon + shadow
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF2563EB).withOpacity(0.3), //30% transparent
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.pets,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 16),


                    Text(
                      'PawWalk',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E3A5F),
                        letterSpacing: 1.0,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'Sign in to your account',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),

                  ],
                ),
              ),

              SizedBox(height: 48),

              //Email label + Textfield
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A5F),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: _inputStyle(
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                ),
              ),

              SizedBox(height: 20),

              //Password label + Textfield
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A5F),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _hidePassword,
                decoration: _inputStyle(
                  hint: 'Enter your password',
                  icon: Icons.lock_outline,
                ).copyWith(
                  //Eye icon to show/hide password
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hidePassword //if hidePassword is true then ..
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined, //=> else its off
                      color: Color(0xFF6B7280),
                    ),
                    onPressed: () {
                      setState(() => _hidePassword = !_hidePassword); //password is hidden meaning its true, when clicked it becomes not hidden anymore and does the opposite when clicked again
                    },
                  ),
                ),
              ),

              SizedBox(height: 12),

              //Forgot Password link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              //Error message, only shows if login fails cuz of incorrect credentials
              if (_errorMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Color(0xFFDC2626),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              //Login Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSigningIn ? null : _login, //if SigningIn is false meaning input fields are empty then return null else itll try to login depending on the valid credentials
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),

                  //while logging in, show a spinner. Otherwise if false just show 'Sign In'
                  child: _isSigningIn
                      ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32),

              //Divider with "or"
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey.shade300, thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey.shade300, thickness: 1),
                  ),
                ],
              ),

              SizedBox(height: 24),

              //Register link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }

  //Reusable input field style
  InputDecoration _inputStyle({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      prefixIcon: Icon(icon, color: Color(0xFF6B7280), size: 20),
      filled: true,
      fillColor: Colors.white, //makes the input box white
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), //spacing inside the textField
      enabledBorder: OutlineInputBorder( //when field is not clicked border becomes light grey
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder( //when field is clicked border becomes blue
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),

    );
  }
}