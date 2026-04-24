import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────
// EMAIL VERIFICATION SCREEN
// Shown after login
// User must click the link in their email inbox
// When they tap "I Have Verified" the app checks Firebase
// If verified — go to portal
// If not verified — stay on screen and show error
// ─────────────────────────────────────────────────────────

class EmailVerificationScreen extends StatefulWidget {

  // The screen to go to after successful verification
  final Widget destination;

  const EmailVerificationScreen({super.key, required this.destination});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {

  //Default state variables
  bool _isChecking     = false;
  bool _isResending    = false;
  String _errorMessage = '';
  String _successMessage = '';

  //Check if user actually clicked the link
  Future<void> _checkVerification() async {

    if (_isChecking) return;

    setState(() {
      _isChecking    = true;
      _errorMessage  = '';
      _successMessage = '';
    });

    try {

      //Reload the user to get the latest verification status from Firebase
      await FirebaseAuth.instance.currentUser!.reload();

      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        //Email is verified, go to next screen
        _goTo(widget.destination);
      } else {
        //Not verified yet — stay on screen and show message
        setState(() {
          _errorMessage = 'Email not verified yet. Please check your inbox and click the link first.';
          _isChecking   = false;
        });
      }

    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isChecking   = false;
      });
    }
  }

  //Resend the verification email
  Future<void> _resendEmail() async {

    if (_isResending) return;

    setState(() {
      _isResending    = true;
      _errorMessage   = '';
      _successMessage = '';
    });

    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      setState(() {
        _successMessage = 'Verification email sent! Check your inbox.';
        _isResending    = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Could not resend email. Please wait a moment and try again.';
        _isResending  = false;
      });
    }
  }

  //Navigate
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

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF1E3A5F)),
          onPressed: () {
            // Sign out and go back to Login
            FirebaseAuth.instance.signOut();
            _goTo(LoginScreen());
          },
        ),
      ),

      //SafeArea keeps UI inside the safe visible screen
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              //Email icon box
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: 52,
                  color: Color(0xFF2563EB),
                ),
              ),

              SizedBox(height: 32),

              //Title
              Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E3A5F),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12),

              //Shows the user's email
              Text(
                'We sent a verification link to',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 4),

              //Email address in bold blue
              Text(
                FirebaseAuth.instance.currentUser?.email ?? 'your email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12),

              Text(
                'Click the link in your inbox then come back here and tap the button below.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32),

              // Error message
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
                      Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Color(0xFFDC2626), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              //Success message for resend
              if (_successMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFF6EE7B7)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage,
                          style: TextStyle(color: Color(0xFF065F46), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              //I Have Verified button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  //Show spinner while checking, text when not
                  child: _isChecking
                      ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    'I Have Verified My Email',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              //Resend email link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Did not receive it? ',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: _isResending ? null : _resendEmail,
                          child: Text(
                            _isResending ? 'Sending...' : 'Resend Email',
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

              SizedBox(height: 12),

              //Spam folder reminder
              Text(
                'Do not forget to check your spam folder or junk.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

            ],
          ),
        ),
      ),
    );
  }
}