import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mycityconnect/screen/home_screen.dart';
import 'package:mycityconnect/screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> fadeAnimation;
  late final Animation<double> scaleAnimation;
  late final Animation<double> slideAnimation;

  bool _showNextScreen = false;

  @override
  void initState() {
    super.initState();

    // 🔥 Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    scaleAnimation = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // ⏱️ 3 sec delay ke baad next screen show
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showNextScreen = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// 🔥 Jab tak delay complete nahi hua → Splash UI dikhao
    if (!_showNextScreen) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3A6DD8), Color(0xFF1E4DB7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, slideAnimation.value),
                    child: Transform.scale(
                      scale: scaleAnimation.value,
                      child: child,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo_transparent.png',
                    width: 150,
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "MyCityConnect",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Explore your city services",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    /// 🔥 Delay ke baad → Firebase Stream check
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Logged in
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // ❌ Not logged in
        return const LoginScreen();
      },
    );
  }
}
