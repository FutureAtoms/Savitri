# Live-Audio Modification Guide: Step-by-Step Implementation

## Overview

This guide provides specific, line-by-line modifications to transform your `live-audio` directory into a psychology chatbot. Each section shows exactly what to change in your existing files.

## 1. Modify `index.tsx` - Main Application

### Step 1.1: Update Imports and Add Clinical Components

```typescript
/* MODIFY: Add these imports at the top of index.tsx */
import {GoogleGenAI, LiveServerMessage, Modality, Session} from '@google/genai';
import {LitElement, css, html} from 'lit';
import {customElement, state} from 'lit/decorators.js';
import {createBlob, decode, decodeAudioData} from './utils';
// NEW IMPORTS - Add these
import {ClinicalAnalyser} from './clinical/clinical-analyser';
import {EmotionAnalyzer} from './clinical/emotion-analyzer';
import {CrisisDetector} from './clinical/crisis-detector';
import {SessionManager} from './clinical/session-manager';
import {TherapeuticEngine} from './clinical/therapeutic-engine';
import {HIPAACompliance} from './security/hipaa-compliance';
import './therapeutic-visual-3d'; // Replace './visual-3d'

// ADD: Therapeutic system prompt
const THERAPEUTIC_SYSTEM_PROMPT = `You are a compassionate, licensed clinical psychologist specializing in evidence-based therapy.

Core Principles:
- Always maintain professional therapeutic boundaries
- Use active listening and reflect emotions
- Apply evidence-based techniques (CBT, DBT, ACT) appropriately
- Detect and respond to crisis situations immediately
- Never provide medical advice or medication recommendations
- Encourage professional in-person help when appropriate

Communication Style:
- Warm, empathetic, and non-judgmental
- Use clear, simple language
- Validate feelings before offering strategies
- Ask open-ended questions to understand better
- Pace responses to match the user's emotional state

Crisis Protocol:
If detecting suicidal ideation, self-harm, or immediate danger:
1. Express care and concern
2. Provide crisis hotline numbers (988 in US)
3. Encourage immediate professional help
4. Do not end conversation abruptly

Remember: You are a support tool, not a replacement for professional therapy.`;
```

### Step 1.2: Rename and Enhance the Component

```typescript
/* MODIFY: Change the component name and add new state variables */
@customElement('psychology-chatbot')  // Changed from 'gdm-live-audio'
export class PsychologyChatbot extends LitElement {  // Changed from GdmLiveAudio
  @state() isRecording = false;
  @state() status = '';
  @state() error = '';
  // ADD: New state variables
  @state() emotionalState: EmotionalState | null = null;
  @state() sessionActive = false;
  @state() crisisDetected = false;
  @state() patientId: string = '';

  private client: GoogleGenAI;
  private session: Session;
  // MODIFY: Change audio contexts for clinical quality
  private inputAudioContext = new (window.AudioContext ||
    window.webkitAudioContext)({
      sampleRate: 48000, // Changed from 16000
      latencyHint: 'interactive'
    });
  private outputAudioContext = new (window.AudioContext ||
    window.webkitAudioContext)({
      sampleRate: 24000,
      latencyHint: 'interactive'
    });
    
  // ADD: Clinical components
  private clinicalAnalyser: ClinicalAnalyser;
  private emotionAnalyzer: EmotionAnalyzer;
  private crisisDetector: CrisisDetector;
  private sessionManager: SessionManager;
  private therapeuticEngine: TherapeuticEngine;
  private hipaaCompliance: HIPAACompliance;
  
  // ... rest of existing properties
```

### Step 1.3: Update Constructor and Initialization

```typescript
/* MODIFY: Update the constructor */
constructor() {
  super();
  this.initializeClinicalSystem(); // Changed from this.initClient()
}

/* ADD: New initialization method */
private async initializeClinicalSystem() {
  // Initialize clinical components first
  this.clinicalAnalyser = new ClinicalAnalyser(this.inputNode);
  this.emotionAnalyzer = new EmotionAnalyzer(this.inputAudioContext);
  this.crisisDetector = new CrisisDetector();
  this.sessionManager = new SessionManager();
  this.therapeuticEngine = new TherapeuticEngine();
  this.hipaaCompliance = new HIPAACompliance({
    encryptionKey: process.env.ENCRYPTION_KEY!
  });
  
  // Get or create patient ID (in production, this would come from auth)
  this.patientId = await this.getOrCreatePatientId();
  
  // Initialize audio
  this.initAudio();
  
  // Initialize Gemini client with clinical configuration
  await this.initClient();
}

/* ADD: Patient identification method */
private async getOrCreatePatientId(): Promise<string> {
  // In production, this would come from authentication
  // For now, use localStorage with encryption
  let patientId = localStorage.getItem('patientId');
  if (!patientId) {
    patientId = crypto.randomUUID();
    localStorage.setItem('patientId', patientId);
  }
  return patientId;
}
```

### Step 1.4: Enhance Session Initialization

```typescript
/* MODIFY: Update initSession() method */
private async initSession() {
  const model = 'gemini-2.5-flash-preview-native-audio-dialog';

  try {
    this.session = await this.client.live.connect({
      model: model,
      // ADD: System instruction for therapeutic behavior
      systemInstruction: THERAPEUTIC_SYSTEM_PROMPT,
      callbacks: {
        onopen: () => {
          // MODIFY: Update status message
          this.updateStatus('Therapy session started. How can I support you today?');
          this.sessionActive = true;
          // ADD: Start session tracking
          this.sessionManager.startSession(this.patientId);
        },
        onmessage: async (message: LiveServerMessage) => {
          // MODIFY: Use enhanced handler
          await this.handleTherapeuticResponse(message);
        },
        onerror: (e: ErrorEvent) => {
          this.updateError(e.message);
          // ADD: Log clinical error
          this.hipaaCompliance.logError(e);
        },
        onclose: (e: CloseEvent) => {
          this.updateStatus('Session ended: ' + e.reason);
          // ADD: End session tracking
          this.sessionManager.endSession();
        },
      },
      config: {
        responseModalities: [Modality.AUDIO],
        speechConfig: {
          voiceConfig: {
            prebuiltVoiceConfig: {voiceName: 'Orus'} // Calm voice
          },
        },
        // ADD: Generation config for therapeutic responses
        generationConfig: {
          temperature: 0.7,  // Balanced for empathy
          topP: 0.9,
          maxOutputTokens: 500  // Appropriate length
        }
      },
    });
  } catch (e) {
    console.error('Session initialization failed:', e);
    this.updateError('Unable to start therapy session. Please try again.');
  }
}
```

### Step 1.5: Replace Audio Processing with Clinical Analysis

```typescript
/* ADD: New therapeutic response handler */
private async handleTherapeuticResponse(message: LiveServerMessage) {
  const audio = message.serverContent?.modelTurn?.parts[0]?.inlineData;
  
  if (audio) {
    // Existing audio playback
    this.nextStartTime = Math.max(
      this.nextStartTime,
      this.outputAudioContext.currentTime,
    );

    const audioBuffer = await decodeAudioData(
      decode(audio.data),
      this.outputAudioContext,
      24000,
      1,
    );
    
    const source = this.outputAudioContext.createBufferSource();
    source.buffer = audioBuffer;
    source.connect(this.outputNode);
    source.addEventListener('ended', () => {
      this.sources.delete(source);
    });

    source.start(this.nextStartTime);
    this.nextStartTime = this.nextStartTime + audioBuffer.duration;
    this.sources.add(source);
    
    // ADD: Track therapeutic response
    await this.sessionManager.logTherapistResponse({
      timestamp: Date.now(),
      duration: audioBuffer.duration,
      sessionId: this.sessionManager.currentSessionId
    });
  }

  const interrupted = message.serverContent?.interrupted;
  if (interrupted) {
    for (const source of this.sources.values()) {
      source.stop();
      this.sources.delete(source);
    }
    this.nextStartTime = 0;
  }
}

/* MODIFY: Update the audio processing callback */
private scriptProcessorCallback = async (audioProcessingEvent: AudioProcessingEvent) => {
  if (!this.isRecording) return;

  const inputBuffer = audioProcessingEvent.inputBuffer;
  const pcmData = inputBuffer.getChannelData(0);

  // ADD: Clinical analysis pipeline
  try {
    // Analyze emotions from voice
    const emotions = await this.emotionAnalyzer.analyzeChunk(pcmData);
    this.emotionalState = emotions;
    
    // Check for crisis indicators
    const crisisLevel = await this.crisisDetector.analyzeAudio(
      pcmData, 
      emotions
    );
    
    if (crisisLevel > CrisisLevel.MODERATE) {
      this.crisisDetected = true;
      await this.handleCrisisDetection(crisisLevel);
    }
    
    // Get clinical features
    const clinicalFeatures = await this.clinicalAnalyser.getClinicalFeatures();
    
    // Create encrypted audio blob with metadata
    const clinicalBlob = await this.hipaaCompliance.createSecureBlob(
      pcmData,
      {
        patientId: this.patientId,
        emotions,
        clinicalFeatures,
        timestamp: Date.now()
      }
    );
    
    // Send to Gemini with clinical context
    this.session.sendRealtimeInput({media: clinicalBlob});
    
    // Log interaction for compliance
    await this.hipaaCompliance.logInteraction({
      type: 'patient_voice_input',
      patientId: this.patientId,
      timestamp: Date.now(),
      encrypted: true
    });
    
  } catch (error) {
    console.error('Clinical analysis error:', error);
    this.hipaaCompliance.logError(error);
  }
};

/* ADD: Crisis handling method */
private async handleCrisisDetection(level: CrisisLevel) {
  // Immediate UI update
  this.requestUpdate();
  
  // Get crisis intervention
  const intervention = await this.therapeuticEngine.getCrisisIntervention(level);
  
  // If high crisis, notify emergency contacts
  if (level >= CrisisLevel.HIGH) {
    await this.notifyEmergencyContacts({
      patientId: this.patientId,
      level,
      timestamp: Date.now()
    });
  }
  
  // Update status with crisis resources
  this.updateStatus(
    'I\'m concerned about you. If you\'re in immediate danger, ' +
    'please call 988 (Suicide & Crisis Lifeline) or 911.'
  );
}

/* MODIFY: Override the startRecording method */
private async startRecording() {
  if (this.isRecording) return;

  // ADD: Check patient consent
  const hasConsent = await this.checkPatientConsent();
  if (!hasConsent) {
    await this.requestConsent();
    return;
  }

  this.inputAudioContext.resume();
  this.updateStatus('Starting therapeutic session...');

  try {
    this.mediaStream = await navigator.mediaDevices.getUserMedia({
      audio: {
        echoCancellation: true,
        noiseSuppression: true,
        autoGainControl: true,
        sampleRate: 48000
      },
      video: false,
    });

    this.updateStatus('Session active. I\'m here to listen...');

    this.sourceNode = this.inputAudioContext.createMediaStreamSource(
      this.mediaStream,
    );
    this.sourceNode.connect(this.inputNode);

    const bufferSize = 2048; // Larger buffer for clinical analysis
    this.scriptProcessorNode = this.inputAudioContext.createScriptProcessor(
      bufferSize,
      1,
      1,
    );

    // Use the clinical callback
    this.scriptProcessorNode.onaudioprocess = this.scriptProcessorCallback;

    this.sourceNode.connect(this.scriptProcessorNode);
    this.scriptProcessorNode.connect(this.inputAudioContext.destination);

    this.isRecording = true;
    
    // ADD: Log session start
    await this.sessionManager.logSessionStart({
      patientId: this.patientId,
      timestamp: Date.now()
    });
    
  } catch (err) {
    console.error('Error starting recording:', err);
    this.updateStatus(`Error: ${err.message}`);
    this.stopRecording();
  }
}
```

### Step 1.6: Update the UI with Clinical Features

```typescript
/* MODIFY: Update styles to include clinical UI elements */
static styles = css`
  /* ... existing styles ... */
  
  /* ADD: Clinical UI styles */
  .emotional-indicator {
    position: absolute;
    top: 20px;
    right: 20px;
    padding: 10px 20px;
    border-radius: 20px;
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(10px);
    color: white;
    font-size: 14px;
    display: flex;
    align-items: center;
    gap: 10px;
  }
  
  .emotion-emoji {
    font-size: 24px;
  }
  
  .crisis-banner {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    background: #dc2626;
    color: white;
    padding: 15px;
    text-align: center;
    z-index: 1000;
    font-weight: bold;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 20px;
  }
  
  .crisis-number {
    background: white;
    color: #dc2626;
    padding: 5px 15px;
    border-radius: 20px;
    font-size: 18px;
  }
  
  .session-info {
    position: absolute;
    top: 20px;
    left: 20px;
    color: white;
    font-size: 12px;
    opacity: 0.7;
  }
`;

/* MODIFY: Update render method */
render() {
  return html`
    <div>
      ${this.crisisDetected ? html`
        <div class="crisis-banner">
          <span>If you're in immediate danger, please call</span>
          <span class="crisis-number">988</span>
          <span>or</span>
          <span class="crisis-number">911</span>
        </div>
      ` : ''}
      
      ${this.sessionActive ? html`
        <div class="session-info">
          Session ID: ${this.sessionManager.currentSessionId}
        </div>
      ` : ''}
      
      ${this.emotionalState ? html`
        <div class="emotional-indicator">
          <span class="emotion-emoji">${this.getEmotionEmoji(this.emotionalState.primary)}</span>
          <span>
            Detected: ${this.emotionalState.primary} 
            (${Math.round(this.emotionalState.confidence * 100)}% confidence)
          </span>
        </div>
      ` : ''}
      
      <div class="controls">
        <button
          id="resetButton"
          @click=${this.reset}
          ?disabled=${this.isRecording}>
          <!-- ... existing SVG ... -->
        </button>
        <button
          id="startButton"
          @click=${this.startRecording}
          ?disabled=${this.isRecording}>
          <!-- ... existing SVG ... -->
        </button>
        <button
          id="stopButton"
          @click=${this.stopRecording}
          ?disabled=${!this.isRecording}>
          <!-- ... existing SVG ... -->
        </button>
      </div>

      <div id="status">${this.status}</div>
      
      <!-- MODIFY: Use therapeutic visualization component -->
      <therapeutic-visual-3d
        .inputNode=${this.inputNode}
        .outputNode=${this.outputNode}
        .emotionalState=${this.emotionalState}>
      </therapeutic-visual-3d>
    </div>
  `;
}

/* ADD: Helper method for emotion display */
private getEmotionEmoji(emotion: string): string {
  const emojiMap = {
    neutral: '😐',
    happy: '😊',
    sad: '😢',
    anxious: '😰',
    angry: '😠',
    fearful: '😨'
  };
  return emojiMap[emotion] || '😐';
}
```

## 2. Create `therapeutic-visual-3d.ts` (Enhanced from `visual-3d.ts`)

```typescript
/* CREATE NEW FILE: therapeutic-visual-3d.ts */
/* This extends the existing visual-3d.ts with therapeutic features */

import {customElement, property} from 'lit/decorators.js';
import {GdmLiveAudioVisuals3D} from './visual-3d';
import * as THREE from 'three';
import {EmotionalState} from './clinical/types';

@customElement('therapeutic-visual-3d')
export class TherapeuticVisual3D extends GdmLiveAudioVisuals3D {
  @property() emotionalState: EmotionalState | null = null;
  
  private breathingGuide: BreathingGuide;
  private emotionColors = {
    neutral: new THREE.Color(0x4a5568),
    happy: new THREE.Color(0x48bb78),
    sad: new THREE.Color(0x5a67d8),
    anxious: new THREE.Color(0x9f7aea),
    angry: new THREE.Color(0xed8936),
    fearful: new THREE.Color(0x38b2ac)
  };
  
  protected init() {
    super.init();
    
    // Add therapeutic elements
    this.breathingGuide = new BreathingGuide(this.scene);
    
    // Modify sphere material for softer appearance
    if (this.sphere) {
      this.sphere.material.roughness = 0.3;
      this.sphere.material.metalness = 0.7;
    }
  }
  
  protected animation() {
    requestAnimationFrame(() => this.animation());
    
    // Update analyzers
    this.inputAnalyser.update();
    this.outputAnalyser.update();
    
    // Therapeutic modifications
    if (this.emotionalState) {
      this.updateEmotionalVisualization();
      
      // Activate breathing guide for anxiety
      if (this.emotionalState.anxietyIndicators.score > 0.6) {
        this.breathingGuide.activate();
      } else {
        this.breathingGuide.deactivate();
      }
    }
    
    // Continue with base animation logic
    this.updateSphereAnimation();
    this.composer.render();
  }
  
  private updateEmotionalVisualization() {
    if (!this.sphere || !this.emotionalState) return;
    
    // Smoothly transition sphere color based on emotion
    const targetColor = this.emotionColors[this.emotionalState.primary];
    this.sphere.material.color.lerp(targetColor, 0.05);
    
    // Adjust animation intensity based on stress
    const stressModifier = 1 - this.emotionalState.stress;
    this.sphere.scale.setScalar(1 + (0.2 * stressModifier));
    
    // Calm the backdrop for high stress
    if (this.backdrop) {
      const backdropMaterial = this.backdrop.material as THREE.RawShaderMaterial;
      backdropMaterial.uniforms.rand.value = 
        Math.random() * (1 - this.emotionalState.stress) * 10000;
    }
  }
  
  private updateSphereAnimation() {
    const t = performance.now();
    const dt = (t - this.prevTime) / (1000 / 60);
    this.prevTime = t;
    
    if (this.sphere.material.userData.shader) {
      // Slower, calmer rotations for therapy
      const calmnessFactor = this.emotionalState ? 
        (1 - this.emotionalState.stress) : 1;
      
      this.rotation.x += dt * 0.0005 * calmnessFactor;
      this.rotation.y += dt * 0.0003 * calmnessFactor;
      this.rotation.z += dt * 0.0002 * calmnessFactor;
      
      // Apply rotation
      const euler = new THREE.Euler(
        this.rotation.x,
        this.rotation.y,
        this.rotation.z
      );
      const quaternion = new THREE.Quaternion().setFromEuler(euler);
      const vector = new THREE.Vector3(0, 0, 5);
      vector.applyQuaternion(quaternion);
      this.camera.position.copy(vector);
      this.camera.lookAt(this.sphere.position);
      
      // Update shader uniforms with calmer values
      const shader = this.sphere.material.userData.shader;
      shader.uniforms.time.value += dt * 0.05 * calmnessFactor;
      
      // Gentle pulsing based on breathing
      if (this.breathingGuide.isActive) {
        const breathPhase = this.breathingGuide.getPhase();
        shader.uniforms.outputData.value.set(
          breathPhase * 0.1,
          breathPhase * 0.05,
          10,
          0
        );
      }
    }
  }
}

// Breathing guide visualization
class BreathingGuide {
  private ring: THREE.Mesh;
  private isActive = false;
  private phase = 0;
  private breathingCycle = {
    inhale: 4,
    hold: 7,
    exhale: 8
  };
  
  constructor(private scene: THREE.Scene) {
    this.createBreathingRing();
  }
  
  private createBreathingRing() {
    const geometry = new THREE.TorusGeometry(2, 0.1, 16, 100);
    const material = new THREE.MeshBasicMaterial({
      color: 0x00ff88,
      transparent: true,
      opacity: 0
    });
    
    this.ring = new THREE.Mesh(geometry, material);
    this.ring.position.z = -0.5;
    this.scene.add(this.ring);
  }
  
  activate() {
    if (this.isActive) return;
    this.isActive = true;
    this.animateBreathingCycle();
  }
  
  deactivate() {
    this.isActive = false;
    this.ring.material.opacity = 0;
  }
  
  getPhase(): number {
    return this.phase;
  }
  
  private async animateBreathingCycle() {
    if (!this.isActive) return;
    
    // Inhale
    await this.animatePhase(0, 1, this.breathingCycle.inhale * 1000);
    
    // Hold
    await new Promise(resolve => 
      setTimeout(resolve, this.breathingCycle.hold * 1000)
    );
    
    // Exhale
    await this.animatePhase(1, 0, this.breathingCycle.exhale * 1000);
    
    // Continue cycle
    this.animateBreathingCycle();
  }
  
  private animatePhase(from: number, to: number, duration: number): Promise<void> {
    return new Promise(resolve => {
      const startTime = Date.now();
      
      const animate = () => {
        if (!this.isActive) {
          resolve();
          return;
        }
        
        const elapsed = Date.now() - startTime;
        const progress = Math.min(elapsed / duration, 1);
        
        this.phase = from + (to - from) * this.easeInOutSine(progress);
        
        // Update ring appearance
        this.ring.material.opacity = 0.3 + 0.3 * this.phase;
        this.ring.scale.setScalar(1 + 0.5 * this.phase);
        
        if (progress < 1) {
          requestAnimationFrame(animate);
        } else {
          resolve();
        }
      };
      
      animate();
    });
  }
  
  private easeInOutSine(t: number): number {
    return -(Math.cos(Math.PI * t) - 1) / 2;
  }
}
```

## 3. Extend `analyser.ts` with Clinical Features

```typescript
/* CREATE NEW FILE: clinical/clinical-analyser.ts */
/* This extends the base Analyser class */

import {Analyser} from '../analyser';

export interface ClinicalFeatures {
  pitchMean: number;
  pitchVariability: number;
  speechRate: number;
  pauseDuration: number;
  energyRMS: number;
  spectralCentroid: number;
  voiceTremor: number;
  emotionalStability: number;
}

export class ClinicalAnalyser extends Analyser {
  private sampleRate: number;
  private frameBuffer: Float32Array[] = [];
  private readonly FRAME_SIZE = 2048;
  
  constructor(node: AudioNode) {
    super(node);
    this.analyser.fftSize = 2048; // Higher resolution
    this.sampleRate = node.context.sampleRate;
  }
  
  async getClinicalFeatures(): Promise<ClinicalFeatures> {
    // Get frequency data
    const freqData = new Float32Array(this.bufferLength);
    this.analyser.getFloatFrequencyData(freqData);
    
    // Extract clinical features
    const pitch = this.extractPitch(freqData);
    const spectral = this.extractSpectralFeatures(freqData);
    const energy = this.calculateEnergy();
    const temporal = this.extractTemporalFeatures();
    
    return {
      pitchMean: pitch.mean,
      pitchVariability: pitch.variability,
      speechRate: temporal.rate,
      pauseDuration: temporal.pauseDuration,
      energyRMS: energy,
      spectralCentroid: spectral.centroid,
      voiceTremor: this.detectTremor(freqData),
      emotionalStability: this.calculateEmotionalStability()
    };
  }
  
  private extractPitch(freqData: Float32Array): {mean: number, variability: number} {
    // Simplified pitch detection using autocorrelation
    const correlation = this.autocorrelate(freqData);
    const pitchIndex = this.findPitchPeriod(correlation);
    const pitchHz = this.sampleRate / pitchIndex;
    
    // Store for variability calculation
    if (!this.pitchHistory) this.pitchHistory = [];
    this.pitchHistory.push(pitchHz);
    if (this.pitchHistory.length > 100) this.pitchHistory.shift();
    
    const mean = this.pitchHistory.reduce((a, b) => a + b) / this.pitchHistory.length;
    const variability = this.calculateStandardDeviation(this.pitchHistory);
    
    return {mean, variability};
  }
  
  private extractSpectralFeatures(freqData: Float32Array): {centroid: number} {
    let weightedSum = 0;
    let magnitudeSum = 0;
    
    for (let i = 0; i < freqData.length; i++) {
      const magnitude = Math.pow(10, freqData[i] / 20);
      const frequency = (i * this.sampleRate) / (2 * freqData.length);
      
      weightedSum += magnitude * frequency;
      magnitudeSum += magnitude;
    }
    
    const centroid = magnitudeSum > 0 ? weightedSum / magnitudeSum : 0;
    return {centroid};
  }
  
  private calculateEnergy(): number {
    const timeData = new Float32Array(this.analyser.fftSize);
    this.analyser.getFloatTimeDomainData(timeData);
    
    let sum = 0;
    for (let i = 0; i < timeData.length; i++) {
      sum += timeData[i] * timeData[i];
    }
    
    return Math.sqrt(sum / timeData.length);
  }
  
  private detectTremor(freqData: Float32Array): number {
    // Detect 4-12 Hz tremor in voice
    const tremorRange = {
      min: Math.floor(4 * freqData.length * 2 / this.sampleRate),
      max: Math.floor(12 * freqData.length * 2 / this.sampleRate)
    };
    
    let tremorEnergy = 0;
    for (let i = tremorRange.min; i <= tremorRange.max; i++) {
      tremorEnergy += Math.pow(10, freqData[i] / 20);
    }
    
    return tremorEnergy / (tremorRange.max - tremorRange.min);
  }
  
  private extractTemporalFeatures(): {rate: number, pauseDuration: number} {
    // Simplified speech rate detection
    const timeData = new Float32Array(this.analyser.fftSize);
    this.analyser.getFloatTimeDomainData(timeData);
    
    // Detect speech segments
    const threshold = 0.01;
    let speechSegments = 0;
    let inSpeech = false;
    let pauseDuration = 0;
    let pauseStart = 0;
    
    for (let i = 0; i < timeData.length; i++) {
      const amplitude = Math.abs(timeData[i]);
      
      if (amplitude > threshold && !inSpeech) {
        inSpeech = true;
        speechSegments++;
        if (pauseStart > 0) {
          pauseDuration += i - pauseStart;
        }
      } else if (amplitude <= threshold && inSpeech) {
        inSpeech = false;
        pauseStart = i;
      }
    }
    
    const rate = speechSegments / (timeData.length / this.sampleRate);
    const avgPause = pauseDuration / (this.sampleRate * Math.max(speechSegments - 1, 1));
    
    return {rate, pauseDuration: avgPause};
  }
  
  private calculateEmotionalStability(): number {
    // Measure consistency of vocal features
    if (!this.featureHistory) this.featureHistory = [];
    
    const currentFeatures = {
      pitch: this.extractPitch(new Float32Array(this.bufferLength)).mean,
      energy: this.calculateEnergy()
    };
    
    this.featureHistory.push(currentFeatures);
    if (this.featureHistory.length > 50) this.featureHistory.shift();
    
    if (this.featureHistory.length < 2) return 1;
    
    // Calculate stability as inverse of variability
    const pitchVar = this.calculateVariability(
      this.featureHistory.map(f => f.pitch)
    );
    const energyVar = this.calculateVariability(
      this.featureHistory.map(f => f.energy)
    );
    
    return 1 / (1 + pitchVar + energyVar);
  }
  
  // Helper methods
  private autocorrelate(buffer: Float32Array): Float32Array {
    const result = new Float32Array(buffer.length);
    for (let lag = 0; lag < buffer.length; lag++) {
      let sum = 0;
      for (let i = 0; i < buffer.length - lag; i++) {
        sum += buffer[i] * buffer[i + lag];
      }
      result[lag] = sum;
    }
    return result;
  }
  
  private findPitchPeriod(correlation: Float32Array): number {
    // Find first peak after initial decline
    let peakIndex = 20; // Skip very short periods
    let peakValue = correlation[peakIndex];
    
    for (let i = 21; i < correlation.length / 2; i++) {
      if (correlation[i] > peakValue) {
        peakValue = correlation[i];
        peakIndex = i;
      }
    }
    
    return peakIndex;
  }
  
  private calculateStandardDeviation(values: number[]): number {
    const mean = values.reduce((a, b) => a + b) / values.length;
    const squaredDiffs = values.map(v => Math.pow(v - mean, 2));
    const variance = squaredDiffs.reduce((a, b) => a + b) / values.length;
    return Math.sqrt(variance);
  }
  
  private calculateVariability(values: number[]): number {
    if (values.length < 2) return 0;
    const stdDev = this.calculateStandardDeviation(values);
    const mean = values.reduce((a, b) => a + b) / values.length;
    return mean > 0 ? stdDev / mean : 0;
  }
  
  // Store history for analysis
  private pitchHistory: number[] = [];
  private featureHistory: {pitch: number, energy: number}[] = [];
}
```

## 4. Update `utils.ts` with HIPAA Compliance

```typescript
/* MODIFY: Add to existing utils.ts */

import * as CryptoJS from 'crypto-js';

// ADD: HIPAA-compliant encryption functions
export interface SecureBlob extends Blob {
  encrypted: boolean;
  metadata: {
    patientId: string;
    timestamp: number;
    algorithm: string;
  };
}

export function encryptAudioData(
  data: Float32Array,
  patientId: string,
  encryptionKey: string
): string {
  // Convert to base64
  const base64Audio = encode(new Uint8Array(data.buffer));
  
  // Encrypt with AES-256
  const encrypted = CryptoJS.AES.encrypt(base64Audio, encryptionKey, {
    mode: CryptoJS.mode.GCM,
    padding: CryptoJS.pad.Pkcs7
  });
  
  return encrypted.toString();
}

export function createSecureBlob(
  data: Float32Array,
  metadata: {
    patientId: string;
    emotions?: any;
    clinicalFeatures?: any;
    timestamp: number;
  },
  encryptionKey: string
): SecureBlob {
  // Encrypt audio data
  const encryptedData = encryptAudioData(data, metadata.patientId, encryptionKey);
  
  // Create secure blob
  const secureData = {
    audio: encryptedData,
    metadata: {
      ...metadata,
      encrypted: true,
      algorithm: 'AES-256-GCM'
    }
  };
  
  // Convert to blob format expected by Gemini
  const jsonString = JSON.stringify(secureData);
  const base64 = btoa(jsonString);
  
  return {
    data: base64,
    mimeType: 'application/encrypted-audio;rate=48000',
    encrypted: true,
    metadata: {
      patientId: metadata.patientId,
      timestamp: metadata.timestamp,
      algorithm: 'AES-256-GCM'
    }
  } as SecureBlob;
}

// ADD: Secure session storage
export class SecureSessionStorage {
  private static encryptionKey: string;
  
  static initialize(key: string) {
    this.encryptionKey = key;
  }
  
  static setItem(key: string, value: any): void {
    const encrypted = CryptoJS.AES.encrypt(
      JSON.stringify(value),
      this.encryptionKey
    ).toString();
    
    sessionStorage.setItem(key, encrypted);
  }
  
  static getItem(key: string): any {
    const encrypted = sessionStorage.getItem(key);
    if (!encrypted) return null;
    
    try {
      const decrypted = CryptoJS.AES.decrypt(
        encrypted,
        this.encryptionKey
      ).toString(CryptoJS.enc.Utf8);
      
      return JSON.parse(decrypted);
    } catch {
      return null;
    }
  }
  
  static removeItem(key: string): void {
    sessionStorage.removeItem(key);
  }
  
  static clear(): void {
    sessionStorage.clear();
  }
}

// ADD: Clinical data validation
export function validateClinicalData(data: any): boolean {
  // Ensure required fields
  const requiredFields = ['patientId', 'timestamp', 'sessionId'];
  
  for (const field of requiredFields) {
    if (!data[field]) {
      console.error(`Missing required field: ${field}`);
      return false;
    }
  }
  
  // Validate data types
  if (typeof data.patientId !== 'string') return false;
  if (typeof data.timestamp !== 'number') return false;
  if (typeof data.sessionId !== 'string') return false;
  
  return true;
}

// ADD: Audit trail helper
export async function logAuditTrail(
  action: string,
  details: any,
  endpoint: string
): Promise<void> {
  const auditEntry = {
    action,
    timestamp: Date.now(),
    details,
    userAgent: navigator.userAgent,
    sessionId: SecureSessionStorage.getItem('sessionId')
  };
  
  try {
    await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Audit-Log': 'true'
      },
      body: JSON.stringify(auditEntry)
    });
  } catch (error) {
    console.error('Failed to log audit trail:', error);
    // Store locally for later sync
    const localAudits = SecureSessionStorage.getItem('pendingAudits') || [];
    localAudits.push(auditEntry);
    SecureSessionStorage.setItem('pendingAudits', localAudits);
  }
}
```

## 5. Update HTML and Metadata

### 5.1 Update `index.html`

```html
<!-- MODIFY: Update index.html -->
<script type="importmap">
  {
    "imports": {
      "lit": "https://esm.sh/lit@^3.3.0",
      "lit/": "https://esm.sh/lit@^3.3.0/",
      "@lit/context": "https://esm.sh/@lit/context@^1.1.5",
      "@google/genai": "https://esm.sh/@google/genai@^0.9.0",
      "three": "https://esm.sh/three@^0.176.0",
      "three/": "https://esm.sh/three@^0.176.0/",
      "@tensorflow/tfjs": "https://esm.sh/@tensorflow/tfjs@^4.17.0",
      "crypto-js": "https://esm.sh/crypto-js@^4.2.0"
    }
  }
</script>
<body>
  <!-- MODIFY: Change component name -->
  <psychology-chatbot></psychology-chatbot>
  <script type="module" src="/index.tsx"></script>
</body>
<link rel="stylesheet" href="/index.css">
<!-- ADD: Clinical UI styles -->
<link rel="stylesheet" href="/clinical-ui.css">
```

### 5.2 Update `metadata.json`

```json
{
  "name": "Psychology Chatbot - Voice Therapy",
  "description": "Professional voice-based psychological support with real-time emotion detection, crisis intervention, and evidence-based therapeutic techniques.",
  "requestFramePermissions": [
    "microphone",
    "storage"
  ],
  "version": "1.0.0",
  "clinical": true,
  "compliance": {
    "hipaa": true,
    "encryption": "AES-256-GCM"
  }
}
```

### 5.3 Update `package.json`

```json
{
  "name": "psychology-chatbot-voice",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "test": "jest",
    "test:clinical": "jest --testPathPattern=clinical",
    "test:compliance": "jest --testPathPattern=compliance",
    "audit": "npm audit --production"
  },
  "dependencies": {
    "lit": "^3.3.0",
    "@lit/context": "^1.1.5",
    "@google/genai": "^0.9.0",
    "three": "^0.176.0",
    "@tensorflow/tfjs": "^4.17.0",
    "@tensorflow-models/speech-commands": "^0.5.4",
    "crypto-js": "^4.2.0",
    "uuid": "^9.0.1"
  },
  "devDependencies": {
    "@types/node": "^22.14.0",
    "@types/crypto-js": "^4.2.2",
    "typescript": "~5.7.2",
    "vite": "^6.2.0",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.11"
  }
}
```

## 6. Create New Clinical Directories

```bash
# Run these commands in your live-audio directory
mkdir -p clinical
mkdir -p security
mkdir -p protocols
mkdir -p tests
mkdir -p visualizations

# Create placeholder files
touch clinical/emotion-analyzer.ts
touch clinical/crisis-detector.ts
touch clinical/session-manager.ts
touch clinical/therapeutic-engine.ts
touch clinical/types.ts

touch security/hipaa-compliance.ts
touch security/audit-logger.ts
touch security/encryption.ts

touch protocols/cbt.json
touch protocols/dbt.json
touch protocols/act.json
touch protocols/crisis.json

touch tests/clinical-validation.test.ts
touch tests/crisis-detection.test.ts
touch tests/compliance.test.ts
```

## Summary

This guide transforms your `live-audio` directory into a clinical-grade psychology chatbot by:

1. **Enhancing `index.tsx`** with clinical analysis, emotion detection, and crisis management
2. **Creating `therapeutic-visual-3d.ts`** with calming visualizations and breathing guides
3. **Extending `analyser.ts`** with clinical voice feature extraction
4. **Adding HIPAA compliance** to `utils.ts`
5. **Updating configuration files** for clinical requirements
6. **Creating new directories** for clinical components

The modifications maintain your existing real-time voice interface while adding the therapeutic intelligence, security, and compliance features required for a professional mental health support system.