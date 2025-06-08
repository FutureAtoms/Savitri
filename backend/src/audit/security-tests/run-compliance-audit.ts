#!/usr/bin/env node

import { MongoClient } from 'mongodb';
import { HIPAAComplianceValidator } from '../hipaa-compliance-validator';
import { runSecurityAudit } from './automated-security-audit';
import * as fs from 'fs';
import * as path from 'path';

interface AuditConfig {
  mongoUri: string;
  apiBaseUrl: string;
  outputDir: string;
  emailRecipients?: string[];
}

class ComplianceAuditRunner {
  private config: AuditConfig;

  constructor(config: AuditConfig) {
    this.config = config;
  }

  async run(): Promise<void> {
    console.log('=================================');
    console.log('HIPAA Compliance Audit Starting');
    console.log('=================================');
    console.log(`Date: ${new Date().toISOString()}`);
    console.log(`API URL: ${this.config.apiBaseUrl}`);
    console.log('');

    try {
      // Ensure output directory exists
      if (!fs.existsSync(this.config.outputDir)) {
        fs.mkdirSync(this.config.outputDir, { recursive: true });
      }

      // Run HIPAA compliance validation
      console.log('Running HIPAA compliance checks...');
      const complianceReport = await this.runHIPAACompliance();
      
      // Run security audit
      console.log('\nRunning security vulnerability scan...');
      const securityReport = await runSecurityAudit(this.config.apiBaseUrl);
      
      // Generate combined report
      const combinedReport = this.generateCombinedReport(complianceReport, securityReport);
      
      // Save reports
      await this.saveReports(complianceReport, securityReport, combinedReport);
      
      // Send notifications if configured
      if (this.config.emailRecipients && this.config.emailRecipients.length > 0) {
        await this.sendNotifications(combinedReport);
      }
      
      // Print summary
      this.printSummary(combinedReport);
      
      // Exit with appropriate code
      process.exit(combinedReport.passedAudit ? 0 : 1);
    } catch (error) {
      console.error('Audit failed with error:', error);
      process.exit(2);
    }
  }

  private async runHIPAACompliance(): Promise<any> {
    const client = new MongoClient(this.config.mongoUri);
    
    try {
      await client.connect();
      const db = client.db();
      
      const validator = new HIPAAComplianceValidator(db);
      return await validator.validateCompliance();
    } finally {
      await client.close();
    }
  }

  private generateCombinedReport(complianceReport: any, securityReport: any): any {
    const criticalFindings = [
      ...complianceReport.details.filter((d: any) => d.severity === 'CRITICAL'),
      ...securityReport.findings.filter((f: any) => f.severity === 'CRITICAL')
    ];

    const highFindings = [
      ...complianceReport.details.filter((d: any) => d.severity === 'HIGH'),
      ...securityReport.findings.filter((f: any) => f.severity === 'HIGH')
    ];

    const passedAudit = complianceReport.overallCompliant && 
                       securityReport.vulnerabilitiesFound === 0;

    return {
      auditDate: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'production',
      passedAudit,
      complianceScore: complianceReport.complianceScore,
      securityRisk: securityReport.overallRisk,
      criticalFindings: criticalFindings.length,
      highFindings: highFindings.length,
      summary: {
        hipaaCompliant: complianceReport.overallCompliant,
        securityVulnerabilities: securityReport.vulnerabilitiesFound,
        nextAuditDate: complianceReport.nextAuditDate
      },
      criticalIssues: criticalFindings,
      highPriorityIssues: highFindings,
      recommendations: [
        ...complianceReport.recommendations,
        ...this.generateSecurityRecommendations(securityReport)
      ]
    };
  }

  private generateSecurityRecommendations(securityReport: any): string[] {
    const recommendations: string[] = [];
    
    if (securityReport.criticalCount > 0) {
      recommendations.push('IMMEDIATE: Address all critical security vulnerabilities within 24 hours');
    }
    
    if (securityReport.findings.some((f: any) => f.vulnerability.includes('SQL Injection'))) {
      recommendations.push('Implement parameterized queries throughout the application');
    }
    
    if (securityReport.findings.some((f: any) => f.vulnerability.includes('XSS'))) {
      recommendations.push('Implement Content Security Policy (CSP) headers');
    }
    
    if (securityReport.findings.some((f: any) => f.vulnerability.includes('Authentication'))) {
      recommendations.push('Review and strengthen authentication mechanisms');
    }
    
    return recommendations;
  }

  private async saveReports(
    complianceReport: any,
    securityReport: any,
    combinedReport: any
  ): Promise<void> {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    
    // Save compliance report
    const compliancePath = path.join(
      this.config.outputDir,
      `hipaa-compliance-${timestamp}.json`
    );
    fs.writeFileSync(compliancePath, JSON.stringify(complianceReport, null, 2));
    console.log(`\nCompliance report saved to: ${compliancePath}`);
    
    // Save security report
    const securityPath = path.join(
      this.config.outputDir,
      `security-audit-${timestamp}.json`
    );
    fs.writeFileSync(securityPath, JSON.stringify(securityReport, null, 2));
    console.log(`Security report saved to: ${securityPath}`);
    
    // Save combined report
    const combinedPath = path.join(
      this.config.outputDir,
      `audit-summary-${timestamp}.json`
    );
    fs.writeFileSync(combinedPath, JSON.stringify(combinedReport, null, 2));
    console.log(`Combined report saved to: ${combinedPath}`);
    
    // Generate HTML report
    const htmlReport = this.generateHTMLReport(combinedReport);
    const htmlPath = path.join(
      this.config.outputDir,
      `audit-report-${timestamp}.html`
    );
    fs.writeFileSync(htmlPath, htmlReport);
    console.log(`HTML report saved to: ${htmlPath}`);
  }

  private generateHTMLReport(report: any): string {
    return `
<!DOCTYPE html>
<html>
<head>
    <title>HIPAA Compliance & Security Audit Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            max-width: 1200px;
            margin: 0 auto;
        }
        h1, h2, h3 {
            color: #333;
        }
        .status-pass {
            color: #28a745;
            font-weight: bold;
        }
        .status-fail {
            color: #dc3545;
            font-weight: bold;
        }
        .critical {
            background-color: #dc3545;
            color: white;
            padding: 2px 8px;
            border-radius: 4px;
        }
        .high {
            background-color: #fd7e14;
            color: white;
            padding: 2px 8px;
            border-radius: 4px;
        }
        .summary-box {
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            padding: 20px;
            border-radius: 4px;
            margin: 20px 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            text-align: left;
            padding: 12px;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f8f9fa;
            font-weight: bold;
        }
        .recommendation {
            background-color: #e7f3ff;
            border-left: 4px solid #0066cc;
            padding: 10px;
            margin: 10px 0;
        }
        .footer {
            margin-top: 40px;
            text-align: center;
            color: #666;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>HIPAA Compliance & Security Audit Report</h1>
        
        <div class="summary-box">
            <h2>Executive Summary</h2>
            <p><strong>Audit Date:</strong> ${new Date(report.auditDate).toLocaleString()}</p>
            <p><strong>Environment:</strong> ${report.environment}</p>
            <p><strong>Overall Status:</strong> 
                <span class="${report.passedAudit ? 'status-pass' : 'status-fail'}">
                    ${report.passedAudit ? 'PASSED' : 'FAILED'}
                </span>
            </p>
            <p><strong>Compliance Score:</strong> ${report.complianceScore.toFixed(1)}%</p>
            <p><strong>Security Risk Level:</strong> ${report.securityRisk}</p>
            <p><strong>Critical Findings:</strong> ${report.criticalFindings}</p>
            <p><strong>High Priority Findings:</strong> ${report.highFindings}</p>
            <p><strong>Next Audit Date:</strong> ${new Date(report.summary.nextAuditDate).toLocaleDateString()}</p>
        </div>

        ${report.criticalIssues.length > 0 ? `
        <h2>Critical Issues Requiring Immediate Action</h2>
        <table>
            <thead>
                <tr>
                    <th>Category</th>
                    <th>Issue</th>
                    <th>Details</th>
                    <th>Action Required</th>
                </tr>
            </thead>
            <tbody>
                ${report.criticalIssues.map((issue: any) => `
                <tr>
                    <td>${issue.category || issue.vulnerability}</td>
                    <td><span class="critical">CRITICAL</span></td>
                    <td>${issue.findings ? issue.findings.join(', ') : issue.details}</td>
                    <td>${issue.recommendation || 'Immediate remediation required'}</td>
                </tr>
                `).join('')}
            </tbody>
        </table>
        ` : ''}

        ${report.highPriorityIssues.length > 0 ? `
        <h2>High Priority Issues</h2>
        <table>
            <thead>
                <tr>
                    <th>Category</th>
                    <th>Issue</th>
                    <th>Details</th>
                    <th>Action Required</th>
                </tr>
            </thead>
            <tbody>
                ${report.highPriorityIssues.map((issue: any) => `
                <tr>
                    <td>${issue.category || issue.vulnerability}</td>
                    <td><span class="high">HIGH</span></td>
                    <td>${issue.findings ? issue.findings.join(', ') : issue.details}</td>
                    <td>${issue.recommendation || 'Address within 72 hours'}</td>
                </tr>
                `).join('')}
            </tbody>
        </table>
        ` : ''}

        <h2>Recommendations</h2>
        ${report.recommendations.map((rec: string) => `
        <div class="recommendation">
            ${rec}
        </div>
        `).join('')}

        <div class="footer">
            <p>This report is confidential and contains sensitive security information.</p>
            <p>Generated by Savitri HIPAA Compliance Auditor v1.0</p>
        </div>
    </div>
</body>
</html>
    `;
  }

  private async sendNotifications(report: any): Promise<void> {
    // Implementation would send email notifications
    console.log('\nNotifications sent to:', this.config.emailRecipients?.join(', '));
  }

  private printSummary(report: any): void {
    console.log('\n=================================');
    console.log('AUDIT SUMMARY');
    console.log('=================================');
    console.log(`Status: ${report.passedAudit ? 'PASSED ✓' : 'FAILED ✗'}`);
    console.log(`Compliance Score: ${report.complianceScore.toFixed(1)}%`);
    console.log(`Security Risk: ${report.securityRisk}`);
    console.log(`Critical Findings: ${report.criticalFindings}`);
    console.log(`High Priority Findings: ${report.highFindings}`);
    console.log('');
    
    if (report.criticalFindings > 0) {
      console.log('⚠️  CRITICAL ISSUES REQUIRE IMMEDIATE ATTENTION!');
      console.log('   Address all critical findings within 24 hours.');
    }
    
    console.log('\nNext scheduled audit:', new Date(report.summary.nextAuditDate).toLocaleDateString());
  }
}

// Main execution
if (require.main === module) {
  const config: AuditConfig = {
    mongoUri: process.env.MONGODB_URI || 'mongodb://localhost:27017/savitri',
    apiBaseUrl: process.env.API_BASE_URL || 'https://api.savitri.health',
    outputDir: process.env.AUDIT_OUTPUT_DIR || './audit-reports',
    emailRecipients: process.env.AUDIT_EMAIL_RECIPIENTS?.split(',') || []
  };

  const runner = new ComplianceAuditRunner(config);
  runner.run().catch(console.error);
}

export { ComplianceAuditRunner, AuditConfig };
