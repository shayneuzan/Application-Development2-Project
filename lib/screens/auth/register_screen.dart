import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../owner/owner_home_screen.dart';
import '../walker/walker_home_screen.dart';
import 'email_verification_screen.dart';

// ─────────────────────────────────────────────────────────
// REGISTER SCREEN
// User fills in name, email, password and picks a role
// Pet Owner or Dog Walker only — no admin option
// Saves user to Firebase Auth + Firestore on register
// ─────────────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // Controllers hold what the user types
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();

  // Default state variables
  bool _isRegistering    = false;
  bool _hidePassword     = true;
  bool _hideConfirm      = true;
  String _selectedRole   = 'owner'; // default role is Pet Owner
  String _errorMessage   = '';

  String _getDayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }

  // To Prevent Memory Leaks
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Main register function ─────────────────────────────
  Future<void> _register() async {

    if(_isRegistering) return; //prevents double tapping

    // Basic checks before doing anything
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    //Show spinner, clear error
    setState(() {
      _isRegistering = true;
      _errorMessage  = '';
    });

    try {

      //Create account in Firebase Auth
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email:    _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print("Email created successfully");


      //Save user profile to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(result.user!.uid)
          .set({
        'uid':       result.user!.uid,
        'name':      _nameController.text.trim(),
        'email':     _emailController.text.trim(),
        'role':      _selectedRole,
        'photoUrl':  '',
        'createdAt': FieldValue.serverTimestamp(),

        //Walker specific fields
        if (_selectedRole == 'walker') ...{
          'isApproved': false,  //admin must approve before accepting bookings
          'status': 'pending',  //pending until admin approves
        },

        // Owner specific fields
        if (_selectedRole == 'owner') ...{
          'status': 'active',   // owners can use app immediately
        },
      });
      print("User Profile created successfully");

      if (_selectedRole == 'walker') {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(result.user!.uid)
            .collection('earnings')
            .add({
          'amount': 0.0,
          'date': FieldValue.serverTimestamp(),
          'dayOfWeek': _getDayName(DateTime.now().weekday),
          'experience': 'N/A',
          'hourlyRate': '12',
          'todayEarnings': 0.0,
          'weeklyEarnings': 0.0,
          'monthEarnings': 0.0,
        });
      }
      // Go directly to Verification Screen instead of forcing them to log in again
      Widget destination = _selectedRole == 'walker' ? WalkerHomeScreen() : OwnerHomeScreen();
      _goTo(EmailVerificationScreen(destination: destination));

    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please try again.';

      if (e.code == 'email-already-in-use') {
        message = 'The email address is already in use by another account.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      }

      print("FIREBASE ERROR: $e");
      setState(() {
        _errorMessage = message;
        _isRegistering = false;
      });
    } catch (e) {
      print("REGULAR ERROR: $e");
      setState(() {
        _errorMessage = 'Connection error or profile creation failed. Please try again.';
        _isRegistering = false;
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF1E3A5F)),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // SafeArea keeps UI inside the safe visible screen
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //Title
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E3A5F),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Join PawWalk today',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
              ),

              SizedBox(height: 32),

              //Role Selector
              //Only Pet Owner and Dog Walker, no admin
              Text(
                'I am a...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A5F),
                ),
              ),
              SizedBox(height: 12),

              Row(
                children: [

                  //Pet Owner card
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = 'owner'),
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          //box becomes blue when selected, white when not
                          color: _selectedRole == 'owner'
                              ? Color(0xFF2563EB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all( //border is blue when selected, grey when not
                            color: _selectedRole == 'owner'
                                ? Color(0xFF2563EB)
                                : Colors.grey.shade200,
                          ),
                          boxShadow: _selectedRole == 'owner' //shadows when card is selected to get that 3d effect
                              ? [
                            BoxShadow(
                              color: Color(0xFF2563EB).withOpacity(0.3),
                              blurRadius: 12,
                            )
                          ]
                              : [], //no shadow if not selected
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.pets,
                              color: _selectedRole == 'owner'
                                  ? Colors.white
                                  : Color(0xFF6B7280),
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Pet Owner',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _selectedRole == 'owner'
                                    ? Colors.white
                                    : Color(0xFF1E3A5F),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'I want to book walkers',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: _selectedRole == 'owner'
                                    ? Colors.white70
                                    : Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  //Dog Walker card
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = 'walker'),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'walker'
                              ? Color(0xFF2563EB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedRole == 'walker'
                                ? Color(0xFF2563EB)
                                : Colors.grey.shade200,
                          ),
                          boxShadow: _selectedRole == 'walker'
                              ? [
                            BoxShadow(
                              color: Color(0xFF2563EB).withOpacity(0.3),
                              blurRadius: 12,
                            )
                          ]
                              : [],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.directions_walk,
                              color: _selectedRole == 'walker'
                                  ? Colors.white
                                  : Color(0xFF6B7280), //grey if not pressed
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Dog Walker',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _selectedRole == 'walker'
                                    ? Colors.white
                                    : Color(0xFF1E3A5F),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'I want to walk dogs',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: _selectedRole == 'walker'
                                    ? Colors.white70
                                    : Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),

              SizedBox(height: 28),

              //Full Name label + field
              Text(
                'Full Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A5F),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words, //the first letter of every word is uppercase
                decoration: _inputStyle(
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                ),
              ),

              SizedBox(height: 18),

              //Email label + field
              Text(
                'Email Address',
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

              SizedBox(height: 18),

              //Password label + field
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
                  hint: 'Create a password',
                  icon: Icons.lock_outline,
                ).copyWith(
                  // Eye icon to show/hide password
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Color(0xFF6B7280),
                    ),
                    onPressed: () {
                      setState(() => _hidePassword = !_hidePassword);
                    },
                  ),
                ),
              ),

              SizedBox(height: 18),

              //Confirm Password label + field
              Text(
                'Confirm Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A5F),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                obscureText: _hideConfirm,
                decoration: _inputStyle(
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline,
                ).copyWith(
                  // Eye icon to show/hide confirm password
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hideConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Color(0xFF6B7280),
                    ),
                    onPressed: () {
                      setState(() => _hideConfirm = !_hideConfirm);
                    },
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Error message, only shows if registration fails
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

              //Register Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isRegistering ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  //While registering show spinner, otherwise show text
                  child: _isRegistering
                      ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    'Create Account',
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
                    padding: EdgeInsets.symmetric(horizontal: 12),
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

              //Already have account link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
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