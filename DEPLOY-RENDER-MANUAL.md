# Deploy VoiceFX AI on Render - Simple Manual Setup

The one-click deploy has some issues with Docker builds. Here's a simple manual setup that WILL work!

## 🚀 Simple 10-Minute Setup

### Step 1: Create Render Account

1. Go to https://render.com
2. Click "Get Started"
3. Sign up with GitHub
4. Authorize Render

### Step 2: Fork the Repository (Required)

Render needs direct access to your repo:

1. Go to https://github.com/Shaus12/voiceAI-agents
2. Click "Fork" (top right)
3. Now you have your own copy at `https://github.com/YOUR_USERNAME/voiceAI-agents`

### Step 3: Create PostgreSQL Database

1. In Render dashboard, click "New +" → "PostgreSQL"
2. **Name:** `voicefx-db`
3. **Database:** `voicefx`
4. **User:** `voicefx`
5. **Region:** Choose closest to you
6. **Plan:** Select "Free"
7. Click "Create Database"
8. Wait for it to be created (~2 minutes)
9. **Copy the "Internal Database URL"** - you'll need this!

### Step 4: Deploy API Backend

1. Click "New +" → "Web Service"
2. Click "Build and deploy from a Git repository"
3. Connect your forked repository
4. Configure:
   - **Name:** `voicefx-api`
   - **Region:** Same as database
   - **Branch:** `main`
   - **Runtime:** `Docker`
   - **Dockerfile Path:** `./api/Dockerfile`
   - **Docker Context Directory:** `.` (root)
   - **Plan:** `Free`

5. Click "Advanced" and add Environment Variables:
   ```
   DATABASE_URL=<paste-your-internal-database-url-here>
   LOG_LEVEL=INFO
   ENVIRONMENT=production
   ENABLE_TELEMETRY=true
   ENABLE_AWS_S3=false
   PORT=8000
   REDIS_URL=redis://dummy:6379
   ```

6. Click "Create Web Service"
7. Wait for build to complete (5-10 minutes first time)

### Step 5: Deploy UI Frontend

1. Click "New +" → "Web Service"
2. Connect your repository again
3. Configure:
   - **Name:** `voicefx-ui`
   - **Region:** Same as API
   - **Branch:** `main`
   - **Runtime:** `Docker`
   - **Dockerfile Path:** `./ui/Dockerfile`
   - **Docker Context Directory:** `.` (root)
   - **Plan:** `Free`

4. Add Environment Variables:
   ```
   BACKEND_URL=https://voicefx-api.onrender.com
   NEXT_PUBLIC_API_URL=https://voicefx-api.onrender.com
   NODE_ENV=production
   ENABLE_TELEMETRY=true
   NEXT_PUBLIC_AUTH_PROVIDER=local
   PORT=3010
   ```

5. Click "Create Web Service"
6. Wait for build (~5-10 minutes)

### Step 6: Update UI Environment Variable

After API is deployed:

1. Go to your API service
2. Copy the actual URL (should be like `https://voicefx-api.onrender.com`)
3. Go to UI service → "Environment"
4. Update these two variables with the actual API URL:
   - `BACKEND_URL=https://voicefx-api.onrender.com`
   - `NEXT_PUBLIC_API_URL=https://voicefx-api.onrender.com`
5. Click "Save Changes" (this will redeploy)

### Step 7: Access Your App! 🎉

1. Go to your UI service
2. Click on the URL at the top (like `https://voicefx-ui-xxxx.onrender.com`)
3. **Your VoiceFX AI is live!**

---

## ⚠️ Important Notes

### Free Tier Limitations:

1. **Services sleep after 15 minutes** of inactivity
   - First request takes ~30 seconds to wake up
   - This is normal for free tier!

2. **PostgreSQL free for 90 days**
   - After 90 days, costs $7/month
   - You'll get email reminders

3. **Build times are slow**
   - First build: 5-10 minutes
   - Subsequent builds: 3-5 minutes

### If Build Fails:

**Most common issue:** Docker can't find files

**Solution:** Make sure you set **Docker Context Directory** to `.` (just a dot)

This tells Render to build from the root directory so it can find all the files.

---

## 🐛 Troubleshooting

### API won't start

**Check logs:**
1. Go to API service
2. Click "Logs" tab
3. Look for error messages

**Common issues:**
- Database URL wrong → Double check you copied the INTERNAL url
- Build failed → Check Dockerfile path is correct: `./api/Dockerfile`

### UI won't start

**Check:**
1. Make sure API is running first
2. Verify `BACKEND_URL` points to your actual API URL
3. Check logs for errors

### UI loads but can't connect to API

**Fix:**
1. Go to UI environment variables
2. Make sure `NEXT_PUBLIC_API_URL` has your real API URL (with https://)
3. Save and let it redeploy

### "Service Unavailable" Error

This means the service is sleeping! Just wait 30 seconds and refresh.

---

## 💡 Better Alternatives

If Render's free tier limitations bother you:

### **Fly.io** - Better Free Tier
- Services don't sleep
- 256MB RAM x3 VMs free
- More reliable
- See `ONE-CLICK-DEPLOY.md` for Fly.io instructions

### **Oracle Cloud Always Free** - Best Free Option
- 4 CPUs + 24GB RAM
- FREE forever
- No sleeping
- See `DEPLOY-FREE-TESTING.md` for instructions

---

## 📊 What You're Getting

With Render's free tier:
- ✅ PostgreSQL database (90 days free)
- ✅ API backend
- ✅ UI frontend
- ✅ HTTPS/SSL automatically
- ✅ Auto-redeploy on git push
- ❌ Services sleep after 15 min
- ❌ Slow wake-up time

**Good for:** Testing, demos, showing to others
**Not good for:** Production, high traffic, always-on

---

## 🔄 Next Steps

After deployment:

1. **Test your app** - Create a test workflow
2. **Bookmark the URL** - You'll need to wake it up on first visit
3. **Expect slow first load** - This is normal for free tier
4. **Plan for production** - When ready, check `DEPLOYMENT.md`

---

## 💰 Cost After Free Tier

If you like it and want to keep using Render:

- **PostgreSQL:** $7/month (after 90 days)
- **Web Services:** Can stay on free tier if you don't mind sleeping

**OR** migrate to:
- Your own VPS: $24/month (see `DEPLOY-FOR-BEGINNERS.md`)
- Oracle Cloud: $0/month forever (see `DEPLOY-FREE-TESTING.md`)

---

## ✅ Checklist

- [ ] Created Render account
- [ ] Forked repository
- [ ] Created PostgreSQL database
- [ ] Deployed API service
- [ ] Deployed UI service
- [ ] Updated UI environment variables
- [ ] Tested the application
- [ ] Bookmarked the URL

---

**Still having issues?** Try one of these instead:
- **Fly.io:** Better free tier, no sleeping (see `ONE-CLICK-DEPLOY.md`)
- **Local Docker:** Just run locally (see README.md)
- **Oracle Cloud:** Best free specs (see `DEPLOY-FREE-TESTING.md`)

Need help? Open an issue: https://github.com/Shaus12/voiceAI-agents/issues
