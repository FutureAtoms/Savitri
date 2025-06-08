export interface EmotionFeatures {
  pitch: number;
  pitchVariability: number;
  energy: number;
  spectralCentroid: number;
  zeroCrossingRate: number;
  mfcc: number[];
  speechRate: number;
  pauseRatio: number;
}

export interface EmotionResult {
  primary: string;
  secondary: string[];
  intensity: number;
  confidence: number;
  markers?: {
    depression?: number;
    anxiety?: number;
    stress?: number;
    trauma?: number;
  };
  valence: number; // -1 (negative) to 1 (positive)
  arousal: number; // 0 (calm) to 1 (excited)
}

export interface EmotionalState {
    dominantEmotion: string;
    intensity: number;
}

export interface TherapyProtocol {
  name: string;
  techniques: {
    [key: string]: TherapyTechnique;
  };
}

export interface TherapyTechnique {
  name: string;
  description: string;
  // other properties
}

export interface TherapeuticResponse {
  timestamp: Date;
  protocol: string;
  technique: string;
  response: string;
  emotionalValidation: string;
  therapeuticSuggestions: string[];
  homework: string[];
  boundaries: string[];
}

export interface TherapyContext {
    currentProtocol: string;
    sessionDuration: number;
    previousResponses: TherapeuticResponse[];
    patientGoals: string[];
    riskFactors: string[];
} 