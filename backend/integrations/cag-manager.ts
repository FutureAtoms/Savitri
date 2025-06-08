export type TherapeuticProtocol = 'CBT' | 'DBT' | 'ACT' | 'Mindfulness' | 'Crisis Intervention' | 'Integrative';

export interface TherapeuticTechnique {
  name: string;
  content: string;
  protocol: TherapeuticProtocol;
  relevanceScore: number;
  evidenceLevel: 'high' | 'medium' | 'low';
  applicableEmotions?: string[];
  contraindicatedConditions?: string[];
}

export interface ProtocolLibrary {
  [key: string]: TherapeuticTechnique[];
}

export class CAGManager {
  private protocolLibrary: ProtocolLibrary = {};
  private initialized = false;

  async loadProtocols(protocols: TherapeuticProtocol[]): Promise<void> {
    for (const protocol of protocols) {
      await this.loadProtocol(protocol);
    }
    this.initialized = true;
  }

  private async loadProtocol(protocol: TherapeuticProtocol): Promise<void> {
    // In production, these would be loaded from a database or file system
    switch (protocol) {
      case 'CBT':
        this.protocolLibrary['CBT'] = this.getCBTTechniques();
        break;
      case 'DBT':
        this.protocolLibrary['DBT'] = this.getDBTTechniques();
        break;
      case 'ACT':
        this.protocolLibrary['ACT'] = this.getACTTechniques();
        break;
      case 'Mindfulness':
        this.protocolLibrary['Mindfulness'] = this.getMindfulnessTechniques();
        break;
      case 'Crisis Intervention':
        this.protocolLibrary['Crisis Intervention'] = this.getCrisisInterventionTechniques();
        break;
    }
  }

  async getRelevantTechniques(
    protocol: TherapeuticProtocol,
    userInput: string,
    emotionalState: any
  ): Promise<TherapeuticTechnique[]> {
    if (!this.initialized) {
      throw new Error('CAG Manager not initialized');
    }

    const techniques = this.protocolLibrary[protocol] || [];
    
    // Score techniques based on relevance to user input and emotional state
    const scoredTechniques = techniques.map(technique => ({
      ...technique,
      relevanceScore: this.calculateRelevance(technique, userInput, emotionalState)
    }));

    // Sort by relevance and return top techniques
    return scoredTechniques
      .sort((a, b) => b.relevanceScore - a.relevanceScore)
      .slice(0, 3);
  }

  private calculateRelevance(
    technique: TherapeuticTechnique,
    userInput: string,
    emotionalState: any
  ): number {
    let score = 0.5; // Base score

    // Check if technique is applicable to current emotion
    if (technique.applicableEmotions?.includes(emotionalState.primaryEmotion)) {
      score += 0.2;
    }

    // Check for keyword matches
    const keywords = this.extractKeywords(userInput);
    const techniqueKeywords = this.extractKeywords(technique.content);
    const overlap = this.calculateKeywordOverlap(keywords, techniqueKeywords);
    score += overlap * 0.3;

    // Adjust based on evidence level
    if (technique.evidenceLevel === 'high') score += 0.1;
    if (technique.evidenceLevel === 'medium') score += 0.05;

    return Math.min(score, 1.0);
  }

  private extractKeywords(text: string): string[] {
    // Simple keyword extraction - in production, use NLP
    return text.toLowerCase()
      .split(/\W+/)
      .filter(word => word.length > 3)
      .filter(word => !this.isStopWord(word));
  }

  private isStopWord(word: string): boolean {
    const stopWords = ['the', 'and', 'but', 'for', 'with', 'this', 'that', 'have', 'from'];
    return stopWords.includes(word);
  }

  private calculateKeywordOverlap(keywords1: string[], keywords2: string[]): number {
    const set1 = new Set(keywords1);
    const set2 = new Set(keywords2);
    const intersection = new Set([...set1].filter(x => set2.has(x)));
    return intersection.size / Math.max(set1.size, set2.size);
  }

  private getCBTTechniques(): TherapeuticTechnique[] {
    return [
      {
        name: 'Thought Record',
        content: 'Let\'s examine this thought more closely. Can you identify the specific thought that\'s troubling you? Once we identify it, we can look at the evidence for and against this thought, and work on developing a more balanced perspective.',
        protocol: 'CBT',
        relevanceScore: 0,
        evidenceLevel: 'high',
        applicableEmotions: ['anxiety', 'depression', 'anger']
      },
      {
        name: 'Cognitive Restructuring',
        content: 'I notice you might be experiencing some cognitive distortions. Let\'s work on reframing these thoughts. What would you say to a friend who had this same thought? Often we\'re much kinder and more realistic with others than ourselves.',
        protocol: 'CBT',
        relevanceScore: 0,
        evidenceLevel: 'high',
        applicableEmotions: ['anxiety', 'depression', 'guilt']
      },
      {
        name: 'Behavioral Activation',
        content: 'When we\'re feeling down, it\'s natural to withdraw from activities. However, engaging in pleasant activities can help improve mood. What\'s one small activity you used to enjoy that you could try today, even for just 10 minutes?',
        protocol: 'CBT',
        relevanceScore: 0,
        evidenceLevel: 'high',
        applicableEmotions: ['depression', 'apathy']
      },
      {
        name: 'Problem-Solving Therapy',
        content: 'Let\'s break down this problem into smaller, manageable steps. First, can you clearly define the problem? Then we\'ll brainstorm possible solutions without judging them, and finally evaluate which might work best for you.',
        protocol: 'CBT',
        relevanceScore: 0,
        evidenceLevel: 'medium',
        applicableEmotions: ['stress', 'anxiety', 'overwhelm']
      }
    ];
  }

  private getDBTTechniques(): TherapeuticTechnique[] {
    return [
      {
        name: 'TIPP',
        content: 'When emotions feel overwhelming, try TIPP: Temperature (cold water on face), Intense exercise (jumping jacks for 1 minute), Paced breathing (breathe out longer than in), and Paired muscle relaxation. These can quickly reduce emotional intensity.',
        protocol: 'DBT',
        relevanceScore: 0,
        evidenceLevel: 'high',
        applicableEmotions: ['distress', 'panic', 'anger']
      },
      {
        name: 'Radical Acceptance',
        content: 'Sometimes we suffer not from the pain itself, but from our non-acceptance of the pain. Radical acceptance means acknowledging reality as it is, without approving or liking it. What would it feel like to stop fighting this reality, just for a moment?',
        protocol: 'DBT',
        relevanceScore: 0,
        evidenceLevel: 'high',
        applicableEmotions: ['grief', 'disappointment', 'frustration']
      },
      {
        name: 'Opposite Action',
        content: 'When emotions don\'t fit the facts or aren\'t effective, try acting opposite to the emotion urge. If anxiety says hide, gently approach. If anger says attack, gently avoid or be kind. What would be the opposite action to what you\'re feeling urged to do right now?',
        protocol: 'DBT',
        relevanceScore: 0,
        evidenceLevel: 'high',
        applicableEmotions: ['anxiety', 'anger', 'shame']
      },
      {
        name: 'PLEASE Skills',
        content: 'Taking care of your body helps emotional regulation. PLEASE stands for: treat PhysicaL illness, balance Eating, avoid mood-Altering substances, balance Sleep, and get Exercise. Which of these areas might need attention right now?',
        protocol: 'DBT',
        relevanceScore: 0,
        evidenceLevel: 'medium',
        applicableEmotions: ['irritability', 'mood swings', 'emotional sensitivity']
      }
    ];
  }

  private getACTTechniques(): TherapeuticTechnique[] {
    return [
      {
        name: 'Values Clarification',
        content: 'Let\'s connect with what truly matters to you. If this struggle magically disappeared tomorrow, what would you do differently? What would you move toward? These hints can help us identify your core values.',
        protocol: 'ACT',
        relevanceScore: 0,
        evidenceLevel: 'high',
        applicableEmotions: ['confusion', 'emptiness', 'disconnection']
      },
      {
        name: 'Defusion',
        content: 'You\'re having the thought that [repeat their thought]. Notice how I added "You\'re having the thought that..." This small shift can help you see thoughts as mental events rather than facts. Try saying it this way and notice what happens.',
        protocol: 'ACT',
        relevanceScore: 0,
        evidenceLevel: 'high',
        applicableEmotions: ['rumination', 'worry', 'obsessive thoughts']
      },
      {
        name: 'Expansion',
        content: 'Instead of struggling with this feeling, what if we made room for it? Breathe into the sensation. Imagine your breath flowing around it, creating space. You don\'t have to like it, just allow it to be there while you focus on what matters.',
        protocol: 'ACT',
        relevanceScore: 0,
        evidenceLevel: 'medium',
        applicableEmotions: ['anxiety', 'pain', 'discomfort']
      },
      {
        name: 'Committed Action',
        content: 'What\'s one small step you could take today that aligns with your values, even while carrying these difficult feelings? We\'re not waiting for the feelings to change - we\'re learning to act with purpose despite them.',
        protocol: 'ACT',
        relevanceScore: 0,
        evidenceLevel: 'high',
        applicableEmotions: ['avoidance', 'procrastination', 'fear']
      }
    ];
  }

  private getMindfulnessTechniques(): TherapeuticTechnique[] {
    return [
      {
        name: 'Breath Awareness',
        content: 'Let\'s pause and turn attention to your breath. No need to change it, just notice it. Follow the sensation of breathing in and out. When your mind wanders (and it will), gently return attention to the breath. This is the practice.',
        protocol: 'Mindfulness',
        relevanceScore: 0,
        evidenceLevel: 'high',
        applicableEmotions: ['anxiety', 'stress', 'overwhelm']
      },
      {
        name: 'Body Scan',
        content: 'Starting at the top of your head, slowly move your attention through your body. Notice any sensations without trying to change them. Tension, relaxation, warmth, coolness - just notice. This helps us reconnect with the present moment.',
        protocol: 'Mindfulness',
        relevanceScore: 0,
        evidenceLevel: 'high',
        applicableEmotions: ['dissociation', 'anxiety', 'stress']
      },
      {
        name: 'RAIN Technique',
        content: 'Try RAIN with this feeling: Recognize what\'s happening, Allow the experience to be there, Investigate with kindness (how does it feel in your body?), and Nurture with self-compassion. What do you notice as you do this?',
        protocol: 'Mindfulness',
        relevanceScore: 0,
        evidenceLevel: 'medium',
        applicableEmotions: ['sadness', 'fear', 'shame']
      },
      {
        name: '5-4-3-2-1 Grounding',
        content: 'Let\'s ground in the present moment. Name 5 things you can see, 4 things you can touch, 3 things you can hear, 2 things you can smell, and 1 thing you can taste. This anchors us in the here and now.',
        protocol: 'Mindfulness',
        relevanceScore: 0,
        evidenceLevel: 'medium',
        applicableEmotions: ['panic', 'dissociation', 'flashback']
      }
    ];
  }

  private getCrisisInterventionTechniques(): TherapeuticTechnique[] {
    return [
      {
        name: 'Safety Planning',
        content: 'Your safety is my primary concern. Let\'s create a safety plan together. Who can you reach out to right now for support? What has helped you get through difficult moments before? Let\'s identify specific steps you can take to stay safe.',
        protocol: 'Crisis Intervention',
        relevanceScore: 0,
        evidenceLevel: 'high',
        applicableEmotions: ['suicidal ideation', 'self-harm urges']
      },
      {
        name: 'Crisis Resources',
        content: 'I want to make sure you have immediate support available. The 988 Suicide & Crisis Lifeline is available 24/7. You can also text "HELLO" to 741741 for the Crisis Text Line. Would you like me to stay with you while you reach out?',
        protocol: 'Crisis Intervention',
        relevanceScore: 0,
        evidenceLevel: 'high',
        applicableEmotions: ['crisis', 'emergency']
      },
      {
        name: 'Immediate Coping',
        content: 'Right now, let\'s focus on getting through this moment. Can you do something to change your physical state? Splash cold water on your face, step outside for fresh air, or call someone you trust. These immediate actions can help interrupt the crisis spiral.',
        protocol: 'Crisis Intervention',
        relevanceScore: 0,
        evidenceLevel: 'high',
        applicableEmotions: ['acute distress', 'panic']
      }
    ];
  }
}
