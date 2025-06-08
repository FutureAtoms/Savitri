import { TherapeuticResponse, EmotionalState } from './types';
import { CrisisDetector } from './crisis-detector';
import { GraphitiClient } from '../integrations/graphiti-client';
import { CAGManager, TherapeuticProtocol } from '../integrations/cag-manager';
import { VectorDatabase } from '../integrations/vector-database';

export interface QueryContext {
  userInput: string;
  emotionalState: EmotionalState;
  sessionHistory?: string[];
  userId?: string;
  currentProtocol?: string;
}

export interface RetrievalResult {
  content: string;
  source: 'CAG' | 'RAG';
  relevanceScore: number;
  protocol?: string;
  metadata?: Record<string, any>;
}

export class HybridTherapeuticEngine {
  private crisisDetector: CrisisDetector;
  private graphitiClient: GraphitiClient;
  private cagManager: CAGManager;
  private vectorDb: VectorDatabase;
  
  // Thresholds for hybrid decision making
  private readonly CAG_THRESHOLD = 0.85; // High confidence for pre-loaded protocols
  private readonly RAG_THRESHOLD = 0.7;  // Medium confidence for retrieval
  private readonly HYBRID_THRESHOLD = 0.6; // Low confidence - use both

  constructor() {
    this.crisisDetector = new CrisisDetector();
    this.graphitiClient = new GraphitiClient();
    this.cagManager = new CAGManager();
    this.vectorDb = new VectorDatabase();
  }

  async initialize(): Promise<void> {
    // Load therapeutic protocols into CAG
    await this.cagManager.loadProtocols([
      'CBT', 'DBT', 'ACT', 'Mindfulness', 'Crisis Intervention'
    ]);
    
    // Initialize vector database for RAG
    await this.vectorDb.initialize();
    
    // Connect to Graphiti for temporal knowledge
    await this.graphitiClient.connect();
  }

  async generateTherapeuticResponse(
    context: QueryContext
  ): Promise<TherapeuticResponse> {
    // 1. Crisis Detection - Always runs first
    const crisisLevel = this.crisisDetector.detectCrisis(
      context.userInput, 
      context.emotionalState
    );

    if (crisisLevel >= 5) {
      return this.generateCrisisResponse();
    }

    // 2. Determine best retrieval strategy
    const strategy = await this.determineRetrievalStrategy(context);
    
    // 3. Retrieve relevant content based on strategy
    const retrievalResults = await this.retrieveContent(context, strategy);
    
    // 4. Get historical context from Graphiti
    const historicalContext = await this.getHistoricalContext(context.userId);
    
    // 5. Generate response using retrieved content
    const response = await this.synthesizeResponse(
      context,
      retrievalResults,
      historicalContext
    );

    // 6. Store interaction in Graphiti for future sessions
    if (context.userId) {
      await this.storeInteraction(context, response);
    }

    return response;
  }

  private async determineRetrievalStrategy(
    context: QueryContext
  ): Promise<'CAG' | 'RAG' | 'HYBRID'> {
    // Analyze query characteristics
    const queryFeatures = this.analyzeQuery(context.userInput);
    
    // Check if query matches known therapeutic patterns
    if (queryFeatures.isCrisisRelated || queryFeatures.isProtocolSpecific) {
      return 'CAG'; // Use pre-loaded protocols for critical/specific queries
    }
    
    // Check if query is about recent/external information
    if (queryFeatures.requiresExternalInfo || queryFeatures.isTimeSpecific) {
      return 'RAG'; // Use retrieval for recent/external information
    }
    
    // Default to hybrid for complex or ambiguous queries
    return 'HYBRID';
  }

  private analyzeQuery(userInput: string): any {
    const lowerInput = userInput.toLowerCase();
    
    return {
      isCrisisRelated: this.containsCrisisKeywords(lowerInput),
      isProtocolSpecific: this.containsProtocolKeywords(lowerInput),
      requiresExternalInfo: this.requiresExternalInformation(lowerInput),
      isTimeSpecific: this.containsTemporalMarkers(lowerInput),
      complexity: this.calculateComplexity(userInput)
    };
  }

  private containsCrisisKeywords(input: string): boolean {
    const crisisKeywords = [
      'suicide', 'hurt myself', 'end it', 'worthless', 
      'no hope', 'can\'t go on', 'self harm'
    ];
    return crisisKeywords.some(keyword => input.includes(keyword));
  }

  private containsProtocolKeywords(input: string): boolean {
    const protocolKeywords = [
      'thought record', 'behavioral activation', 'exposure',
      'mindfulness', 'distress tolerance', 'radical acceptance'
    ];
    return protocolKeywords.some(keyword => input.includes(keyword));
  }

  private requiresExternalInformation(input: string): boolean {
    const externalMarkers = [
      'research', 'study', 'article', 'news', 
      'latest', 'recent findings', 'what do experts'
    ];
    return externalMarkers.some(marker => input.includes(marker));
  }

  private containsTemporalMarkers(input: string): boolean {
    const temporalMarkers = [
      'today', 'yesterday', 'last week', 'recently',
      'lately', 'these days', 'since'
    ];
    return temporalMarkers.some(marker => input.includes(marker));
  }

  private calculateComplexity(input: string): number {
    // Simple complexity calculation based on length and sentence structure
    const sentences = input.split(/[.!?]+/).filter(s => s.trim().length > 0);
    const avgWordsPerSentence = input.split(' ').length / sentences.length;
    return Math.min(avgWordsPerSentence / 20, 1); // Normalize to 0-1
  }

  private async retrieveContent(
    context: QueryContext,
    strategy: 'CAG' | 'RAG' | 'HYBRID'
  ): Promise<RetrievalResult[]> {
    const results: RetrievalResult[] = [];

    if (strategy === 'CAG' || strategy === 'HYBRID') {
      // Retrieve from pre-loaded therapeutic protocols
      const cagResults = await this.retrieveFromCAG(context);
      results.push(...cagResults);
    }

    if (strategy === 'RAG' || strategy === 'HYBRID') {
      // Retrieve from vector database
      const ragResults = await this.retrieveFromRAG(context);
      results.push(...ragResults);
    }

    // Sort by relevance score
    return results.sort((a, b) => b.relevanceScore - a.relevanceScore);
  }

  private async retrieveFromCAG(
    context: QueryContext
  ): Promise<RetrievalResult[]> {
    const results: RetrievalResult[] = [];
    
    // Determine most relevant protocol based on emotional state and input
    const protocol = this.selectTherapeuticProtocol(context);
    
    // Get relevant techniques from the protocol
    const techniques = await this.cagManager.getRelevantTechniques(
      protocol,
      context.userInput,
      context.emotionalState
    );

    for (const technique of techniques) {
      results.push({
        content: technique.content,
        source: 'CAG',
        relevanceScore: technique.relevanceScore,
        protocol: protocol,
        metadata: {
          technique: technique.name,
          evidenceLevel: technique.evidenceLevel
        }
      });
    }

    return results;
  }

  private selectTherapeuticProtocol(context: QueryContext): TherapeuticProtocol {
    const { emotionalState, userInput } = context;
    
    // CBT for cognitive distortions and thought patterns
    if (this.detectsCognitiveDistortion(userInput)) {
      return 'CBT';
    }
    
    // DBT for emotional dysregulation
    if (emotionalState.valence < -0.5 && emotionalState.arousal > 0.7) {
      return 'DBT';
    }
    
    // ACT for acceptance and values-based issues
    if (this.detectsAcceptanceIssues(userInput)) {
      return 'ACT';
    }
    
    // Default to Mindfulness for general distress
    return 'Mindfulness';
  }

  private detectsCognitiveDistortion(input: string): boolean {
    const distortionPatterns = [
      'always', 'never', 'everyone', 'no one',
      'should', 'must', 'terrible', 'awful',
      'can\'t', 'impossible', 'failure', 'stupid'
    ];
    return distortionPatterns.some(pattern => 
      input.toLowerCase().includes(pattern)
    );
  }

  private detectsAcceptanceIssues(input: string): boolean {
    const acceptancePatterns = [
      'can\'t accept', 'wish it was different', 'hate that',
      'fighting with', 'struggling to accept', 'why me'
    ];
    return acceptancePatterns.some(pattern => 
      input.toLowerCase().includes(pattern)
    );
  }

  private async retrieveFromRAG(
    context: QueryContext
  ): Promise<RetrievalResult[]> {
    // Generate embedding for the query
    const queryEmbedding = await this.vectorDb.generateEmbedding(
      context.userInput
    );
    
    // Search vector database for relevant content
    const searchResults = await this.vectorDb.search(
      queryEmbedding,
      {
        topK: 5,
        threshold: this.RAG_THRESHOLD,
        filters: {
          type: 'therapeutic_content',
          emotionalRelevance: context.emotionalState.primaryEmotion
        }
      }
    );

    return searchResults.map(result => ({
      content: result.content,
      source: 'RAG' as const,
      relevanceScore: result.score,
      metadata: result.metadata
    }));
  }

  private async getHistoricalContext(
    userId?: string
  ): Promise<any> {
    if (!userId) return null;

    try {
      // Query Graphiti for user's session history
      const history = await this.graphitiClient.queryUserHistory(userId, {
        limit: 5,
        includeEmotionalTrajectory: true,
        includeTherapeuticProgress: true
      });

      return {
        recentThemes: history.themes,
        emotionalTrajectory: history.emotionalTrajectory,
        progressIndicators: history.progress,
        previousProtocols: history.protocols
      };
    } catch (error) {
      console.error('Error fetching historical context:', error);
      return null;
    }
  }

  private async synthesizeResponse(
    context: QueryContext,
    retrievalResults: RetrievalResult[],
    historicalContext: any
  ): Promise<TherapeuticResponse> {
    // Select best content based on relevance and source diversity
    const selectedContent = this.selectBestContent(retrievalResults);
    
    // Determine therapeutic approach based on all available information
    const approach = this.determineTherapeuticApproach(
      context,
      selectedContent,
      historicalContext
    );

    // Generate the actual response
    const response = await this.generateResponse(
      context,
      selectedContent,
      approach,
      historicalContext
    );

    return response;
  }

  private selectBestContent(
    results: RetrievalResult[]
  ): RetrievalResult[] {
    const selected: RetrievalResult[] = [];
    const usedSources = new Set<string>();

    // Prefer diverse sources up to 3 results
    for (const result of results) {
      if (selected.length >= 3) break;
      
      // Always include high-confidence CAG results
      if (result.source === 'CAG' && result.relevanceScore >= this.CAG_THRESHOLD) {
        selected.push(result);
        usedSources.add(result.source);
      }
      // Include RAG results if relevant and diverse
      else if (result.relevanceScore >= this.RAG_THRESHOLD && 
               !usedSources.has(result.source)) {
        selected.push(result);
        usedSources.add(result.source);
      }
    }

    return selected;
  }

  private determineTherapeuticApproach(
    context: QueryContext,
    selectedContent: RetrievalResult[],
    historicalContext: any
  ): any {
    // Analyze patterns in selected content
    const protocols = selectedContent
      .filter(r => r.protocol)
      .map(r => r.protocol!);
    
    const primaryProtocol = protocols[0] || 'Integrative';
    
    // Consider historical effectiveness
    let adjustedApproach = primaryProtocol;
    if (historicalContext?.previousProtocols) {
      const effectiveProtocols = historicalContext.previousProtocols
        .filter((p: any) => p.effectiveness > 0.7);
      
      if (effectiveProtocols.length > 0) {
        adjustedApproach = effectiveProtocols[0].name;
      }
    }

    return {
      primaryProtocol: adjustedApproach,
      techniques: this.selectTechniques(selectedContent),
      personalizationLevel: historicalContext ? 'high' : 'medium'
    };
  }

  private selectTechniques(content: RetrievalResult[]): string[] {
    return content
      .filter(r => r.metadata?.technique)
      .map(r => r.metadata!.technique)
      .slice(0, 3); // Limit to 3 techniques
  }

  private async generateResponse(
    context: QueryContext,
    selectedContent: RetrievalResult[],
    approach: any,
    historicalContext: any
  ): Promise<TherapeuticResponse> {
    // Construct prompt with all context
    const prompt = this.constructTherapeuticPrompt(
      context,
      selectedContent,
      approach,
      historicalContext
    );

    // Generate response using the constructed prompt
    // In production, this would call Gemini AI
    const generatedText = await this.callGeminiAI(prompt);

    // Extract therapeutic elements from generated response
    const therapeuticElements = this.extractTherapeuticElements(
      generatedText,
      approach.primaryProtocol
    );

    return {
      timestamp: new Date(),
      protocol: approach.primaryProtocol,
      technique: approach.techniques[0] || 'Supportive Listening',
      response: therapeuticElements.mainResponse,
      emotionalValidation: therapeuticElements.validation,
      therapeuticSuggestions: therapeuticElements.suggestions,
      isCrisis: false,
      metadata: {
        retrievalStrategy: selectedContent[0]?.source,
        confidenceScore: selectedContent[0]?.relevanceScore || 0,
        personalizedElements: historicalContext ? true : false
      }
    };
  }

  private constructTherapeuticPrompt(
    context: QueryContext,
    content: RetrievalResult[],
    approach: any,
    history: any
  ): string {
    let prompt = `You are an empathetic AI therapist using ${approach.primaryProtocol} approach.\n\n`;
    
    prompt += `Client's current emotional state: ${JSON.stringify(context.emotionalState)}\n`;
    prompt += `Client says: "${context.userInput}"\n\n`;
    
    if (history) {
      prompt += `Historical context: Recent themes include ${history.recentThemes.join(', ')}.\n`;
      prompt += `Emotional trajectory: ${history.emotionalTrajectory}\n\n`;
    }
    
    prompt += `Relevant therapeutic content:\n`;
    content.forEach((item, idx) => {
      prompt += `${idx + 1}. [${item.source}] ${item.content}\n`;
    });
    
    prompt += `\nGenerate a therapeutic response that:
    1. Validates the client's emotions
    2. Uses ${approach.techniques.join(' or ')} techniques
    3. Provides actionable suggestions
    4. Maintains professional boundaries
    5. Is warm and empathetic\n`;

    return prompt;
  }

  private async callGeminiAI(prompt: string): Promise<string> {
    // Placeholder for Gemini AI integration
    // In production, this would make actual API call
    return `I hear that you're going through a difficult time. Your feelings are valid and it's okay to feel this way. 

    Let's explore what's happening for you right now. When you notice these thoughts coming up, what do you observe in your body? Sometimes our physical sensations can give us clues about our emotional state.

    One technique that might help is to pause and take three deep breaths when you notice these feelings intensifying. This can create a small space between you and the emotion, allowing you to respond rather than react.`;
  }

  private extractTherapeuticElements(
    generatedText: string,
    protocol: string
  ): any {
    // Parse generated text to extract therapeutic components
    // This is a simplified implementation
    const lines = generatedText.split('\n').filter(l => l.trim());
    
    return {
      mainResponse: lines[0] || 'I hear you.',
      validation: lines.find(l => l.includes('feel') || l.includes('valid')) || 
                  'Your feelings are valid.',
      suggestions: lines
        .filter(l => l.includes('try') || l.includes('might help') || l.includes('technique'))
        .slice(0, 3)
    };
  }

  private async storeInteraction(
    context: QueryContext,
    response: TherapeuticResponse
  ): Promise<void> {
    if (!context.userId) return;

    try {
      await this.graphitiClient.addEvent({
        userId: context.userId,
        timestamp: response.timestamp,
        type: 'therapeutic_interaction',
        data: {
          userInput: context.userInput,
          emotionalState: context.emotionalState,
          protocol: response.protocol,
          technique: response.technique,
          response: response.response,
          retrievalMetadata: response.metadata
        }
      });
    } catch (error) {
      console.error('Error storing interaction:', error);
    }
  }

  private generateCrisisResponse(): TherapeuticResponse {
    return {
      timestamp: new Date(),
      protocol: 'CRISIS',
      technique: 'Crisis Intervention',
      response: 'I\'m very concerned about what you\'re sharing. Your safety is the most important thing right now. Please reach out for immediate help.',
      emotionalValidation: 'I can hear that you\'re in tremendous pain right now.',
      therapeuticSuggestions: [
        'Call 988 (Suicide & Crisis Lifeline) for immediate support',
        'Text "HELLO" to 741741 (Crisis Text Line)',
        'If you\'re in immediate danger, please call 911',
        'Reach out to a trusted friend or family member right now'
      ],
      isCrisis: true,
      metadata: {
        crisisResources: {
          phone: '988',
          text: '741741',
          emergency: '911'
        }
      }
    };
  }
}
