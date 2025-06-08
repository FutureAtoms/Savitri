# Savitri Production Monitoring & Clinical Analytics Guide

## Overview

This guide covers the setup and configuration of production monitoring and clinical analytics for the Savitri Psychology Therapy App. The monitoring stack includes Prometheus for metrics collection, Grafana for visualization, Loki for log aggregation, and custom clinical analytics dashboards.

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Application   │────▶│   Prometheus    │────▶│    Grafana      │
│   (Metrics)     │     │  (Time Series)  │     │ (Visualization) │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                                                │
         │              ┌─────────────────┐              │
         └─────────────▶│      Loki       │◀─────────────┘
           (Logs)       │ (Log Storage)   │
                        └─────────────────┘
```

## Components

### 1. Prometheus
- **Purpose**: Collects and stores time-series metrics
- **Port**: 9090
- **Configuration**: `/monitoring/prometheus.yml`

### 2. Grafana
- **Purpose**: Visualizes metrics and logs
- **Port**: 3002
- **Default Credentials**: admin/admin (change immediately)
- **Dashboards**: Pre-configured for API, Clinical, and Business metrics

### 3. Loki
- **Purpose**: Log aggregation and querying
- **Port**: 3100
- **Integration**: Automatically connected to Grafana

### 4. Alertmanager
- **Purpose**: Handles alerts from Prometheus
- **Port**: 9093
- **Notifications**: Slack, PagerDuty, Email

## Metrics

### API Metrics
- `http_request_duration_seconds`: Request latency histogram
- `http_requests_total`: Total requests counter
- `http_request_size_bytes`: Request size histogram
- `http_response_size_bytes`: Response size histogram
- `api_concurrent_requests`: Current concurrent requests

### Clinical Metrics
- `clinical_sessions_total`: Total therapy sessions
- `clinical_crisis_detections_total`: Crisis events detected
- `clinical_emotion_analysis_duration`: Emotion analysis latency
- `clinical_therapeutic_response_duration`: Response generation time
- `clinical_protocol_usage`: Usage by therapeutic protocol (CBT, DBT, etc.)

### Security Metrics
- `auth_attempts_total`: Authentication attempts
- `auth_failures_total`: Failed authentication attempts
- `hipaa_compliance_violations_total`: HIPAA violations detected
- `encryption_operations_total`: Encryption operations performed
- `audit_events_total`: Audit log entries created

### Business Metrics
- `sessions_started_total`: New sessions started
- `sessions_completed_total`: Sessions completed successfully
- `sessions_abandoned_total`: Sessions abandoned
- `concurrent_users`: Current active users
- `user_satisfaction_score`: Average satisfaction rating

## Dashboards

### 1. API Performance Dashboard
```json
{
  "dashboard": {
    "title": "Savitri API Performance",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Response Time (p95)",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))"
          }
        ]
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m])"
          }
        ]
      }
    ]
  }
}
```

### 2. Clinical Analytics Dashboard
```json
{
  "dashboard": {
    "title": "Clinical Analytics",
    "panels": [
      {
        "title": "Crisis Detection Rate",
        "targets": [
          {
            "expr": "rate(clinical_crisis_detections_total[1h])"
          }
        ]
      },
      {
        "title": "Emotion Distribution",
        "targets": [
          {
            "expr": "sum by (emotion) (rate(clinical_emotion_detections_total[1h]))"
          }
        ]
      },
      {
        "title": "Protocol Effectiveness",
        "targets": [
          {
            "expr": "avg by (protocol) (clinical_session_satisfaction_score)"
          }
        ]
      }
    ]
  }
}
```

### 3. HIPAA Compliance Dashboard
```json
{
  "dashboard": {
    "title": "HIPAA Compliance Monitoring",
    "panels": [
      {
        "title": "PHI Access Logs",
        "targets": [
          {
            "expr": "rate(audit_phi_access_total[1h])"
          }
        ]
      },
      {
        "title": "Encryption Status",
        "targets": [
          {
            "expr": "encryption_operations_total{status=\"success\"} / encryption_operations_total"
          }
        ]
      },
      {
        "title": "Compliance Violations",
        "targets": [
          {
            "expr": "hipaa_compliance_violations_total"
          }
        ]
      }
    ]
  }
}
```

## Setup Instructions

### 1. Deploy Monitoring Stack

```bash
# Start monitoring services
docker-compose -f docker-compose.yml up -d prometheus grafana loki

# Verify services are running
docker-compose ps

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets
```

### 2. Configure Grafana

```bash
# Access Grafana
open http://localhost:3002

# Login with admin/admin
# Change password immediately

# Import dashboards
# Go to Dashboards > Import
# Upload JSON files from /monitoring/grafana/dashboards/
```

### 3. Configure Alerting

```bash
# Edit Alertmanager configuration
vim monitoring/alertmanager.yml

# Add notification channels (Slack example):
route:
  receiver: 'slack-notifications'
  
receivers:
  - name: 'slack-notifications'
    slack_configs:
      - api_url: 'YOUR_SLACK_WEBHOOK_URL'
        channel: '#alerts'
        title: 'Savitri Alert'
```

### 4. Configure Application Metrics

```javascript
// backend/src/metrics/index.ts
import { Registry, Counter, Histogram, Gauge } from 'prom-client';

export const registry = new Registry();

// API Metrics
export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.5, 1, 2.5, 5, 10],
  registers: [registry]
});

// Clinical Metrics
export const crisisDetections = new Counter({
  name: 'clinical_crisis_detections_total',
  help: 'Total number of crisis detections',
  labelNames: ['severity'],
  registers: [registry]
});

export const concurrentUsers = new Gauge({
  name: 'concurrent_users',
  help: 'Number of concurrent users',
  registers: [registry]
});
```

## Production Checklist

### Pre-deployment
- [ ] All metrics endpoints secured with authentication
- [ ] Prometheus scrape configs use HTTPS
- [ ] Grafana admin password changed
- [ ] Alert notification channels configured
- [ ] Backup retention policies set

### Post-deployment
- [ ] Verify all metrics are being collected
- [ ] Test alert notifications
- [ ] Configure dashboard refresh rates
- [ ] Set up automated reports
- [ ] Train team on dashboard usage

## Monitoring Best Practices

### 1. Metric Naming
- Use consistent prefixes (e.g., `clinical_`, `api_`, `security_`)
- Follow Prometheus naming conventions
- Include units in metric names (e.g., `_seconds`, `_bytes`)

### 2. Label Usage
- Keep cardinality low (< 10 unique values per label)
- Use meaningful label names
- Avoid high-cardinality labels (e.g., user_id)

### 3. Alert Design
- Alert on symptoms, not causes
- Include clear descriptions and runbooks
- Set appropriate thresholds based on SLOs
- Avoid alert fatigue with proper severity levels

### 4. Dashboard Design
- Group related metrics together
- Use consistent time ranges
- Include both current values and trends
- Add annotations for deployments and incidents

## Troubleshooting

### Prometheus Issues
```bash
# Check Prometheus configuration
promtool check config /etc/prometheus/prometheus.yml

# Verify targets are up
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets'

# Check for metric ingestion
curl http://localhost:9090/api/v1/query?query=up
```

### Grafana Issues
```bash
# Check Grafana logs
docker logs savitri-grafana

# Verify data source connection
curl -u admin:password http://localhost:3002/api/datasources

# Test query
curl -u admin:password -X POST http://localhost:3002/api/ds/query \
  -H "Content-Type: application/json" \
  -d '{"queries":[{"expr":"up","refId":"A"}]}'
```

### Loki Issues
```bash
# Check Loki status
curl http://localhost:3100/ready

# Query logs
curl -G -s "http://localhost:3100/loki/api/v1/query_range" \
  --data-urlencode 'query={job="savitri-backend"}' | jq
```

## Clinical Analytics Queries

### Session Analysis
```promql
# Average session duration by protocol
avg by (protocol) (
  clinical_session_duration_seconds
)

# Session completion rate
sum(rate(sessions_completed_total[1d])) / 
sum(rate(sessions_started_total[1d]))

# Most common emotional states
topk(5, sum by (emotion) (
  rate(clinical_emotion_detections_total[1h])
))
```

### Crisis Analysis
```promql
# Crisis detection trend
rate(clinical_crisis_detections_total[1h])

# Crisis response time
histogram_quantile(0.95, 
  rate(clinical_crisis_response_duration_bucket[5m])
)

# Crisis by time of day
sum by (hour) (
  increase(clinical_crisis_detections_total[1h])
)
```

### Therapeutic Effectiveness
```promql
# Protocol success rate
avg by (protocol) (
  clinical_session_outcome_score
) / 5 * 100

# Improvement over time
rate(clinical_patient_progress_score[7d])

# Technique usage patterns
sum by (technique) (
  rate(clinical_technique_usage_total[1d])
)
```

## Compliance Reporting

### Monthly HIPAA Report
```promql
# PHI Access Summary
sum(increase(audit_phi_access_total[30d]))

# Encryption Compliance
avg(encryption_success_rate[30d]) * 100

# Security Incidents
sum(increase(security_incidents_total[30d]))
```

### Clinical Outcomes Report
```promql
# Patient Satisfaction
avg(clinical_session_satisfaction_score[30d])

# Crisis Prevention Rate
1 - (sum(rate(clinical_crisis_detections_total[30d])) / 
     sum(rate(sessions_started_total[30d])))

# Treatment Adherence
sum(rate(sessions_completed_total[30d])) / 
sum(rate(sessions_scheduled_total[30d]))
```

## Maintenance

### Daily Tasks
- Review overnight alerts
- Check dashboard health
- Verify backup completion
- Monitor disk usage

### Weekly Tasks
- Review metric cardinality
- Update alert thresholds
- Generate compliance reports
- Clean up old logs

### Monthly Tasks
- Update Grafana dashboards
- Review and optimize queries
- Audit access logs
- Update documentation

## Contact

For monitoring issues or questions:
- **On-call Engineer**: Check PagerDuty schedule
- **Monitoring Team**: monitoring@savitri.health
- **Security Team**: security@savitri.health (for compliance issues)
