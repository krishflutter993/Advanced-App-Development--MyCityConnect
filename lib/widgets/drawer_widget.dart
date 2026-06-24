import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mycityconnect/screen/home_screen.dart';
import 'package:mycityconnect/screen/login_screen.dart';
import 'package:mycityconnect/screen/profile_screen.dart';
import 'package:mycityconnect/screen/my_bookings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerWidget extends StatelessWidget {
  final String userName;
  final String userEmail;

  const DrawerWidget({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _animatedTile(0, Icons.home_rounded, "Home", () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                }),
                _animatedTile(1, Icons.bookmark_border, "My Bookings", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                  );
                }),
                _animatedTile(2, Icons.person_outline, "Profile", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                }),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Divider(),
                ),
                _animatedTile(3, Icons.support_agent, "Contact Us", () {
                  _showContactDialog(context);
                }),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Divider(),
                ),
                _animatedTile(4, Icons.logout, "Logout", () {
                  _logout(context);
                }, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 45, color: Color(0xFF667eea)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            userEmail,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _animatedTile(
      int index, IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 50, end: 0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: Opacity(
            opacity: (1 - (value / 50)).clamp(0, 1),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            splashColor: (color ?? const Color(0xFF667eea)).withOpacity(0.2),
            highlightColor: (color ?? const Color(0xFF667eea)).withOpacity(0.1),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          (color ?? const Color(0xFF667eea)).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color ?? const Color(0xFF667eea)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: color ?? Colors.black87,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Contact Us",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _contactButton(Icons.call, "Call", Colors.green, () {
                  _launch(Uri(scheme: 'tel', path: '+1234567890'));
                }),
                _contactButton(Icons.message, "SMS", Colors.blue, () {
                  _launch(Uri(scheme: 'sms', path: '+1234567890'));
                }),
                _contactButton(Icons.language, "Web", Colors.purple, () {
                  _launch(Uri.parse('https://mycityconnect.com'));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }
}
