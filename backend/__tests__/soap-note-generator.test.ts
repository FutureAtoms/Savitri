import { SoapNoteGenerator } from '../clinical/soap-note-generator';
import { ISession } from '../persistence/models/Session';

describe('SoapNoteGenerator', () => {
  let soapNoteGenerator: SoapNoteGenerator;

  beforeEach(() => {
    soapNoteGenerator = new SoapNoteGenerator();
  });

  it('should generate a SOAP note', () => {
    // Create a mock session object with the required properties
    const session = {
      _id: 'test-id',
      user: 'test-user' as any,
      startTime: new Date(),
      endTime: new Date(),
      interactions: [],
    } as any; // Cast as any to avoid Mongoose document type requirements
    
    const note = soapNoteGenerator.generate(session);
    expect(note).toContain('S:');
    expect(note).toContain('O:');
    expect(note).toContain('A:');
    expect(note).toContain('P:');
  });
});
