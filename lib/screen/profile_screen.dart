import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Map<String, dynamic> userData = {};
  bool loading = true;

  final db = FirebaseDatabase.instanceFor(
    app: FirebaseAuth.instance.app,
    databaseURL:
        "https://myapp-b8bfe-default-rtdb.asia-southeast1.firebasedatabase.app",
  );

  @override
  void initState() {
    super.initState();
    initUser();
  }

  String? errorMessage;

  /// 🔥 INIT USER
  Future<void> initUser() async {
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final ref = db.ref("users/${user!.uid}");
      final snapshot = await ref.get();

      if (!snapshot.exists) {
        await ref.set({
          "name": user!.email?.split('@')[0] ?? "User",
          "email": user!.email ?? "",
          "phone": "",
          "address": "",
          "photo": "",
          "createdAt": DateTime.now().toIso8601String(),
        });
      }

      ref.onValue.listen((event) {
        final data = event.snapshot.value;

        setState(() {
          if (data != null) {
            userData = Map<String, dynamic>.from(data as Map);
          }
          loading = false;
        });
      }, onError: (error) {
        setState(() {
          errorMessage = error.toString();
          loading = false;
        });
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  /// 🔥 UPDATE FIELD
  Future<void> updateField(String key, String value) async {
    if (user == null) return;
    final ref = db.ref("users/${user!.uid}");
    await ref.update({key: value});
  }

  /// 🔥 EDIT FIELD
  void editField(String key, String oldValue) {
    final controller = TextEditingController(text: oldValue);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Edit $key"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter $key",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await updateField(key, controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  /// 🔥 TILE
  Widget tile(IconData icon, String label, String value, String key,
      {bool editable = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(label),
        subtitle: Text(value.isEmpty ? "Not added" : value),
        trailing: editable ? const Icon(Icons.edit) : null,
        onTap: editable ? () => editField(key, value) : null,
      ),
    );
  }

  String formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return "Not available";
    try {
      final date = DateTime.parse(iso);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "Invalid date";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
            child: Text("Error: $errorMessage",
                style: const TextStyle(color: Colors.red))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          /// 🔥 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
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
                /// ✅ FIXED STACK
                SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.home, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  userData['name']?.toString() ?? "User",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),

                Text(
                  userData['email']?.toString() ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 6),

                Text(
                  "Member Since: ${formatDate(userData['createdAt']?.toString())}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          /// 🔥 DETAILS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  tile(Icons.person, "Name", userData['name']?.toString() ?? "",
                      "name"),
                  tile(Icons.email, "Email",
                      userData['email']?.toString() ?? "", "email",
                      editable: false),
                  tile(Icons.phone, "Phone",
                      userData['phone']?.toString() ?? "", "phone"),
                  tile(Icons.home, "Address",
                      userData['address']?.toString() ?? "", "address"),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
