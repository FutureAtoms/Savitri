import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/therapeutic_visual_3d.dart';
import '../widgets/emotion_indicator.dart';
import '../widgets/crisis_banner.dart';
import '../utils/constants.dart';

class TherapyScreen extends StatefulWidget {
  const TherapyScreen({super.key});

  @override
  State<TherapyScreen> createState() => _TherapyScreenState();
}

class _TherapyScreenState extends State<TherapyScreen>
    with TickerProviderStateMixin {
  // Session state
  bool _isSessionActive = false;
  final bool _isCrisis = false;
  final EmotionalState _currentEmotionalState = EmotionalState.neutral;
  final double _audioLevel = 0.0;
  bool _showBreathingGuide = false;
  
  // Animation controllers
  late AnimationController _micButtonAnimationController;
  late Animation<double> _micButtonAnimation;
  
  // Session info
  Duration _sessionDuration = Duration.zero;
  DateTime? _sessionStartTime;
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _micButtonAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _micButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _micButtonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _toggleSession() {
    setState(() {
      _isSessionActive = !_isSessionActive;
      
      if (_isSessionActive) {
        _sessionStartTime = DateTime.now();
        _startSession();
        _micButtonAnimationController.repeat(reverse: true);
      } else {
        _endSession();
        _micButtonAnimationController.stop();
        _micButtonAnimationController.reset();
      }
    });
  }

  void _startSession() {
    // TODO: Initialize voice recording and Gemini connection
    // TODO: Start WebSocket connection for real-time updates
    
    // Start session timer
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isSessionActive && mounted) {
        setState(() {
          _sessionDuration = DateTime.now().difference(_sessionStartTime!);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _endSession() {
    // Cancel the timer
    _sessionTimer?.cancel();
    _sessionTimer = null;
    
    // TODO: Stop voice recording
    // TODO: Close WebSocket connection
    // TODO: Save session data
    
    // Only update state if widget is still mounted
    if (mounted) {
      setState(() {
        _sessionDuration = Duration.zero;
        _sessionStartTime = null;
      });
    }
  }

  void _toggleBreathingGuide() {
    setState(() {
      _showBreathingGuide = !_showBreathingGuide;
    });
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _viewSessionHistory() {
    Navigator.pushNamed(context, '/history');
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  void dispose() {
    // Cancel timer if active
    _sessionTimer?.cancel();
    _sessionTimer = null;
    
    // Stop the session without setState since we're disposing
    if (_isSessionActive) {
      _isSessionActive = false;
      _sessionDuration = Duration.zero;
      _sessionStartTime = null;
      // TODO: Stop voice recording
      // TODO: Close WebSocket connection
      // TODO: Save session data
    }
    _micButtonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // App bar
                _buildAppBar(),
                
                // 3D Visualization
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TherapeuticVisual3D(
                      emotionalState: _currentEmotionalState,
                      showBreathingGuide: _showBreathingGuide,
                      audioLevel: _audioLevel,
                      onTap: _toggleBreathingGuide,
                    ).animate().fadeIn(duration: 1.seconds),
                  ),
                ),
                
                // Session info
                if (_isSessionActive)
                  _buildSessionInfo()
                      .animate()
                      .fadeIn()
                      .slideY(begin: 0.5, end: 0),
                
                // Control panel
                _buildControlPanel(),
              ],
            ),
            
            // Crisis banner (always on top)
            CrisisBanner(isCrisis: _isCrisis),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App title
          Text(
            'Therapy Session',
            style: AppTextStyles.headline2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          
          // Action buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: _viewSessionHistory,
                tooltip: 'Session History',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _openSettings,
                tooltip: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoItem(
            icon: Icons.timer,
            label: 'Duration',
            value: _formatDuration(_sessionDuration),
          ),
          Container(
            height: 40,
            width: 1,
            color: AppColors.textLight.withOpacity(0.3),
          ),
          _buildInfoItem(
            icon: Icons.mic,
            label: 'Status',
            value: 'Recording',
            valueColor: AppColors.error,
          ),
          Container(
            height: 40,
            width: 1,
            color: AppColors.textLight.withOpacity(0.3),
          ),
          _buildInfoItem(
            icon: Icons.mood,
            label: 'Mood',
            value: _currentEmotionalState.toString().split('.').last,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Quick actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAction(
                icon: Icons.air,
                label: 'Breathing',
                onTap: _toggleBreathingGuide,
                isActive: _showBreathingGuide,
              ),
              _buildQuickAction(
                icon: Icons.psychology,
                label: 'Exercises',
                onTap: () {
                  // TODO: Navigate to exercises
                },
              ),
              _buildQuickAction(
                icon: Icons.assessment,
                label: 'Assessment',
                onTap: () {
                  // TODO: Navigate to assessment
                },
              ),
              _buildQuickAction(
                icon: Icons.help_outline,
                label: 'Resources',
                onTap: () {
                  // TODO: Navigate to resources
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Microphone button
          Center(
            child: AnimatedBuilder(
              animation: _micButtonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isSessionActive ? _micButtonAnimation.value : 1.0,
                  child: GestureDetector(
                    onTap: _toggleSession,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _isSessionActive
                              ? [AppColors.error, AppColors.error.withOpacity(0.8)]
                              : [AppColors.primary, AppColors.primaryDark],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isSessionActive ? AppColors.error : AppColors.primary)
                                .withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isSessionActive ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            _isSessionActive ? 'Tap to end session' : 'Tap to start session',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.textLight.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
