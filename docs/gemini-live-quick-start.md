# Quick Start Guide: Enhanced Gemini Live Voice Mode

## Prerequisites

1. **API Key**: Obtain a Gemini API key with access to `gemini-2.0-flash-exp` model
2. **Environment**: Node.js 18+ for web, Flutter 3.0+ for mobile
3. **Permissions**: Microphone access must be granted by users

## Web Implementation

### 1. Install Dependencies

```bash
cd live-audio
npm install
```

### 2. Set Environment Variables

Create `.env.local`:
```bash
VITE_GEMINI_API_KEY=your-gemini-api-key
```

### 3. Update Your HTML

Replace the existing component in `therapy.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Ashray Therapy Session</title>
  <script type="module">
    import { EnhancedTherapeuticVoiceSession } from './enhanced-therapeutic-voice-session.js';
    
    // Initialize session
    const session = new EnhancedTherapeuticVoiceSession({
      apiKey: import.meta.env.VITE_GEMINI_API_KEY,
      patientId: 'demo-patient',
      therapyProtocol: 'CBT',
      enableCrisisDetection: true,
      enableEmotionAnalysis: true
    });
    
    document.body.appendChild(session);
    
    // Handle events
    session.addEventListener('crisis-detected', (e) => {
      console.log('Crisis detected:', e.detail);
      // Show crisis resources
    });
    
    session.addEventListener('activate-breathing-guide', () => {
      console.log('Breathing exercise activated');
      // Show breathing UI
    });
  </script>
</head>
<body>
  <!-- Session component will be inserted here -->
</body>
</html>
```

### 4. Run Development Server

```bash
npm run dev
```

Visit `http://localhost:5173/therapy.html`

## Flutter Implementation

### 1. Update Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  google_generative_ai: ^0.2.0
  web_socket_channel: ^2.4.0
  record: ^5.0.0
  just_audio: ^0.9.35
  permission_handler: ^11.0.0
```

### 2. Add Service to Your App

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'services/enhanced_therapeutic_voice_service.dart';

class TherapyScreen extends StatefulWidget {
  @override
  _TherapyScreenState createState() => _TherapyScreenState();
}

class _TherapyScreenState extends State<TherapyScreen> {
  late EnhancedTherapeuticVoiceService _voiceService;
  bool _isRecording = false;
  
  @override
  void initState() {
    super.initState();
    _initializeService();
  }
  
  Future<void> _initializeService() async {
    _voiceService = EnhancedTherapeuticVoiceService(
      apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
      patientId: 'demo-patient',
    );
    
    await _voiceService.initialize();
    
    // Listen for events
    _voiceService.events.listen((event) {
      if (event.type == 'crisisDetected') {
        _showCrisisAlert(event.data);
      }
    });
    
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Therapy Session')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_voiceService.status),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              iconSize: 64,
              onPressed: _toggleRecording,
              color: _isRecording ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _voiceService.stopRecording();
    } else {
      await _voiceService.startRecording();
    }
    setState(() {
      _isRecording = !_isRecording;
    });
  }
  
  void _showCrisisAlert(Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Crisis Support Available'),
        content: Text('988 Lifeline is available 24/7'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

### 3. Run with API Key

```bash
flutter run --dart-define=GEMINI_API_KEY=your-api-key
```

## Testing the Implementation

### Basic Flow Test

1. **Start Session**: Click microphone button
2. **Speak**: "I'm feeling really anxious today"
3. **Expected**: 
   - Emotion detection shows "anxious"
   - Therapeutic response with coping strategies
   - Possible breathing exercise activation

### Crisis Detection Test

1. **Speak**: "I don't want to be here anymore"
2. **Expected**:
   - Crisis alert appears
   - 988 resource information shown
   - Supportive response from AI

### Therapeutic Technique Test

1. **Speak**: "I can't stop worrying about everything"
2. **Expected**:
   - Anxiety detected
   - CBT thought challenging offered
   - Grounding exercise suggested

## Common Issues & Solutions

### Issue: No Audio Response
- Check API key is valid
- Ensure microphone permissions granted
- Verify WebSocket connection in console

### Issue: High Latency
- Check internet connection speed
- Reduce audio quality if needed (change to 16kHz)
- Use closer Gemini API endpoint

### Issue: Crisis Detection Too Sensitive
- Adjust thresholds in `CrisisDetector`
- Review crisis indicators list
- Test with various phrases

## Production Checklist

- [ ] Replace demo patient IDs with real authentication
- [ ] Implement proper error handling UI
- [ ] Add session recording consent
- [ ] Set up monitoring and analytics
- [ ] Configure crisis alert notifications
- [ ] Test on all target devices
- [ ] Implement offline fallback
- [ ] Add loading states for all async operations

## Next Steps

1. **Customize UI**: Modify the components to match your design
2. **Add Features**: Implement breathing guides, mood tracking
3. **Integrate Backend**: Connect to your session storage
4. **Clinical Review**: Have mental health professionals test
5. **Security Audit**: Ensure HIPAA compliance

For more details, see the [full documentation](./gemini-live-enhancement-summary.md).
