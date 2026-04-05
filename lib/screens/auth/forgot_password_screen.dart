import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────
// FORGOT PASSWORD SCREEN
// User types their email
// Firebase sends a reset link to that email
// Shows a success message after sending
// ─────────────────────────────────────────────────────────

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  // Controller holds what the user types
  final _emailController = TextEditingController();

  // Default state variables
  bool _isSending      = false;
  bool _emailSent      = false;
  String _errorMessage = '';

  // ── Main send reset email function ────────────────────
  Future<void> _sendResetEmail() async {

    // Basic check before doing anything
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address.');
      return;
    }

    // Show spinner, clear error
    setState(() {
      _isSending    = true;
      _errorMessage = '';
    });

    try {

      //Firebase sends the reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      //Show success screen
      setState(() {
        _emailSent = true;
        _isSending = false;
      });

    } catch (e) {
      // Show error if sending fails
      setState(() {
        _errorMessage = 'No account found with this email.';
        _isSending    = false;
      });
    }
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Color(0xFFF0F4FF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF1E3A5F)),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      //SafeArea keeps UI inside the safe visible screen
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),

          // Show success screen if email was sent
          // Otherwise show the form
          child: _emailSent ? _successScreen() : _formScreen(),
        ),
      ),
    );
  }

  //Form screen , before sending email
  Widget _formScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(height: 20),

        //Blue lock icon box
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.lock_reset,
              size: 42,
              color: Color(0xFF2563EB),
            ),
          ),
        ),

        SizedBox(height: 28),

        Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E3A5F),
          ),
        ),

        SizedBox(height: 8),

        Text(
          'Enter your email and we will send you a reset link.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),

        SizedBox(height: 36),

        //Email label
        Text(
          'Email Address',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A5F),
          ),
        ),
        SizedBox(height: 8),

        //Email field
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: _inputStyle(
            hint: 'Enter your email',
            icon: Icons.email_outlined,
          ),
        ),

        SizedBox(height: 24),

        // Error message, only shows if sending fails
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

        //Send reset link button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSending ? null : _sendResetEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            // While sending show spinner, otherwise show text
            child: _isSending
                ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : Text(
              'Send Reset Link',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        SizedBox(height: 24),

        //Back to login link
        Center(
          child: RichText(
            text: TextSpan(
              text: 'Remember your password? ',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Sign In',
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

      ],
    );
  }

  //Success screen ,after email is sent
  Widget _successScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        //Green checkmark circle
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            size: 52,
            color: Color(0xFF10B981),
          ),
        ),

        SizedBox(height: 32),

        Text(
          'Email Sent!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E3A5F),
          ),
        ),

        SizedBox(height: 12),

        //Shows the email they entered
        Text(
          'We sent a reset link to\n${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),

        SizedBox(height: 8),

        Text(
          'Check your inbox and follow the link.\nDon\'t forget to check your spam folder.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF9CA3AF),
            height: 1.5,
          ),
        ),

        SizedBox(height: 40),

        //Back to login button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => _goTo(LoginScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            child: Text(
              'Back to Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Colors.white
              ),
            ),
          ),
        ),

        SizedBox(height: 20),

        //Try again link
        GestureDetector(
          onTap: () {
            setState(() {
              _emailSent    = false;
              _errorMessage = '';
            });
          },
          child: Text(
            'Did not receive it? Try again',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

      ],
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