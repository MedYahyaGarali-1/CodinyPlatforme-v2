# 🚀 Quick GitHub Setup & Railway Deployment

Your project is now committed and ready to push to GitHub!

## Step 1: Create GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `codiny-platform` (or any name you prefer)
3. **Choose:** Private repository (recommended)
4. **DO NOT** initialize with README, .gitignore, or license (we already have these)
5. Click "Create repository"

## Step 2: Push to GitHub

After creating the repository, run these commands in PowerShell:

```powershell
# Replace YOUR_USERNAME with your GitHub username
# Replace YOUR_REPO_NAME with the repository name you chose

cd "C:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2"

git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

git branch -M main

git push -u origin main
```

**Example:**
```powershell
git remote add origin https://github.com/MedYahyaGarali-1/codiny-platform.git
git branch -M main
git push -u origin main
```

You'll be asked to login to GitHub. Use your GitHub credentials.

## Step 3: Deploy to Railway (15 minutes)

### 3.1 Create Railway Account
1. Go to: https://railway.app
2. Click "Sign up with GitHub"
3. Authorize Railway to access your GitHub

### 3.2 Create New Project
1. Click **"New Project"**
2. Click **"Deploy from GitHub repo"**
3. Select your repository: `codiny-platform`
4. Railway detects Node.js and starts building

### 3.3 Add PostgreSQL Database
1. Click **"+ New"** button
2. Select **"Database"**
3. Click **"Add PostgreSQL"**
4. Railway creates database automatically

### 3.4 Configure Backend Service
1. Click on your backend service (node.js)
2. Go to **"Settings"** tab
3. **Root Directory:** Type `backend` (since backend is in a subfolder)
4. **Start Command:** Should auto-detect `npm start`

### 3.5 Set Environment Variables
1. Click your backend service
2. Go to **"Variables"** tab
3. Click **"+ New Variable"**
4. Add these:

```
DATABASE_URL = ${{Postgres.DATABASE_URL}}
JWT_SECRET = your_super_secret_key_here_change_this_to_something_random
NODE_ENV = production
```

**Note:** `DATABASE_URL` is auto-filled by Railway from your PostgreSQL service!

### 3.6 Deploy!
1. Railway automatically deploys
2. Wait 2-5 minutes
3. Check **"Deployments"** tab for progress
4. Once successful, click **"Settings"** → **"Generate Domain"**
5. Copy your URL! Example: `https://codiny-backend.up.railway.app`

## Step 4: Run Database Migrations

1. In Railway, click your backend service
2. Click **"Shell"** or **"Terminal"** button
3. Run your migration scripts:

```bash
# Example - adjust based on your migration files
node migrations/001_add_student_onboarding_fields.sql
node migrations/002_create_revenue_tracking.sql
node migrations/003_add_performance_indexes.sql
```

Or if you have a single migration runner:
```bash
node run-migrations.js
```

## Step 5: Update Flutter App

1. Copy your Railway URL
2. Open: `codiny_platform_app/lib/core/config/environment.dart`
3. Update baseUrl:

```dart
static const String baseUrl = 'https://your-app.up.railway.app';
```

4. Rebuild APK:

```powershell
cd codiny_platform_app
flutter clean
flutter pub get
flutter build apk --release
```

5. Test the new APK - it should work from anywhere! 🎉

## Step 6: Future Updates (Auto-Deploy!)

Now whenever you make changes:

```powershell
# 1. Make your changes
code backend/routes/school.routes.js

# 2. Test locally
cd backend
npm start

# 3. Commit and push
git add .
git commit -m "Fixed school activation bug"
git push origin main

# 4. Railway auto-deploys in 2-5 minutes! ✅
# No manual work needed!
```

## ✅ Checklist

### GitHub Setup:
- [ ] Created GitHub repository
- [ ] Ran `git remote add origin ...`
- [ ] Ran `git push -u origin main`
- [ ] Code is visible on GitHub

### Railway Deployment:
- [ ] Created Railway account
- [ ] Created new project from GitHub
- [ ] Added PostgreSQL database
- [ ] Set Root Directory to `backend`
- [ ] Added environment variables (JWT_SECRET, DATABASE_URL, NODE_ENV)
- [ ] Deployment successful (green checkmark)
- [ ] Generated domain/URL
- [ ] Ran database migrations

### Flutter App Update:
- [ ] Updated environment.dart with Railway URL
- [ ] Rebuilt APK
- [ ] Tested from phone
- [ ] App works from anywhere!

## 🎯 What You've Accomplished

✅ **Code on GitHub** - Version controlled and backed up
✅ **Automatic Deployments** - Push code → Auto-deploys in 2-5 minutes
✅ **Permanent URL** - Never changes, works anywhere
✅ **Free Hosting** - Railway free tier ($5/month credit)
✅ **PostgreSQL Database** - Fully managed
✅ **Production Ready** - Your friends can test from their homes!

## 🆘 Need Help?

### Railway Not Detecting Backend?
- Make sure "Root Directory" is set to `backend`
- Check that package.json has `"start": "node server.js"`

### Deployment Failed?
- Check logs in Railway dashboard
- Common issue: Missing environment variables
- Make sure DATABASE_URL is set to `${{Postgres.DATABASE_URL}}`

### Database Connection Issues?
- Verify DATABASE_URL is auto-filled from PostgreSQL service
- Check that config/db.js supports DATABASE_URL (it does now!)

### Still Stuck?
- Railway Discord: https://discord.gg/railway
- Railway Docs: https://docs.railway.app

## 🚀 Ready?

Start with Step 1: Create your GitHub repository!

Then come back here and follow Steps 2-6.

Total time: **15-20 minutes** for first deployment.
Future updates: **10 seconds** (just `git push`)! 🎉
