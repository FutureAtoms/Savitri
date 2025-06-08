import { TherapeuticEngine } from '../therapeutic-engine';
import { EmotionalState } from '../types';

describe('TherapeuticEngine', () => {
  let therapeuticEngine: TherapeuticEngine;

  beforeEach(() => {
    therapeuticEngine = new TherapeuticEngine();
  });

  it('should return a normal therapeutic response for non-crisis input', () => {
    const userInput = 'I had a stressful day at work.';
    const emotionalState: EmotionalState = { dominantEmotion: 'stress', intensity: 0.7 };
    const response = therapeuticEngine.generateTherapeuticResponse(userInput, emotionalState);
    expect(response.protocol).toBe('CBT');
  });

  it('should return a crisis response for input with high crisis level', () => {
    const userInput = 'I want to end my life.';
    const emotionalState: EmotionalState = { dominantEmotion: 'sadness', intensity: 0.9 };
    const response = therapeuticEngine.generateTherapeuticResponse(userInput, emotionalState);
    expect(response.protocol).toBe('CRISIS');
  });
}); 