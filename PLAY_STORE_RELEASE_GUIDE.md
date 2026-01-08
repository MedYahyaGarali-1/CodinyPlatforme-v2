# Google Play Store Release Guide

## ✅ Pre-Release Checklist Completed

The following critical issues have been fixed:

### 1. Package Name ✅
- Changed from: `com.example.codiny_platform_app`
- Changed to: `ma.codiny.drivingexam`
- Updated in: `android/app/build.gradle.kts`

### 2. App Name ✅
- Changed from: `codiny_platform_app`
- Changed to: `Codiny - Driving Exam`
- Updated in: `android/app/src/main/AndroidManifest.xml`

### 3. Security Settings ✅
- Removed: `android:usesCleartextTraffic="true"`
- Removed: `android:networkSecurityConfig`
- Now requires HTTPS for all network traffic

### 4. Code Optimization ✅
- Added: ProGuard rules for code shrinking
- Enabled: `minifyEnabled` and `shrinkResources`
- Created: `proguard-rules.pro` file

### 5. Privacy Policy ✅
- Created: `PRIVACY_POLICY.md`
- Covers: Data collection, usage, storage, and user rights

---

## 🔑 STEP 1: Create Release Signing Key

**IMPORTANT**: You MUST create a release signing key before publishing to Play Store.

### Generate Keystore (Run once):

```bash
keytool -genkey -v -keystore C:\Users\yahya\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# You'll be asked for:
# - Keystore password (REMEMBER THIS!)
# - Your name and organization details
# - Key password (can be same as keystore password)
```

### Create key.properties file:

Create file: `android/key.properties`

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=C:/Users/yahya/upload-keystore.jks
```

⚠️ **NEVER commit key.properties or .jks file to Git!**

Add to `.gitignore`:
```
android/key.properties
*.jks
*.keystore
```

### Update build.gradle.kts:

Replace the signingConfigs section with:

```kotlin
// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

---

## 📱 STEP 2: Build Release APK/AAB

### Build App Bundle (Recommended for Play Store):
```bash
cd codiny_platform_app
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Or Build APK:
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🌐 STEP 3: Host Privacy Policy

Choose one option:

### Option A: GitHub Pages (Free, Recommended)
1. Create new repository: `codiny-privacy-policy`
2. Create `index.html` with privacy policy
3. Enable GitHub Pages in repository settings
4. Use URL: `https://medyahyagarali-1.github.io/codiny-privacy-policy/`

### Option B: Your Website
- Upload `PRIVACY_POLICY.md` to your website
- Convert to HTML or use Markdown viewer
- Use URL: `https://yourwebsite.com/privacy-policy`

---

## 🎨 STEP 4: Prepare Store Assets

### Required Assets:

1. **App Icon** (512x512 PNG)
   - High-resolution, no transparency
   - Current location: `android/app/src/main/res/mipmap-*/ic_launcher.png`

2. **Feature Graphic** (1024x500 PNG/JPEG)
   - Banner shown on Play Store
   - Should include app name and key visual

3. **Screenshots** (Minimum 2, Maximum 8)
   - Phone: 16:9 or 9:16 aspect ratio
   - Minimum dimension: 320px
   - Maximum dimension: 3840px
   - Show key features:
     * Login screen
     * Dashboard
     * Exam screen
     * Progress tracking
     * Course viewer

4. **Short Description** (80 characters max)
   ```
   Prepare for your driving exam with interactive lessons and practice tests
   ```

5. **Full Description** (4000 characters max)
   ```
   Master your driving exam with Codiny - the complete preparation platform!

   🚗 KEY FEATURES:
   • 30-question practice exams matching official format
   • Interactive traffic signs reference
   • Complete driving code PDF courses
   • Progress tracking and performance analytics
   • Scheduled exams and calendar management
   • School integration for institutional users

   📚 COMPREHENSIVE LEARNING:
   • Complete Traffic Code course
   • Interactive Traffic Signs guide with 40+ signs
   • Real exam simulation (45 minutes, 30 questions)
   • Passing threshold: 23/30 (76.67%)

   📊 TRACK YOUR PROGRESS:
   • Detailed exam history
   • Score tracking and performance graphs
   • Review wrong answers with explanations
   • Identify weak areas for improvement

   👥 FOR SCHOOLS & STUDENTS:
   • School-managed accounts
   • Student progress monitoring
   • Bulk exam scheduling
   • Performance reports

   🎯 EXAM SIMULATION:
   • Random question selection
   • 45-minute timed tests
   • Mark questions for review
   • Instant results with detailed breakdown

   Perfect for:
   ✓ New drivers preparing for license exam
   ✓ Driving schools managing student progress
   ✓ Anyone wanting to refresh traffic rules knowledge

   Download now and pass your driving exam with confidence!

   Privacy Policy: [Your Privacy Policy URL]
   Support: [Your Support Email]
   ```

---

## 🎮 STEP 5: Play Console Setup

### Content Rating:
Answer questionnaire honestly:
- **Category**: Education/Training
- **Violence**: None
- **Sexual Content**: None
- **Controlled Substances**: None
- **Expected Rating**: Everyone (PEGI 3)

### Data Safety:
Declare collected data:

**Data Collected:**
- ✅ Personal Info (Name, Email, Phone)
- ✅ App Activity (Exam scores, course progress)
- ✅ App Info (Crash logs, diagnostics)

**Data Usage:**
- ✅ App functionality (Authentication, progress tracking)
- ✅ Account management

**Data Sharing:**
- ✅ Shared with schools (if student enrolled)
- ❌ NOT shared with third parties
- ❌ NO advertising or analytics

**Security:**
- ✅ Data encrypted in transit (HTTPS)
- ✅ Data encrypted at rest (Database encryption)
- ✅ Users can request data deletion

---

## 📝 STEP 6: Submit to Play Store

1. **Create Play Console Account** ($25 one-time fee)
   - https://play.google.com/console/signup

2. **Create New App**
   - App name: "Codiny - Driving Exam"
   - Default language: Arabic (or your primary language)
   - App/Game: Application
   - Free/Paid: Free

3. **Fill Required Sections**:
   - [x] App content (Content rating, Privacy policy, Ads)
   - [x] Store presence (Main store listing, Graphics)
   - [x] Production (Release track, App bundle)

4. **Upload Release**:
   - Production → Create new release
   - Upload: `app-release.aab`
   - Release name: "1.0.0 - Initial Release"
   - Release notes:
     ```
     Initial release of Codiny - Driving Exam platform
     
     Features:
     • 30-question practice exams
     • Interactive traffic signs guide
     • Complete driving code courses
     • Progress tracking
     • School integration
     • Calendar management
     ```

5. **Submit for Review**
   - Review takes 1-7 days
   - Monitor status in Play Console

---

## ⚠️ Common Rejection Reasons (Avoid These!)

1. **Debug signing** - Fixed ✅
2. **com.example package** - Fixed ✅
3. **Missing privacy policy** - Fixed ✅
4. **Cleartext traffic** - Fixed ✅
5. **Insufficient screenshots** - Need to add
6. **Broken functionality** - Test thoroughly!
7. **Misleading content** - Be honest in description
8. **Copyright issues** - Ensure you own all content

---

## 🧪 Testing Checklist

Before submitting, test:

- [ ] Fresh install on clean device
- [ ] Registration and login flow
- [ ] All exam features working
- [ ] Course PDFs loading
- [ ] Traffic signs displaying
- [ ] Progress saving correctly
- [ ] Logout and re-login
- [ ] Network error handling
- [ ] No crashes or freezes
- [ ] Proper back button behavior
- [ ] Text legibility on all screens

---

## 📧 Support & Updates

After approval:
- Monitor Play Console for user reviews
- Respond to user feedback
- Plan updates for bug fixes and features
- Maintain privacy policy
- Keep target SDK up to date

---

## 🚀 Next Version (Future Updates)

When releasing updates:

```bash
# Update version in pubspec.yaml
version: 1.0.1+2  # version+build_number

# Build and upload new AAB
flutter build appbundle --release

# Create new release in Play Console
# Select "Production" track
# Upload new AAB
# Add release notes
```

---

## Need Help?

- Play Console Help: https://support.google.com/googleplay/android-developer
- Flutter Deployment Guide: https://docs.flutter.dev/deployment/android
- App Signing: https://developer.android.com/studio/publish/app-signing

---

**Current Status**: ✅ App is configured and ready for signing key creation and Play Store submission!
