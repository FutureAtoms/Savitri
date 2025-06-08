import { HipaaCompliance } from '../security/hipaa-compliance';
import { AuditLogger } from '../security/audit-logger';

jest.mock('../security/audit-logger');

describe('HipaaCompliance', () => {
  let hipaaCompliance: HipaaCompliance;
  const password = 'test-password';
  const userId = 'test-user';
  const mockedAuditLogger = AuditLogger as jest.MockedClass<typeof AuditLogger>;

  beforeEach(() => {
    mockedAuditLogger.mockClear();
    hipaaCompliance = new HipaaCompliance(password);
  });

  it('should encrypt and decrypt data correctly and log the events', () => {
    const data = 'This is a secret';
    const encryptedData = hipaaCompliance.encryptAndLog(data, userId);
    const decryptedData = hipaaCompliance.decryptAndLog(encryptedData, userId);
    expect(decryptedData).toBe(data);
    expect(mockedAuditLogger.prototype.log).toHaveBeenCalledTimes(2);
  });
}); 