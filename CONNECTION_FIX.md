# 🔧 Connection Error Fix - School Login

## Problem
**Error:** `ClientException: Connection closed before full header was received`
**URL:** `https://nonconvivially-oculistic-deandrea.ngrok-free.dev/schools/me`

## Root Cause
**Ngrok's Anti-Bot Protection** - The free ngrok tier shows an interstitial "Visit Site" page before allowing connections. Mobile apps cannot handle this browser-based check, causing the connection to close.

---

## ✅ Solution Options

### Option 1: Use Ngrok with --authtoken (Bypass Browser Check) ⭐ RECOMMENDED
This tells ngrok to skip the interstitial page.

**Steps:**
1. Get your ngrok authtoken from: https://dashboard.ngrok.com/get-started/your-authtoken
2. Run this command:
```powershell
ngrok http 3000 --authtoken YOUR_AUTH_TOKEN
```

**Note:** You may already have authtoken configured. Try restarting ngrok:
```powershell
# Stop current ngrok
Stop-Process -Name ngrok

# Start ngrok again (should use saved authtoken)
cd C:\ngrok-v3-stable-windows-amd64
.\ngrok http 3000
```

---

### Option 2: Use Local Network IP (Same WiFi Required) 
Good for testing with friends on the same WiFi network.

**Steps:**
1. Find your PC's local IP:
```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "192.168.*"} | Select-Object IPAddress
```

2. Update the Flutter app's base URL:
```dart
// lib/core/config/environment.dart
static const String baseUrl = 'http://YOUR_LOCAL_IP:3000';
```

3. Make sure Windows Firewall allows port 3000
4. Both you and friends must be on **same WiFi network**

---

### Option 3: Deploy Backend to Free Cloud Service (Best for Production)
Deploy backend to a cloud service with permanent URL.

**Free Options:**
- **Railway.app** (500 hours/month free)
- **Render.com** (750 hours/month free)
- **Fly.io** (Free tier available)
- **Heroku** (Free tier discontinued, but alternatives exist)

---

### Option 4: Use Ngrok Static Domain (Paid)
Get a permanent ngrok domain that doesn't change.

**Cost:** ~$8/month
**Benefit:** Permanent URL, no browser checks, no reconnection needed

---

## 🚀 Quick Fix (Try This First)

### Step 1: Check Ngrok Authtoken
```powershell
cd C:\ngrok-v3-stable-windows-amd64
.\ngrok config check
```

### Step 2: Restart Ngrok Properly
```powershell
# Kill current ngrok
Stop-Process -Name ngrok -Force

# Start fresh (this should use your saved authtoken)
.\ngrok http 3000
```

### Step 3: Test Connection
After ngrok starts, you'll see output like:
```
Session Status                online
Account                       your@email.com (Plan: Free)
Forwarding                    https://something-new.ngrok-free.dev -> http://localhost:3000
```

**Important:** The URL might be different! Copy the new HTTPS URL.

### Step 4: Update Flutter App
If the ngrok URL changed, update:

```dart
// lib/core/config/environment.dart
static const String baseUrl = 'https://YOUR_NEW_NGROK_URL';
```

Then rebuild APK:
```powershell
cd codiny_platform_app
flutter build apk --release
```

---

## 🔍 Verify Backend is Working

### Test 1: Check if backend responds
```powershell
curl http://localhost:3000
```
Should return: "Driving Exam API is running"

### Test 2: Check ngrok tunnel
```powershell
curl https://YOUR_NGROK_URL
```
Should also return: "Driving Exam API is running"

### Test 3: Check specific endpoint
```powershell
Invoke-WebRequest -Uri "https://YOUR_NGROK_URL/schools/me" -Headers @{"Authorization"="Bearer test"}
```

---

## 📱 If Error Persists

### Check These:
1. ✅ Backend running? `Get-Process -Name node`
2. ✅ Ngrok running? `Get-Process -Name ngrok`
3. ✅ Ngrok URL matches app? Check `environment.dart`
4. ✅ Firewall allows connections?
5. ✅ Authtoken configured? `ngrok config check`

### Common Issues:

**Issue:** "ERR_NGROK_108"
- **Fix:** Authtoken not configured or expired
- **Solution:** Run `ngrok config add-authtoken YOUR_TOKEN`

**Issue:** Connection timeout
- **Fix:** Backend not responding
- **Solution:** Restart backend: `node backend/server.js`

**Issue:** 502 Bad Gateway
- **Fix:** Ngrok can't reach backend
- **Solution:** Check port 3000 is not in use by another app

---

## 🎯 Recommended Solution for Testing with Friends

### Short Term (Next Few Days):
Use **Option 1** - Restart ngrok with proper authtoken. This should bypass the browser check.

### Long Term (Production):
Use **Option 3** - Deploy to Railway.app or Render.com for a permanent, free backend URL.

---

## 📋 Action Steps RIGHT NOW

1. **Stop ngrok:**
```powershell
Stop-Process -Name ngrok -Force
```

2. **Check if you have authtoken configured:**
```powershell
cd C:\ngrok-v3-stable-windows-amd64
.\ngrok config check
```

3. **If no authtoken, add it:**
```powershell
.\ngrok config add-authtoken YOUR_AUTHTOKEN_FROM_DASHBOARD
```

4. **Start ngrok fresh:**
```powershell
.\ngrok http 3000
```

5. **Copy the new HTTPS URL** from ngrok output

6. **Update Flutter app** if URL changed

7. **Test the connection** from your phone

---

## 💡 Pro Tip
For testing during development, consider using **localtunnel** as an alternative:
```powershell
npm install -g localtunnel
lt --port 3000
```

It provides a URL like `https://random-name.loca.lt` with fewer restrictions than ngrok free tier.

---

## Need More Help?
1. Share the ngrok output after restarting
2. Share any error messages from backend logs
3. Confirm if authtoken is properly configured
