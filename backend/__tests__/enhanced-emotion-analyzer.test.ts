import { EnhancedEmotionAnalyzer } from '../clinical/enhanced-emotion-analyzer';
import { EmotionFeatures } from '../clinical/types';

describe('EnhancedEmotionAnalyzer', () => {
  let emotionAnalyzer: EnhancedEmotionAnalyzer;

  beforeEach(() => {
    emotionAnalyzer = new EnhancedEmotionAnalyzer();
  });

  it('should return a valid EmotionResult', async () => {
    const features: EmotionFeatures = {
      pitch: 150,
      pitchVariability: 0.1,
      energy: 0.5,
      spectralCentroid: 1500,
      zeroCrossingRate: 0.1,
      mfcc: [],
      speechRate: 1.0,
      pauseRatio: 0.2,
    };
    const result = await emotionAnalyzer.analyzeEmotions(features);
    expect(result).toBeDefined();
    expect(result.primary).toBeDefined();
  });
}); 