import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String address;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });
}

class UserProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: FirebaseAuth.instance.app,
    databaseURL: "https://myapp-b8bfe-default-rtdb.asia-southeast1.firebasedatabase.app",
  );

  Future<UserProfile?> fetchCurrentUserProfile() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      final DatabaseReference ref = _database.ref().child('users').child(user.uid);
      final DataSnapshot snapshot = await ref.get().timeout(const Duration(seconds: 5));

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return UserProfile(
          name: data['name']?.toString() ?? '',
          email: data['email']?.toString() ?? user.email ?? '',
          phone: data['phone']?.toString() ?? '',
          address: data['address']?.toString() ?? '',
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }
}
