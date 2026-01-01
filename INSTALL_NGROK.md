# 🌐 Install and Setup Ngrok

## What is Ngrok?
Ngrok creates a secure public URL that tunnels to your localhost. Perfect for testing your app with friends!

---

## 📥 Installation Options

### Option A: Download Executable (Recommended)

1. **Download ngrok:**
   - Go to: https://ngrok.com/download
   - Or direct link: https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip

2. **Extract the ZIP:**
   - Extract `ngrok.exe` to a folder, e.g., `C:\ngrok\`

3. **Add to PATH (optional but helpful):**
   ```powershell
   # Add ngrok to PATH permanently
   $env:Path += ";C:\ngrok"
   [Environment]::SetEnvironmentVariable("Path", $env:Path, [EnvironmentVariableTarget]::User)
   ```

4. **Sign up for free account:**
   - Go to: https://dashboard.ngrok.com/signup
   - Get your authtoken

5. **Configure ngrok:**
   ```powershell
   cd C:\ngrok
   .\ngrok.exe config add-authtoken YOUR_AUTH_TOKEN_HERE
   ```

### Option B: Using Chocolatey Package Manager

If you have Chocolatey installed:
```powershell
choco install ngrok
```

### Option C: Using Scoop Package Manager

If you have Scoop installed:
```powershell
scoop install ngrok
```

---

## 🚀 Quick Start (After Installation)

### 1. Start Your Backend
```powershell
cd "c:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2\backend"
node server.js
```
Keep this terminal open!

### 2. Start Ngrok (New Terminal)
```powershell
# If ngrok is in PATH:
ngrok http 3000

# If you extracted to C:\ngrok:
cd C:\ngrok
.\ngrok.exe http 3000
```

### 3. Copy the Public URL
You'll see output like:
```
Forwarding   https://abc123.ngrok-free.app -> http://localhost:3000
```

Copy the `https://abc123.ngrok-free.app` URL

### 4. Update Flutter App
Edit: `lib/core/config/environment.dart`
```dart
static const String baseUrl = 'https://abc123.ngrok-free.app';
```

### 5. Rebuild APK
```powershell
cd "c:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2\codiny_platform_app"
flutter build apk --release
```

### 6. Share APK
The APK at `build\app\outputs\flutter-apk\app-release.apk` will now work anywhere!

---

## ⚡ Features

✅ **Works anywhere** - Friends can use the app even on mobile data  
✅ **Free tier available** - No credit card required  
✅ **HTTPS secure** - Automatic SSL certificate  
✅ **Easy setup** - Just 2 commands to run  

---

## 📝 Ngrok Free Tier Limits

- ✅ 1 online ngrok process
- ✅ 4 tunnels/ngrok process  
- ✅ 40 connections/minute
- ⚠️ URL changes each restart (e.g., `https://abc123.ngrok-free.app`)
- ⚠️ Session limit: 2 hours (need to restart)

**For Testing**: Free tier is perfect!  
**For Production**: Consider paid plan ($8/month) for:
- Fixed domain (e.g., `https://codiny.ngrok.app`)
- No session limits
- More connections

---

## 🔄 Complete Workflow

```powershell
# Terminal 1: Backend
cd "c:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2\backend"
node server.js

# Terminal 2: Ngrok
ngrok http 3000

# Copy URL from ngrok output
# Update environment.dart with the URL
# Rebuild APK
# Share with friends!
```

---

## 🆘 Troubleshooting

### Error: "ngrok is not recognized"
**Solution**: Either:
1. Use full path: `C:\ngrok\ngrok.exe http 3000`
2. Add to PATH (see Option A step 3)

### Error: "Failed to start tunnel"
**Solution**: Make sure you added your authtoken:
```powershell
ngrok config add-authtoken YOUR_TOKEN
```

### Error: "Backend connection refused"
**Solution**: 
- Make sure backend is running first (`node server.js`)
- Check backend is on port 3000
- Try restarting both backend and ngrok

---

## ✅ Ready to Use

After setup, you only need 2 commands each time:
```powershell
# Terminal 1
cd backend
node server.js

# Terminal 2
ngrok http 3000
```

That's it! 🎉
