import { CrisisDetector } from '../crisis-detector';
import { EmotionalState } from '../types';

describe('CrisisDetector', () => {
  let crisisDetector: CrisisDetector;

  beforeEach(() => {
    crisisDetector = new CrisisDetector();
  });

  it('should return a low crisis level for normal text', () => {
    const text = 'I had a good day today.';
    const emotionalState: EmotionalState = { dominantEmotion: 'happy', intensity: 0.8 };
    const crisisLevel = crisisDetector.detectCrisis(text, emotionalState);
    expect(crisisLevel).toBe(0);
  });

  it('should return a high crisis level for text with crisis keywords', () => {
    const text = 'I want to kill myself.';
    const emotionalState: EmotionalState = { dominantEmotion: 'sadness', intensity: 0.9 };
    const crisisLevel = crisisDetector.detectCrisis(text, emotionalState);
    expect(crisisLevel).toBe(5);
  });

  it('should consider emotional state when calculating crisis level', () => {
    const text = 'I feel so alone.';
    const emotionalState: EmotionalState = { dominantEmotion: 'sadness', intensity: 0.95 };
    const crisisLevel = crisisDetector.detectCrisis(text, emotionalState);
    expect(crisisLevel).toBe(2);
  });
}); 