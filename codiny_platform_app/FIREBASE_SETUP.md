# Firebase Setup & Image Upload Guide

## 📱 **Result: App Size ~45MB** (down from 168MB!)

---

## 🔥 **Step 1: Create Firebase Project**

1. **Go to:** https://console.firebase.google.com/
2. **Click:** "Add project"
3. **Name:** `codiny-driving-exam`
4. **Disable** Google Analytics (not needed)
5. **Click:** "Create project"

---

## 📦 **Step 2: Add Android App to Firebase**

1. In Firebase Console, click **"Add app"** → **Android**
2. **Android package name:** `ma.codiny.drivingexam`
3. **App nickname:** Codiny - Driving Exam
4. **Click:** "Register app"
5. **Download:** `google-services.json`
6. **Move file to:** `codiny_platform_app\android\app\google-services.json`

---

## ⚙️ **Step 3: Configure Android Build**

Add to `android/build.gradle` (project level):

```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Add to `android/app/build.gradle` (app level) at the BOTTOM:

```gradle
apply plugin: 'com.google.gms.google-services'
```

---

## 📤 **Step 4: Upload Images to Firebase Storage**

### Option A: Using Firebase Console (Easy)
1. Go to Firebase Console → **Storage**
2. Click **"Get Started"**
3. Choose **"Start in test mode"** (we'll fix rules later)
4. Create folder: `exam_images`
5. **Upload ALL 126 images** from `assets\exam_images\`

### Option B: Using Firebase CLI (Faster)
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Init storage
firebase init storage

# Upload images (use the PowerShell script)
```

---

## 🔒 **Step 5: Set Storage Rules**

In Firebase Console → Storage → Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /exam_images/{imageId} {
      // Allow anyone to read exam images
      allow read: if true;
      // Only authenticated users can write (for future updates)
      allow write: if request.auth != null;
    }
  }
}
```

**Click:** "Publish"

---

## 🗑️ **Step 6: Remove Bundled Exam Images**

**IMPORTANT:** Before removing, ensure Firebase upload is complete!

### Run this PowerShell script:

```powershell
# Backup first
Copy-Item -Path "assets\exam_images" -Destination "assets\exam_images_BACKUP" -Recurse

# Keep only logo in illustrations folder
Remove-Item -Path "assets\exam_images\*" -Exclude "*.gitkeep" -Force

# Create .gitkeep to keep folder
New-Item -Path "assets\exam_images\.gitkeep" -ItemType File -Force
```

Or manually:
1. Keep folder `assets\exam_images\` (don't delete folder!)
2. Delete ALL images inside it
3. Create empty file `.gitkeep` inside to keep folder structure

---

## 🚀 **Step 7: Update pubspec.yaml Assets**

The folder should still be listed but will be empty:

```yaml
flutter:
  assets:
    - assets/illustrations/  # Logo only
    - assets/exam_images/    # Empty - images from Firebase
    - assets/courses/        # PDFs stay
    - assets/traffic_signs/  # Keep these local
```

---

## 🔧 **Step 8: Initialize Firebase in App**

The service is ready! Just need to initialize Firebase in your main app.

**Check if you have:** `lib/main.dart`

Add Firebase initialization (I can help update this file)

---

## 📊 **Expected Results:**

| Item | Size |
|------|------|
| **Before** | 168MB |
| Logo | 0.5MB |
| PDFs (courses) | 2MB |
| Traffic Signs | ~5MB |
| App Code | ~35MB |
| **New Total** | **~45MB** ✅ |

**Savings:** 123MB (73% reduction!)

---

## ✅ **Testing:**

1. **With Internet:** Images load from Firebase → cached
2. **Offline (after cache):** Images load from cache
3. **First time user:** Sees loading spinner, then images

---

## 🎯 **Next Steps:**

1. Complete Firebase setup (Steps 1-5)
2. Upload all images to Firebase Storage
3. Run: `.\remove-exam-images.bat` (after confirming upload)
4. Update main.dart to initialize Firebase
5. Build: `flutter clean && flutter build appbundle --release`
6. **Result:** ~45MB app! 🎉

---

**Ready to start?** Let me know when you've created the Firebase project!
