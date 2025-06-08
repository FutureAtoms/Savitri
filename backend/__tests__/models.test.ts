import { MongoMemoryServer } from 'mongodb-memory-server';
import mongoose from 'mongoose';
import User from '../persistence/models/User';
import Session from '../persistence/models/Session';
import Interaction from '../persistence/models/Interaction';

describe('Mongoose Models', () => {
  let mongoServer: MongoMemoryServer;

  beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();
    const mongoUri = mongoServer.getUri();
    await mongoose.connect(mongoUri);
  });

  afterAll(async () => {
    await mongoose.disconnect();
    await mongoServer.stop();
  });

  it('should create and save a user successfully', async () => {
    const userData = { email: 'test@example.com', password: 'password123' };
    const validUser = new User(userData);
    const savedUser = await validUser.save();

    expect(savedUser._id).toBeDefined();
    expect(savedUser.email).toBe(userData.email);
  });

  it('should create and save a session successfully', async () => {
    const user = await new User({ email: 'sessionuser@example.com' }).save();
    const sessionData = { user: user._id };
    const validSession = new Session(sessionData);
    const savedSession = await validSession.save();

    expect(savedSession._id).toBeDefined();
    expect(savedSession.user).toBe(user._id);
  });

  it('should create and save an interaction successfully', async () => {
    const user = await new User({ email: 'interactionuser@example.com' }).save();
    const session = await new Session({ user: user._id }).save();
    const interactionData = {
      session: session._id,
      userInput: 'I am feeling down today.',
      emotionalState: { primary: 'sadness', secondary: [], intensity: 0.8, confidence: 0.9, valence: -0.8, arousal: 0.2 },
      therapeuticResponse: {
        timestamp: new Date(),
        protocol: 'CBT',
        technique: 'Cognitive Restructuring',
        response: 'I hear you. It sounds like you are having a tough day.',
        emotionalValidation: 'It is understandable to feel down sometimes.',
        therapeuticSuggestions: ['Can you tell me more about what is making you feel this way?'],
        isCrisis: false
      }
    };
    const validInteraction = new Interaction(interactionData);
    const savedInteraction = await validInteraction.save();

    expect(savedInteraction._id).toBeDefined();
    expect(savedInteraction.userInput).toBe(interactionData.userInput);
  });
}); 