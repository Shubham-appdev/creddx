import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'onboarding_screen.dart';
import '../main_navigation.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // System chrome configuration for immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    
    // Fade animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // Start animation
    _fadeController.forward();
    
    // Navigate after delay (Reduced to 2 seconds)
    Timer(const Duration(seconds: 2), () async {
      if (mounted) {
        try {
          // Check if user is already logged in
          final isLoggedIn = await AuthService.isLoggedIn();
          
          if (isLoggedIn) {
            // User is logged in, go to main navigation with bottom nav bar
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => 
                    const MainNavigation(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(0.0, 1.0), end: Offset.zero),
                    ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          } else {
            // User is not logged in, go to onboarding
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => 
                    const OnboardingScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(0.0, 1.0), end: Offset.zero),
                    ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          }
        } catch (e) {
          debugPrint('Navigation error: $e');
          // Fallback to onboarding if there's an error
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // Logo in center
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Creddxlogo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Version number at bottom
              const Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'v.1.1.1',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.white54,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
