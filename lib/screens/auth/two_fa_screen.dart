import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'dart:async';

// ─────────────────────────────────────────────────────────
// 2FA SCREEN
// After login, a 6 digit code is generated and "sent" to email
// User types the code to verify their identity
// For school project: code is generated locally and shown
// in a snackbar (no real email sending needed)
// ─────────────────────────────────────────────────────────

class TwoFAScreen extends StatefulWidget {

  // We pass the destination screen so 2FA works for any role
  final Widget destination;

  const TwoFAScreen({super.key, required this.destination});

  @override
  State<TwoFAScreen> createState() => _TwoFAScreenState();
}

class _TwoFAScreenState extends State<TwoFAScreen> {

  // 6 separate controllers — one for each digit box
  final List<TextEditingController> _controllers = List.generate(
    6,
        (_) => TextEditingController(),
  );

  // 6 separate focus nodes — to auto jump between boxes
  final List<FocusNode> _focusNodes = List.generate(
    6,
        (_) => FocusNode(),
  );

  // Default state variables
  bool _isVerifying    = false;
  bool _canResend      = false;
  int _secondsLeft     = 60;
  String _errorMessage = '';
  String _generatedCode = '';

  // Timer for the resend countdown
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Generate and "send" the code when screen opens
    _generateAndSendCode();
  }

  //Generate a 6 digit code and show it
  void _generateAndSendCode() {

    // Generate random 6 digit code
    final code = (Random().nextInt(900000) + 100000).toString();
    _generatedCode = code;

    // Reset timer
    setState(() {
      _canResend   = false;
      _secondsLeft = 60;
      _errorMessage = '';
    });

    // Start countdown timer
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsLeft--);
      }
    });

    // Show the code in a snackbar
    // In a real app this would be sent to the user's email
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your code is: $code  (simulated — would be sent to your email)',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Color(0xFF2563EB),
          duration: Duration(seconds: 8),
        ),
      );
    });
  }

  // ── Verify the code the user typed ────────────────────
  Future<void> _verifyCode() async {

    // Join all 6 boxes into one string
    final enteredCode = _controllers.map((c) => c.text).join();

    // Check all boxes are filled
    if (enteredCode.length < 6) {
      setState(() => _errorMessage = 'Please enter the full 6 digit code.');
      return;
    }

    // Show spinner
    setState(() {
      _isVerifying  = true;
      _errorMessage = '';
    });

    // Small delay to feel like verification is happening
    await Future.delayed(Duration(milliseconds: 800));

    // Check if code matches
    if (enteredCode == _generatedCode) {
      // Code is correct — go to the right portal
      _goTo(widget.destination);
    } else {
      // Code is wrong — show error and clear boxes
      setState(() {
        _errorMessage = 'Incorrect code. Please try again.';
        _isVerifying  = false;
      });
      // Clear all boxes
      for (var c in _controllers) {
        c.clear();
      }
      // Focus back to first box
      _focusNodes[0].requestFocus();
    }
  }

  // ── Navigate with fade animation (same as all other screens) ─
  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  // ── Clean up when screen closes ────────────────────────
  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
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
          onPressed: () {
            // Sign the user out if they go back
            FirebaseAuth.instance.signOut();
            Navigator.pop(context);
          },
        ),
      ),

      // SafeArea keeps UI inside the safe visible screen
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 20),

              // Shield icon box
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    size: 42,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),

              SizedBox(height: 28),

              // Title
              Text(
                'Verify Your Identity',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E3A5F),
                ),
              ),

              SizedBox(height: 8),

              // Subtitle showing the email
              Text(
                'We sent a 6 digit code to ${FirebaseAuth.instance.currentUser?.email ?? 'your email'}.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Enter the code below to continue.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),

              SizedBox(height: 40),

              // ── 6 digit code boxes ──────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1, // only 1 digit per box
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A5F),
                      ),
                      decoration: InputDecoration(
                        counterText: '', // hides the "0/1" character counter
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFF2563EB),
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        // Auto jump to next box when a digit is typed
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        }
                        // Auto jump back when deleted
                        if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              SizedBox(height: 28),

              // Error message, only shows if code is wrong
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

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  // While verifying show spinner, otherwise show text
                  child: _isVerifying
                      ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    'Verify Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Resend code section
              Center(
                child: _canResend

                // Show resend button when timer runs out
                    ? RichText(
                  text: TextSpan(
                    text: 'Did not receive it? ',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: _generateAndSendCode,
                          child: Text(
                            'Resend Code',
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
                )

                // Show countdown timer while waiting
                    : Text(
                  'Resend code in $_secondsLeft seconds',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
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
}