# 💰 Payment System & Security Testing Guide

## Overview
Complete testing guide for payment flows and security validations.

---

## 🔐 Security Rules (IMPORTANT)

### What Schools CAN Do:
✅ Activate their own school-linked students (after cash payment)
✅ View their own students' progress
✅ Manage their own financial reports

### What Schools CANNOT Do:
❌ Activate independent students
❌ Activate students from other schools
❌ View other schools' data

---

## 💳 Payment Methods

### School-Linked Students: In-Person Cash Payment
**Flow:**
1. Student → Pays 50 TND cash at school
2. School → Keeps 20 TND
3. School → Owes platform 30 TND
4. School Admin → Activates student in dashboard
5. Student → Gets immediate access

### Independent Students: Online Payment (Future)
**Flow:**
1. Student → Tries to access features
2. System → Shows "Payment Required" banner
3. Student → Will pay 50 TND online (to be developed)
4. Platform → Gets full 50 TND
5. System → Auto-activates student
6. Student → Gets immediate access

**Current Status:** ⚠️ Online payment NOT implemented yet

---

## 🧪 Test Scenarios

### Scenario 1: School Activates Their Student ✅

**Prerequisites:**
- Student is school-linked
- Student paid 50 TND cash to school
- Student is approved by school

**Steps:**
1. Login as school administrator
2. Go to "Student Management" → "View all students"
3. Find the student who paid
4. Click "Activate" button
5. Wait for confirmation

**Expected Results:**
✓ Success message appears
✓ Student status changes to "Active"
✓ Student subscription valid for 30 days
✓ School finances update:
  - total_earned +20 TND
  - total_owed_to_platform +30 TND
  - total_students +1
✓ Student can now access all features

**Verification:**
```sql
-- Check in database
SELECT subscription_start, subscription_end, payment_verified 
FROM students WHERE id = [STUDENT_ID];
-- Should show dates set

SELECT total_earned, total_owed_to_platform, total_students
FROM schools WHERE id = [SCHOOL_ID];
-- Should show updated amounts
```

---

### Scenario 2: School Tries to Activate Independent Student ❌

**Prerequisites:**
- Student is independent type
- School administrator logged in

**Steps:**
1. Try to activate independent student via:
   - Option A: API call to `/schools/students/activate`
   - Option B: Dashboard action (if button exists)

**Expected Results:**
✓ Request FAILS with 403 error
✓ Error message: "Cannot activate independent students. They must pay online."
✓ Student remains inactive
✓ No changes to database
✓ No financial updates

**Why This Matters:**
- Independent students pay online (50 TND to platform)
- Schools shouldn't handle independent payments
- Prevents financial conflicts

---

### Scenario 3: Independent Student Without Payment ❌

**Prerequisites:**
- Student is independent type
- payment_verified = false
- Student logged into mobile app

**Steps:**
1. Login as independent student
2. Observe dashboard
3. Try to click "Courses"
4. Try to click "Tests"  
5. Try to click "View Calendar"

**Expected Results:**
✓ Banner shows "💳 Payment Required"
✓ Message: "Please complete your subscription payment to access all content"
✓ Clicking "Courses" → Error: "Please complete payment to access courses"
✓ Clicking "Tests" → Error: "Please complete payment to access tests"
✓ Clicking "Calendar" → Error: "Please complete payment to access calendar"
✓ Features are blocked, cannot navigate

**Mobile App Behavior:**
- Dashboard visible but features locked
- Clear payment prompt shown
- User understands they need to pay

---

### Scenario 4: Independent Student After Payment ✅

**Prerequisites:**
- Student is independent type
- payment_verified = true (manually set for testing)

**Simulate Payment:**
```sql
-- Manually verify payment for testing
UPDATE students 
SET payment_verified = true,
    subscription_start = NOW(),
    subscription_end = NOW() + INTERVAL '30 days'
WHERE id = [STUDENT_ID] AND student_type = 'independent';
```

**Steps:**
1. Login as independent student (after payment verified)
2. Observe dashboard
3. Try to click "Courses"
4. Try to click "Tests"
5. Try to click "View Calendar"

**Expected Results:**
✓ NO payment banner shown
✓ Dashboard shows full access
✓ "Courses" opens successfully
✓ "Tests" opens successfully
✓ "View Calendar" opens successfully
✓ Subscription dates visible
✓ All features unlocked

---

### Scenario 5: School-Linked Student (Pending Approval) ⏳

**Prerequisites:**
- Student is school-linked
- school_approval_status = 'pending'
- Student logged into mobile app

**Steps:**
1. Login as pending student
2. Observe dashboard status

**Expected Results:**
✓ Banner shows "⏳ Awaiting School Approval"
✓ Message: "Your school will review your request within 24-48 hours"
✓ Features are blocked until approval
✓ Student cannot access courses/tests yet

---

### Scenario 6: School Tries to Activate Wrong Student ❌

**Prerequisites:**
- Two schools exist: School A and School B
- Student belongs to School B
- Logged in as School A admin

**Steps:**
1. Login as School A administrator
2. Try to activate student from School B

**Expected Results:**
✓ Request FAILS with 403 error
✓ Error message: "Student does not belong to your school"
✓ No activation occurs
✓ Security validation works correctly

---

## 📊 Financial Verification

### Check School Finances

**Query:**
```sql
SELECT 
  name,
  total_students,
  total_earned,              -- Should be 20 TND per activated student
  total_owed_to_platform,    -- Should be 30 TND per activated student
  (total_earned + total_owed_to_platform) as total_collected
FROM schools
WHERE id = [SCHOOL_ID];
```

**Expected Math:**
- If 5 students activated:
  - total_earned = 100 TND (5 × 20)
  - total_owed_to_platform = 150 TND (5 × 30)
  - total_collected = 250 TND (5 × 50)

### Check Student Status

**Query:**
```sql
SELECT 
  first_name,
  last_name,
  student_type,
  payment_verified,
  subscription_start,
  subscription_end,
  school_id,
  school_approval_status
FROM students
WHERE id = [STUDENT_ID];
```

**Validation:**
- School-linked active: subscription dates set, school_id present
- Independent unpaid: payment_verified = false, no subscription dates
- Independent paid: payment_verified = true, subscription dates set

---

## 🔧 Manual Testing Checklist

### Before Production Release:

**Backend Security:**
- [ ] School CAN activate their own students
- [ ] School CANNOT activate independent students (403 error)
- [ ] School CANNOT activate other schools' students (403 error)
- [ ] Financial calculations correct (20/30 split)

**Independent Student Flow:**
- [ ] Shows payment required banner
- [ ] Blocks feature access without payment
- [ ] Allows full access after payment_verified = true
- [ ] Error messages are clear and helpful

**School-Linked Student Flow:**
- [ ] Pending students see waiting message
- [ ] Approved students can be activated by school
- [ ] Activated students get 30-day subscription
- [ ] Financial tracking updates correctly

**Mobile App:**
- [ ] "Renew" button removed from student dashboard
- [ ] "Exam Simulation" replaced with "View Calendar"
- [ ] Currency shows TND (not MAD) in financial reports
- [ ] Payment gates work on all feature buttons

---

## 🚨 Known Limitations

### Not Yet Implemented:
1. **Online Payment Gateway**
   - Independent students cannot actually pay yet
   - Must manually update payment_verified for testing
   - Recommendation: Clictopay (Tunisia Post)

2. **Payment Button**
   - No button to initiate payment
   - Banner shows requirement but no action

3. **Payment Webhooks**
   - No automatic verification after payment
   - Manual database update required

4. **Payment History**
   - No transaction log
   - No receipt generation

### Fully Functional:
1. ✅ School cash payment activation
2. ✅ Financial split calculations (20/30)
3. ✅ Access control (payment gates)
4. ✅ Security validations
5. ✅ Error handling

---

## 📞 Support & Troubleshooting

### Common Issues:

**Issue:** School can't activate student
- ✓ Check: Is student school-linked (not independent)?
- ✓ Check: Does student belong to this school?
- ✓ Check: Is student already active?

**Issue:** Independent student can't access features
- ✓ Check: Is payment_verified = true?
- ✓ Check: Are subscription dates set?
- ✓ Expected: Access blocked until payment

**Issue:** Financial numbers wrong
- ✓ Check: Each activation = +20 school, +30 platform
- ✓ Check: Independent students don't affect school finances
- ✓ Check: total_students count matches activations

---

## 📈 Future Development

### Phase 1: Online Payment (HIGH PRIORITY)
1. Integrate Clictopay or similar gateway
2. Add payment button to independent student dashboard
3. Create payment processing screen
4. Implement webhook for payment verification
5. Auto-set payment_verified after successful payment
6. Send confirmation email/SMS

### Phase 2: Enhanced Tracking
1. Payment transaction history
2. Digital receipt generation
3. Payment failure handling
4. Refund processing

### Phase 3: School Portal
1. Bulk student activation
2. Export financial reports
3. Payment reconciliation dashboard
4. Payment reminder system

---

## 📋 Quick Reference

| Feature | School-Linked | Independent |
|---------|--------------|-------------|
| **Payment Type** | Cash at school | Online (future) |
| **Amount** | 50 TND | 50 TND |
| **Platform Gets** | 30 TND | 50 TND |
| **School Gets** | 20 TND | 0 TND |
| **Who Activates** | School Admin | Auto (after payment) |
| **Status** | ✅ Working | ⚠️ To be developed |

**Security Rules:**
- ✅ Schools activate school-linked students only
- ❌ Schools CANNOT activate independent students
- ✅ Independent students self-activate via online payment
- ✅ All financial data in TND (Tunisian Dinar)
