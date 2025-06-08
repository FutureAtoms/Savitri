export enum AuditEvent {
  PHI_ACCESS = 'PHI_ACCESS',
  LOGIN_SUCCESS = 'LOGIN_SUCCESS',
  LOGIN_FAILURE = 'LOGIN_FAILURE',
}

export interface AuditLog {
  event: AuditEvent;
  userId?: string;
  timestamp: Date;
  details: any;
}

export class AuditLogger {
  log(log: AuditLog) {
    console.log(JSON.stringify(log));
  }
} 