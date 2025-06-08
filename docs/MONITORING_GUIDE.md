# Production Monitoring Setup Guide

## Overview

This guide covers the complete setup of production monitoring for the Ashray Psychology App using Prometheus, Grafana, and AlertManager.

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│   Ashray    │────▶│  Prometheus  │────▶│   Grafana    │
│     API     │     │              │     │              │
└─────────────┘     └──────────────┘     └──────────────┘
                            │                     ▲
                            ▼                     │
                    ┌──────────────┐              │
                    │ AlertManager │──────────────┘
                    └──────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │  PagerDuty   │
                    └──────────────┘
```

## Quick Start

### 1. Prerequisites

- Docker and Docker Compose installed
- Domain configured for monitoring.ashray.app
- PagerDuty account (for critical alerts)
- SMTP server access (for email alerts)
- Slack webhook URL (optional)

### 2. Environment Configuration

Create a `.env.monitoring` file:

```bash
# Grafana Admin
GRAFANA_ADMIN_PASSWORD=your-secure-password
GRAFANA_SECRET_KEY=your-secret-key

# SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=alerts@ashray.app
SMTP_PASSWORD=your-smtp-password

# Alert Integrations
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
PAGERDUTY_SERVICE_KEY=your-pagerduty-service-key
PAGERDUTY_CRISIS_KEY=your-crisis-service-key
PAGERDUTY_SECURITY_KEY=your-security-service-key
CRISIS_WEBHOOK_URL=https://your-crisis-webhook.com

# OAuth Configuration (optional)
OAUTH_ENABLED=false
OAUTH_CLIENT_ID=your-oauth-client-id
OAUTH_CLIENT_SECRET=your-oauth-secret
OAUTH_AUTH_URL=https://auth.ashray.app/authorize
OAUTH_TOKEN_URL=https://auth.ashray.app/token
OAUTH_API_URL=https://auth.ashray.app/userinfo

# AWS Configuration (if using CloudWatch)
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
```

### 3. Start Monitoring Stack

```bash
# Create networks
docker network create monitoring
docker network create ashray-network

# Start monitoring stack
docker-compose -f docker-compose.monitoring.yml --env-file .env.monitoring up -d

# Check status
docker-compose -f docker-compose.monitoring.yml ps

# View logs
docker-compose -f docker-compose.monitoring.yml logs -f
```

### 4. Access Dashboards

- **Grafana**: http://localhost:3003 (admin/[GRAFANA_ADMIN_PASSWORD])
- **Prometheus**: http://localhost:9090
- **AlertManager**: http://localhost:9093

## Dashboards Overview

### 1. API Performance Dashboard
- Request rate and latency metrics
- HTTP status code distribution
- Top routes by traffic
- Error rate analysis

### 2. Clinical Metrics Dashboard
- Active therapy sessions
- Crisis detection events
- Patient engagement scores
- Session duration analysis

### 3. Business KPIs Dashboard
- Monthly Recurring Revenue (MRR)
- Active subscriptions
- User acquisition funnel
- Churn rate analysis

### 4. Infrastructure Monitoring
- CPU, Memory, Disk usage
- Network I/O
- Database connections
- Container health

### 5. SLO/SLA Monitoring
- Service Level Objective compliance
- Error budget tracking
- Availability metrics
- Performance targets

## Alert Configuration

### Critical Alerts (PagerDuty)
- API Down
- Crisis Detected
- MongoDB/Redis Down
- Encryption Failure
- Audit Log Failure

### Warning Alerts (Email/Slack)
- High API Latency (>2s P95)
- High Error Rate (>10%)
- Memory Usage >85%
- Disk Space <15%
- SLO Violations

### Info Alerts (Slack Only)
- Low Patient Engagement
- High Session Dropout Rate
- Business metric anomalies

## SLO Targets

| SLO | Target | Window | Description |
|-----|--------|---------|-------------|
| API Availability | 99.9% | 30d | API uptime |
| API Latency P95 | <2.5s | 30d | Response time |
| Voice Session Success | 99.5% | 7d | Successful sessions |
| Crisis Detection | 95% | 30d | Detection accuracy |
| Gemini API | 99% | 24h | API success rate |
| Auth Service | 99.95% | 30d | Authentication uptime |

## Metric Collection

### Application Metrics

The application exposes metrics at `/monitoring/metrics`:

```javascript
// Example metric recording
metricsService.increment('api_requests_total', {
  method: req.method,
  route: req.route.path,
  status: res.statusCode
});

metricsService.observe('api_request_duration_seconds', duration, {
  method: req.method,
  route: req.route.path
});
```

### Custom Business Metrics

```javascript
// Record business events
metricsService.increment('therapy_sessions_completed', {
  therapy_type: 'CBT'
});

metricsService.gauge('active_users', activeUserCount, {
  plan: 'premium'
});
```

## Prometheus Queries

### Common Queries

```promql
# API Success Rate
(1 - (sum(rate(api_requests_total{status=~"5.."}[5m])) / sum(rate(api_requests_total[5m])))) * 100

# P95 Latency
histogram_quantile(0.95, sum(rate(api_request_duration_seconds_bucket[5m])) by (le))

# Active Sessions
sum(ashray_active_sessions)

# Crisis Detection Rate
sum(rate(crisis_detections_total[5m])) by (severity)

# Error Budget Remaining
100 - ((1 - (avg_over_time((up{job="ashray-api"})[30d:5m]))) * 100)
```

## Troubleshooting

### Container Issues

```bash
# Check container logs
docker logs ashray-prometheus
docker logs ashray-grafana
docker logs ashray-alertmanager

# Restart containers
docker-compose -f docker-compose.monitoring.yml restart prometheus

# Check network connectivity
docker exec ashray-prometheus ping ashray-api
```

### Metric Collection Issues

1. Verify application is exposing metrics:
   ```bash
   curl http://localhost:3000/monitoring/metrics
   ```

2. Check Prometheus targets:
   - Navigate to http://localhost:9090/targets
   - Ensure all targets are "UP"

3. Verify scrape configuration in prometheus.yml

### Alert Issues

1. Check AlertManager status:
   ```bash
   curl http://localhost:9093/api/v1/status
   ```

2. Test alert routing:
   ```bash
   amtool alert add alertname=test severity=warning -a alertmanager:9093
   ```

3. Check webhook endpoints are accessible

## Maintenance

### Backup Procedures

```bash
# Backup Prometheus data
docker run --rm -v ashray-prometheus-data:/data -v $(pwd):/backup alpine tar czf /backup/prometheus-backup-$(date +%Y%m%d).tar.gz -C /data .

# Backup Grafana dashboards
curl -H "Authorization: Bearer $GRAFANA_API_KEY" http://localhost:3003/api/dashboards/db/api-performance > api-performance-dashboard.json
```

### Update Procedures

```bash
# Update container images
docker-compose -f docker-compose.monitoring.yml pull

# Restart with new images
docker-compose -f docker-compose.monitoring.yml up -d
```

### Data Retention

- Prometheus: 30 days (configurable via --storage.tsdb.retention.time)
- Loki: 7 days (configurable in loki config)
- Grafana: Unlimited (SQLite database)

## Security Considerations

1. **Network Isolation**: Monitoring stack should be on isolated network
2. **Authentication**: Enable OAuth2 for Grafana in production
3. **TLS**: Use HTTPS for all external endpoints
4. **Secrets**: Store sensitive data in environment variables or secrets manager
5. **Access Control**: Implement RBAC in Grafana

## Integration with CI/CD

### GitHub Actions Example

```yaml
- name: Record Deployment Metric
  run: |
    curl -X POST http://monitoring.ashray.app/monitoring/metrics/record \
      -H "Content-Type: application/json" \
      -d '{
        "metric": "deployment",
        "tags": {
          "version": "${{ github.sha }}",
          "environment": "production"
        }
      }'
```

## Cost Optimization

1. **Metric Cardinality**: Limit label combinations to reduce storage
2. **Scrape Intervals**: Adjust based on metric importance
3. **Retention Policies**: Shorter retention for high-frequency metrics
4. **Downsampling**: Use recording rules for long-term storage

## Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [AlertManager Documentation](https://prometheus.io/docs/alerting/latest/alertmanager/)
- [PromQL Examples](https://prometheus.io/docs/prometheus/latest/querying/examples/)
