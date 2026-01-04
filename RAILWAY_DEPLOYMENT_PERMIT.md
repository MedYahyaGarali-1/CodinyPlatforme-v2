# 🚀 Railway Deployment Guide - Permit System

**Date:** January 4, 2026  
**Status:** Code committed and pushed to GitHub

---

## ✅ What Just Happened

1. ✅ **All backend changes committed** (controllers, routes, student API)
2. ✅ **All frontend changes committed** (onboarding screen, repository, models)
3. ✅ **Code pushed to GitHub** (`git push origin main`)
4. ⏳ **Railway auto-deployment triggered** (will take ~2 minutes)

---

## 📋 Deployment Steps

### Step 1: Wait for Railway Deployment ⏳

Railway is automatically deploying the new code. You can check status at:
- **Railway Dashboard:** https://railway.app/
- Look for your project deployment status
- Wait until you see "✅ Deployed successfully"

**Estimated time:** 2-3 minutes

---

### Step 2: Run Database Migration on Railway 🗄️

After deployment completes, you MUST run the migration to add the `permit_type` column.

**Option A: Using Railway CLI** (Recommended)
```bash
# Install Railway CLI if you don't have it
# Visit: https://docs.railway.app/develop/cli

# Login to Railway
railway login

# Link to your project
railway link

# Run the migration
railway run node run-permit-migration.js
```

**Option B: Using Railway Dashboard**
1. Go to Railway Dashboard
2. Open your backend service
3. Click "Variables" tab
4. Add a temporary variable to trigger migration:
   - Name: `RUN_MIGRATION`
   - Value: `true`
5. Redeploy
6. Check logs to see migration complete
7. Remove the variable after migration

**Option C: Direct Database Connection**
If you have Railway PostgreSQL credentials:
```sql
-- Connect to Railway PostgreSQL
-- Then run:

ALTER TABLE students 
ADD COLUMN permit_type VARCHAR(10) 
CHECK (permit_type IN ('A', 'B', 'C'));

UPDATE students 
SET permit_type = 'B' 
WHERE permit_type IS NULL;

-- Verify
SELECT COUNT(*), permit_type 
FROM students 
GROUP BY permit_type;
```

---

## 🔍 How to Verify Deployment

### 1. Check Railway Logs
Look for these success messages:
```
✅ Backend deployed successfully
🟢 Server listening on port 3000
🟢 Connected to PostgreSQL
```

### 2. Test the API Endpoint
```bash
# Get your Railway URL (e.g., https://your-app.railway.app)
# Test the new endpoint (replace with your URL and token)

curl -X POST https://your-app.railway.app/students/onboarding/choose-permit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"permit_type": "B"}'
```

**Expected Response:**
```json
{
  "message": "Permit type selected successfully",
  "permit_type": "B",
  "info": "Permit B selected! Full content available once your school approves."
}
```

### 3. Check Database Column
In Railway PostgreSQL dashboard:
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'students' 
AND column_name = 'permit_type';
```

Should return:
```
column_name  | data_type
-------------+-----------
permit_type  | varchar
```

---

## 📱 Update Flutter App Configuration

Make sure your Flutter app points to Railway backend:

**File:** `codiny_platform_app/lib/core/config/environment.dart`

```dart
class Environment {
  static const String baseUrl = 'https://your-railway-app.railway.app';
  // Replace with your actual Railway URL
}
```

---

## 🏗️ Rebuild APK with Railway URL

After Railway deployment is complete:

```bash
cd "c:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2\codiny_platform_app"

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

**APK Location:** `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Testing Checklist

### Before Testing:
- [ ] Railway deployment completed successfully
- [ ] Migration ran successfully (permit_type column added)
- [ ] Flutter app configured with Railway URL
- [ ] New APK built with updated code
- [ ] Old app uninstalled from device

### Testing Steps:
1. Install new APK on device
2. Open app and register new account
3. **YOU SHOULD SEE:** "Choose Your Permit 🚗" screen
4. **YOU SHOULD SEE:** 3 permit cards (🏍️ Motorcycle, 🚗 Car, 🚛 Truck)
5. Tap "Permit B" (only available option)
6. Should show success message
7. Should navigate to student dashboard
8. Dashboard should show "🚗 Permit B" badge

---

## 🚨 If You See "Cannot POST /students/onboarding/choose-permit"

This means one of these issues:

1. **Railway hasn't deployed yet** → Wait 2-3 minutes
2. **Railway deployment failed** → Check Railway logs for errors
3. **Old APK still using old code** → Rebuild and reinstall APK
4. **Wrong Railway URL** → Verify `environment.dart` has correct URL

---

## 📊 What Changed on Railway

### New Backend Routes:
```javascript
POST /students/onboarding/choose-permit
// Body: { "permit_type": "A" | "B" | "C" }
// Returns: { message, permit_type, info }
```

### Updated Backend Routes:
```javascript
GET /students/me
// Now includes: permit_type field
```

### New Database Column:
```sql
students.permit_type VARCHAR(10)
CHECK (permit_type IN ('A', 'B', 'C'))
```

---

## 🎯 Quick Command Reference

```bash
# 1. Check Railway deployment status
railway status

# 2. View Railway logs
railway logs

# 3. Run migration
railway run node run-permit-migration.js

# 4. Connect to Railway database
railway connect

# 5. Rebuild Flutter APK
cd codiny_platform_app
flutter clean && flutter pub get && flutter build apk --release
```

---

## 💡 Pro Tips

1. **Keep Railway logs open** while testing to see real-time errors
2. **Use Railway's "View Logs"** button in dashboard for debugging
3. **Test API with Postman first** before building APK
4. **Always uninstall old APK** before installing new one
5. **Use fresh account** for testing (don't test with old accounts)

---

## 🆘 Troubleshooting

### "Cannot POST" Error
- ✅ Check Railway deployment completed
- ✅ Check Railway logs for startup errors
- ✅ Verify route is registered in logs
- ✅ Test with curl/Postman to isolate issue

### "Column doesn't exist" Error
- ✅ Run migration script on Railway
- ✅ Check database with `railway connect`
- ✅ Verify column exists with SQL query

### App Shows Old UI
- ✅ Rebuild APK after code changes
- ✅ Uninstall old app completely
- ✅ Verify `environment.dart` has Railway URL
- ✅ Check Flutter build logs for errors

---

## ✅ Success Criteria

You'll know it's working when:
- ✅ Railway shows "Deployed successfully"
- ✅ Migration shows "✅ permit_type column added"
- ✅ API test returns correct JSON response
- ✅ App shows "Choose Your Permit 🚗" screen
- ✅ Selecting Permit B navigates to dashboard
- ✅ Dashboard shows "🚗 Permit B" badge

---

## 📞 Next Steps

1. **Monitor Railway deployment** (~2 minutes)
2. **Run database migration** (use Railway CLI or SQL)
3. **Verify API endpoint** (test with curl/Postman)
4. **Update environment.dart** (if not already pointing to Railway)
5. **Rebuild APK** with Railway URL
6. **Test on device** with fresh account

**Estimated total time:** 10-15 minutes

---

🎉 **Once complete, your app will have the new Permit A/B/C system live on Railway!**
