import * as crypto from 'crypto';

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 16;
const SALT_LENGTH = 64;
const TAG_LENGTH = 16;
const KEY_LENGTH = 32;
const PBKDF2_ITERATIONS = 100000;

export class HipaaEncryption {
  private key: Buffer;

  constructor(password: string) {
    this.key = crypto.pbkdf2Sync(password, 'salt', PBKDF2_ITERATIONS, KEY_LENGTH, 'sha512');
  }

  encrypt(data: string): string {
    const iv = crypto.randomBytes(IV_LENGTH);
    const cipher = crypto.createCipheriv(ALGORITHM, this.key, iv);
    const encrypted = Buffer.concat([cipher.update(data, 'utf8'), cipher.final()]);
    const tag = cipher.getAuthTag();
    return Buffer.concat([iv, tag, encrypted]).toString('hex');
  }

  decrypt(data: string): string {
    const buffer = Buffer.from(data, 'hex');
    const iv = buffer.slice(0, IV_LENGTH);
    const tag = buffer.slice(IV_LENGTH, IV_LENGTH + TAG_LENGTH);
    const encrypted = buffer.slice(IV_LENGTH + TAG_LENGTH);
    const decipher = crypto.createDecipheriv(ALGORITHM, this.key, iv);
    decipher.setAuthTag(tag);
    return decipher.update(encrypted.toString('hex'), 'hex', 'utf8') + decipher.final('utf8');
  }
} 