import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../widgets/walker_bottom_nav_bar.dart';
import '../widgets/walker_drawer.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  // Implement dispose() to clean up memory
  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          String name = 'Guest';
          String email = 'No Email';
          String bio = 'No Bio';
          String hourlyRate = '';
          String experience = '';

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            name = data['name'] ?? 'Guest';
            email = data['email'] ?? 'No Email';
            bio = data['bio'] ?? 'No Bio';
            hourlyRate = (data['hourlyRate'] ?? '').toString();
            experience = data['experience'] ?? '';

            // 3. Set initial text only if the user hasn't started typing yet
            if (_nameController.text.isEmpty) _nameController.text = name;
            if (_bioController.text.isEmpty) _bioController.text = bio;
            if (_hourlyRateController.text.isEmpty) _hourlyRateController.text = hourlyRate;
            if (_experienceController.text.isEmpty) _experienceController.text = experience;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.blueAccent,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            drawer: WalkerDrawer(name: name),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Card
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.lightBlue,
                                child: Icon(Icons.person, size: 50, color: Colors.white,),
                              ),
                              const SizedBox(height: 15),
                              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),),
                              const SizedBox(height: 5),
                              Text(email, style: TextStyle(fontSize: 16, color: Colors.grey.shade600),),
                            ],
                          )
                      ),
                    ),
                  ),

                  // Name Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Full Name:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your name',
                                  prefixIcon: Icon(Icons.edit, size: 20),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ]
                        ),
                      ),
                    ),
                  ),

                  // Bio Card
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Full Bio:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _bioController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'Tell us about yourself',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12,),
                  // Hourly Rate Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hourly Rate:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _hourlyRateController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                //label: Text("Hourly Rate"),
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.monetization_on_outlined),
                                prefix: Text("\$ "),
                                suffix: Text("/hour"),
                                hint: Text("25"),
                              ),
                            ),
                          ]
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12,),
                  // Experience Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Experience:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _experienceController,
                              decoration: InputDecoration(
                                //label: Text("Experience"),
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.history),
                                hint: Text("e.g. 5 years of Dog Walking"),
                              ),
                            ),
                          ]
                        ),
                      ),
                    ),
                  ),

                  // Save Changes Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_nameController.text.isEmpty || _bioController.text.isEmpty || _hourlyRateController.text.isEmpty || _experienceController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields.")),);
                            throw 'ERROR: One or more fields is empty. Fill them up!';
                          } else if (_hourlyRateController.text == '0') {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hourly Rate must be greater than \$0.")),);
                            throw 'ERROR: One or more fields is empty. Fill them up!';
                          }
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .update({
                            'name': _nameController.text,
                            'bio': _bioController.text,
                            'hourlyRate': _hourlyRateController.text,
                            'experience': _experienceController.text,
                            'updatedAt': FieldValue.serverTimestamp(),
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Profile Updated!")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),
                  // Log out Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // 1. Log out
                          await FirebaseAuth.instance.signOut();
                          // 2. CHECK THE ASYNC GAP: Make sure the screen is still active
                          if (!context.mounted) return;
                          // 3. Now it is safe to navigate
                          Navigator.pop(context); // Close drawer
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Row (
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_outlined),
                            SizedBox(width: 8),
                            Text("LOG OUT", style: TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        )
                      ),
                    ),
                  ),
                  const SizedBox(height: 30), // Extra space at bottom for scrolling
                ],
              ),
            ),
            bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 4),
          );
        }
    );
  }
}