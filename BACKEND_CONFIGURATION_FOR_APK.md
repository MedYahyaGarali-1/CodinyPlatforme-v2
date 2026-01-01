# ⚠️ IMPORTANT: Backend Configuration for APK Testing

## 🚨 Critical Issue: Localhost Won't Work on APK!

Your APK is currently configured to connect to:
```dart
baseUrl = 'http://localhost:3000'
```

**This will NOT work when testing with friends!** `localhost` only works on the same device.

---

## ✅ Solutions (Choose One)

### Option 1: Use Your Local IP (Same WiFi) ⭐ EASIEST

#### Step 1: Find Your PC's IP Address
```powershell
ipconfig
```
Look for **IPv4 Address** under your active network (e.g., `192.168.1.100`)

#### Step 2: Update Flutter App
Edit `lib/core/config/environment.dart`:
```dart
static const String baseUrl = 'http://192.168.1.100:3000'; // Replace with YOUR IP
```

#### Step 3: Start Backend
```powershell
cd backend
node server.js
```

#### Step 4: Rebuild APK
```powershell
cd codiny_platform_app
flutter build apk --release
```

#### Step 5: Share WiFi
Make sure your friends connect to **the same WiFi network** as your PC.

**Limitations**: Only works on same WiFi network.

---

### Option 2: Use Ngrok 🌐 BEST FOR TESTING

Ngrok creates a public URL that tunnels to your localhost.

#### Step 1: Download & Install Ngrok
1. Go to: https://ngrok.com/download
2. Download for Windows
3. Extract and place `ngrok.exe` somewhere accessible

#### Step 2: Start Your Backend
```powershell
cd "c:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2\backend"
node server.js
```

#### Step 3: Start Ngrok (New Terminal)
```powershell
ngrok http 3000
```

#### Step 4: Copy Public URL
Ngrok will show something like:
```
Forwarding    https://abc123.ngrok.io -> http://localhost:3000
```

Copy the HTTPS URL (e.g., `https://abc123.ngrok.io`)

#### Step 5: Update Flutter App
Edit `lib/core/config/environment.dart`:
```dart
static const String baseUrl = 'https://abc123.ngrok.io'; // Your ngrok URL
```

#### Step 6: Rebuild APK
```powershell
cd codiny_platform_app
flutter build apk --release
```

**Advantages**:
- ✅ Works anywhere (not just same WiFi)
- ✅ HTTPS supported
- ✅ Easy to share with friends

**Limitations**:
- ⚠️ Free tier has connection limits
- ⚠️ URL changes when you restart ngrok (update app each time)
- ⚠️ Backend must stay running on your PC

---

### Option 3: Deploy Backend Online 🚀 BEST FOR PRODUCTION

Deploy your backend to a cloud service.

#### Recommended Services (Free Tier):
1. **Railway.app** (Easiest)
2. **Render.com** (Free PostgreSQL included)
3. **Fly.io**
4. **Heroku** (if still free)

#### Example: Deploy to Railway

1. **Create Account**: https://railway.app
2. **Create New Project** → Deploy from GitHub
3. **Connect PostgreSQL** database
4. **Set Environment Variables**:
   ```
   DB_HOST=your-postgres-host
   DB_PORT=5432
   DB_NAME=driving_exam
   DB_USER=postgres
   DB_PASSWORD=your-password
   JWT_SECRET=your-secret-key
   PORT=3000
   ```
5. **Deploy** - Railway will give you a URL like `https://your-app.railway.app`
6. **Update Flutter**: Change `baseUrl` to your Railway URL
7. **Rebuild APK**

**Advantages**:
- ✅ Always online
- ✅ Scalable
- ✅ Professional
- ✅ No need to keep your PC running

---

## 🎯 Quick Decision Guide

| Scenario | Best Solution | Setup Time |
|----------|---------------|------------|
| Testing with 1-2 friends on same WiFi | Option 1 (Local IP) | 5 minutes |
| Testing with friends anywhere | Option 2 (Ngrok) | 10 minutes |
| Real production app | Option 3 (Deploy) | 1-2 hours |

---

## ⚡ Quick Steps for Option 1 (Fastest)

```powershell
# 1. Find your IP
ipconfig
# Look for IPv4: 192.168.x.x

# 2. Edit environment.dart
# Change: 'http://localhost:3000'
# To: 'http://192.168.1.XXX:3000' (your IP)

# 3. Rebuild
cd codiny_platform_app
flutter build apk --release

# 4. Start backend
cd ../backend
node server.js

# 5. Share APK + Tell friends to connect to your WiFi
```

---

## ⚡ Quick Steps for Option 2 (Ngrok)

```powershell
# 1. Start backend
cd backend
node server.js

# 2. In NEW terminal - Start ngrok
ngrok http 3000
# Copy the https URL

# 3. Edit environment.dart
# Change: 'http://localhost:3000'
# To: 'https://YOUR-NGROK-URL.ngrok.io'

# 4. Rebuild
cd codiny_platform_app
flutter build apk --release

# 5. Share APK - Works anywhere!
```

---

## 📝 Current Build Status

Your **current APK being built** uses `http://localhost:3000`.

### What This Means:
- ❌ **Won't work** when friends install on their phones
- ✅ **Will work** if you test on emulator/device connected to your PC
- ⚠️ You need to pick Option 1, 2, or 3 above and **rebuild**

---

## 🔄 After Changing URL

Always rebuild after changing `baseUrl`:
```powershell
cd codiny_platform_app
flutter clean
flutter build apk --release
```

---

## 💡 Pro Tip: Use Environment Variables

For better flexibility, you could set up multiple environments:

```dart
class Environment {
  static const String devUrl = 'http://localhost:3000';
  static const String stagingUrl = 'https://your-ngrok.ngrok.io';
  static const String prodUrl = 'https://your-app.railway.app';
  
  // Change this to switch environments
  static const String baseUrl = devUrl; // or stagingUrl or prodUrl
}
```

---

## ✅ Checklist Before Sharing APK

- [ ] Backend is accessible (not just localhost)
- [ ] Updated `baseUrl` in `environment.dart`
- [ ] Rebuilt APK after URL change
- [ ] Tested on at least one device
- [ ] Backend is running and will stay running
- [ ] Database is accessible from backend

---

**Remember**: Your backend must be accessible from the internet (or same network) for the app to work on your friends' phones! 📱🌐
