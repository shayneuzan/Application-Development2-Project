import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/login_screen.dart';
import '../widgets/walker_bottom_nav_bar.dart';
import '../widgets/walker_drawer.dart';
import '../widgets/walker_notification_icon.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          String name = 'Guest';
          String email = 'No Email';
          String bio = 'No Bio';
          double hourlyRate = 0.0;
          int experience = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            name = data['name'] ?? 'Guest';
            email = data['email'] ?? 'No Email';
            bio = data['bio'] ?? 'No Bio';
            hourlyRate = (data['hourlyRate'] ?? 0.0).toDouble();
            experience = (data['experienceYears'] ?? 0).toInt();

            if (_nameController.text.isEmpty) _nameController.text = name;
            if (_bioController.text.isEmpty) _bioController.text = bio;
            if (_hourlyRateController.text.isEmpty) _hourlyRateController.text = hourlyRate.toDouble().toStringAsFixed(2);
            if (_experienceController.text.isEmpty) _experienceController.text = experience.toInt().toString();
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.editProfile, style: const TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF2563EB),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: const [
                NotificationIcon(),
                SizedBox(width: 8,),
              ],
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
                                backgroundColor: Color(0xFF2563EB),
                                child: Icon(Icons.person, size: 50, color: Colors.white,),
                              ),
                              const SizedBox(height: 15),
                              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                              const SizedBox(height: 5),
                              Text(email, style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),),
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
                              Text(l10n.nameCardLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: l10n.nameCardHint,
                                  prefixIcon: const Icon(Icons.edit, size: 20),
                                  border: const OutlineInputBorder(),
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
                            Text(l10n.bioCardLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _bioController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: l10n.bioCardHint,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12,),
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
                            Text(l10n.hourlyRateCardLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _hourlyRateController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.monetization_on_outlined),
                                prefixText: "\$ ",
                                suffixText: l10n.hourlyRateCardSuffix,
                                hintText: "25.00",
                              ),
                            ),
                          ]
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12,),
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
                            Text(l10n.yearsCardLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _experienceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.history),
                                hintText: l10n.yearsCardHint,
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
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.fillAllFields)),);
                            return;
                          } else if (_hourlyRateController.text == '0') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.hourlyRateZero)),);
                            return;
                          }
                          String name = _nameController.text;
                          String bio = _bioController.text;
                          String hourlyRate = _hourlyRateController.text;
                          String exp = _experienceController.text;
                          await FirebaseFirestore.instance.collection('users').doc(uid).update({
                            'name': name,
                            'bio': bio,
                            'hourlyRate': double.parse(hourlyRate),
                            'experienceYears': int.parse(exp),
                            'updatedAt': FieldValue.serverTimestamp(),
                          });
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.changesSaved)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(l10n.saveChanges, style: const TextStyle(fontWeight: FontWeight.bold),),
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
                          await FirebaseAuth.instance.signOut();
                          if (!context.mounted) return;
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
                            const Icon(Icons.logout_outlined),
                            const SizedBox(width: 8),
                            Text(l10n.logOut, style: const TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        )
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            bottomNavigationBar: const WalkerBottomNavBar(currentIndex: 4),
          );
        }
    );
  }
}
