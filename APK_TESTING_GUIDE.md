# 🚀 APK Testing Guide - Share with Friends

**App**: Codiny Platform - Driving Exam Preparation  
**Version**: 1.0.0+1  
**Build Date**: December 31, 2025

---

## 📦 APK Location

After build completes, find your APK at:
```
C:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2\codiny_platform_app\build\app\outputs\flutter-apk\app-release.apk
```

---

## 📱 How to Install & Test

### For Your Friends:

1. **Transfer APK**:
   - Share via WhatsApp, Telegram, email, or USB
   - Or upload to Google Drive/Dropbox

2. **Enable Unknown Sources** (first time only):
   - Settings → Security → Unknown Sources → Enable
   - Or: Settings → Apps → Special Access → Install Unknown Apps → Allow for your file manager

3. **Install**:
   - Open the APK file on Android device
   - Tap "Install"
   - Tap "Open" when done

---

## 🧪 Testing Checklist

### Test 1: Registration & Login ✅
- [ ] Create new account (student)
- [ ] Login with created account
- [ ] Check JWT token expires after 1 hour
- [ ] Test logout functionality

### Test 2: Onboarding Flow ✅
- [ ] Complete onboarding steps
- [ ] Select access method (independent or school)
- [ ] Verify access control works

### Test 3: Dashboard ✅
- [ ] Dashboard loads correctly
- [ ] All cards display properly
- [ ] Statistics show correct data
- [ ] Navigation between screens works

### Test 4: Courses ✅
- [ ] Course list displays
- [ ] Can open course details
- [ ] PDF viewer works (web only - not applicable for APK)
- [ ] Traffic signs viewer opens correctly

### Test 5: Traffic Signs Viewer ✅
- [ ] Grid displays all 30 signs
- [ ] Category filtering works (7 categories)
- [ ] Tap sign opens detail view
- [ ] Large image displays correctly
- [ ] Description shows properly
- [ ] Back button works

### Test 6: Exams ✅
- [ ] Can start new exam
- [ ] 30 questions load properly
- [ ] Can select answers (A/B/C)
- [ ] Images display if present
- [ ] Timer counts down (45 minutes)
- [ ] Submit exam works
- [ ] Results screen shows score
- [ ] Pass/fail status correct (23/30 passing)

### Test 7: Exam History ✅
- [ ] Previous exams list displays
- [ ] Pagination works (10 items per page)
- [ ] Can view exam details
- [ ] Score and date show correctly

### Test 8: Profile ✅
- [ ] Profile information displays
- [ ] Can edit profile
- [ ] Settings work properly
- [ ] Logout works

### Test 9: Performance ✅
- [ ] App loads quickly
- [ ] No lag when navigating
- [ ] Images load fast
- [ ] Smooth scrolling
- [ ] No crashes

### Test 10: School Features (if applicable) ✅
- [ ] School admin can login
- [ ] Can view pending students
- [ ] Can approve/reject students
- [ ] Pagination works on student lists
- [ ] Revenue tracking visible

---

## 🐛 Bug Reporting Template

If testers find issues, ask them to report with this format:

```
**Bug Title**: [Short description]

**Steps to Reproduce**:
1. 
2. 
3. 

**Expected Result**: [What should happen]

**Actual Result**: [What actually happened]

**Device**: [Brand, Model, Android version]

**Screenshot**: [If possible]
```

---

## 📊 Test Results Tracking

### Tester Information:

| Tester Name | Device | Android Version | Test Date | Status | Issues Found |
|-------------|--------|-----------------|-----------|--------|--------------|
| Friend 1    |        |                 |           |        |              |
| Friend 2    |        |                 |           |        |              |
| Friend 3    |        |                 |           |        |              |
| Friend 4    |        |                 |           |        |              |
| Friend 5    |        |                 |           |        |              |

---

## 🔐 Test Accounts

### For Testing (Create these in backend):

**Student Account**:
- Email: `test@student.com`
- Password: `Test123!`
- Type: Independent student

**School Admin Account**:
- Email: `admin@school.com`
- Password: `Admin123!`
- Type: School administrator

---

## 🌐 Backend Configuration

**Important**: Make sure your backend is running and accessible!

### If Backend is on Local Machine:

Your friends **CANNOT** access localhost. You need to:

#### Option 1: Use Your Local IP (Same WiFi)
1. Find your IP: `ipconfig` (Windows) - look for IPv4
2. Update Flutter app API base URL to: `http://YOUR_IP:3000`
3. Start backend: `cd backend && node server.js`
4. Share your WiFi with friends

#### Option 2: Use Ngrok (Recommended for Testing)
```powershell
# Install ngrok: https://ngrok.com/download

# Run backend
cd backend
node server.js

# In new terminal, expose backend
ngrok http 3000

# Copy the ngrok URL (e.g., https://abc123.ngrok.io)
# Update Flutter app to use this URL
```

#### Option 3: Deploy Backend Online
- Deploy to: Railway, Render, Heroku, or VPS
- Update Flutter app with production URL
- Most reliable for testing with friends

### Current API Configuration:
Check `lib/core/api/api_client.dart` for current base URL.

---

## 📱 APK Information

### File Details:
- **Name**: app-release.apk
- **Size**: ~30-60 MB (expected)
- **Min Android**: 5.0 (API 21)
- **Target Android**: 14 (API 34)
- **Architecture**: Universal (works on all ARM/x86 devices)

### Permissions Required:
- ✅ Internet (for API calls)
- ✅ Network State (to check connectivity)

---

## ✅ What's Working

Based on our implementation:

### Fully Functional:
- ✅ Authentication (JWT 1-hour expiry)
- ✅ Student onboarding flow
- ✅ Access control (independent/school)
- ✅ Dashboard with statistics
- ✅ Course system
- ✅ **Traffic Signs Viewer** (30 signs, 7 categories, interactive)
- ✅ Exam system (30 questions, 45 min timer)
- ✅ Exam history with pagination
- ✅ School management (admin approval)
- ✅ Backend pagination (max 100 items/page)
- ✅ Database indexes (41 total, performance optimized)

### Limitations:
- ⚠️ PDF viewing only works on **web** (uses HTML iframe)
- ⚠️ Backend must be accessible (not localhost for remote testing)

---

## 🎯 Success Criteria

Your app is ready for friends to test if:

✅ All testers can install APK  
✅ All testers can register/login  
✅ All core features work (dashboard, exams, traffic signs)  
✅ No crashes reported  
✅ Performance is acceptable  
✅ At least 80% of test checklist passes  

---

## 📞 Support Information

**For Testers**:
- Contact: [Your contact info]
- Expected response time: [e.g., within 24 hours]
- Test period: [e.g., December 31, 2025 - January 7, 2026]

**Known Issues**:
- PDF courses not available on mobile (only web)
- Backend must be online for app to work

---

## 🚀 Next Steps After Testing

1. **Collect Feedback**: Gather all tester reports
2. **Fix Critical Bugs**: Address blocking issues
3. **Optimize**: Improve performance based on feedback
4. **Iterate**: Build new version with fixes
5. **Prepare for Production**: 
   - Update package name from `com.example`
   - Add proper app signing
   - Create Play Store listing
   - Deploy backend to production

---

## 📝 Quick Command Reference

### To rebuild after fixes:
```powershell
cd "c:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2\codiny_platform_app"
flutter clean
flutter pub get
flutter build apk --release
```

### To check APK size:
```powershell
cd "c:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2\codiny_platform_app\build\app\outputs\flutter-apk"
dir app-release.apk
```

### To test on connected device:
```powershell
flutter install
```

---

**Happy Testing! 🎉**

Remember: This is a **test build**. Collect feedback, fix issues, and iterate!
