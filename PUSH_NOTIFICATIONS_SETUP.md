# Push Notifications Setup Guide 🔔

## What Was Implemented

Push notifications have been added to notify students when their school creates a new calendar event.

## Backend Changes

### 1. Database Migration
**File:** `backend/migrations/add-fcm-token-to-students.sql`
- Adds `fcm_token` column to `students` table
- **Action Required:** Run this on Railway database:
```sql
ALTER TABLE students ADD COLUMN fcm_token TEXT;
```

### 2. Notification Service
**File:** `backend/services/notification.service.js`
- Handles sending push notifications via Firebase Cloud Messaging
- Functions:
  - `sendNotificationToStudent()` - Send to one student
  - `sendNotificationToMultipleStudents()` - Send to multiple students
  - `saveFCMToken()` - Save device token

### 3. Updated Routes
**File:** `backend/routes/school.routes.js`
- Modified `POST /schools/students/:id/events` to send notification when event is created
- Notification format: "📅 New Event Scheduled - [Title] - [Date] at [Location]"

**File:** `backend/routes/student.routes.js`
- Added `POST /students/fcm-token` endpoint to save device tokens from Flutter app

### 4. Environment Variables
**Action Required:** Add Firebase service account to Railway environment:

1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Copy the entire JSON content
4. In Railway, add environment variable:
   ```
   FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account","project_id":"...","private_key":"..."}
   ```

## Flutter App Changes

### 1. Dependencies Added
**File:** `codiny_platform_app/pubspec.yaml`
- `firebase_core: ^3.10.0` - Firebase initialization
- `firebase_messaging: ^15.2.0` - Push notifications

**Action Required:** Run:
```bash
cd codiny_platform_app
flutter pub get
```

### 2. Notification Service
**File:** `lib/services/notification_service.dart`
- Handles FCM token registration
- Listens for incoming notifications
- Sends token to backend
- Handles notification taps

### 3. App Initialization
**File:** `lib/main.dart`
- Initializes Firebase on app startup
- Registers for push notifications after login
- Sends FCM token to backend

### 4. Android Configuration
**Action Required:** Create Firebase project and add config files:

1. **Create Firebase Project:**
   - Go to https://console.firebase.google.com
   - Create new project or use existing
   - Add Android app with package name: `com.codiny.platform.app`

2. **Download google-services.json:**
   - In Firebase Console → Project Settings → Your apps
   - Download `google-services.json`
   - Place in: `codiny_platform_app/android/app/google-services.json`

3. **Update android/build.gradle:**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

4. **Update android/app/build.gradle:**
```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services'
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

5. **Update AndroidManifest.xml** to add notification channel:
```xml
<manifest>
    <application>
        <!-- Add this inside <application> tag -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="events" />
    </application>
</manifest>
```

## How It Works

### Flow:
1. **Student logs in** → App gets FCM token from Firebase
2. **App sends token** → `POST /students/fcm-token` → Saved in database
3. **School creates event** → `POST /schools/students/:id/events`
4. **Backend sends notification** → Firebase Cloud Messaging → Student's device
5. **Student receives** → Notification appears even if app is closed

### Notification Content:
- **Title:** "📅 New Event Scheduled"
- **Body:** "[Event Title] - [Date & Time] at [Location]"
- **Data:** Event ID, Student ID (for navigation)

## Testing

### 1. Test Backend (Without Firebase)
The backend will work fine without Firebase credentials - it just logs warnings:
```
⚠️  FIREBASE_SERVICE_ACCOUNT_JSON not set. Push notifications disabled.
```

### 2. Test With Firebase
After setting up:
1. Deploy backend with `FIREBASE_SERVICE_ACCOUNT_JSON` env variable
2. Build Flutter app with Firebase configured
3. Login as student
4. Check logs for: `✅ FCM token saved for student [ID]`
5. As school, create an event for that student
6. Student should receive notification

## Troubleshooting

### Backend Issues:
- **"Firebase not initialized"**: Check `FIREBASE_SERVICE_ACCOUNT_JSON` is valid JSON
- **"No FCM token"**: Student hasn't logged in with updated app yet
- **"Invalid registration token"**: Student uninstalled app - token cleared automatically

### Flutter Issues:
- **"Target of URI doesn't exist"**: Run `flutter pub get`
- **Build fails**: Check Firebase configuration files are in correct location
- **No notifications received**: Check app has notification permissions (Settings → Apps → Codiny → Notifications)

## Optional Enhancements

### 1. Add to schema-clean.sql
For fresh database setups:
```sql
ALTER TABLE students ADD COLUMN fcm_token TEXT;
```

### 2. Notification Types
Expand to include:
- Subscription expiring soon
- New exam questions added
- School announcements
- Payment reminders

### 3. In-App Notifications
Show notification banner when app is in foreground using `flutter_local_notifications` package

### 4. Notification History
Create `notifications` table to track sent notifications for analytics

## Security Notes

- FCM tokens are device-specific and refresh periodically
- Backend validates student ownership before sending notifications
- Only schools can create events for their students
- Invalid tokens are automatically cleared from database

## Need Help?

Check logs:
- **Backend:** Railway logs for notification sending
- **Flutter:** Android Studio logcat or `flutter logs` for FCM token registration
