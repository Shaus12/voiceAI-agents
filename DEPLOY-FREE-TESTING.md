# Free Deployment Options for Testing VoiceFX AI

Want to test VoiceFX AI without spending money? Here are your best options!

## 🏆 Recommended: Railway (Easiest!)

**What you get:**
- $5 free credit per month (enough for ~5-7 days of testing)
- One-click deployment
- No credit card needed initially
- All services in one place

**Time to deploy: 10 minutes**

### Step-by-Step: Deploy on Railway

#### 1. Create Railway Account

1. Go to https://railway.app
2. Click "Login" → "Login with GitHub"
3. Authorize Railway to access your GitHub

#### 2. Create New Project

1. Click "New Project"
2. Select "Deploy from GitHub repo"
3. Choose `voiceAI-agents` repository
4. Railway will detect your project

#### 3. Add Services

Unfortunately, Railway doesn't support `docker-compose.yaml` directly, so we need to add services one by one:

**Add PostgreSQL:**
1. Click "New" → "Database" → "Add PostgreSQL"
2. Done! Railway auto-configures it

**Add Redis:**
1. Click "New" → "Database" → "Add Redis"
2. Done!

**Deploy API:**
1. Click "New" → "GitHub Repo"
2. Select your repo
3. Click "Add variables"
4. Add these environment variables:
   ```
   DATABASE_URL=${{Postgres.DATABASE_URL}}
   REDIS_URL=${{Redis.REDIS_URL}}
   ENABLE_AWS_S3=false
   ENABLE_TELEMETRY=true
   LOG_LEVEL=INFO
   PORT=8000
   ```
5. In Settings → set "Root Directory" to `api`
6. Deploy!

**Deploy UI:**
1. Click "New" → "GitHub Repo" → Select your repo again
2. Add variables:
   ```
   BACKEND_URL=${{api.RAILWAY_PRIVATE_DOMAIN}}
   NEXT_PUBLIC_API_URL=https://${{api.RAILWAY_PUBLIC_DOMAIN}}
   NODE_ENV=production
   ENABLE_TELEMETRY=true
   ```
3. In Settings → set "Root Directory" to `ui`
4. Deploy!

#### 4. Access Your App

1. Go to the UI service
2. Click "Settings" → "Networking" → "Generate Domain"
3. Copy the URL - that's your app! 🎉

**Note:** Railway's $5 credit typically lasts 5-7 days with this setup. Perfect for testing!

---

## 🚀 Option 2: Fly.io (More Free Time)

**What you get:**
- Free tier: 3 VMs with 256MB RAM each
- Runs longer than Railway
- Better for Docker apps

**Time to deploy: 20 minutes**

### Step-by-Step: Deploy on Fly.io

#### 1. Install Fly CLI

**Mac/Linux:**
```bash
curl -L https://fly.io/install.sh | sh
```

**Windows:**
```powershell
powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"
```

#### 2. Sign Up & Login

```bash
fly auth signup
# Or if you have an account:
fly auth login
```

#### 3. Create App Configuration

I'll create a simplified setup for Fly.io...

Actually, let me create separate fly configs for you:

```bash
# In your project directory
cd /path/to/voicefx
```

**Create `fly.api.toml`:**
```toml
app = "voicefx-api-test"

[build]
  dockerfile = "api/Dockerfile"

[env]
  PORT = "8000"
  LOG_LEVEL = "INFO"

[[services]]
  internal_port = 8000
  protocol = "tcp"

  [[services.ports]]
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443
```

**Create `fly.ui.toml`:**
```toml
app = "voicefx-ui-test"

[build]
  dockerfile = "ui/Dockerfile"

[env]
  PORT = "3010"

[[services]]
  internal_port = 3010
  protocol = "tcp"

  [[services.ports]]
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443
```

#### 4. Deploy API

```bash
# Create Postgres
fly postgres create --name voicefx-db-test

# Deploy API
fly launch --config fly.api.toml
```

#### 5. Deploy UI

```bash
fly launch --config fly.ui.toml
```

**Free tier limitations:**
- 3 shared-cpu VMs (256MB each)
- 3GB storage
- 160GB outbound data transfer/month

---

## 💰 Option 3: Render (Partially Free)

**What you get:**
- Free tier web services (750 hours/month)
- Free PostgreSQL (90 days, then $7/month)
- Services sleep after 15 min of inactivity

**Best for:** Quick demos (but slow to wake up)

### Step-by-Step: Deploy on Render

#### 1. Create Account

1. Go to https://render.com
2. Sign up with GitHub

#### 2. Create PostgreSQL Database

1. Click "New +" → "PostgreSQL"
2. Name: `voicefx-db`
3. Select "Free" tier
4. Click "Create Database"
5. Copy the "Internal Database URL"

#### 3. Deploy API

1. Click "New +" → "Web Service"
2. Connect your GitHub repo
3. Configure:
   - **Name:** `voicefx-api`
   - **Environment:** Docker
   - **Dockerfile path:** `api/Dockerfile`
   - **Plan:** Free
4. Add Environment Variables:
   ```
   DATABASE_URL=<paste-internal-database-url>
   LOG_LEVEL=INFO
   ENABLE_TELEMETRY=true
   PORT=8000
   ```
5. Click "Create Web Service"

#### 4. Deploy UI

1. Click "New +" → "Web Service"
2. Connect your repo again
3. Configure:
   - **Name:** `voicefx-ui`
   - **Environment:** Docker
   - **Dockerfile path:** `ui/Dockerfile`
   - **Plan:** Free
4. Add Environment Variables:
   ```
   BACKEND_URL=https://voicefx-api.onrender.com
   NEXT_PUBLIC_API_URL=https://voicefx-api.onrender.com
   NODE_ENV=production
   PORT=3010
   ```
5. Click "Create Web Service"

**Access:** Your UI will be at `https://voicefx-ui.onrender.com`

**⚠️ Warning:** Free tier sleeps after 15 minutes of inactivity. First request takes ~30 seconds to wake up.

---

## 🎓 Option 4: Oracle Cloud Always Free (Most Generous)

**What you get:**
- Actually FREE forever (not a trial)
- 4 ARM CPUs + 24GB RAM (can run 4 VMs)
- 200GB storage
- Better than paid options!

**Downside:** More complex setup

### Step-by-Step: Oracle Cloud

#### 1. Create Account

1. Go to https://www.oracle.com/cloud/free/
2. Click "Start for free"
3. Fill out form (requires credit card for verification, but won't charge)
4. Verify email and account

#### 2. Create a VM

1. Click "Create a VM instance"
2. **Image:** Select "Ubuntu 22.04"
3. **Shape:** Select "Ampere" (ARM) - **Always Free eligible**
   - Choose: VM.Standard.A1.Flex
   - OCPUs: 2
   - Memory: 12 GB
4. **Networking:**
   - Create new VCN (default settings)
   - Assign public IP: Yes
5. **SSH Keys:**
   - Download the private key (save it!)
6. Click "Create"

#### 3. Configure Firewall

1. Go to "Virtual Cloud Networks"
2. Click your VCN → "Security Lists" → "Default Security List"
3. Click "Add Ingress Rules"
4. Add these rules:
   - Source: `0.0.0.0/0`, Port: `80`
   - Source: `0.0.0.0/0`, Port: `443`
   - Source: `0.0.0.0/0`, Port: `22`

#### 4. Connect to Your VM

Get your VM's public IP from the instance details.

**Mac/Linux:**
```bash
chmod 400 ~/Downloads/ssh-key.key
ssh -i ~/Downloads/ssh-key.key ubuntu@<YOUR_VM_IP>
```

**Windows:** Use PuTTY with the private key

#### 5. Deploy VoiceFX

Once connected, follow the regular deployment guide:

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Download VoiceFX
cd /opt
git clone https://github.com/Shaus12/voiceAI-agents.git voicefx
cd voicefx

# Configure
cp .env.production.example .env.production
nano .env.production  # Edit the settings

# Deploy
./scripts/deploy.sh setup
./scripts/deploy.sh start
```

Access at: `http://<YOUR_VM_IP>:3010`

**This is FREE FOREVER!** 🎉

---

## 📊 Comparison

| Platform | Free Duration | Setup Time | Sleeps? | Best For |
|----------|--------------|------------|---------|----------|
| **Railway** | 5-7 days | 10 min | No | Quick test |
| **Fly.io** | Forever* | 20 min | No | Longer testing |
| **Render** | 90 days** | 15 min | Yes (15 min) | Demos |
| **Oracle Cloud** | Forever | 45 min | No | Long-term free |

\* Free tier has limitations (3 small VMs)
\*\* PostgreSQL free for 90 days, then $7/month

---

## 🏃 Quick Start: Railway (Recommended for Testing)

The absolute fastest way to test:

1. **Go to:** https://railway.app
2. **Login** with GitHub
3. **New Project** → Deploy from GitHub
4. **Select:** your voiceAI-agents repo
5. **Add PostgreSQL** database
6. **Add Redis** database
7. **Configure** API and UI services (see Railway section above)
8. **Generate domain** for UI
9. **Done!** Visit your URL

You'll have ~$5 credit which lasts about a week of testing.

---

## 🆓 My Recommendation for FREE Testing

**For 1 week of testing:**
→ Use **Railway** (easiest, fast setup)

**For permanent free hosting:**
→ Use **Oracle Cloud Always Free** (takes longer to setup, but actually free forever)

**For quick demo:**
→ Use **Render** (but it sleeps, so slow to wake up)

---

## ⚡ Limitations of Free Tiers

All free tiers have some limitations:

- **Railway:** $5/month credit (runs out in ~7 days)
- **Fly.io:** Small VMs (256MB RAM each)
- **Render:** Services sleep after 15 min inactivity
- **Oracle:** Great specs, but ARM architecture (some images may not work)

**For serious testing:** You might need the $24/month DigitalOcean server eventually.

But for **"let's see if this works"** testing → Free tiers are perfect! 🎉

---

## 🔄 Moving from Free to Paid Later

When you're ready for production:

1. Export your data (use backup scripts)
2. Setup production server (DigitalOcean guide)
3. Import your data
4. Update DNS

Your configuration work isn't wasted - you can reuse all your settings!

---

## ❓ Which Should I Choose?

**Answer these questions:**

1. **"I just want to click and test quickly"**
   → Railway

2. **"I want to test for free as long as possible"**
   → Oracle Cloud Always Free

3. **"I'm okay with slow wake-up times"**
   → Render

4. **"I'm comfortable with command line"**
   → Fly.io or Oracle Cloud

---

**Want me to create the actual deployment files for any of these?** Just let me know which platform you prefer!
