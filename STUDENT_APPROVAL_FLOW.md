# 📋 Student Approval Flow - Complete Documentation

**Date:** January 4, 2026  
**Status:** Implementation Complete

---

## 🎯 Complete Student Journey

### **Phase 1: Registration** 📝
**What happens:**
- Student creates account with email and password
- Backend creates user in `users` table
- Backend creates student profile in `students` table with:
  - `student_type = 'independent'`
  - `is_active = false` ⛔ (account locked)
  - `access_level = 'limited'`
  - `onboarding_complete = false`

**Student Status:** ❌ Not Active, No Content Access

---

### **Phase 2: Permit Selection** 🚗
**What happens:**
- Student sees "Choose Your Permit 🚗" screen
- Student selects **Permit B** (Car license)
- Backend updates:
  - `permit_type = 'B'`
  - `onboarding_complete = true`
  
**Student Status:** ❌ Still Not Active (waiting for school)

---

### **Phase 3: School Link** 🏫
**What happens:**
- Student links to a school (provides school_id)
- Backend updates:
  - `school_id = [school_id]`
  - `school_approval_status = 'pending'`
  - Creates request in `school_student_requests` table

**Student Status:** ⏳ Pending School Approval

---

### **Phase 4: School Approval** ✅ **[KEY STEP]**
**What happens:**
- School admin reviews pending students
- School admin clicks "Approve" for the student
- **Backend updates (THIS IS THE MAGIC):**
  ```sql
  UPDATE students SET 
    student_type = 'attached_to_school',  ← Changes from 'independent'
    school_approval_status = 'approved',
    school_approved_at = CURRENT_TIMESTAMP,
    is_active = TRUE,                      ← UNLOCKS THE ACCOUNT!
    access_level = 'full'                  ← GRANTS FULL ACCESS!
  WHERE id = student_id AND school_id = school_id
  ```
  
- Revenue tracking: 20 TND to school, 30 TND to platform

**Student Status:** ✅ **ACTIVE! Content Unlocked!**

---

## 🔓 What Gets Unlocked After Approval

Once `is_active = TRUE` and `student_type = 'attached_to_school'`:

### ✅ **Available Features:**
1. **Lessons** - All driving theory lessons
2. **Exams** - Practice exams and tests
3. **Questions** - Question bank access
4. **Progress Tracking** - Stats and completion tracking
5. **Calendar** - School events and schedules
6. **Certificates** - Upon completion

### ❌ **Still Locked:**
- **Permit A content** (if student chose Permit B)
- **Permit C content** (if student chose Permit B)

---

## 📊 Database States

| Field | Registration | After Permit | After School Link | After Approval |
|-------|-------------|--------------|-------------------|----------------|
| `student_type` | `independent` | `independent` | `independent` | ✅ `attached_to_school` |
| `is_active` | `false` | `false` | `false` | ✅ `true` |
| `access_level` | `limited` | `limited` | `limited` | ✅ `full` |
| `permit_type` | `NULL` | ✅ `B` | `B` | `B` |
| `school_id` | `NULL` | `NULL` | ✅ `[id]` | `[id]` |
| `school_approval_status` | `NULL` | `NULL` | `pending` | ✅ `approved` |
| `onboarding_complete` | `false` | ✅ `true` | `true` | `true` |

---

## 🔧 Implementation Details

### **Backend Function:** `approveStudent()`
**File:** `backend/controllers/school.controller.js`

**Endpoint:** `POST /api/schools/:schoolId/approve-student`

**Request Body:**
```json
{
  "student_id": "b5de7dc9-a49b-4429-a662-55eb3511eda8"
}
```

**Response:**
```json
{
  "message": "Student approved successfully!",
  "student_id": "...",
  "status": "approved",
  "revenue": {
    "school": "20 TND",
    "platform": "30 TND",
    "total": "50 TND"
  }
}
```

**What it does:**
1. ✅ Verifies student has pending request
2. ✅ Updates student record:
   - Sets `student_type` to `'attached_to_school'`
   - Sets `is_active` to `TRUE`
   - Sets `access_level` to `'full'`
   - Sets `school_approval_status` to `'approved'`
3. ✅ Updates request record to `'approved'`
4. ✅ Tracks revenue (20 TND school, 30 TND platform)
5. ✅ Returns success response

---

## 🎨 User Experience

### **Student Side:**
1. Register → See "Choose Permit" screen
2. Select Permit B → See "Link to School" screen
3. Enter school code → See "Waiting for Approval" message
4. **After school approves:**
   - 🎉 Notification: "Your account is now active!"
   - ✅ Dashboard unlocks
   - ✅ All content becomes accessible
   - 🚗 Permit B badge shows

### **School Side:**
1. Login to school dashboard
2. See "Pending Students" list
3. Review student details
4. Click "Approve" button
5. **System automatically:**
   - Activates student account
   - Changes type to "attached_to_school"
   - Tracks revenue
   - Student gets access immediately

---

## 🔍 Content Access Control

The system uses these checks to control content access:

```javascript
// Pseudo-code for content access
function canAccessContent(student) {
  return (
    student.is_active === true &&
    student.student_type === 'attached_to_school' &&
    student.access_level === 'full' &&
    student.permit_type !== null
  );
}

function canAccessPermitContent(student, contentPermitType) {
  if (!canAccessContent(student)) {
    return false; // Not active at all
  }
  
  if (student.permit_type !== contentPermitType) {
    return false; // Wrong permit type
  }
  
  return true; // All checks passed!
}
```

**Examples:**
- Student with Permit B + approved → ✅ Can access Permit B lessons
- Student with Permit B + approved → ❌ Cannot access Permit A/C lessons
- Student with Permit B + pending → ❌ Cannot access any lessons
- Student with Permit B + no school → ❌ Cannot access any lessons

---

## 📱 Frontend Implementation

### **Access Status Display:**
`lib/features/dashboard/student/student_home_screen.dart` shows:

```dart
if (student.isActive && student.studentType == 'attached_to_school') {
  // ✅ Show "Account Active" banner
  // ✅ Enable all navigation buttons
  // ✅ Show full content access
} else if (student.schoolApprovalStatus == 'pending') {
  // ⏳ Show "Waiting for School Approval" banner
  // ❌ Disable content access
  // ℹ️ Show expected wait time
} else {
  // ❌ Show "Please link to a school" banner
  // 🔗 Show school link button
}
```

---

## 🚀 Testing the Flow

### **Test Scenario 1: New Student Registration**
1. Register new account: `testuser@example.com`
2. **Check database:**
   ```sql
   SELECT student_type, is_active, access_level 
   FROM students 
   WHERE user_id = (SELECT id FROM users WHERE identifier = 'testuser@example.com');
   ```
   **Expected:** `independent`, `false`, `limited`

3. Select Permit B
4. **Check database:**
   ```sql
   SELECT permit_type, onboarding_complete 
   FROM students 
   WHERE user_id = ...;
   ```
   **Expected:** `B`, `true`

5. Link to school (school_id = 1)
6. **Check database:**
   ```sql
   SELECT school_id, school_approval_status 
   FROM students 
   WHERE user_id = ...;
   ```
   **Expected:** `1`, `pending`

7. School approves student
8. **Check database:**
   ```sql
   SELECT student_type, is_active, access_level, school_approval_status 
   FROM students 
   WHERE user_id = ...;
   ```
   **Expected:** `attached_to_school`, `true`, `full`, `approved` ✅

---

## ✅ Implementation Status

| Component | Status | Notes |
|-----------|--------|-------|
| Student Registration | ✅ Complete | Creates with `independent` type |
| Permit Selection | ✅ Complete | Updates `permit_type` |
| School Linking | ✅ Complete | Creates pending request |
| School Approval | ✅ **FIXED** | Now updates `student_type` correctly |
| Content Unlocking | ✅ Complete | Based on `is_active` + type |
| Revenue Tracking | ✅ Complete | 20 TND school, 30 TND platform |

---

## 🎯 Summary

**The Complete Flow:**
1. Register → `independent` + `inactive`
2. Choose Permit → `independent` + `inactive` + `permit_type`
3. Link School → `independent` + `inactive` + `pending`
4. **School Approves** → ✅ `attached_to_school` + ✅ `active` + ✅ `full access`

**Result:** Student can now access all Permit B content! 🎉

---

## 📝 Deployment Notes

**What Changed:**
- Updated `approveStudent()` function to set `student_type = 'attached_to_school'`

**Needs Deployment:**
- ✅ Commit and push to GitHub
- ✅ Railway will auto-deploy
- ✅ No database migration needed
- ✅ No frontend changes needed

**Testing After Deployment:**
1. Create test student account
2. Choose Permit B
3. Link to test school
4. Approve from school dashboard
5. Verify content unlocks immediately
