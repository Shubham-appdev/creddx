import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResetPasswordSuccessfulScreen extends StatefulWidget {
  const ResetPasswordSuccessfulScreen({super.key});

  @override
  State<ResetPasswordSuccessfulScreen> createState() => _ResetPasswordSuccessfulScreenState();
}

class _ResetPasswordSuccessfulScreenState extends State<ResetPasswordSuccessfulScreen> {
  @override
  void initState() {
    super.initState();
    
    // System chrome configuration
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        title: const SizedBox.shrink(), // Remove center title
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Success Icon at top
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF84BD00).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/successtick.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF84BD00),
                    size: 40,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title at top
              const Text(
                'Reset password successful',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              const Text(
                'Successfully changed password. you can enter the main page',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6C7278),
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Go to Home Button at bottom
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF90C128),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to home screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF90C128),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Go to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
