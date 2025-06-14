import * as crypto from 'crypto';

/**
 * HIPAA-compliant encryption manager using AES-256-GCM
 */
export class EncryptionManager {
  private algorithm = 'AES-256-GCM';
  private keyLength = 32; // 256 bits
  private ivLength = 16; // 128 bits
  private tagLength = 16; // 128 bits
  private saltLength = 32; // 256 bits

  constructor(private masterKey: string) {
    if (!masterKey || masterKey.length < 32) {
      throw new Error('Master key must be at least 32 characters long');
    }
  }

  /**
   * Encrypts sensitive data using AES-256-GCM
   */
  async encrypt(data: string | Buffer): Promise<{
    encrypted: string;
    iv: string;
    tag: string;
    salt: string;
  }> {
    try {
      // Generate random salt and IV
      const salt = crypto.randomBytes(this.saltLength);
      const iv = crypto.randomBytes(this.ivLength);

      // Derive key from master key using PBKDF2
      const key = crypto.pbkdf2Sync(
        this.masterKey,
        salt,
        100000, // iterations
        this.keyLength,
        'sha256'
      );

      // Create cipher using AES-256-GCM
      const cipher = crypto.createCipheriv(this.algorithm, key, iv);

      // Encrypt data
      const encrypted = Buffer.concat([
        cipher.update(data),
        cipher.final()
      ]);

      // Get authentication tag
      const tag = cipher.getAuthTag();

      return {
        encrypted: encrypted.toString('base64'),
        iv: iv.toString('base64'),
        tag: tag.toString('base64'),
        salt: salt.toString('base64')
      };
    } catch (error) {
      throw new Error(`Encryption failed: ${error.message}`);
    }
  }

  /**
   * Decrypts data encrypted with AES-256-GCM
   */
  async decrypt(encryptedData: {
    encrypted: string;
    iv: string;
    tag: string;
    salt: string;
  }): Promise<string> {
    try {
      // Convert from base64
      const encrypted = Buffer.from(encryptedData.encrypted, 'base64');
      const iv = Buffer.from(encryptedData.iv, 'base64');
      const tag = Buffer.from(encryptedData.tag, 'base64');
      const salt = Buffer.from(encryptedData.salt, 'base64');

      // Derive key from master key
      const key = crypto.pbkdf2Sync(
        this.masterKey,
        salt,
        100000,
        this.keyLength,
        'sha256'
      );

      // Create decipher using AES-256-GCM
      const decipher = crypto.createDecipheriv(this.algorithm, key, iv);
      decipher.setAuthTag(tag);

      // Decrypt data
      const decrypted = Buffer.concat([
        decipher.update(encrypted),
        decipher.final()
      ]);

      return decrypted.toString('utf8');
    } catch (error) {
      throw new Error(`Decryption failed: ${error.message}`);
    }
  }

  /**
   * Generates a secure random key for encryption
   */
  static generateKey(): string {
    return crypto.randomBytes(32).toString('base64');
  }

  /**
   * Hashes sensitive data using SHA-256
   */
  static hash(data: string): string {
    return crypto
      .createHash('sha256')
      .update(data)
      .digest('hex');
  }

  /**
   * Compares a plain value with a hashed value
   */
  static compareHash(plain: string, hashed: string): boolean {
    const plainHash = this.hash(plain);
    return crypto.timingSafeEqual(
      Buffer.from(plainHash),
      Buffer.from(hashed)
    );
  }
}

/**
 * Middleware for handling encrypted fields in MongoDB
 */
export class EncryptedFieldHandler {
  private encryptionManager: EncryptionManager;

  constructor(masterKey: string) {
    this.encryptionManager = new EncryptionManager(masterKey);
  }

  /**
   * Encrypts specified fields in an object
   */
  async encryptFields<T extends Record<string, any>>(
    obj: T,
    fieldsToEncrypt: string[]
  ): Promise<T> {
    const encrypted = { ...obj };

    for (const field of fieldsToEncrypt) {
      if (obj[field] !== undefined && obj[field] !== null) {
        const encryptedData = await this.encryptionManager.encrypt(
          JSON.stringify(obj[field])
        );
        encrypted[field] = encryptedData;
      }
    }

    return encrypted;
  }

  /**
   * Decrypts specified fields in an object
   */
  async decryptFields<T extends Record<string, any>>(
    obj: T,
    fieldsToDecrypt: string[]
  ): Promise<T> {
    const decrypted = { ...obj };

    for (const field of fieldsToDecrypt) {
      if (obj[field] && typeof obj[field] === 'object' && obj[field].encrypted) {
        try {
          const decryptedData = await this.encryptionManager.decrypt(obj[field]);
          decrypted[field] = JSON.parse(decryptedData);
        } catch (error) {
          console.error(`Failed to decrypt field ${field}:`, error);
          // Leave field as is if decryption fails
        }
      }
    }

    return decrypted;
  }
}

// Export a singleton instance
const MASTER_KEY = process.env.ENCRYPTION_MASTER_KEY || 'default-development-key-change-in-production';
export const encryptionManager = new EncryptionManager(MASTER_KEY);
export const encryptedFieldHandler = new EncryptedFieldHandler(MASTER_KEY);
