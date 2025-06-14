import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/biometric_auth_service.dart';
import '../utils/theme.dart';

/// Screen for biometric enrollment
class BiometricEnrollmentScreen extends StatefulWidget {
  const BiometricEnrollmentScreen({super.key});

  @override
  State<BiometricEnrollmentScreen> createState() => _BiometricEnrollmentScreenState();
}

class _BiometricEnrollmentScreenState extends State<BiometricEnrollmentScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isEnrolling = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleEnrollment() async {
    setState(() {
      _isEnrolling = true;
      _statusMessage = 'Initializing biometric enrollment...';
    });

    final biometricService = context.read<BiometricAuthService>();
    
    // Check availability
    final isAvailable = await biometricService.checkBiometricAvailability();
    if (!isAvailable) {
      setState(() {
        _statusMessage = 'Biometric authentication is not available on this device';
        _isEnrolling = false;
      });
      return;
    }

    // Enable biometric
    setState(() {
      _statusMessage = 'Enabling biometric authentication...';
    });
    
    final enabled = await biometricService.enableBiometric();
    if (!enabled) {
      setState(() {
        _statusMessage = 'Failed to enable biometric authentication';
        _isEnrolling = false;
      });
      return;
    }

    // Enroll biometric
    setState(() {
      _statusMessage = 'Completing enrollment...';
    });
    
    final enrolled = await biometricService.enrollBiometric();
    if (enrolled) {
      setState(() {
        _statusMessage = 'Enrollment successful!';
      });
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() {
        _statusMessage = 'Enrollment failed. Please try again.';
        _isEnrolling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final biometricService = context.watch<BiometricAuthService>();
    final biometricType = biometricService.getBiometricTypeName();
    final biometricIcon = biometricService.getBiometricIcon();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Biometric Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Animated biometric icon
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity( 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        biometricIcon,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              
              // Title
              Text(
                'Enable $biometricType',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Use $biometricType for quick and secure access to your therapy sessions',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textColor.withOpacity( 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Benefits list
              _buildBenefitItem(
                Icons.lock_outline,
                'Enhanced Security',
                'Your biometric data never leaves your device',
              ),
              _buildBenefitItem(
                Icons.flash_on,
                'Quick Access',
                'Login instantly without typing passwords',
              ),
              _buildBenefitItem(
                Icons.privacy_tip_outlined,
                'Privacy Protected',
                'HIPAA-compliant security measures',
              ),
              
              const SizedBox(height: 40),
              
              // Status message
              if (_statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _statusMessage.contains('failed') 
                        ? Colors.red.withOpacity( 0.1)
                        : AppTheme.primaryColor.withOpacity( 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.contains('failed')
                          ? Colors.red
                          : AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Enable button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isEnrolling ? null : _handleEnrollment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: _isEnrolling ? 0 : 4,
                  ),
                  child: _isEnrolling
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Enable $biometricType',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Skip button
              TextButton(
                onPressed: _isEnrolling 
                    ? null 
                    : () => Navigator.of(context).pop(false),
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: AppTheme.textColor.withOpacity( 0.6),
                    fontSize: 16,
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

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity( 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.textColor.withOpacity( 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
