# Deploy VoiceFX AI - Complete Beginner's Guide

This guide assumes you know NOTHING and will walk you through EVERYTHING.

## What You'll Need to Buy/Get

1. **A Domain Name** (~$12/year)
   - This is your website address (like `myvoicefx.com`)
   - Buy from: Namecheap, GoDaddy, or Google Domains

2. **A Server** (~$24/month)
   - This is a computer that runs 24/7 in the cloud
   - Recommended: DigitalOcean Droplet or Linode

**Total Cost: ~$12/year + $24/month = ~$300/year**

---

## PART 1: Get a Server (DigitalOcean Example)

### Step 1: Create DigitalOcean Account

1. Go to https://www.digitalocean.com
2. Click "Sign Up"
3. Enter your email and create a password
4. Verify your email
5. Add a payment method (credit card)

### Step 2: Create a Server (Called a "Droplet")

1. Click the green "Create" button (top right)
2. Select "Droplets"
3. **Choose Region**: Pick closest to you or your users
   - Example: New York, San Francisco, London, etc.
4. **Choose Image**:
   - Click "Ubuntu"
   - Select "22.04 LTS x64"
5. **Choose Size**:
   - Click "Regular" (not Premium)
   - Select the **$24/month** option (4GB RAM, 2 CPUs)
   - This one: `Regular - $24/mo - 4 GB / 2 CPUs - 80 GB SSD`
6. **Authentication**:
   - Choose "Password" (easier for beginners)
   - Create a strong password (write it down!)
   - Example: `MySecurePassword123!@#`
7. **Hostname**:
   - Give it a name: `voicefx-server`
8. Click **"Create Droplet"**
9. Wait 1-2 minutes for it to be created

### Step 3: Get Your Server's IP Address

1. You'll see your new droplet in the list
2. Copy the **IP address** - it looks like: `142.93.123.45`
3. Write this down! You'll need it.

---

## PART 2: Get a Domain Name

### Step 1: Buy a Domain

1. Go to https://www.namecheap.com (or your preferred registrar)
2. Search for a domain name
   - Example: `myvoicefx.com`
3. Add to cart and checkout
4. Complete the purchase (~$12)

### Step 2: Point Your Domain to Your Server

1. Log into Namecheap
2. Go to "Domain List"
3. Click "Manage" next to your domain
4. Click "Advanced DNS"
5. Add these records (delete any existing A records first):

| Type | Host | Value | TTL |
|------|------|-------|-----|
| A Record | @ | YOUR_SERVER_IP | Automatic |
| A Record | www | YOUR_SERVER_IP | Automatic |
| A Record | api | YOUR_SERVER_IP | Automatic |
| A Record | app | YOUR_SERVER_IP | Automatic |

Replace `YOUR_SERVER_IP` with the IP from Part 1, Step 3.

Example:
- Type: `A Record`
- Host: `@`
- Value: `142.93.123.45`
- TTL: `Automatic`

6. Click "Save All Changes"
7. Wait 5-30 minutes for DNS to update

**To check if DNS is ready:**
- Open Command Prompt (Windows) or Terminal (Mac)
- Type: `ping yourdomain.com`
- If you see your IP address, it's ready!

---

## PART 3: Connect to Your Server

### For Windows Users:

1. **Download PuTTY**: https://www.putty.org/
2. **Open PuTTY**
3. In "Host Name" field, enter your server's IP address: `142.93.123.45`
4. Click "Open"
5. Click "Yes" on the security alert
6. Login:
   - Username: `root`
   - Password: (the password you created in Part 1, Step 2)
   - Note: When typing password, you won't see anything - this is normal!
7. Press Enter

### For Mac/Linux Users:

1. **Open Terminal** (search for "Terminal" in Spotlight)
2. Type: `ssh root@142.93.123.45` (replace with YOUR IP)
3. Type `yes` when asked about authenticity
4. Enter your password (you won't see it as you type - this is normal)
5. Press Enter

**You're now connected to your server!** 🎉

---

## PART 4: Install Required Software

Copy and paste each command below, one at a time, into your server terminal:

### Step 1: Update the System

```bash
apt update && apt upgrade -y
```

Wait for this to complete (may take 2-3 minutes).

### Step 2: Install Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

Wait for installation (1-2 minutes).

### Step 3: Install Docker Compose

```bash
apt-get install docker-compose-plugin -y
```

### Step 4: Verify Installation

```bash
docker --version
docker compose version
```

You should see version numbers. If you do, great! ✅

### Step 5: Install Git

```bash
apt install git -y
```

---

## PART 5: Download VoiceFX AI

### Step 1: Create a Directory

```bash
cd /opt
```

### Step 2: Clone the Repository

```bash
git clone https://github.com/Shaus12/voiceAI-agents.git voicefx
```

### Step 3: Go to the Directory

```bash
cd voicefx
```

### Step 4: List Files (to make sure it worked)

```bash
ls -la
```

You should see files like `docker-compose.prod.yaml`, `scripts/`, etc.

---

## PART 6: Configure Your Application

### Step 1: Copy the Environment Template

```bash
cp .env.production.example .env.production
```

### Step 2: Edit the Configuration File

```bash
nano .env.production
```

This opens a text editor. Now you need to change some values:

**Things to CHANGE (use arrow keys to navigate):**

1. Find `POSTGRES_PASSWORD=CHANGE_THIS` and change to something secure:
   ```
   POSTGRES_PASSWORD=MyVerySecureDBPassword123!
   ```

2. Find `REDIS_PASSWORD=CHANGE_THIS` and change it:
   ```
   REDIS_PASSWORD=MyRedisPassword456!
   ```

3. Find `MINIO_ACCESS_KEY=CHANGE_THIS` and change it:
   ```
   MINIO_ACCESS_KEY=minio_admin_user
   ```

4. Find `MINIO_SECRET_KEY=CHANGE_THIS` and change it:
   ```
   MINIO_SECRET_KEY=MinioSecretKey789!
   ```

5. Find `JWT_SECRET=CHANGE_THIS` and change to a long random string:
   ```
   JWT_SECRET=your-very-long-random-string-here-make-it-really-long-123456789
   ```

6. Find `DOMAIN=yourdomain.com` and change to YOUR domain:
   ```
   DOMAIN=myvoicefx.com
   ```

7. Find `NEXT_PUBLIC_API_URL=https://api.yourdomain.com` and change:
   ```
   NEXT_PUBLIC_API_URL=https://api.myvoicefx.com
   ```

**To save and exit nano:**
1. Press `Ctrl + X`
2. Press `Y` (for yes)
3. Press `Enter`

---

## PART 7: Update Nginx Configuration

### Step 1: Edit Nginx Config

```bash
nano nginx/conf.d/voicefx.conf
```

### Step 2: Replace Domain Name

You need to replace ALL instances of `yourdomain.com` with YOUR domain.

**In nano:**
1. Press `Ctrl + \` (this is "find and replace")
2. Type: `yourdomain.com`
3. Press `Enter`
4. Type: `myvoicefx.com` (or whatever YOUR domain is)
5. Press `Enter`
6. Press `A` (to replace All)

**Save and exit:**
1. Press `Ctrl + X`
2. Press `Y`
3. Press `Enter`

---

## PART 8: Setup SSL Certificates (HTTPS)

### Step 1: Make Script Executable

```bash
chmod +x scripts/setup-ssl.sh
```

### Step 2: Run SSL Setup

```bash
./scripts/setup-ssl.sh
```

### Step 3: Answer the Prompts

1. **Enter your domain name**: Type `myvoicefx.com` (your actual domain)
2. **Enter your email**: Type your real email address
3. Press `Enter` when it asks you to continue

**This might take 1-2 minutes.**

If it says "SSL certificate obtained successfully!" - Great! ✅

If it fails:
- Make sure your domain DNS is pointing to your server
- Wait 30 minutes and try again (DNS can be slow)

---

## PART 9: Deploy the Application

### Step 1: Make Deploy Script Executable

```bash
chmod +x scripts/deploy.sh
```

### Step 2: Run Initial Setup

```bash
./scripts/deploy.sh setup
```

This will:
- Create necessary directories
- Download Docker images (will take 5-10 minutes)
- Setup the database

**Wait for it to complete!**

### Step 3: Start the Application

```bash
./scripts/deploy.sh start
```

This will:
- Start all services
- Takes about 2-3 minutes

You'll see lots of text scrolling. That's normal!

### Step 4: Check if Everything is Running

```bash
./scripts/deploy.sh status
```

You should see something like:
```
NAME        IMAGE       STATUS      PORTS
postgres    postgres    Up (healthy)
redis       redis       Up (healthy)
minio       minio       Up (healthy)
api         dograh-api  Up (healthy)
ui          dograh-ui   Up (healthy)
nginx       nginx       Up
```

All should say "Up" and most should say "(healthy)" ✅

---

## PART 10: Setup Firewall (Security)

### Step 1: Install Firewall

```bash
apt install ufw -y
```

### Step 2: Allow Necessary Ports

```bash
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
```

### Step 3: Enable Firewall

```bash
ufw enable
```

Type `y` and press Enter.

### Step 4: Check Firewall Status

```bash
ufw status
```

Should show ports 22, 80, and 443 as ALLOWED ✅

---

## PART 11: Test Your Application

### Step 1: Open Your Browser

Go to: `https://myvoicefx.com` (use YOUR domain)

**You should see the VoiceFX AI homepage!** 🎉

### Step 2: Test the API

Go to: `https://api.myvoicefx.com/docs`

You should see the API documentation page!

### Step 3: Test API Health

Go to: `https://api.myvoicefx.com/api/v1/health`

You should see: `{"status":"healthy"}` or similar

---

## PART 12: Setup Automated Backups

### Step 1: Open Crontab Editor

```bash
crontab -e
```

If asked which editor, choose `1` (nano).

### Step 2: Add Backup Jobs

Scroll to the bottom and add these lines:

```bash
# Daily backup at 2 AM
0 2 * * * /opt/voicefx/scripts/deploy.sh backup

# Clean old backups (keep 30 days)
0 3 * * * find /opt/voicefx/backups -name "backup_*.tar.gz" -mtime +30 -delete

# Health check every 5 minutes
*/5 * * * * /opt/voicefx/scripts/health-check.sh >> /var/log/voicefx-health.log 2>&1

# SSL renewal weekly
0 0 * * 0 /opt/voicefx/scripts/renew-ssl.sh
```

**Save and exit:**
1. Press `Ctrl + X`
2. Press `Y`
3. Press `Enter`

---

## 🎉 CONGRATULATIONS! YOU'RE DONE!

Your VoiceFX AI application is now:
- ✅ Running in production
- ✅ Accessible via HTTPS
- ✅ Automatically backing up daily
- ✅ Secured with firewall
- ✅ Monitoring itself

---

## Common Commands You'll Need

### View Logs
```bash
cd /opt/voicefx
./scripts/deploy.sh logs
```

### View Logs for Specific Service
```bash
./scripts/deploy.sh logs api
./scripts/deploy.sh logs ui
```

### Restart Everything
```bash
./scripts/deploy.sh restart
```

### Check Status
```bash
./scripts/deploy.sh status
```

### Create Manual Backup
```bash
./scripts/deploy.sh backup
```

### Update to Latest Version
```bash
cd /opt/voicefx
git pull
./scripts/deploy.sh update
```

---

## Troubleshooting

### Can't Access Website

**Check 1: Is DNS ready?**
```bash
ping myvoicefx.com
```
If it doesn't show your server IP, wait longer (DNS can take up to 24 hours, but usually 30 minutes).

**Check 2: Are services running?**
```bash
cd /opt/voicefx
./scripts/deploy.sh status
```
All should say "Up".

**Check 3: Check logs**
```bash
./scripts/deploy.sh logs nginx
./scripts/deploy.sh logs ui
./scripts/deploy.sh logs api
```

### SSL Certificate Didn't Work

1. Make sure DNS is pointing to your server:
   ```bash
   ping myvoicefx.com
   ```

2. Try again:
   ```bash
   cd /opt/voicefx
   ./scripts/setup-ssl.sh
   ```

3. If still failing, use Cloudflare (easier):
   - Add your domain to Cloudflare
   - Point DNS there
   - Enable "Full (Strict)" SSL mode

### Service Won't Start

```bash
# Check what's wrong
./scripts/deploy.sh logs [service-name]

# Try restarting
./scripts/deploy.sh restart

# If still broken, restart Docker
systemctl restart docker
./scripts/deploy.sh start
```

### Forgot Server Password

You'll need to reset it via DigitalOcean dashboard:
1. Go to your droplet
2. Click "Access" → "Reset Root Password"
3. New password will be emailed to you

---

## Maintenance Checklist

**Weekly:**
- [ ] Check `./scripts/deploy.sh status`
- [ ] Check disk space: `df -h`

**Monthly:**
- [ ] Update system: `apt update && apt upgrade -y`
- [ ] Test backups by downloading one
- [ ] Check logs for errors

**Every 3 Months:**
- [ ] Review security updates
- [ ] Test disaster recovery (restore from backup)

---

## Getting Help

1. **Check Logs First:**
   ```bash
   ./scripts/deploy.sh logs
   ```

2. **Run Health Check:**
   ```bash
   ./scripts/health-check.sh
   ```

3. **Check Documentation:**
   - Full guide: `DEPLOYMENT.md`
   - Quick reference: `DEPLOYMENT-QUICKREF.md`
   - Monitoring: `MONITORING.md`

4. **Still Stuck?**
   - Open an issue: https://github.com/Shaus12/voiceAI-agents/issues

---

## What You've Deployed

You now have a full production stack running:
- **UI** (Next.js frontend) - Your user interface
- **API** (FastAPI backend) - Your application logic
- **PostgreSQL** - Your database
- **Redis** - Your cache
- **MinIO** - Your file storage
- **Nginx** - Your web server/reverse proxy

All secured with HTTPS and automated backups! 🔒

---

## Next Steps

1. **Create Your First Workflow**: Visit your site and create a test workflow
2. **Setup Monitoring**: Check `MONITORING.md` for alert setup
3. **Invite Users**: Share your domain with team members
4. **Configure Integrations**: Add your telephony and AI service keys

---

**Need to shut everything down?**
```bash
cd /opt/voicefx
./scripts/deploy.sh stop
```

**Need to start it back up?**
```bash
./scripts/deploy.sh start
```

---

**You did it! Welcome to production! 🚀**
