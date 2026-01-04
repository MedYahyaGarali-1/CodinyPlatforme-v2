# 🔍 System Diagnostics Tool - User Guide

## What This Does

The diagnostic tool checks **EVERYTHING** in your system and shows you exactly what's happening:
- ✅ Database connection
- ✅ All users and their names
- ✅ All students and their permit types
- ✅ Active/inactive status
- ✅ School approval status
- ✅ Issues detection
- ✅ Health check

---

## 🚀 How to Run It

### **Option 1: On Your Local Machine** (If you have Railway CLI)

```powershell
# 1. Make sure you're in the project directory
cd "c:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2\backend"

# 2. Run the diagnostic
node diagnostic-check.js
```

**Note:** This will use your Railway database if you have the DATABASE_URL in your .env file.

---

### **Option 2: On Railway** (Recommended - See Live Production Data)

#### **Method A: Using Railway CLI**

```bash
# 1. Login to Railway (first time only)
railway login

# 2. Link to your project
railway link

# 3. Run the diagnostic on Railway
railway run node diagnostic-check.js
```

#### **Method B: Using Railway Dashboard**

1. Go to Railway Dashboard
2. Open your backend service
3. Click **"Shell"** tab
4. Run: `node diagnostic-check.js`
5. Watch the output!

---

## 📊 What You'll See

The tool will show you **7 sections**:

### 1. **Database Connection** 📊
```
✅ Database Connected Successfully!
   Time: 2026-01-04 18:30:15
   Version: PostgreSQL 14.5
```

### 2. **Users Table Analysis** 👥
```
📈 Total Users: 15

👤 Users by Role:
   student: 12
   school: 3

⚠️  Users with missing names: 2

📋 Recent 5 Users:
┌─────────┬──────────────┬───────────────────────┬─────────┬────────────┐
│ ID      │ Name         │ Email                 │ Role    │ Created    │
├─────────┼──────────────┼───────────────────────┼─────────┼────────────┤
│ b5de7dc9│ Yahya Garali │ yahyagarali1@gmail... │ student │ 1/3/2026   │
│ ...     │ ❌ NULL      │ test@example.com      │ student │ 1/4/2026   │
└─────────┴──────────────┴───────────────────────┴─────────┴────────────┘
```

### 3. **Students Table Analysis** 🎓
```
📈 Total Students: 12

✅ permit_type column exists

🚗 Permit Type Distribution:
   Permit B: 10
   Permit NULL: 2

📊 Student Type Distribution:
   independent: 8
   attached_to_school: 4

🔓 Activation Status:
   ✅ Active: 4
   ❌ Inactive: 8

🏫 School Approval Status:
   approved: 4
   pending: 3
   No School Linked: 5
```

### 4. **Schools Table Analysis** 🏫
```
📈 Total Schools: 3

📋 Recent Schools:
┌─────────┬────────────────┬──────────────┬──────────┬──────────┐
│ ID      │ Name           │ Email        │ Students │ Approved │
├─────────┼────────────────┼──────────────┼──────────┼──────────┤
│ abc123..│ Test School    │ school@...   │ 5        │ 3        │
└─────────┴────────────────┴──────────────┴──────────┴──────────┘
```

### 5. **Issues Detection** 🚨
```
❌ Issue 1: 2 users have no name
   Users affected:
   - test@example.com (student)
   - another@test.com (student)
   Fix: UPDATE users SET name = 'User Name' WHERE id = '...'

✅ No students with incorrect type/active combination

⚠️  Issue 3: 2 students completed onboarding but have no permit_type
   Fix: UPDATE students SET permit_type = 'B' WHERE permit_type IS NULL

✅ All approved students are active

⚠️  Found 2 issue(s) that need attention
```

### 6. **API Routes Verification** 🛣️
```
Expected Routes:
┌────────┬──────────────────────────────────────────┬─────────────────────┐
│ Method │ Path                                     │ Status              │
├────────┼──────────────────────────────────────────┼─────────────────────┤
│ POST   │ /api/auth/register                       │ ✅ Should exist     │
│ POST   │ /api/auth/login                          │ ✅ Should exist     │
│ POST   │ /api/students/onboarding/choose-permit   │ ✅ NEW              │
└────────┴──────────────────────────────────────────┴─────────────────────┘
```

### 7. **Environment Configuration** ⚙️
```
Environment Variables:
   NODE_ENV: production
   PORT: 3000
   DATABASE_URL: ✅ Set
   JWT_SECRET: ✅ Set
```

---

## 🎯 How to Use the Results

### **If You See Issues:**

1. **Copy the suggested SQL fixes**
2. **Go to Railway Query Tool**
3. **Run the fixes**
4. **Run diagnostics again** to verify

### **Example Fix Flow:**

```
Diagnostic shows:
❌ Issue 1: 2 users have no name
   - test@example.com (student)

↓

Go to Railway Query:
UPDATE users 
SET name = 'Test User' 
WHERE identifier = 'test@example.com';

↓

Run diagnostic again:
✅ No users with missing names
```

---

## 📱 When to Run This

### **Run diagnostics:**

1. **After any deployment** - Verify everything deployed correctly
2. **When users report issues** - See the actual data state
3. **Before major releases** - Health check
4. **After database migrations** - Verify changes applied
5. **When debugging** - Understand current state

---

## 🎬 Quick Start Example

```bash
# Install Railway CLI (first time only)
# Visit: https://docs.railway.app/develop/cli

# Login and link
railway login
railway link

# Run diagnostics
railway run node diagnostic-check.js

# Watch the magic happen! ✨
```

---

## 💡 Pro Tips

1. **Save the output** - Copy/paste to a file for reference
2. **Compare runs** - Run before and after fixes to see changes
3. **Share with team** - Easy way to show system state
4. **Automate** - Add to CI/CD for automatic health checks
5. **Schedule** - Run daily to catch issues early

---

## 🚨 Understanding the Output

### **Green ✅ Means:**
- Everything is working correctly
- No action needed
- System is healthy

### **Yellow ⚠️ Means:**
- Minor issue detected
- Not critical but should be fixed
- System still functional

### **Red ❌ Means:**
- Critical issue found
- Needs immediate attention
- May affect functionality

---

## 📞 What to Do If...

### **"Database Connection FAILED"**
- Check Railway is running
- Check DATABASE_URL is set
- Check network connection

### **"permit_type column MISSING"**
- Run migration: `node run-permit-migration.js`
- Or run SQL: `ALTER TABLE students ADD COLUMN permit_type VARCHAR(10)`

### **"Users with missing names"**
- Run SQL fix provided in output
- Update each user's name

### **"Students approved but NOT active"**
- Critical! Run fix immediately
- SQL: `UPDATE students SET is_active = true WHERE school_approval_status = 'approved'`

---

## ✅ Success Looks Like

When everything is working, you'll see:

```
📊 SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   Total Users: 15
   Total Students: 12
   Total Schools: 3
   Permit System: ✅ Enabled
   Issues Found: 0
   Overall Health: ✅ HEALTHY

🎯 NEXT STEPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   ✅ System is healthy!
   ✅ Ready for production use
   ✅ Test the app on device
```

---

## 🎊 You're All Set!

This tool gives you **X-ray vision** into your system. Use it wisely! 🚀
