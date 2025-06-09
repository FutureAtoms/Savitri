import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/biometric_auth_service.dart';
import '../utils/theme.dart';

/// Widget for biometric login button
class BiometricLoginButton extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback? onError;
  final String? customReason;

  const BiometricLoginButton({
    Key? key,
    required this.onSuccess,
    this.onError,
    this.customReason,
  }) : super(key: key);

  @override
  State<BiometricLoginButton> createState() => _BiometricLoginButtonState();
}

class _BiometricLoginButtonState extends State<BiometricLoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleBiometricAuth() async {
    final biometricService = context.read<BiometricAuthService>();
    
    // Check if biometric is available and enrolled
    if (!biometricService.isAvailable || 
        !biometricService.isEnabled || 
        !biometricService.isEnrolled) {
      _showErrorSnackBar('Biometric authentication not set up');
      widget.onError?.call();
      return;
    }

    setState(() {
      _isAuthenticating = true;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    try {
      final authenticated = await biometricService.authenticate(
        reason: widget.customReason ?? 
                'Please authenticate to access your therapy session',
      );

      if (authenticated) {
        widget.onSuccess();
      } else {
        _showErrorSnackBar('Authentication failed');
        widget.onError?.call();
      }
    } catch (e) {
      _showErrorSnackBar('Authentication error occurred');
      widget.onError?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final biometricService = context.watch<BiometricAuthService>();
    
    // Don't show button if biometric is not available or not enrolled
    if (!biometricService.isAvailable || 
        !biometricService.isEnabled || 
        !biometricService.isEnrolled) {
      return const SizedBox.shrink();
    }

    final biometricIcon = biometricService.getBiometricIcon();
    final biometricType = biometricService.getBiometricTypeName();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                // Divider with "OR"
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppTheme.textColor.withOpacity(0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: AppTheme.textColor.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppTheme.textColor.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Biometric button
                InkWell(
                  onTap: _isAuthenticating ? null : _handleBiometricAuth,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: _isAuthenticating
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                biometricIcon,
                                color: AppTheme.primaryColor,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Login with $biometricType',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Dialog for biometric settings
class BiometricSettingsDialog extends StatelessWidget {
  const BiometricSettingsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final biometricService = context.watch<BiometricAuthService>();
    final biometricType = biometricService.getBiometricTypeName();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        '$biometricType Settings',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              biometricService.getBiometricIcon(),
              color: AppTheme.primaryColor,
            ),
            title: Text('Enable $biometricType'),
            subtitle: Text(
              biometricService.isEnabled 
                  ? 'Currently enabled' 
                  : 'Currently disabled',
            ),
            trailing: Switch(
              value: biometricService.isEnabled,
              onChanged: (value) async {
                if (value) {
                  await biometricService.enableBiometric();
                } else {
                  await biometricService.disableBiometric();
                }
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),
          if (biometricService.isEnabled && !biometricService.isEnrolled)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final enrolled = await Navigator.pushNamed(
                    context,
                    '/biometric-enrollment',
                  );
                  if (enrolled == true) {
                    // Show success message
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Complete Setup'),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
