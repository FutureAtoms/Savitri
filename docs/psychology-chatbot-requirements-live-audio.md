# Comprehensive Requirements: Psychology Chatbot Built on Live-Audio Foundation

## Executive Summary

This document outlines the comprehensive requirements for transforming the existing `live-audio` directory implementation into a clinical-grade psychology chatbot. The project leverages the Gemini 2.5 Flash Preview Native Audio Dialog model with real-time voice processing, 3D visualizations, and WebAudio API integration as the foundation for a revolutionary mental health support platform.

## Technical Foundation: Live-Audio Directory

### Existing Assets to Leverage

The `live-audio` directory provides a robust foundation with:

1. **Real-time Voice Processing** (`index.tsx`)
   - Gemini AI integration with native audio dialog
   - 16kHz input / 24kHz output audio contexts
   - Script processor for real-time PCM chunk processing
   - WebRTC-based media stream capture

2. **3D Visualization System** (`visual-3d.ts`)
   - Three.js-based emotional feedback
   - Audio-reactive sphere with shader animations
   - Real-time audio analysis integration
   - Bloom and post-processing effects

3. **Audio Analysis** (`analyser.ts`)
   - FFT-based frequency analysis
   - Real-time data array updates
   - Modular analyser node architecture

4. **Utility Functions** (`utils.ts`)
   - PCM audio encoding/decoding
   - Base64 conversion for Gemini API
   - Audio buffer manipulation

## Architecture Overview

```
Psychology Chatbot Architecture
├── Audio Front-End (live-audio/)
│   ├── index.tsx [ENHANCE]
│   │   ├── Add clinical audio processing
│   │   ├── Integrate emotion detection
│   │   └── Implement crisis detection
│   ├── visual-3d.ts [ENHANCE]
│   │   ├── Add therapeutic visualizations
│   │   ├── Breathing exercise guides
│   │   └── Progress indicators
│   ├── analyser.ts [EXTEND]
│   │   ├── Clinical feature extraction
│   │   └── Voice biomarker analysis
│   └── utils.ts [EXTEND]
│       ├── HIPAA-compliant encryption
│       └── Clinical data formatting
│
├── Clinical Intelligence Layer [NEW]
│   ├── therapeutic-engine.ts
│   ├── emotion-analyzer.ts
│   ├── crisis-detector.ts
│   └── session-manager.ts
│
├── Data Persistence Layer [NEW]
│   ├── graphiti-integration.ts
│   ├── cag-context-manager.ts
│   └── patient-history.ts
│
└── Compliance Layer [NEW]
    ├── hipaa-compliance.ts
    ├── audit-logger.ts
    └── consent-manager.ts
```

## Detailed Requirements

### 1. Enhanced Audio Processing (Modifications to `index.tsx`)

#### 1.1 Clinical-Grade Audio Capture

**Current State:**
```typescript
private inputAudioContext = new AudioContext({sampleRate: 16000});
```

**Required Enhancement:**
```typescript
private inputAudioContext = new AudioContext({
  sampleRate: 48000, // Higher quality for emotion detection
  latencyHint: 'interactive',
  numberOfChannels: 1
});

// Add clinical processors
private emotionAnalyzer: EmotionAnalyzer;
private voiceQualityMonitor: VoiceQualityMonitor;
private crisisDetector: CrisisDetector;
```

#### 1.2 Therapeutic System Configuration

**Modify `initSession()` to include:**
```typescript
this.session = await this.client.live.connect({
  model: 'gemini-2.5-flash-preview-native-audio-dialog',
  systemInstruction: THERAPEUTIC_SYSTEM_PROMPT, // New therapeutic prompt
  callbacks: {
    onmessage: async (message) => {
      await this.handleTherapeuticResponse(message); // Enhanced handler
    }
  },
  config: {
    responseModalities: [Modality.AUDIO],
    speechConfig: {
      voiceConfig: {
        prebuiltVoiceConfig: {
          voiceName: 'Orus' // Maintain calm therapeutic voice
        }
      }
    },
    // Add therapeutic parameters
    generationConfig: {
      temperature: 0.7,
      topP: 0.9,
      maxOutputTokens: 500
    }
  }
});
```

#### 1.3 Real-time Clinical Analysis

**Enhance `scriptProcessorNode.onaudioprocess`:**
```typescript
this.scriptProcessorNode.onaudioprocess = async (audioProcessingEvent) => {
  if (!this.isRecording) return;

  const inputBuffer = audioProcessingEvent.inputBuffer;
  const pcmData = inputBuffer.getChannelData(0);

  // Clinical analysis pipeline
  const emotions = await this.emotionAnalyzer.analyze(pcmData);
  const voiceQuality = await this.voiceQualityMonitor.assess(pcmData);
  const crisisIndicators = await this.crisisDetector.detect(pcmData, emotions);

  // Update UI with clinical insights
  this.updateClinicalUI(emotions, crisisIndicators);

  // Enhanced blob with metadata
  const clinicalBlob = this.createClinicalBlob(pcmData, {
    emotions,
    voiceQuality,
    timestamp: Date.now()
  });

  this.session.sendRealtimeInput({media: clinicalBlob});
  
  // Compliance logging
  await this.complianceLogger.logInteraction({
    type: 'voice_input',
    encrypted: true,
    emotionalState: emotions
  });
};
```

### 2. Therapeutic Visualization System (Enhancements to `visual-3d.ts`)

#### 2.1 Emotion-Responsive Visuals

**Add to `GdmLiveAudioVisuals3D` class:**
```typescript
// Therapeutic visualization properties
private emotionColorMap = {
  neutral: 0x4a5568,
  happy: 0x48bb78,
  sad: 0x5a67d8,
  anxious: 0x9f7aea,
  angry: 0xed8936,
  fearful: 0x38b2ac
};

private breathingGuide: BreathingVisualization;
private progressTracker: ProgressVisualization;
private calmingEffects: CalmingEffectSystem;

// Modify animation loop
private animation() {
  requestAnimationFrame(() => this.animation());
  
  // Existing analysis
  this.inputAnalyser.update();
  this.outputAnalyser.update();
  
  // Therapeutic modifications
  if (this.currentEmotionalState) {
    this.adaptVisualsToEmotion(this.currentEmotionalState);
    
    if (this.currentEmotionalState.anxiety > 0.7) {
      this.activateBreathingGuide();
    }
  }
  
  // Rest of animation...
}
```

#### 2.2 Breathing Exercise Visualization

**New component in `visual-3d.ts`:**
```typescript
class BreathingVisualization {
  private breathingSphere: THREE.Mesh;
  private breathingRing: THREE.Mesh;
  
  constructor(scene: THREE.Scene) {
    // Create breathing guide elements
    this.createBreathingGuide(scene);
  }
  
  activate478Pattern() {
    // 4-7-8 breathing visualization
    this.animateInhale(4000)
      .then(() => this.animateHold(7000))
      .then(() => this.animateExhale(8000));
  }
}
```

### 3. Clinical Audio Analysis (Extensions to `analyser.ts`)

#### 3.1 Enhanced Analyser Class

**Extend current `Analyser` class:**
```typescript
export class ClinicalAnalyser extends Analyser {
  private emotionExtractor: EmotionFeatureExtractor;
  private voiceBiomarkers: VoiceBiomarkerAnalyzer;
  
  constructor(node: AudioNode) {
    super(node);
    this.analyser.fftSize = 2048; // Higher resolution for clinical analysis
    this.initializeClinicalAnalysis();
  }
  
  async getClinicalFeatures(): Promise<ClinicalFeatures> {
    const spectral = this.getSpectralFeatures();
    const temporal = this.getTemporalFeatures();
    const prosodic = this.getProsodicFeatures();
    
    return {
      emotion: await this.emotionExtractor.extract(spectral, prosodic),
      depression: this.detectDepressionMarkers(temporal, prosodic),
      anxiety: this.detectAnxietyMarkers(spectral, temporal),
      stress: this.calculateStressLevel(spectral)
    };
  }
}
```

### 4. Secure Data Handling (Enhancements to `utils.ts`)

#### 4.1 HIPAA-Compliant Audio Processing

**Add to existing `utils.ts`:**
```typescript
import * as crypto from 'crypto-js';

// Encrypt audio data before transmission
export function encryptAudioData(
  data: Float32Array,
  patientId: string
): EncryptedBlob {
  const base64Audio = encode(convertToInt16(data));
  
  const encrypted = crypto.AES.encrypt(base64Audio, 
    derivePatientKey(patientId), {
    mode: crypto.mode.GCM,
    padding: crypto.pad.Pkcs7
  });
  
  return {
    data: encrypted.toString(),
    mimeType: 'audio/encrypted-pcm;rate=16000',
    metadata: {
      encrypted: true,
      algorithm: 'AES-256-GCM',
      timestamp: Date.now()
    }
  };
}

// Create clinical blob with metadata
export function createClinicalBlob(
  data: Float32Array,
  clinical: ClinicalMetadata
): ClinicalBlob {
  const encrypted = encryptAudioData(data, clinical.patientId);
  
  return {
    ...encrypted,
    clinical: {
      emotions: clinical.emotions,
      voiceQuality: clinical.voiceQuality,
      sessionId: clinical.sessionId
    }
  };
}
```

### 5. New Clinical Components

#### 5.1 Therapeutic Engine (`therapeutic-engine.ts`)

```typescript
export class TherapeuticEngine {
  private cagContext: CAGTherapeuticContext;
  private graphiti: GraphitiClient;
  private protocolSelector: ProtocolSelector;
  
  constructor(audioContext: AudioContext) {
    this.initializeTherapeuticProtocols();
  }
  
  async processTherapeuticInput(
    audioBlob: Blob,
    emotions: EmotionalState,
    sessionContext: SessionContext
  ): Promise<TherapeuticResponse> {
    // Select appropriate therapeutic approach
    const protocol = this.protocolSelector.select(emotions, sessionContext);
    
    // Generate contextual response
    const response = await this.generateResponse({
      protocol,
      emotions,
      history: await this.graphiti.getRecentInteractions()
    });
    
    // Track in temporal graph
    await this.graphiti.recordInteraction({
      input: audioBlob,
      emotions,
      protocol,
      response
    });
    
    return response;
  }
}
```

#### 5.2 Crisis Detection System (`crisis-detector.ts`)

```typescript
export class CrisisDetector {
  private nlpEngine: ClinicalNLPEngine;
  private audioDistressAnalyzer: AudioDistressAnalyzer;
  
  async detectFromAudio(
    pcmData: Float32Array,
    emotions: EmotionalState
  ): Promise<CrisisAssessment> {
    // Multi-modal crisis detection
    const voiceDistress = await this.audioDistressAnalyzer.analyze(pcmData);
    const emotionalRisk = this.assessEmotionalRisk(emotions);
    
    return {
      level: this.calculateCrisisLevel(voiceDistress, emotionalRisk),
      confidence: this.calculateConfidence(voiceDistress, emotionalRisk),
      recommendedAction: this.determineAction(voiceDistress, emotionalRisk)
    };
  }
}
```

### 6. Integration Requirements

#### 6.1 Graphiti Integration

```typescript
// graphiti-integration.ts
export class GraphitiPatientGraph {
  async initializePatient(patientId: string) {
    const graph = await this.graphiti.createGraph({
      id: `patient-${patientId}`,
      schema: PATIENT_SCHEMA,
      features: {
        biTemporal: true,
        contradictionResolution: true
      }
    });
  }
  
  async trackSession(session: TherapySession) {
    // Create temporal nodes for each interaction
    // Link to previous sessions
    // Detect patterns and progress
  }
}
```

#### 6.2 CAG Context Management

```typescript
// cag-context-manager.ts
export class CAGTherapeuticContext {
  private protocols = {
    CBT: require('./protocols/cbt.json'),
    DBT: require('./protocols/dbt.json'),
    ACT: require('./protocols/act.json'),
    crisis: require('./protocols/crisis.json')
  };
  
  async preloadContext() {
    // Load all protocols into 128K context window
    // Optimize for 2.33s response time
    // Cache frequently used responses
  }
}
```

### 7. Deployment Configuration

#### 7.1 Updated Package.json

```json
{
  "name": "psychology-chatbot-live-audio",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "test:clinical": "jest --config=jest.clinical.config.js",
    "test:compliance": "jest --config=jest.compliance.config.js"
  },
  "dependencies": {
    "lit": "^3.3.0",
    "@lit/context": "^1.1.5",
    "@google/genai": "^0.9.0",
    "three": "^0.176.0",
    "@tensorflow/tfjs": "^4.17.0",
    "graphiti": "^1.0.0",
    "crypto-js": "^4.2.0",
    "zep-js": "^2.0.0"
  },
  "devDependencies": {
    "@types/node": "^22.14.0",
    "typescript": "~5.7.2",
    "vite": "^6.2.0",
    "jest": "^29.7.0"
  }
}
```

#### 7.2 Environment Configuration

```env
# .env.local
GEMINI_API_KEY=your_gemini_api_key
GRAPHITI_API_KEY=your_graphiti_api_key
MONGODB_URI=mongodb://localhost:27017/psychology-chatbot
REDIS_URL=redis://localhost:6379
ENCRYPTION_KEY=your_256_bit_key
AUDIT_ENDPOINT=https://audit.yourdomain.com
CRISIS_WEBHOOK=https://crisis.yourdomain.com/alert
```

### 8. File Structure After Implementation

```
live-audio/
├── index.tsx [MODIFIED]
│   └── Enhanced with clinical features
├── visual-3d.ts [MODIFIED]
│   └── Therapeutic visualizations added
├── analyser.ts [EXTENDED]
│   └── Clinical analysis features
├── utils.ts [EXTENDED]
│   └── HIPAA-compliant utilities
├── clinical/ [NEW]
│   ├── therapeutic-engine.ts
│   ├── emotion-analyzer.ts
│   ├── crisis-detector.ts
│   ├── session-manager.ts
│   └── protocols/
│       ├── cbt.json
│       ├── dbt.json
│       ├── act.json
│       └── crisis.json
├── integrations/ [NEW]
│   ├── graphiti-client.ts
│   ├── cag-manager.ts
│   └── ehr-connector.ts
├── security/ [NEW]
│   ├── hipaa-compliance.ts
│   ├── audit-logger.ts
│   └── encryption.ts
├── visualizations/ [NEW]
│   ├── breathing-guide.ts
│   ├── progress-tracker.ts
│   └── calming-effects.ts
└── tests/ [NEW]
    ├── clinical-validation.test.ts
    ├── crisis-detection.test.ts
    └── compliance.test.ts
```

### 9. Implementation Timeline

#### Phase 1: Core Clinical Features (Weeks 1-6)
1. **Week 1-2**: Enhance audio processing in `index.tsx`
2. **Week 3-4**: Implement clinical analysis extensions
3. **Week 5-6**: Integrate Graphiti and CAG

#### Phase 2: Therapeutic Intelligence (Weeks 7-12)
1. **Week 7-8**: Build therapeutic engine
2. **Week 9-10**: Implement crisis detection
3. **Week 11-12**: Add visualization enhancements

#### Phase 3: Compliance & Integration (Weeks 13-18)
1. **Week 13-14**: HIPAA compliance layer
2. **Week 15-16**: Documentation system
3. **Week 17-18**: Testing and validation

### 10. Success Metrics

#### Technical Performance
- Voice latency: <2.5 seconds (maintain current performance)
- Emotion detection accuracy: >85%
- Crisis detection sensitivity: >95%
- Audio quality: 48kHz clinical grade
- Visualization frame rate: 60fps

#### Clinical Outcomes
- User engagement: >70% weekly active
- Crisis intervention success: >90%
- Therapeutic alliance score: >4.5/5
- Documentation compliance: 100%
- Session continuity: >80%

### 11. Testing Requirements

#### Clinical Validation
```typescript
// clinical-validation.test.ts
describe('Clinical Audio Processing', () => {
  test('Emotion detection accuracy', async () => {
    const testAudio = loadTestAudio('depression-markers.wav');
    const result = await emotionAnalyzer.analyze(testAudio);
    expect(result.depression.score).toBeGreaterThan(0.7);
  });
  
  test('Crisis detection sensitivity', async () => {
    const crisisAudio = loadTestAudio('crisis-simulation.wav');
    const result = await crisisDetector.detect(crisisAudio);
    expect(result.level).toBeGreaterThan(CrisisLevel.MODERATE);
  });
});
```

### 12. Regulatory Compliance

#### HIPAA Requirements
- All audio data encrypted with AES-256-GCM
- Audit logs for every interaction
- Business Associate Agreements for third-party services
- Data retention policies implemented
- Patient consent management

#### FDA Considerations
- Software as Medical Device (SaMD) classification
- Clinical validation studies required
- Post-market surveillance planning
- Adverse event reporting system

This comprehensive requirements document provides a clear roadmap for transforming the `live-audio` directory into a clinical-grade psychology chatbot while maintaining the existing real-time voice interaction capabilities and enhancing them with therapeutic intelligence.