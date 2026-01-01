# 🧪 Testing Guide for New Features

## 📱 Installation

1. **Transfer APK to phone:**
   - Location: `build\app\outputs\flutter-apk\app-release.apk`
   - Size: ~167 MB

2. **Install APK:**
   - Enable "Install from unknown sources"
   - Open APK and install

3. **Login as School:**
   - Use your school credentials

---

## ✅ Feature Testing Checklist

### 1. Student Management Section

Navigate to: **Home → Student Management**

#### Test Student Calendars:
- [ ] Click "Student calendars"
- [ ] Should see list of students
- [ ] Click any student
- [ ] Calendar should open
- [ ] Try adding events (if implemented)

#### Test Track Student Progress:
- [ ] Click "Track student progress"
- [ ] Should see list of all students with status indicators
- [ ] Each student card shows:
  - [ ] Avatar with first letter
  - [ ] Student name
  - [ ] Active/Inactive status (green/gray dot)
  - [ ] "View Exams" chip
  - [ ] "See Progress" chip
- [ ] Click any student card
- [ ] Should see progress detail screen with:
  - [ ] Student name in gradient header
  - [ ] 4 stat cards: Total Exams, Passed, Average Score, Success Rate
  - [ ] "Exam History" section
  - [ ] Currently shows "No Exams Yet" message (normal - needs backend)
- [ ] Pull down to refresh
- [ ] Back button works

### 2. Financial Reports

Navigate to: **Home → Reports & Analytics → Financial reports**

#### Test Financial Dashboard:
- [ ] Should see gradient header card with:
  - [ ] Total Revenue amount (in MAD)
  - [ ] Student count
- [ ] Financial Overview section shows:
  - [ ] Collected amount (green card with check icon)
  - [ ] Pending amount (orange card with pending icon)
- [ ] Key Metrics section shows:
  - [ ] Collection Rate with progress bar
  - [ ] Average Per Student
  - [ ] Total Students
- [ ] Payment Breakdown section shows:
  - [ ] Total Expected row
  - [ ] Collected row (green)
  - [ ] Pending row (orange)
- [ ] Info card at bottom explains real-time updates
- [ ] Pull down to refresh
- [ ] Data should match dashboard stats

### 3. Performance Analytics (Should Be Removed)

Navigate to: **Home → Reports & Analytics**

- [ ] Should NOT see "Performance analytics" option
- [ ] Only "Financial reports" should be visible
- [ ] Section should be cleaner

### 4. PDF Viewer (CRITICAL TEST)

Navigate to: **Any traffic sign or course**

#### Test PDF Loading:
- [ ] Click any course with PDF
- [ ] Should see "Loading PDF..." spinner
- [ ] PDF should load and display
- [ ] Page counter should show (e.g., "1 / 23")
- [ ] Try swiping up/down to change pages
- [ ] Page counter should update
- [ ] Try pinching to zoom in/out
- [ ] PDF should zoom smoothly

#### Test PDF Error Handling:
If PDF fails to load:
- [ ] Should see red error icon
- [ ] Error message displayed
- [ ] Course info card shown below
- [ ] Two buttons: "إعادة المحاولة" (Retry) and "العودة" (Back)
- [ ] Click Retry - should try loading again
- [ ] Click Back - should return to courses list

#### PDF Navigation:
- [ ] Swipe gestures work smoothly
- [ ] Pages snap into place
- [ ] No lag or freezing
- [ ] Back button returns to course list

---

## 🐛 Expected Issues (Normal Behavior)

### Track Student Progress:
**Issue:** Shows "No Exams Yet" for all students  
**Why:** Backend endpoint not yet implemented  
**Status:** Expected - need to add `/api/schools/students/:studentId/exams`

### PDF Viewer:
**Issue:** May show error if PDF file not in assets  
**Why:** PDF files need to be placed in `assets/courses/`  
**Status:** Expected - ensure PDF files exist

---

## 📊 Success Criteria

### Track Student Progress:
- ✅ List loads without errors
- ✅ Detail screen opens
- ✅ Stats calculate correctly (even if 0)
- ✅ UI is smooth and responsive
- ✅ Arabic text displays correctly

### Financial Reports:
- ✅ All numbers display correctly
- ✅ Progress bar shows correct percentage
- ✅ Currency format is "MAD XX,XXX"
- ✅ Refresh works
- ✅ UI looks professional

### PDF Viewer:
- ✅ PDFs load and display
- ✅ Navigation works
- ✅ Zoom works
- ✅ Page counter updates
- ✅ Error handling works

---

## 🎯 Performance Tests

### App Launch:
- [ ] App opens without crashes
- [ ] Login works
- [ ] Dashboard loads within 3 seconds

### Navigation:
- [ ] All new screens load quickly
- [ ] No lag when switching tabs
- [ ] Back button always works

### Data Loading:
- [ ] Shimmer placeholders show while loading
- [ ] Data appears smoothly
- [ ] No sudden UI jumps

---

## 📱 Device Compatibility

Test on:
- [ ] Android 7.0+ (minSdk 21)
- [ ] Different screen sizes
- [ ] Light/Dark mode (if applicable)
- [ ] Different orientations (portrait/landscape)

---

## 🚨 Critical Tests

These MUST work:
1. ✅ Login as school
2. ✅ Dashboard loads
3. ✅ Student list displays
4. ✅ Financial reports show data
5. ✅ PDF viewer opens
6. ✅ No crashes

---

## 📝 Bug Reporting Template

If you find a bug, note:
```
Feature: [e.g., Track Student Progress]
Screen: [e.g., Student Progress Detail]
Action: [What you did]
Expected: [What should happen]
Actual: [What actually happened]
Error: [Any error message]
```

---

## ✨ What to Look For

### Good Signs:
- 🟢 Smooth animations
- 🟢 No crashes
- 🟢 Data loads correctly
- 🟢 Arabic text renders properly
- 🟢 Colors are consistent

### Red Flags:
- 🔴 App crashes
- 🔴 Blank screens
- 🔴 Data doesn't load
- 🔴 Buttons don't work
- 🔴 PDF viewer fails

---

## 🎉 After Testing

Once tested, the app is ready for:
- Distribution to students
- Production use
- Collecting real user feedback

**Enjoy your fully-featured school management platform!** 🚀
