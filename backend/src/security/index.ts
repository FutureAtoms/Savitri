/**
 * Security module for HIPAA-compliant operations
 * Includes encryption (AES-256-GCM) and audit logging
 */

export { AuditLogger } from './audit-logger';
export { 
  EncryptionManager, 
  EncryptedFieldHandler,
  encryptionManager,
  encryptedFieldHandler 
} from './encryption-manager';

// Re-export for easy access
export { HIPAAComplianceManager } from './hipaa-compliance-manager';
