# VoiceFX AI - Monitoring & Alerting Guide

This guide covers setting up monitoring and alerting for your VoiceFX AI deployment.

## Table of Contents

- [Built-in Monitoring](#built-in-monitoring)
- [Uptime Monitoring](#uptime-monitoring)
- [Log Management](#log-management)
- [Metrics & Dashboards](#metrics--dashboards)
- [Alerting](#alerting)
- [Performance Monitoring](#performance-monitoring)

---

## Built-in Monitoring

VoiceFX AI comes with built-in monitoring through:

### 1. PostHog (Analytics)

**What it tracks:**
- User behavior and feature usage
- Session recordings
- Feature flags
- A/B testing

**Access:**
- Dashboard: https://us.posthog.com
- Project Key: `phc_ItizB1dP6yv7ZYobbcqrpxTdbomDA8hJFSEmAMdYvIr`

**Configuration:**
```env
# In .env.production
ENABLE_TELEMETRY=true
POSTHOG_KEY=phc_ItizB1dP6yv7ZYobbcqrpxTdbomDA8hJFSEmAMdYvIr
POSTHOG_HOST=https://us.posthog.com
```

### 2. Sentry (Error Tracking)

**What it tracks:**
- Application errors and exceptions
- Performance issues
- Release tracking
- Error trends

**Access:**
- Dashboard: https://sentry.io
- API DSN: `https://3acdb63d5f1f70430953353b82de61e0@o4509486225096704.ingest.us.sentry.io/4510152922693632`
- UI DSN: `https://d9387fed5f80e90781f1dbd9b2c0994c@o4509486225096704.ingest.us.sentry.io/4510124708200448`

**Configuration:**
```env
# In .env.production
ENABLE_TELEMETRY=true
SENTRY_DSN=https://3acdb63d5f1f70430953353b82de61e0@o4509486225096704.ingest.us.sentry.io/4510152922693632
UI_SENTRY_DSN=https://d9387fed5f80e90781f1dbd9b2c0994c@o4509486225096704.ingest.us.sentry.io/4510124708200448
```

### 3. Docker Health Checks

All services have built-in health checks:

```bash
# Check service health
docker compose -f docker-compose.prod.yaml ps

# Run health check script
./scripts/health-check.sh
```

---

## Uptime Monitoring

### Option 1: UptimeRobot (Free)

**Setup:**

1. Go to https://uptimerobot.com
2. Sign up for free account
3. Add monitors:
   - **UI Monitor**: `https://yourdomain.com` (HTTP, 5-min interval)
   - **API Monitor**: `https://api.yourdomain.com/api/v1/health` (HTTP, 5-min interval)
   - **API Docs**: `https://api.yourdomain.com/docs` (HTTP, 5-min interval)

4. Configure alerts:
   - Email notifications
   - Slack/Discord webhooks
   - SMS (paid plans)

**Example Webhook Alert (Slack):**
```bash
# In Slack, create incoming webhook
# Add webhook URL to UptimeRobot alert contacts
```

### Option 2: Better Uptime

**Setup:**

1. Go to https://betteruptime.com
2. Create monitors with advanced checks:
   - Response time tracking
   - Certificate expiration alerts
   - Multi-location monitoring

### Option 3: Self-Hosted (Uptime Kuma)

```bash
# Deploy Uptime Kuma
docker run -d --restart=always \
  -p 3001:3001 \
  -v uptime-kuma:/app/data \
  --name uptime-kuma \
  louislam/uptime-kuma:1

# Access at http://your-server:3001
```

---

## Log Management

### Local Log Management

**View logs:**
```bash
# All services
./scripts/deploy.sh logs

# Specific service
./scripts/deploy.sh logs api

# Follow logs
docker compose -f docker-compose.prod.yaml logs -f api

# Search logs
docker compose -f docker-compose.prod.yaml logs api | grep "ERROR"
```

**Log rotation (prevent disk fill):**

Already configured in `docker-compose.prod.yaml`:
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "50m"
    max-file: "10"
```

### Centralized Logging (Optional)

#### Option 1: Loki + Grafana

```yaml
# Add to docker-compose.prod.yaml

services:
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - loki-data:/loki
    command: -config.file=/etc/loki/local-config.yaml
    networks:
      - app-network

  promtail:
    image: grafana/promtail:latest
    volumes:
      - /var/log:/var/log
      - ./logs:/app/logs
    command: -config.file=/etc/promtail/config.yml
    networks:
      - app-network

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
    networks:
      - app-network
```

#### Option 2: Cloud Services

**Papertrail:**
```bash
# Add to docker-compose.prod.yaml
logging:
  driver: syslog
  options:
    syslog-address: "udp://logs.papertrailapp.com:XXXXX"
    tag: "voicefx-{{.Name}}"
```

**Logtail:**
```bash
# Add log shipping
services:
  vector:
    image: timberio/vector:latest
    volumes:
      - ./vector.toml:/etc/vector/vector.toml
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
```

---

## Metrics & Dashboards

### Option 1: Prometheus + Grafana

**Setup Prometheus:**

1. Create `prometheus/prometheus.yml`:
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'docker'
    static_configs:
      - targets: ['172.17.0.1:9323']

  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx:9113']

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']
```

2. Add to `docker-compose.prod.yaml`:
```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - app-network

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
    networks:
      - app-network
```

3. Access Grafana at `http://your-server:3000`
4. Add Prometheus as data source
5. Import dashboards:
   - Docker Dashboard: ID 893
   - Nginx Dashboard: ID 12708
   - PostgreSQL Dashboard: ID 9628

### Option 2: Cloud Services

**Datadog:**
```yaml
# Add Datadog agent
services:
  datadog:
    image: datadog/agent:latest
    environment:
      - DD_API_KEY=${DATADOG_API_KEY}
      - DD_SITE=datadoghq.com
      - DD_LOGS_ENABLED=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /proc/:/host/proc/:ro
      - /sys/fs/cgroup/:/host/sys/fs/cgroup:ro
```

---

## Alerting

### 1. Email Alerts (SMTP)

**Configure in health check script:**

```bash
# Create .env.monitoring
ALERT_EMAIL=admin@yourdomain.com
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your@gmail.com
SMTP_PASSWORD=your_app_password
```

**Update health-check.sh:**
```bash
send_email_alert() {
    local subject=$1
    local message=$2

    echo "$message" | mail -s "$subject" \
        -S smtp="$SMTP_HOST:$SMTP_PORT" \
        -S smtp-auth=login \
        -S smtp-auth-user="$SMTP_USER" \
        -S smtp-auth-password="$SMTP_PASSWORD" \
        "$ALERT_EMAIL"
}
```

### 2. Slack Alerts

**Setup:**

1. Create Slack incoming webhook: https://api.slack.com/messaging/webhooks
2. Add to `.env.production`:
   ```env
   SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
   ```
3. Run health check with alerts:
   ```bash
   ./scripts/health-check.sh --alert
   ```

**Example Slack webhook payload:**
```json
{
  "text": "🚨 VoiceFX Alert",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Service Down:* API is not responding"
      }
    }
  ]
}
```

### 3. Discord Alerts

**Setup:**

1. Create Discord webhook in channel settings
2. Add to `.env.production`:
   ```env
   DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR/WEBHOOK
   ```

**Send alert:**
```bash
curl -H "Content-Type: application/json" \
  -d '{"content":"🚨 VoiceFX Alert: API is down!"}' \
  "$DISCORD_WEBHOOK_URL"
```

### 4. PagerDuty (For Critical Alerts)

**Setup:**

1. Create PagerDuty integration
2. Get integration key
3. Send alerts:
   ```bash
   curl -X POST https://events.pagerduty.com/v2/enqueue \
     -H 'Content-Type: application/json' \
     -d '{
       "routing_key": "YOUR_INTEGRATION_KEY",
       "event_action": "trigger",
       "payload": {
         "summary": "VoiceFX API Down",
         "severity": "critical",
         "source": "monitoring"
       }
     }'
   ```

---

## Performance Monitoring

### 1. Application Performance (APM)

**Using Sentry Performance:**
- Automatically enabled when `ENABLE_TELEMETRY=true`
- Tracks:
  - API response times
  - Database query performance
  - External API calls
  - Frontend load times

**View in Sentry:**
1. Go to Performance tab
2. Filter by transaction type
3. Identify slow endpoints
4. Check database query performance

### 2. Database Performance

**PostgreSQL monitoring:**

```bash
# Check active connections
docker compose -f docker-compose.prod.yaml exec postgres \
  psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;"

# Check slow queries
docker compose -f docker-compose.prod.yaml exec postgres \
  psql -U postgres -c "SELECT query, calls, total_time FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"

# Enable slow query logging in docker-compose.prod.yaml
services:
  postgres:
    command: postgres -c log_min_duration_statement=1000
```

### 3. Redis Performance

```bash
# Redis stats
docker compose -f docker-compose.prod.yaml exec redis \
  redis-cli -a "${REDIS_PASSWORD}" INFO stats

# Monitor commands
docker compose -f docker-compose.prod.yaml exec redis \
  redis-cli -a "${REDIS_PASSWORD}" MONITOR
```

### 4. Resource Monitoring

```bash
# Real-time resource usage
docker stats

# Add to cron for periodic checks
*/5 * * * * docker stats --no-stream >> /var/log/docker-stats.log
```

---

## Automated Monitoring Setup

**Add to crontab:**

```bash
crontab -e

# Health check every 5 minutes
*/5 * * * * /opt/voicefx/scripts/health-check.sh --alert >> /var/log/voicefx-health.log 2>&1

# Resource check every hour
0 * * * * docker stats --no-stream >> /var/log/docker-stats.log

# Clean old logs daily
0 0 * * * find /var/log -name "*.log" -mtime +7 -delete
```

---

## Monitoring Checklist

- [ ] Uptime monitoring configured (UptimeRobot/Better Uptime)
- [ ] Health check cron job running
- [ ] Log rotation configured
- [ ] Sentry error tracking enabled
- [ ] PostHog analytics configured
- [ ] Alert channels setup (Email/Slack/Discord)
- [ ] Resource monitoring active
- [ ] SSL certificate expiry monitoring
- [ ] Backup monitoring
- [ ] Database performance monitoring

---

## Dashboard URLs

After setup, access monitoring at:

- **Application**: `https://yourdomain.com`
- **Sentry**: `https://sentry.io/organizations/your-org`
- **PostHog**: `https://us.posthog.com/project/your-project`
- **Grafana** (if installed): `http://your-server:3000`
- **Prometheus** (if installed): `http://your-server:9090`

---

## Troubleshooting Monitoring

### Health checks failing

```bash
# Test manually
./scripts/health-check.sh

# Check cron logs
grep CRON /var/log/syslog
```

### Alerts not sending

```bash
# Test Slack webhook
curl -X POST -H 'Content-Type: application/json' \
  -d '{"text":"Test alert"}' \
  "$SLACK_WEBHOOK_URL"

# Check webhook URL is set
echo $SLACK_WEBHOOK_URL
```

### High resource usage alerts

```bash
# Identify resource hog
docker stats --no-stream | sort -k7 -h

# Check logs
docker compose -f docker-compose.prod.yaml logs --tail=100 api
```

---

**Need help?** Check the main DEPLOYMENT.md or open an issue on GitHub.
