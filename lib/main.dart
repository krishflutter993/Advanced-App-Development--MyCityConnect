import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mycityconnect/screen/Splash_Screen.dart';
import 'package:mycityconnect/screen/home_screen.dart';
import 'package:mycityconnect/screen/login_screen.dart';
import 'package:mycityconnect/screen/profile_screen.dart';
import 'package:mycityconnect/screen/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyCityConnectApp());
}

class MyCityConnectApp extends StatelessWidget {
  const MyCityConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyCityConnectss',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
