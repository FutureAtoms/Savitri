import { AuditLogger } from './audit-logger';
import { EncryptionManager } from './encryption-manager';

/**
 * HIPAA Compliance Manager
 * Ensures all PHI operations are properly encrypted and audited
 */
export class HIPAAComplianceManager {
  private auditLogger: AuditLogger;
  private encryptionManager: EncryptionManager;

  constructor(masterKey: string) {
    this.auditLogger = new AuditLogger();
    this.encryptionManager = new EncryptionManager(masterKey);
  }

  /**
   * Processes PHI data with proper encryption and audit logging
   */
  async processPHI(
    userId: string,
    operation: string,
    data: any,
    metadata?: any
  ): Promise<any> {
    try {
      // Log the access attempt
      await this.auditLogger.logPHIAccess({
        userId,
        action: operation,
        resource: 'PHI_DATA',
        metadata,
        success: true
      });

      // Encrypt the data using AES-256-GCM
      if (operation === 'STORE' || operation === 'UPDATE') {
        return await this.encryptionManager.encrypt(
          typeof data === 'string' ? data : JSON.stringify(data)
        );
      }

      // For read operations, just log and return
      return data;
    } catch (error) {
      // Log failed access attempt
      await this.auditLogger.logPHIAccess({
        userId,
        action: operation,
        resource: 'PHI_DATA',
        metadata: { error: error.message },
        success: false
      });

      throw error;
    }
  }

  /**
   * Validates HIPAA compliance for data operations
   */
  async validateCompliance(operation: {
    type: string;
    userId: string;
    hasEncryption: boolean;
    hasAuditLog: boolean;
  }): Promise<{
    compliant: boolean;
    issues: string[];
  }> {
    const issues: string[] = [];

    // Check for AES-256-GCM encryption
    if (!operation.hasEncryption) {
      issues.push('Data must be encrypted using AES-256-GCM');
    }

    // Check for audit logging (AuditLogger must be used)
    if (!operation.hasAuditLog) {
      issues.push('All PHI access must be logged using AuditLogger');
    }

    // Check for user authentication
    if (!operation.userId) {
      issues.push('User must be authenticated for PHI access');
    }

    return {
      compliant: issues.length === 0,
      issues
    };
  }

  /**
   * Emergency access procedure with enhanced logging
   */
  async emergencyAccess(
    userId: string,
    patientId: string,
    reason: string
  ): Promise<void> {
    await this.auditLogger.logPHIAccess({
      userId,
      action: 'EMERGENCY_ACCESS',
      resource: `patient:${patientId}`,
      metadata: {
        reason,
        timestamp: new Date(),
        flagged: true
      },
      success: true
    });
  }

  /**
   * Data retention compliance check
   */
  async checkDataRetention(
    dataType: string,
    createdDate: Date
  ): Promise<{
    shouldRetain: boolean;
    daysRemaining: number;
  }> {
    const retentionPeriods = {
      'clinical_notes': 2555, // 7 years
      'audit_logs': 2190,     // 6 years
      'session_data': 365,    // 1 year
      'temporary_data': 30    // 30 days
    };

    const retentionDays = retentionPeriods[dataType] || 2555;
    const daysSinceCreation = Math.floor(
      (Date.now() - createdDate.getTime()) / (1000 * 60 * 60 * 24)
    );

    return {
      shouldRetain: daysSinceCreation < retentionDays,
      daysRemaining: Math.max(0, retentionDays - daysSinceCreation)
    };
  }
}
