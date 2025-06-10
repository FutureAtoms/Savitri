import crypto from 'crypto';
import winston from 'winston';

/**
 * HIPAA Compliance Manager
 * Handles encryption and audit logging for PHI (Protected Health Information)
 */
export class HIPAAComplianceManager {
  private static readonly ALGORITHM = 'AES-256-GCM';
  private static readonly IV_LENGTH = 16;
  private static readonly SALT_LENGTH = 64;
  private static readonly TAG_LENGTH = 16;
  private static readonly PBKDF2_ITERATIONS = 100000;
  
  private encryptionKey: Buffer;
  private auditLogger: AuditLogger;

  constructor(masterKey: string) {
    this.encryptionKey = this.deriveKey(masterKey);
    this.auditLogger = new AuditLogger();
  }

  /**
   * Encrypts sensitive data using AES-256-GCM
   */
  public encrypt(data: string | Buffer): string {
    const iv = crypto.randomBytes(this.constructor.IV_LENGTH);
    const salt = crypto.randomBytes(this.constructor.SALT_LENGTH);
    
    const key = crypto.pbkdf2Sync(this.encryptionKey, salt, this.constructor.PBKDF2_ITERATIONS, 32, 'sha256');
    const cipher = crypto.createCipheriv(this.constructor.ALGORITHM, key, iv);
    
    const encrypted = Buffer.concat([
      cipher.update(data, 'utf8'),
      cipher.final()
    ]);
    
    const tag = cipher.getAuthTag();
    
    // Combine salt, iv, tag, and encrypted data
    const combined = Buffer.concat([salt, iv, tag, encrypted]);
    
    this.auditLogger.logEncryption({
      action: 'encrypt',
      dataType: 'PHI',
      timestamp: new Date().toISOString()
    });
    
    return combined.toString('base64');
  }

  /**
   * Decrypts data encrypted with AES-256-GCM
   */
  public decrypt(encryptedData: string): string {
    const buffer = Buffer.from(encryptedData, 'base64');
    
    const salt = buffer.slice(0, this.constructor.SALT_LENGTH);
    const iv = buffer.slice(this.constructor.SALT_LENGTH, this.constructor.SALT_LENGTH + this.constructor.IV_LENGTH);
    const tag = buffer.slice(this.constructor.SALT_LENGTH + this.constructor.IV_LENGTH, this.constructor.SALT_LENGTH + this.constructor.IV_LENGTH + this.constructor.TAG_LENGTH);
    const encrypted = buffer.slice(this.constructor.SALT_LENGTH + this.constructor.IV_LENGTH + this.constructor.TAG_LENGTH);
    
    const key = crypto.pbkdf2Sync(this.encryptionKey, salt, this.constructor.PBKDF2_ITERATIONS, 32, 'sha256');
    const decipher = crypto.createDecipheriv(this.constructor.ALGORITHM, key, iv);
    decipher.setAuthTag(tag);
    
    const decrypted = Buffer.concat([
      decipher.update(encrypted),
      decipher.final()
    ]);
    
    this.auditLogger.logDecryption({
      action: 'decrypt',
      dataType: 'PHI',
      timestamp: new Date().toISOString()
    });
    
    return decrypted.toString('utf8');
  }

  /**
   * Derives a key from the master key
   */
  private deriveKey(masterKey: string): Buffer {
    return crypto.createHash('sha256').update(masterKey).digest();
  }

  /**
   * Get the audit logger instance
   */
  public getAuditLogger(): AuditLogger {
    return this.auditLogger;
  }
}

/**
 * Audit Logger for HIPAA compliance
 * Logs all access to PHI
 */
export class AuditLogger {
  private logger: winston.Logger;

  constructor() {
    this.logger = winston.createLogger({
      level: 'info',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      ),
      transports: [
        new winston.transports.File({ filename: 'hipaa-audit.log' }),
        new winston.transports.Console({
          format: winston.format.simple()
        })
      ]
    });
  }

  /**
   * Log encryption operations
   */
  public logEncryption(details: any): void {
    this.logger.info('PHI_ENCRYPTION', details);
  }

  /**
   * Log decryption operations
   */
  public logDecryption(details: any): void {
    this.logger.info('PHI_DECRYPTION', details);
  }

  /**
   * Log PHI access
   */
  public logAccess(details: {
    userId: string;
    action: string;
    resource: string;
    timestamp: string;
    ip?: string;
  }): void {
    this.logger.info('PHI_ACCESS', details);
  }

  /**
   * Log PHI modification
   */
  public logModification(details: {
    userId: string;
    action: string;
    resource: string;
    changes: any;
    timestamp: string;
  }): void {
    this.logger.info('PHI_MODIFICATION', details);
  }

  /**
   * Log authentication events
   */
  public logAuthentication(details: {
    userId: string;
    action: 'login' | 'logout' | 'failed_login';
    timestamp: string;
    ip?: string;
  }): void {
    this.logger.info('AUTHENTICATION', details);
  }

  /**
   * Log security events
   */
  public logSecurityEvent(details: {
    type: string;
    severity: 'low' | 'medium' | 'high' | 'critical';
    description: string;
    timestamp: string;
  }): void {
    this.logger.warn('SECURITY_EVENT', details);
  }
}

export default HIPAAComplianceManager;
