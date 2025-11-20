# VoiceFX AI - Deployment Quick Reference

## 🚀 Common Commands

### Initial Deployment

```bash
# 1. Copy and configure environment
cp .env.production.example .env.production
nano .env.production  # Edit with your values

# 2. Setup SSL certificates
./scripts/setup-ssl.sh

# 3. Initialize and start
./scripts/deploy.sh setup
./scripts/deploy.sh start
```

### Daily Operations

```bash
# Check status
./scripts/deploy.sh status

# View logs
./scripts/deploy.sh logs          # All services
./scripts/deploy.sh logs api      # API only
./scripts/deploy.sh logs ui       # UI only

# Restart services
./scripts/deploy.sh restart

# Health check
./scripts/health-check.sh
```

### Updates

```bash
# Pull latest code and update
git pull
./scripts/deploy.sh update
```

### Backups

```bash
# Create backup
./scripts/deploy.sh backup

# Restore from backup
./scripts/deploy.sh restore backups/backup_20240115.tar.gz
```

---

## 📝 Environment Variables (Critical)

Edit `.env.production` and change these:

```env
# Database & Cache
POSTGRES_PASSWORD=CHANGE_THIS
REDIS_PASSWORD=CHANGE_THIS

# Object Storage
MINIO_ACCESS_KEY=CHANGE_THIS
MINIO_SECRET_KEY=CHANGE_THIS

# Security
JWT_SECRET=CHANGE_THIS_LONG_RANDOM_STRING

# Domain
DOMAIN=yourdomain.com
NEXT_PUBLIC_API_URL=https://api.yourdomain.com
```

---

## 🌐 Service URLs

After deployment:

- **UI**: `https://yourdomain.com` or `https://app.yourdomain.com`
- **API**: `https://api.yourdomain.com`
- **API Docs**: `https://api.yourdomain.com/docs`
- **Health Check**: `https://api.yourdomain.com/api/v1/health`

---

## 🐳 Docker Commands

```bash
# View running containers
docker compose -f docker-compose.prod.yaml ps

# View container logs
docker compose -f docker-compose.prod.yaml logs -f [service]

# Restart a specific service
docker compose -f docker-compose.prod.yaml restart api

# Execute command in container
docker compose -f docker-compose.prod.yaml exec api bash

# View resource usage
docker stats
```

---

## 🔥 Emergency Procedures

### Everything is Down

```bash
# Stop all services
./scripts/deploy.sh stop

# Start fresh
./scripts/deploy.sh start

# Check what's wrong
./scripts/deploy.sh logs
```

### Database Issues

```bash
# Check database health
docker compose -f docker-compose.prod.yaml exec postgres pg_isready -U postgres

# Connect to database
docker compose -f docker-compose.prod.yaml exec postgres psql -U postgres

# Run migrations
docker compose -f docker-compose.prod.yaml run --rm api alembic upgrade head
```

### Out of Disk Space

```bash
# Check disk usage
df -h

# Clean Docker
docker system prune -a --volumes

# Remove old logs
find logs/ -name "*.log" -mtime +7 -delete
find nginx/logs/ -name "*.log" -mtime +7 -delete

# Remove old backups
find backups/ -name "backup_*.tar.gz" -mtime +30 -delete
```

### SSL Certificate Expired

```bash
# Renew certificate
./scripts/renew-ssl.sh

# Or manually
docker run --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot renew
```

### High Memory Usage

```bash
# Check memory usage
free -h
docker stats

# Restart specific service
docker compose -f docker-compose.prod.yaml restart api

# Restart all services
./scripts/deploy.sh restart
```

---

## 📊 Monitoring

### Health Check

```bash
# Manual health check
./scripts/health-check.sh

# With alerts (requires SLACK_WEBHOOK_URL)
./scripts/health-check.sh --alert
```

### Add to Cron for Automated Monitoring

```bash
crontab -e

# Add these lines:
# Health check every 5 minutes
*/5 * * * * /opt/voicefx/scripts/health-check.sh --alert

# Daily backup at 2 AM
0 2 * * * /opt/voicefx/scripts/deploy.sh backup

# Weekly SSL renewal
0 0 * * 0 /opt/voicefx/scripts/renew-ssl.sh

# Clean old backups (keep 30 days)
0 3 * * * find /opt/voicefx/backups -name "backup_*.tar.gz" -mtime +30 -delete
```

---

## 🔍 Troubleshooting

### Can't Access Application

1. Check firewall: `sudo ufw status`
2. Check DNS: `dig yourdomain.com`
3. Check nginx: `docker compose -f docker-compose.prod.yaml logs nginx`
4. Check services: `./scripts/deploy.sh status`

### API Returns 502 Bad Gateway

```bash
# Check API health
docker compose -f docker-compose.prod.yaml logs api

# Restart API
docker compose -f docker-compose.prod.yaml restart api

# Check database connection
docker compose -f docker-compose.prod.yaml exec postgres pg_isready
```

### Database Connection Errors

```bash
# Check PostgreSQL is running
docker compose -f docker-compose.prod.yaml ps postgres

# Check database logs
docker compose -f docker-compose.prod.yaml logs postgres

# Restart PostgreSQL
docker compose -f docker-compose.prod.yaml restart postgres
```

---

## 🔐 Security Checklist

- [ ] Changed all default passwords
- [ ] SSL/HTTPS enabled
- [ ] Firewall configured (ports 80, 443 only)
- [ ] SSH key authentication enabled
- [ ] Root SSH login disabled
- [ ] Automatic security updates enabled
- [ ] Backups configured and tested
- [ ] Monitoring enabled

---

## 📞 Quick Links

- Full Documentation: `DEPLOYMENT.md`
- Environment Template: `.env.production.example`
- Nginx Config: `nginx/conf.d/voicefx.conf`
- Docker Compose: `docker-compose.prod.yaml`

---

## 🆘 Getting Help

1. Check logs: `./scripts/deploy.sh logs`
2. Run health check: `./scripts/health-check.sh`
3. Review documentation: `DEPLOYMENT.md`
4. Open issue: https://github.com/Shaus12/voiceAI-agents/issues
