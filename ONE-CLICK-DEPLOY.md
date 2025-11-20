# 🚀 One-Click Free Deployment

Deploy VoiceFX AI for FREE in under 5 minutes!

## ⚡ Option 1: Render (Absolute Easiest)

**Free for 90 days, then PostgreSQL costs $7/month**

### Click This Button:

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/Shaus12/voiceAI-agents)

### Or Manual Steps:

1. Go to https://render.com
2. Sign up with GitHub
3. Click "New +" → "Blueprint"
4. Connect your `voiceAI-agents` repository
5. Click "Apply"
6. Wait 5-10 minutes for deployment
7. Click on the `voicefx-ui` service to get your URL
8. Done! 🎉

**Your app will be at:** `https://voicefx-ui-xxxx.onrender.com`

---

## 🚂 Option 2: Railway (Also Easy)

**Free $5 credit per month (lasts ~5-7 days of testing)**

### Steps:

1. **Go to:** https://railway.app
2. **Click:** "Start a New Project"
3. **Select:** "Deploy from GitHub repo"
4. **Choose:** `voiceAI-agents`
5. **Railway will ask you to add services manually:**

#### Add PostgreSQL:
- Click "New" → "Database" → "PostgreSQL"
- Click "Add"

#### Add Redis:
- Click "New" → "Database" → "Redis"
- Click "Add"

#### Configure API Service:
- Click on your repo service
- Go to "Variables" tab
- Add:
  ```
  DATABASE_URL=${{Postgres.DATABASE_URL}}
  REDIS_URL=${{Redis.REDIS_URL}}
  ENABLE_AWS_S3=false
  LOG_LEVEL=INFO
  PORT=8000
  ```
- Go to "Settings"
- Set "Root Directory" = `api`
- Set "Start Command" = `uvicorn app:app --host 0.0.0.0 --port $PORT`

#### Add UI Service:
- Click "New" → "GitHub Repo"
- Select your repo again
- Go to "Variables" tab
- Add:
  ```
  BACKEND_URL=https://${{api.RAILWAY_PRIVATE_DOMAIN}}
  NEXT_PUBLIC_API_URL=https://${{api.RAILWAY_PUBLIC_DOMAIN}}
  NODE_ENV=production
  PORT=3010
  ```
- Go to "Settings"
- Set "Root Directory" = `ui`

#### Generate Public URL:
- Click on the UI service
- Go to "Settings" → "Networking"
- Click "Generate Domain"
- Copy the URL - that's your app!

**Done!** Your app is live at the generated Railway URL 🎉

---

## 🌩️ Option 3: Fly.io (Best Free Tier)

**Free tier includes 3 VMs with 256MB RAM each - runs indefinitely!**

### Prerequisites:
You need to install Fly CLI first.

**Mac/Linux:**
```bash
curl -L https://fly.io/install.sh | sh
```

**Windows PowerShell:**
```powershell
powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"
```

### Deploy Steps:

1. **Sign up & Login:**
   ```bash
   fly auth signup
   # Then login
   fly auth login
   ```

2. **Clone the repo (if you haven't):**
   ```bash
   git clone https://github.com/Shaus12/voiceAI-agents.git
   cd voiceAI-agents
   ```

3. **Create PostgreSQL Database:**
   ```bash
   fly postgres create --name voicefx-db
   ```

   Save the connection string it gives you!

4. **Create Redis:**
   ```bash
   fly redis create --name voicefx-redis
   ```

5. **Deploy API:**
   ```bash
   cd api
   fly launch --name voicefx-api --region ord
   ```

   When prompted:
   - "Would you like to set up a PostgreSQL database?" → `N` (you already have one)
   - "Would you like to set up an Upstash Redis database?" → `N` (you already have one)
   - "Would you like to deploy now?" → `Y`

6. **Attach Database to API:**
   ```bash
   fly postgres attach voicefx-db --app voicefx-api
   fly redis attach voicefx-redis --app voicefx-api
   ```

7. **Deploy UI:**
   ```bash
   cd ../ui
   fly launch --name voicefx-ui --region ord
   ```

   Set environment variable:
   ```bash
   fly secrets set NEXT_PUBLIC_API_URL=https://voicefx-api.fly.dev -a voicefx-ui
   fly secrets set BACKEND_URL=https://voicefx-api.fly.dev -a voicefx-ui
   ```

8. **Done!** Visit: `https://voicefx-ui.fly.dev`

---

## 🏆 Which One Should I Choose?

### Choose **Render** if:
- ✅ You want absolute simplest (one button)
- ✅ You're okay with services sleeping after 15 min
- ✅ You don't mind slow first load (~30 seconds)
- ✅ You're testing for less than 90 days

### Choose **Railway** if:
- ✅ You want easy setup
- ✅ You need services always awake
- ✅ You're testing for ~1 week
- ✅ You don't want to deal with command line

### Choose **Fly.io** if:
- ✅ You're comfortable with terminal
- ✅ You want best free tier (runs indefinitely)
- ✅ You want more control
- ✅ You want to learn deployment

---

## 📊 Free Tier Comparison

| Feature | Render | Railway | Fly.io |
|---------|--------|---------|--------|
| **Setup Time** | 2 min | 5 min | 10 min |
| **Click Deploy** | ✅ Yes | ❌ No | ❌ No |
| **Free Duration** | 90 days* | ~7 days | Forever** |
| **Sleeps?** | Yes (15 min) | No | No |
| **Database** | PostgreSQL | PostgreSQL + Redis | PostgreSQL + Redis |
| **Ease** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

\* PostgreSQL free for 90 days, then $7/month
\*\* Free tier has resource limits (3x 256MB VMs)

---

## 🐛 Troubleshooting

### Render: Service won't start
- Check the logs in the Render dashboard
- Make sure environment variables are set correctly
- Wait for initial build (can take 10 minutes first time)

### Railway: Can't connect to database
- Make sure you used `${{Postgres.DATABASE_URL}}` syntax exactly
- Check that PostgreSQL service is running
- Verify the API service has the DATABASE_URL variable

### Fly.io: Deploy failed
- Make sure you're in the correct directory (`api/` or `ui/`)
- Check that you attached the databases correctly
- Run `fly logs` to see what went wrong

---

## 💡 After Deployment

Once deployed, you can:

1. **Access your app** at the provided URL
2. **Create workflows** and test functionality
3. **Check logs** in your platform's dashboard
4. **Monitor usage** to see how long free tier lasts
5. **Export data** before free tier expires

---

## 🔄 Moving to Production Later

When ready for production:

1. **Backup your data:**
   - Export workflows from the UI
   - Backup PostgreSQL database

2. **Setup production server** (see DEPLOY-FOR-BEGINNERS.md)

3. **Import your data:**
   - Restore database backup
   - Recreate workflows

---

## 🎯 Quick Decision Tree

```
Do you want ONE-CLICK deploy?
├─ YES → Use Render
└─ NO → Continue

Do you want LONGEST free time?
├─ YES → Use Fly.io
└─ NO → Continue

Do you want EASIEST multi-service setup?
├─ YES → Use Railway
└─ NO → Maybe you need paid hosting 😅
```

---

## ⚡ Super Quick Start (TL;DR)

**Fastest possible:**
1. Click: [![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/Shaus12/voiceAI-agents)
2. Wait 5 minutes
3. Visit your URL
4. Done! 🎉

**That's it!** Your VoiceFX AI is running for free!

---

Need help? Check the full guides:
- `DEPLOY-FOR-BEGINNERS.md` - Complete production deployment
- `DEPLOY-FREE-TESTING.md` - Detailed free hosting options
- `DEPLOYMENT.md` - Technical deployment guide
