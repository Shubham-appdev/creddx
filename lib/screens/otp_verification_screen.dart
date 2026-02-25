import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main_navigation.dart';
import '../services/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _focusedIndex = 0;
  bool _isLoading = false;
  bool _isResending = false;
  
  // TODO: This should be passed as a parameter from the previous screen
  // Currently hardcoded to 'user@example.com' which will cause issues
  static const String _email = 'user@example.com';

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {
            _focusedIndex = i;
          });
        }
      });
    }
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp {
    return _controllers.map((controller) => controller.text).join();
  }

  bool get _isOtpComplete {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete) {
      _showError('Please enter all 6 digits');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.loginWithOtp(_email, _otp);

      if (result['success']) {
        _showSuccess('OTP verified successfully!');
        // Navigate to main navigation with bottom nav bar after successful OTP verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else {
        _showError(result['message']);
      }
    } catch (e) {
      _showError('An error occurred during OTP verification');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
    });

    try {
      final result = await AuthService.resendOtp(_email);

      if (result['success']) {
        _showSuccess('OTP resent successfully!');
        // Clear OTP fields
        for (var controller in _controllers) {
          controller.clear();
        }
        // Focus on first field
        _focusNodes[0].requestFocus();
      } else {
        _showError(result['message']);
      }
    } catch (e) {
      _showError('Failed to resend OTP');
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE74C3C),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF84BD00),
        duration: const Duration(seconds: 2),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              'assets/images/Creddxlogo.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Verification Code',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We have sent the 6-digit verification code to\nyour email address',
                style: TextStyle(fontSize: 16, color: Color(0xFF6C7278)),
              ),
              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpBox(index)),
              ),
              
              const SizedBox(height: 32),
              
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Didn't receive the code?",
                      style: TextStyle(color: Color(0xFF6C7278), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _isResending ? null : _resendOtp,
                      child: Text(
                        _isResending ? 'Sending...' : 'Resend Code',
                        style: TextStyle(
                          color: _isResending ? Colors.grey : const Color(0xFF84BD00),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading ? Colors.grey : const Color(0xFF84BD00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Verify', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    bool isFocused = _focusedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: isFocused ? const Color(0xFF1E1E20) : const Color(0xFF161618),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? const Color(0xFF84BD00) : Colors.white.withValues(alpha: 0.1),
          width: isFocused ? 2 : 1,
        ),
        boxShadow: isFocused ? [
          BoxShadow(
            color: const Color(0xFF84BD00).withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ] : [],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
