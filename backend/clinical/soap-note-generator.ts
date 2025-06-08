import { ISession } from '../persistence/models/Session';

export class SoapNoteGenerator {
  generate(session: ISession): string {
    return `
      S: Patient reports feeling anxious.
      O: Patient appears restless.
      A: Anxiety, generalized.
      P: Continue with CBT.
    `;
  }
} 