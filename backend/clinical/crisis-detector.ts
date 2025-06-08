import { EmotionalState } from './types';

export class CrisisDetector {
  private crisisKeywords: string[] = [
    'kill myself', 'suicide', 'end my life', 'hopeless', 'no reason to live',
    'self-harm', 'cutting', 'overdose', 'want to die', 'goodbye world'
  ];

  detectCrisis(text: string, emotionalState: EmotionalState): number {
    let crisisLevel = 0;
    const lowerCaseText = text.toLowerCase();

    // Keyword-based detection
    for (const keyword of this.crisisKeywords) {
      if (lowerCaseText.includes(keyword)) {
        crisisLevel += 5;
      }
    }

    // Emotion-based detection
    if (emotionalState.dominantEmotion === 'sadness' && emotionalState.intensity > 0.9) {
      crisisLevel += 2;
    }
    if (emotionalState.dominantEmotion === 'fear' && emotionalState.intensity > 0.8) {
      crisisLevel += 1;
    }

    // Normalize crisis level to be between 0 and 10
    return Math.min(crisisLevel, 10);
  }
} 