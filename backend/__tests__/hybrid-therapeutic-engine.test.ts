import { HybridTherapeuticEngine, QueryContext } from '../clinical/hybrid-therapeutic-engine';
import { EmotionalState } from '../clinical/types';

describe('HybridTherapeuticEngine', () => {
  let engine: HybridTherapeuticEngine;

  beforeEach(async () => {
    engine = new HybridTherapeuticEngine();
    await engine.initialize();
  });

  describe('Crisis Detection', () => {
    it('should immediately return crisis response for high crisis level', async () => {
      const context: QueryContext = {
        userInput: 'I want to end it all. I can\'t take this anymore.',
        emotionalState: {
          timestamp: new Date(),
          valence: -1,
          arousal: 0.9,
          dominance: 0.1,
          primaryEmotion: 'despair'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response.isCrisis).toBe(true);
      expect(response.protocol).toBe('CRISIS');
      expect(response.technique).toBe('Crisis Intervention');
      expect(response.therapeuticSuggestions).toContain('Call 988 (Suicide & Crisis Lifeline) for immediate support');
    });

    it('should not trigger crisis response for non-crisis input', async () => {
      const context: QueryContext = {
        userInput: 'I\'m feeling a bit sad today because of the weather.',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.3,
          arousal: 0.2,
          dominance: 0.5,
          primaryEmotion: 'sadness'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response.isCrisis).toBe(false);
      expect(response.protocol).not.toBe('CRISIS');
    });
  });

  describe('Retrieval Strategy Selection', () => {
    it('should use CAG for protocol-specific queries', async () => {
      const context: QueryContext = {
        userInput: 'Can you help me with a thought record for my anxiety?',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.4,
          arousal: 0.6,
          dominance: 0.4,
          primaryEmotion: 'anxiety'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response.protocol).toBe('CBT');
      expect(response.metadata?.retrievalStrategy).toBe('CAG');
    });

    it('should use RAG for queries requiring external information', async () => {
      const context: QueryContext = {
        userInput: 'What do recent studies say about mindfulness for depression?',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.2,
          arousal: 0.3,
          dominance: 0.5,
          primaryEmotion: 'curiosity'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response.metadata?.retrievalStrategy).toBe('RAG');
    });

    it('should use HYBRID strategy for complex queries', async () => {
      const context: QueryContext = {
        userInput: 'I\'ve been practicing CBT techniques but still struggle with accepting my emotions. What else can I try?',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.5,
          arousal: 0.5,
          dominance: 0.4,
          primaryEmotion: 'frustration'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      // Response should blend CBT and ACT approaches
      expect(['CBT', 'ACT', 'Integrative']).toContain(response.protocol);
    });
  });

  describe('Protocol Selection', () => {
    it('should select CBT for cognitive distortions', async () => {
      const context: QueryContext = {
        userInput: 'I always mess everything up. I\'m such a failure and everyone must think I\'m stupid.',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.8,
          arousal: 0.7,
          dominance: 0.2,
          primaryEmotion: 'shame'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response.protocol).toBe('CBT');
      expect(response.technique).toContain('Cognitive Restructuring');
    });

    it('should select DBT for emotional dysregulation', async () => {
      const context: QueryContext = {
        userInput: 'I feel like I\'m going to explode. My emotions are too intense to handle.',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.6,
          arousal: 0.9,
          dominance: 0.2,
          primaryEmotion: 'distress'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response.protocol).toBe('DBT');
    });

    it('should select ACT for acceptance issues', async () => {
      const context: QueryContext = {
        userInput: 'I can\'t accept that this happened to me. Why did it have to be me?',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.7,
          arousal: 0.5,
          dominance: 0.3,
          primaryEmotion: 'grief'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response.protocol).toBe('ACT');
    });

    it('should default to Mindfulness for general distress', async () => {
      const context: QueryContext = {
        userInput: 'I\'m feeling overwhelmed with everything going on.',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.5,
          arousal: 0.6,
          dominance: 0.4,
          primaryEmotion: 'stress'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response.protocol).toBe('Mindfulness');
    });
  });

  describe('Historical Context Integration', () => {
    it('should personalize response based on user history', async () => {
      const context: QueryContext = {
        userInput: 'I\'m having those anxious thoughts again.',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.5,
          arousal: 0.7,
          dominance: 0.4,
          primaryEmotion: 'anxiety'
        },
        userId: 'test-user-123',
        sessionHistory: ['Previous discussion about work anxiety', 'Practiced thought records']
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response.metadata?.personalizedElements).toBe(true);
    });

    it('should handle queries without user history', async () => {
      const context: QueryContext = {
        userInput: 'I\'m feeling anxious about my presentation.',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.4,
          arousal: 0.6,
          dominance: 0.5,
          primaryEmotion: 'anxiety'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response.metadata?.personalizedElements).toBe(false);
    });
  });

  describe('Response Quality', () => {
    it('should include emotional validation in all responses', async () => {
      const contexts: QueryContext[] = [
        {
          userInput: 'I feel so alone.',
          emotionalState: {
            timestamp: new Date(),
            valence: -0.7,
            arousal: 0.3,
            dominance: 0.3,
            primaryEmotion: 'loneliness'
          }
        },
        {
          userInput: 'I\'m angry at everyone.',
          emotionalState: {
            timestamp: new Date(),
            valence: -0.6,
            arousal: 0.8,
            dominance: 0.6,
            primaryEmotion: 'anger'
          }
        }
      ];

      for (const context of contexts) {
        const response = await engine.generateTherapeuticResponse(context);
        expect(response.emotionalValidation).toBeTruthy();
        expect(response.emotionalValidation.length).toBeGreaterThan(10);
      }
    });

    it('should provide actionable therapeutic suggestions', async () => {
      const context: QueryContext = {
        userInput: 'I can\'t stop worrying about everything.',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.5,
          arousal: 0.7,
          dominance: 0.4,
          primaryEmotion: 'worry'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response.therapeuticSuggestions).toBeDefined();
      expect(response.therapeuticSuggestions.length).toBeGreaterThan(0);
      expect(response.therapeuticSuggestions[0]).toContain('try');
    });

    it('should maintain appropriate confidence scores', async () => {
      const context: QueryContext = {
        userInput: 'Tell me about managing stress.',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.3,
          arousal: 0.5,
          dominance: 0.5,
          primaryEmotion: 'stress'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response.metadata?.confidenceScore).toBeGreaterThan(0);
      expect(response.metadata?.confidenceScore).toBeLessThanOrEqual(1);
    });
  });

  describe('Edge Cases', () => {
    it('should handle empty user input gracefully', async () => {
      const context: QueryContext = {
        userInput: '',
        emotionalState: {
          timestamp: new Date(),
          valence: 0,
          arousal: 0.5,
          dominance: 0.5,
          primaryEmotion: 'neutral'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response).toBeDefined();
      expect(response.response).toBeTruthy();
    });

    it('should handle very long user input', async () => {
      const longInput = 'I have been feeling overwhelmed. '.repeat(50);
      const context: QueryContext = {
        userInput: longInput,
        emotionalState: {
          timestamp: new Date(),
          valence: -0.5,
          arousal: 0.6,
          dominance: 0.4,
          primaryEmotion: 'overwhelm'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response).toBeDefined();
      expect(response.protocol).toBeTruthy();
    });

    it('should handle mixed emotional states', async () => {
      const context: QueryContext = {
        userInput: 'I feel happy about the progress but also scared it won\'t last.',
        emotionalState: {
          timestamp: new Date(),
          valence: 0.1, // Slightly positive
          arousal: 0.6,
          dominance: 0.5,
          primaryEmotion: 'mixed'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response).toBeDefined();
      expect(response.emotionalValidation).toContain('feel');
    });
  });

  describe('Performance', () => {
    it('should respond within acceptable time limits', async () => {
      const context: QueryContext = {
        userInput: 'I need help with my anxiety.',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.4,
          arousal: 0.6,
          dominance: 0.4,
          primaryEmotion: 'anxiety'
        }
      };

      const startTime = Date.now();
      const response = await engine.generateTherapeuticResponse(context);
      const endTime = Date.now();

      expect(response).toBeDefined();
      expect(endTime - startTime).toBeLessThan(2500); // Should respond within 2.5 seconds
    });

    it('should handle concurrent requests', async () => {
      const contexts: QueryContext[] = Array(5).fill(null).map((_, i) => ({
        userInput: `I'm feeling stressed about issue ${i}`,
        emotionalState: {
          timestamp: new Date(),
          valence: -0.5,
          arousal: 0.6,
          dominance: 0.4,
          primaryEmotion: 'stress'
        }
      }));

      const responses = await Promise.all(
        contexts.map(context => engine.generateTherapeuticResponse(context))
      );

      expect(responses).toHaveLength(5);
      responses.forEach(response => {
        expect(response).toBeDefined();
        expect(response.protocol).toBeTruthy();
      });
    });
  });

  describe('Integration Tests', () => {
    it('should integrate CAG and RAG seamlessly', async () => {
      const context: QueryContext = {
        userInput: 'I read about CBT helping with anxiety. Can you show me how to apply it to my situation?',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.4,
          arousal: 0.6,
          dominance: 0.5,
          primaryEmotion: 'anxiety'
        }
      };

      const response = await engine.generateTherapeuticResponse(context);

      expect(response.protocol).toBe('CBT');
      expect(response.technique).toBeTruthy();
      expect(response.response).toContain('thought');
    });

    it('should store and retrieve user interactions', async () => {
      const userId = 'test-user-' + Date.now();
      
      // First interaction
      const context1: QueryContext = {
        userInput: 'I\'m struggling with negative thoughts.',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.6,
          arousal: 0.5,
          dominance: 0.4,
          primaryEmotion: 'sadness'
        },
        userId
      };

      await engine.generateTherapeuticResponse(context1);

      // Second interaction should have context
      const context2: QueryContext = {
        userInput: 'The thoughts are getting worse.',
        emotionalState: {
          timestamp: new Date(),
          valence: -0.7,
          arousal: 0.6,
          dominance: 0.3,
          primaryEmotion: 'sadness'
        },
        userId
      };

      const response2 = await engine.generateTherapeuticResponse(context2);

      expect(response2.metadata?.personalizedElements).toBe(true);
    });
  });
});
