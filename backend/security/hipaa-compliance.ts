import { AuditLogger, AuditEvent } from './audit-logger';
import { HipaaEncryption } from './hipaa-encryption';

export class HipaaCompliance {
  private logger = new AuditLogger();
  private encryption: HipaaEncryption;

  constructor(password: string) {
    this.encryption = new HipaaEncryption(password);
  }

  encryptAndLog(data: string, userId: string): string {
    const encryptedData = this.encryption.encrypt(data);
    this.logger.log({
      event: AuditEvent.PHI_ACCESS,
      userId,
      timestamp: new Date(),
      details: 'Data encrypted',
    });
    return encryptedData;
  }

  decryptAndLog(data: string, userId: string): string {
    const decryptedData = this.encryption.decrypt(data);
    this.logger.log({
      event: AuditEvent.PHI_ACCESS,
      userId,
      timestamp: new Date(),
      details: 'Data decrypted',
    });
    return decryptedData;
  }
} 