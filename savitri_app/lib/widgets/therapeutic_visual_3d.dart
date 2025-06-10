import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/constants.dart';
import 'breathing_guide.dart';
import 'emotion_indicator.dart';

class TherapeuticVisual3D extends StatefulWidget {
  final EmotionalState emotionalState;
  final bool showBreathingGuide;
  final double audioLevel;
  final VoidCallback? onTap;

  const TherapeuticVisual3D({
    super.key,
    required this.emotionalState,
    this.showBreathingGuide = false,
    this.audioLevel = 0.0,
    this.onTap,
  });

  @override
  State<TherapeuticVisual3D> createState() => _TherapeuticVisual3DState();
}

class _TherapeuticVisual3DState extends State<TherapeuticVisual3D>
    with TickerProviderStateMixin {
  late AnimationController _colorAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _pulseAnimation;
  WebViewController? _webViewController;
  bool _isWebViewReady = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeWebView();
  }

  void _initializeAnimations() {
    // Color transition animation
    _colorAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Pulse animation for audio visualization
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    // Initialize color animation with initial color
    final Color initialColor = _getColorForState();
    _colorAnimation = ColorTween(
      begin: initialColor,
      end: initialColor,
    ).animate(CurvedAnimation(
      parent: _colorAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isWebViewReady = true;
            });
            _updateVisualization();
          },
        ),
      )
      ..loadHtmlString(_get3DVisualizationHtml());
  }

  void _updateColorAnimation() {
    final Color targetColor = _getColorForState();
    final Color currentColor = _colorAnimation?.value ?? targetColor;

    _colorAnimation = ColorTween(
      begin: currentColor,
      end: targetColor,
    ).animate(CurvedAnimation(
      parent: _colorAnimationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimationController.forward(from: 0);
  }

  Color _getColorForState() {
    switch (widget.emotionalState) {
      case EmotionalState.calm:
        return AppColors.calm;
      case EmotionalState.neutral:
        return AppColors.neutral;
      case EmotionalState.distressed:
        return AppColors.anxious; // Assuming anxious color is the one for distressed
      case EmotionalState.anxious:
        return AppColors.anxious;
      case EmotionalState.sad:
        return AppColors.sad;
      case EmotionalState.angry:
        return AppColors.angry;
      case EmotionalState.happy:
        return AppColors.happy;
    }
  }

  void _updateVisualization() {
    if (!_isWebViewReady || _webViewController == null) return;

    final color = _getColorForState();
    final hexColor = '#${color.value.toRadixString(16).substring(2)}';
    
    _webViewController!.runJavaScript('''
      if (window.updateVisualization) {
        window.updateVisualization({
          color: '$hexColor',
          audioLevel: ${widget.audioLevel},
          emotionalState: '${widget.emotionalState.toString().split('.').last}'
        });
      }
    ''');
  }

  String _get3DVisualizationHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      margin: 0;
      padding: 0;
      overflow: hidden;
      background-color: transparent;
    }
    #canvas {
      width: 100%;
      height: 100%;
      display: block;
    }
  </style>
</head>
<body>
  <canvas id="canvas"></canvas>
  <script>
    // Simple 3D sphere visualization using Canvas
    const canvas = document.getElementById('canvas');
    const ctx = canvas.getContext('2d');
    
    let currentColor = '#7CB8CF';
    let audioLevel = 0;
    let time = 0;
    
    function resizeCanvas() {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    }
    
    window.addEventListener('resize', resizeCanvas);
    resizeCanvas();
    
    function hexToRgb(hex) {
      const result = /^#?([a-f\\d]{2})([a-f\\d]{2})([a-f\\d]{2})\$/i.exec(hex);
      return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
      } : null;
    }
    
    function draw() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      
      const centerX = canvas.width / 2;
      const centerY = canvas.height / 2;
      const baseRadius = Math.min(canvas.width, canvas.height) * 0.3;
      const radius = baseRadius + (audioLevel * 50) + Math.sin(time * 0.02) * 10;
      
      // Create gradient
      const gradient = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, radius);
      const rgb = hexToRgb(currentColor);
      if (rgb) {
        gradient.addColorStop(0, `rgba(\${rgb.r}, \${rgb.g}, \${rgb.b}, 0.8)`);
        gradient.addColorStop(0.5, `rgba(\${rgb.r}, \${rgb.g}, \${rgb.b}, 0.4)`);
        gradient.addColorStop(1, `rgba(\${rgb.r}, \${rgb.g}, \${rgb.b}, 0.1)`);
      }
      
      // Draw sphere
      ctx.beginPath();
      ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
      ctx.fillStyle = gradient;
      ctx.fill();
      
      // Draw audio reactive rings
      for (let i = 0; i < 3; i++) {
        ctx.beginPath();
        ctx.arc(centerX, centerY, radius + (i * 20) + (audioLevel * 10), 0, Math.PI * 2);
        ctx.strokeStyle = `rgba(\${rgb.r}, \${rgb.g}, \${rgb.b}, \${0.3 - i * 0.1})`;
        ctx.lineWidth = 2;
        ctx.stroke();
      }
      
      time++;
      requestAnimationFrame(draw);
    }
    
    window.updateVisualization = function(data) {
      if (data.color) currentColor = data.color;
      if (data.audioLevel !== undefined) audioLevel = data.audioLevel;
    };
    
    draw();
  </script>
</body>
</html>
    ''';
  }

  @override
  void didUpdateWidget(TherapeuticVisual3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emotionalState != widget.emotionalState) {
      _updateColorAnimation();
      _updateVisualization();
    }
    if (oldWidget.audioLevel != widget.audioLevel) {
      _updateVisualization();
    }
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Background Color
          AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _colorAnimation.value,
                ),
              );
            },
          ),

          // 3D Visualization WebView
          Opacity(
            opacity: _isWebViewReady ? 1.0 : 0.0,
            child: WebViewWidget(controller: _webViewController!),
          ),

          // Pulsing overlay for audio visualization
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(widget.audioLevel * 0.1),
              ),
            ),
          ),

          // Breathing Guide Overlay
          if (widget.showBreathingGuide)
            const BreathingGuide(),
          
          // Emotion Indicator (as a fallback or additional info)
          Positioned(
            bottom: 20,
            child: Animate(
              effects: [FadeEffect(duration: 750.ms)],
              child: EmotionIndicator(state: widget.emotionalState),
            ),
          ),
        ],
      ),
    );
  }
}
