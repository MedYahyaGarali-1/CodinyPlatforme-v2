# 🔧 Railway Deployment - Quick Fix Guide

## ✅ Configuration Files Added!

I've added three Railway configuration files to fix the deployment:
1. `railway.json` - Main Railway config
2. `backend/railway.toml` - Railway-specific settings
3. `backend/nixpacks.toml` - Build configuration

These files are now pushed to GitHub!

---

## 🚀 Steps to Redeploy on Railway

### Option 1: Railway Will Auto-Redeploy (Easiest)
Since we pushed new commits, Railway should automatically:
1. Detect the new configuration files
2. Start a new deployment
3. Build successfully this time

**Wait 2-3 minutes and check your Railway dashboard!**

---

### Option 2: Manual Redeploy (If Auto Doesn't Work)

#### In Railway Dashboard:

**Step 1: Verify Settings**
1. Click your service (backend)
2. Go to **"Settings"** tab
3. **CRITICAL:** Set **"Root Directory"** to: `backend`
4. **Start Command** should be: `npm start`
5. Click **"Save"**

**Step 2: Trigger Redeploy**
1. Go to **"Deployments"** tab
2. Click the three dots (...) on latest deployment
3. Click **"Redeploy"**

---

## ⚙️ Critical Railway Settings Checklist

### Service Settings:
- [ ] **Root Directory:** `backend` ⚠️ (MOST IMPORTANT!)
- [ ] **Start Command:** `npm start` (or leave empty to auto-detect)
- [ ] **Build Command:** Leave empty (uses package.json)

### Environment Variables:
- [ ] `DATABASE_URL` = `${{Postgres.DATABASE_URL}}` (auto from PostgreSQL service)
- [ ] `JWT_SECRET` = Your random secret (32+ characters)
- [ ] `NODE_ENV` = `production`

### PostgreSQL Database:
- [ ] PostgreSQL service exists in same project
- [ ] DATABASE_URL variable is linked to Postgres service

---

## 🐛 Common Issues & Solutions

### Issue 1: "Error creating build plan with Railpack"
**Solution:** ✅ Fixed! I added configuration files.
- Railway now knows this is a Node.js app
- Configuration specifies Node 18+

### Issue 2: "Cannot find module 'server.js'"
**Solution:** Set **Root Directory** to `backend`
- Without this, Railway looks in project root
- Your server.js is in the backend folder

### Issue 3: "npm ci failed"
**Solution:** Railway uses `npm ci` which requires package-lock.json
- Check if backend/package-lock.json exists
- If not, run: `cd backend && npm install` locally, then push

### Issue 4: "Database connection failed"
**Solution:** Verify DATABASE_URL is set correctly
- Format: `${{Postgres.DATABASE_URL}}`
- This auto-fills from your PostgreSQL service
- Check PostgreSQL service is running (green status)

### Issue 5: "Port already in use"
**Solution:** Don't hardcode port in server.js
- Use: `const PORT = process.env.PORT || 3000;`
- Railway provides PORT via environment variable

---

## 🔍 How to Check Your server.js

Let me verify your server.js is Railway-ready:

**Should have:**
```javascript
require('dotenv').config();

const PORT = process.env.PORT || 3000; // Railway sets PORT

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

**Check your server.js has:**
- ✅ `dotenv` loaded
- ✅ `PORT` from environment variable
- ✅ Database uses `process.env.DATABASE_URL`

---

## 📊 Deployment Timeline

**After pushing config files:**
1. **0-30 seconds:** Railway detects new commit
2. **30-60 seconds:** Starts new deployment
3. **1-2 minutes:** Installing dependencies
4. **2-3 minutes:** Building application
5. **3-4 minutes:** Starting server
6. **4-5 minutes:** ✅ Deployment successful!

**Total: ~5 minutes**

---

## ✅ Success Indicators

### In Railway Dashboard:
- Deployment status shows **green checkmark** ✅
- Logs show: `Server running on port XXXX`
- Logs show: `🟢 Connected to PostgreSQL`
- Service is "Active" (not "Sleeping")

### Test Your API:
```powershell
# Replace with your Railway URL
curl https://your-app.up.railway.app
# Should return: "Driving Exam API is running"
```

---

## 🆘 Still Not Working?

### Check Build Logs:
1. Railway Dashboard → Your Service
2. Click **"Deployments"** tab
3. Click latest deployment
4. Check **"Build Logs"** and **"Deploy Logs"**
5. Look for red error messages

### Common Error Messages:

**"Module not found: 'express'"**
- Solution: package.json is correct, but npm install failed
- Check package-lock.json exists in backend folder

**"ENOENT: no such file or directory, open 'server.js'"**
- Solution: Root Directory not set to `backend`
- Go to Settings → Root Directory → `backend`

**"listen EADDRINUSE"**
- Solution: Port conflict (shouldn't happen on Railway)
- Verify: `const PORT = process.env.PORT || 3000;`

**"Connection refused: PostgreSQL"**
- Solution: DATABASE_URL not set or wrong format
- Use: `${{Postgres.DATABASE_URL}}` (exact format!)

---

## 📋 Quick Deployment Checklist

Before you can deploy successfully:

### GitHub:
- [x] ✅ Code pushed to GitHub
- [x] ✅ Configuration files added (railway.json, etc.)

### Railway Project:
- [ ] Service created from GitHub repo
- [ ] PostgreSQL database added to project
- [ ] Root Directory set to `backend`
- [ ] Environment variables configured
- [ ] Deployment triggered

### After Deployment:
- [ ] Build logs show no errors
- [ ] Deploy logs show "Server running"
- [ ] Service status is "Active"
- [ ] Can access your Railway URL

---

## 🎯 Next Steps (If Deployment Works):

1. **Copy your Railway URL** from Settings → Domain
   Example: `https://codinyplatforme-v2-production.up.railway.app`

2. **Update Flutter app:**
   ```dart
   // lib/core/config/environment.dart
   static const String baseUrl = 'https://your-railway-url.up.railway.app';
   ```

3. **Rebuild APK:**
   ```powershell
   cd codiny_platform_app
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

4. **Test!** 🎉

---

## 💡 Pro Tips

1. **Watch Logs in Real-Time:**
   - Railway Dashboard → View Logs
   - Shows live server output

2. **Environment Variables:**
   - Can be changed without redeploying
   - Just update in Variables tab → Railway restarts

3. **Rollback if Needed:**
   - Deployments tab → Previous deployment → Redeploy

4. **Database Access:**
   - PostgreSQL tab → Connect
   - Can run SQL queries directly

---

## 🚀 Current Status

✅ Configuration files created and pushed
✅ Railway should auto-detect Node.js app now
⏳ Wait 2-3 minutes for automatic redeployment

**Check your Railway dashboard now!**

If deployment fails again, check the logs and look for the error message. Then refer to the "Common Issues" section above.

Good luck! 🎉
