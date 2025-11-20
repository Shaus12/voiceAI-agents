# VoiceFX AI - Production Deployment Guide

This guide covers deploying VoiceFX AI to production using Docker Compose on a VPS/VM.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Deployment Options](#deployment-options)
  - [Option 1: Single VPS with Docker Compose](#option-1-single-vps-with-docker-compose-recommended)
  - [Option 2: Split Frontend/Backend](#option-2-split-frontendbackend)
  - [Option 3: Managed Platforms](#option-3-managed-platforms)
- [Configuration](#configuration)
- [SSL/HTTPS Setup](#sslhttps-setup)
- [Backups & Recovery](#backups--recovery)
- [Monitoring & Maintenance](#monitoring--maintenance)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Server Requirements

- **OS**: Ubuntu 22.04 LTS or similar Linux distribution
- **RAM**: Minimum 4GB, recommended 8GB+
- **CPU**: 2+ cores
- **Disk**: 50GB+ SSD storage
- **Ports**: 80 (HTTP), 443 (HTTPS) accessible from internet

### Software Requirements

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Verify installations
docker --version
docker compose version
```

### Domain Setup

- Purchase a domain name
- Point DNS A records to your server IP:
  - `yourdomain.com` → `YOUR_SERVER_IP`
  - `www.yourdomain.com` → `YOUR_SERVER_IP`
  - `api.yourdomain.com` → `YOUR_SERVER_IP`
  - `app.yourdomain.com` → `YOUR_SERVER_IP`

---

## Quick Start

### 1. Clone Repository

```bash
cd /opt
git clone https://github.com/Shaus12/voiceAI-agents.git voicefx
cd voicefx
```

### 2. Configure Environment

```bash
# Copy environment template
cp .env.production.example .env.production

# Edit configuration
nano .env.production
```

**Critical settings to change:**

```env
# Database passwords
POSTGRES_PASSWORD=your_secure_password_here
REDIS_PASSWORD=your_secure_redis_password

# MinIO credentials
MINIO_ACCESS_KEY=your_minio_access_key
MINIO_SECRET_KEY=your_minio_secret_key

# Security
JWT_SECRET=your_long_random_jwt_secret

# Domain configuration
DOMAIN=yourdomain.com
NEXT_PUBLIC_API_URL=https://api.yourdomain.com
```

### 3. Update Nginx Configuration

```bash
# Edit nginx config and replace 'yourdomain.com' with your actual domain
nano nginx/conf.d/voicefx.conf
```

### 4. Setup SSL Certificates

```bash
# Run SSL setup script (uses Let's Encrypt)
./scripts/setup-ssl.sh

# Or manually place certificates in nginx/ssl/
# - nginx/ssl/fullchain.pem
# - nginx/ssl/privkey.pem
```

### 5. Initialize and Deploy

```bash
# Run initial setup
./scripts/deploy.sh setup

# Start the application
./scripts/deploy.sh start

# Check status
./scripts/deploy.sh status
```

### 6. Access Your Application

- **UI**: `https://yourdomain.com`
- **API Docs**: `https://api.yourdomain.com/docs`
- **Health Check**: `https://api.yourdomain.com/api/v1/health`

---

## Deployment Options

### Option 1: Single VPS with Docker Compose (Recommended)

**Pros**: Simple, all-in-one, easy to manage
**Cons**: Single point of failure, limited scalability

This is covered in the Quick Start section above.

**Architecture**:
```
Internet → Nginx (443) → UI (3010) + API (8000)
                      ↓
          PostgreSQL + Redis + MinIO
```

**Estimated Monthly Cost**:
- DigitalOcean Droplet (4GB RAM): ~$24/month
- Linode (4GB RAM): ~$24/month
- AWS Lightsail (4GB RAM): ~$32/month

---

### Option 2: Split Frontend/Backend

Deploy Next.js frontend separately from the backend stack.

#### Frontend on Vercel

1. **Create new Vercel project**:
   ```bash
   cd ui
   vercel
   ```

2. **Configure environment variables** in Vercel dashboard:
   ```env
   BACKEND_URL=https://api.yourdomain.com
   NEXT_PUBLIC_API_URL=https://api.yourdomain.com
   NEXT_PUBLIC_AUTH_PROVIDER=local
   ENABLE_TELEMETRY=true
   POSTHOG_KEY=phc_...
   SENTRY_DSN=https://...
   ```

3. **Deploy**:
   ```bash
   vercel --prod
   ```

#### Backend on VPS

1. **Modify docker-compose.prod.yaml** - Remove UI service
2. **Deploy only backend services**:
   ```bash
   docker compose -f docker-compose.prod.yaml up -d postgres redis minio api
   ```

**Pros**: Faster frontend (Vercel CDN), auto-scaling
**Cons**: More complex, higher cost

---

### Option 3: Managed Platforms

#### Backend: Fly.io / Render / Railway

**Fly.io Example**:

1. **Install flyctl**:
   ```bash
   curl -L https://fly.io/install.sh | sh
   ```

2. **Create fly.toml**:
   ```toml
   app = "voicefx-api"

   [env]
     ENVIRONMENT = "production"
     LOG_LEVEL = "INFO"

   [[services]]
     internal_port = 8000
     protocol = "tcp"

     [[services.ports]]
       port = 80
       handlers = ["http"]

     [[services.ports]]
       port = 443
       handlers = ["tls", "http"]
   ```

3. **Deploy**:
   ```bash
   fly launch
   fly deploy
   ```

**Use Managed Databases**:
- PostgreSQL: AWS RDS, DigitalOcean Managed Database, Neon
- Redis: Upstash, Redis Cloud
- S3: AWS S3, Cloudflare R2, Backblaze B2

---

## Configuration

### Environment Variables Reference

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `POSTGRES_PASSWORD` | PostgreSQL password | Yes | - |
| `REDIS_PASSWORD` | Redis password | Yes | - |
| `MINIO_ACCESS_KEY` | MinIO access key | Yes | - |
| `MINIO_SECRET_KEY` | MinIO secret key | Yes | - |
| `JWT_SECRET` | JWT signing secret | Yes | - |
| `DOMAIN` | Your domain name | Yes | - |
| `ENABLE_TELEMETRY` | Enable Sentry/PostHog | No | `true` |
| `ENABLE_AWS_S3` | Use AWS S3 instead of MinIO | No | `false` |
| `LOG_LEVEL` | API log level | No | `INFO` |

### Port Reference

| Service | Internal Port | External Port | Description |
|---------|---------------|---------------|-------------|
| UI | 3010 | 443 (via nginx) | Next.js frontend |
| API | 8000 | 443 (via nginx) | FastAPI backend |
| PostgreSQL | 5432 | Not exposed | Database |
| Redis | 6379 | Not exposed | Cache |
| MinIO | 9000, 9001 | 127.0.0.1 only | Object storage |
| Nginx | 80, 443 | 80, 443 | Reverse proxy |

---

## SSL/HTTPS Setup

### Option A: Let's Encrypt (Automated)

```bash
./scripts/setup-ssl.sh
```

This will:
1. Request certificates for your domain
2. Configure automatic renewal
3. Update nginx configuration

**Setup auto-renewal**:
```bash
# Add to crontab
crontab -e

# Add this line (runs weekly)
0 0 * * 0 /opt/voicefx/scripts/renew-ssl.sh
```

### Option B: Cloudflare (Recommended for simplicity)

1. **Add domain to Cloudflare**
2. **Enable "Full (Strict)" SSL mode**
3. **Create Origin Certificate**:
   - Cloudflare Dashboard → SSL/TLS → Origin Server
   - Create Certificate
   - Save as `nginx/ssl/fullchain.pem` and `nginx/ssl/privkey.pem`
4. **Enable "Always Use HTTPS"**

**Pros**: DDoS protection, CDN, easier management
**Cons**: Traffic goes through Cloudflare

### Option C: Manual Certificate

Place your certificate files:
```
nginx/ssl/fullchain.pem  # Full chain certificate
nginx/ssl/privkey.pem    # Private key
```

---

## Backups & Recovery

### Automated Backups

```bash
# Create backup
./scripts/deploy.sh backup

# Backups stored in: ./backups/backup_YYYYMMDD_HHMMSS.tar.gz
```

**Setup automated backups**:
```bash
# Add to crontab
crontab -e

# Daily backup at 2 AM
0 2 * * * /opt/voicefx/scripts/deploy.sh backup

# Clean old backups (keep last 30 days)
0 3 * * * find /opt/voicefx/backups -name "backup_*.tar.gz" -mtime +30 -delete
```

### Backup to S3

```bash
# Install AWS CLI
sudo apt-get install awscli

# Configure
aws configure

# Sync backups to S3
aws s3 sync ./backups/ s3://your-backup-bucket/voicefx-backups/
```

### Restore from Backup

```bash
./scripts/deploy.sh restore backups/backup_20240115_020000.tar.gz
```

---

## Monitoring & Maintenance

### Health Checks

```bash
# Check service status
./scripts/deploy.sh status

# View logs
./scripts/deploy.sh logs

# View specific service logs
./scripts/deploy.sh logs api
./scripts/deploy.sh logs ui
```

### Built-in Monitoring

**PostHog** (Analytics):
- Dashboard: https://us.posthog.com
- Track user behavior, feature usage

**Sentry** (Error Tracking):
- Dashboard: https://sentry.io
- Real-time error alerts
- Performance monitoring

### System Monitoring

**Install monitoring tools**:
```bash
# Install htop
sudo apt-get install htop

# Install docker stats
docker stats
```

**Setup Uptime Monitoring**:
- UptimeRobot (free): https://uptimerobot.com
- Better Uptime: https://betteruptime.com
- StatusCake: https://www.statuscake.com

### Logs

```bash
# Application logs
tail -f logs/api/*.log

# Nginx logs
tail -f nginx/logs/access.log
tail -f nginx/logs/error.log

# Docker logs
docker compose -f docker-compose.prod.yaml logs -f
```

---

## Updates & Maintenance

### Update Application

```bash
# Pull latest changes
git pull

# Update and restart
./scripts/deploy.sh update
```

### Database Migrations

```bash
# Run migrations manually
docker compose -f docker-compose.prod.yaml run --rm api alembic upgrade head

# Check migration status
docker compose -f docker-compose.prod.yaml run --rm api alembic current
```

### Scaling

#### Horizontal Scaling (Multiple Servers)

1. **Extract database services** to separate server
2. **Use external managed services** (RDS, Redis Cloud, S3)
3. **Deploy multiple API/UI instances** with load balancer
4. **Setup load balancer** (HAProxy, Nginx, Cloudflare Load Balancing)

#### Vertical Scaling (Bigger Server)

```bash
# Increase Docker resource limits in docker-compose.prod.yaml
services:
  api:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
```

---

## Troubleshooting

### Services Won't Start

```bash
# Check logs
docker compose -f docker-compose.prod.yaml logs

# Check if ports are in use
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Restart Docker
sudo systemctl restart docker
```

### Database Connection Errors

```bash
# Check PostgreSQL is healthy
docker compose -f docker-compose.prod.yaml ps postgres

# Test connection
docker compose -f docker-compose.prod.yaml exec postgres psql -U postgres -c "SELECT 1"

# Check database logs
docker compose -f docker-compose.prod.yaml logs postgres
```

### SSL Certificate Issues

```bash
# Test certificate
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com

# Check nginx config
docker compose -f docker-compose.prod.yaml exec nginx nginx -t

# Reload nginx
docker compose -f docker-compose.prod.yaml exec nginx nginx -s reload
```

### High Memory Usage

```bash
# Check resource usage
docker stats

# Limit service memory
# Edit docker-compose.prod.yaml and add:
services:
  api:
    mem_limit: 2g
```

### Can't Access Application

1. **Check firewall**:
   ```bash
   sudo ufw status
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```

2. **Check DNS**:
   ```bash
   dig yourdomain.com
   nslookup yourdomain.com
   ```

3. **Check nginx**:
   ```bash
   docker compose -f docker-compose.prod.yaml logs nginx
   ```

---

## Security Checklist

- [ ] Change all default passwords in `.env.production`
- [ ] Enable SSL/HTTPS
- [ ] Configure firewall (UFW or cloud firewall)
- [ ] Setup automatic security updates
- [ ] Enable fail2ban for SSH protection
- [ ] Regular backups configured
- [ ] Monitoring and alerts configured
- [ ] Review nginx security headers
- [ ] Disable root SSH login
- [ ] Use SSH keys instead of passwords
- [ ] Keep Docker and system updated

```bash
# Setup automatic security updates
sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Setup fail2ban
sudo apt-get install fail2ban
sudo systemctl enable fail2ban
```

---

## Support & Resources

- **Documentation**: This file
- **Issues**: https://github.com/Shaus12/voiceAI-agents/issues
- **Docker Docs**: https://docs.docker.com
- **Nginx Docs**: https://nginx.org/en/docs/
- **Let's Encrypt**: https://letsencrypt.org/docs/

---

## Next Steps

After successful deployment:

1. **Test all functionality**: Create test workflows, make test calls
2. **Setup monitoring alerts**: Configure Sentry and PostHog
3. **Configure backups**: Setup automated backup schedule
4. **Plan for scaling**: Monitor usage and plan capacity
5. **Document customizations**: Keep track of any changes you make

---

**Need help?** Open an issue on GitHub or check the troubleshooting section above.
