# Deploy VoiceFX AI on Railway - Simple Method

Railway is great for testing, but the Dockerfiles need some adjustments. Here's the simplest way:

## 🚀 Option 1: Use Pre-Built Images (Easiest!)

Instead of building from source, use the pre-built Docker images:

### Step 1: Sign Up to Railway

1. Go to https://railway.app
2. Click "Login with GitHub"
3. Authorize Railway

### Step 2: Create New Project

1. Click "New Project"
2. Select "Empty Project"

### Step 3: Add PostgreSQL

1. Click "New" → "Database" → "Add PostgreSQL"
2. Name it: `voicefx-db`
3. Click "Add"

### Step 4: Add Redis

1. Click "New" → "Database" → "Add Redis"
2. Name it: `voicefx-redis`
3. Click "Add"

### Step 5: Add API Service

1. Click "New" → "Empty Service"
2. Name it: `api`
3. Go to "Settings" tab
4. Under "Source":
   - Click "Deploy from Docker Image"
   - Image: `ghcr.io/voicefx-hq/dograh-api:latest`
5. Go to "Variables" tab and add:
   ```
   DATABASE_URL=${{Postgres.DATABASE_URL}}
   REDIS_URL=${{Redis.REDIS_URL}}
   ENABLE_AWS_S3=false
   LOG_LEVEL=INFO
   ENVIRONMENT=production
   PORT=8000
   ENABLE_TELEMETRY=true
   ```
6. Click "Deploy"

### Step 6: Add UI Service

1. Click "New" → "Empty Service"
2. Name it: `ui`
3. Go to "Settings" tab
4. Under "Source":
   - Click "Deploy from Docker Image"
   - Image: `ghcr.io/voicefx-hq/dograh-ui:latest`
5. Go to "Variables" tab and add:
   ```
   BACKEND_URL=https://${{api.RAILWAY_PRIVATE_DOMAIN}}
   NEXT_PUBLIC_API_URL=https://${{api.RAILWAY_PUBLIC_DOMAIN}}
   NODE_ENV=production
   PORT=3010
   ENABLE_TELEMETRY=true
   NEXT_PUBLIC_AUTH_PROVIDER=local
   ```
6. Click "Deploy"

### Step 7: Generate Public Domain

1. Click on the `ui` service
2. Go to "Settings" → "Networking"
3. Click "Generate Domain"
4. Copy the URL - that's your app! 🎉

**Done!** Your VoiceFX AI is running on Railway using pre-built images.

---

## 🎯 Option 2: Render (Even Easier!)

If Railway is giving you trouble, Render is actually simpler:

### Just Click This Button:

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/Shaus12/voiceAI-agents)

1. Click button above
2. Sign in with GitHub
3. Wait 5-10 minutes
4. Get your URL
5. Done! ✨

**Why Render is easier:**
- One-click deployment
- Auto-configures everything
- No manual service setup needed

**Downside:**
- Services sleep after 15 min inactivity
- First load takes ~30 seconds to wake up

---

## 🐞 Troubleshooting Railway

### If Pre-Built Images Don't Work:

The issue might be that the images aren't public. In that case, try this:

#### Alternative: Deploy Without Docker

**For API:**
1. Create service from GitHub repo
2. Set Root Directory: `api`
3. Set Build Command: `pip install -r requirements.txt`
4. Set Start Command: `uvicorn app:app --host 0.0.0.0 --port $PORT`
5. Add environment variables (same as above)

**For UI:**
1. Create service from GitHub repo
2. Set Root Directory: `ui`
3. Set Build Command: `npm install && npm run build`
4. Set Start Command: `npm start`
5. Add environment variables (same as above)

---

## 💰 Railway Free Tier

- **Free credit:** $5/month
- **How long it lasts:** ~5-7 days with all services running
- **Perfect for:** Testing and demos

---

## 🔄 Better Alternatives for Free Testing

If Railway keeps giving you trouble, here are better FREE options:

### 1. Fly.io (Best Free Tier)
- Free tier runs indefinitely
- 3 small VMs (256MB each)
- See `ONE-CLICK-DEPLOY.md` for instructions

### 2. Render (Easiest)
- Literally one button click
- Free for 90 days
- See `ONE-CLICK-DEPLOY.md`

### 3. Oracle Cloud Always Free (Best Value)
- Permanent FREE
- 4 CPUs + 24GB RAM
- See `DEPLOY-FREE-TESTING.md`

---

## ⚡ My Recommendation

**If Railway isn't working smoothly:**

→ Just use **Render** instead! Click the deploy button:

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/Shaus12/voiceAI-agents)

It's actually easier and will work first try! 🎉

---

## 📊 Quick Comparison

| Platform | Setup Time | Works? | Free Duration |
|----------|-----------|--------|---------------|
| **Render** | 2 min | ✅ Always | 90 days |
| **Railway** | 10 min | ⚠️ Sometimes | ~7 days |
| **Fly.io** | 15 min | ✅ Usually | Forever |

**Bottom line:** If you just want to test quickly, use Render!

---

## Need Help?

If you're still stuck:
1. Try Render instead (much simpler)
2. Check the error logs in Railway dashboard
3. Ask in the issues: https://github.com/Shaus12/voiceAI-agents/issues

**Want the easiest path?** Just click: [![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/Shaus12/voiceAI-agents)
