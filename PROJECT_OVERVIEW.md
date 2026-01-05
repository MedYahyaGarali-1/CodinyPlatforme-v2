# Codiny Platform - Project Overview

## 🎯 What is Codiny Platform?

**Codiny Platform** is a modern mobile learning application for driving license education in Tunisia. It connects students preparing for their driving license with driving schools through a digital platform.

---

## 💡 The Concept

### For Students
- Register and choose permit type (A-Motorcycle, B-Car, C-Truck)
- Learn driving theory with interactive courses
- Take practice exams with real traffic signs
- Track progress and view school calendar

### For Driving Schools
- Search and activate students digitally
- Earn revenue for each activated student
- Create events and manage calendars
- Track earnings and student statistics

---

## 💰 Business Model

**Simple Activation Fee**: 50 TND per student
- 🏫 20 TND → Driving School
- 🚀 30 TND → Platform

**No subscriptions** - Schools activate students directly, students pay schools offline.

---

## 🛠 Technology Stack

### Mobile App
- **Framework**: Flutter (Android & iOS ready)
- **Design**: Modern Material Design 3
- **Features**: Offline support, push notifications (coming)

### Backend
- **Server**: Node.js + Express
- **Database**: PostgreSQL
- **Hosting**: Railway (auto-deploy)
- **API**: RESTful with JWT authentication

---

## ✨ Key Features

### 🎓 Learning System
- ✅ Interactive courses with images and videos
- ✅ Practice exams with timer and scoring
- ✅ Progress tracking
- ✅ Three permit types: A (Moto), B (Car), C (Truck)
  - Currently: Permit B content is complete
  - Coming: Permit A & C content

### 🏫 School Management
- ✅ Student search and activation
- ✅ Revenue dashboard with real-time stats
- ✅ Event calendar management
- ✅ Student list with status tracking

### 🔐 Security & Access
- ✅ JWT authentication
- ✅ Role-based access control
- ✅ Secure payment tracking
- ✅ Data encryption

---

## 📊 Current Status

### ✅ Completed
- Full authentication system
- Permit selection (A/B/C)
- Student activation by schools
- Revenue tracking system
- Courses and exams (Permit B)
- School dashboard with statistics
- Event calendar
- Access control system

### 🚧 In Progress
- APK rebuild with latest fixes
- Final testing phase

### 🔮 Coming Soon
- Content for Permit A & C
- Push notifications
- Offline mode
- iOS version
- Multi-language support (Arabic, French, English)

---

## 🎨 User Experience

### Student Journey
```
1. Register → Choose Permit Type → Wait for School
2. School Activates → Full Access to Content
3. Study Courses → Take Exams → Pass License!
```

### School Journey
```
1. Register as School → Setup Profile
2. Student Visits School → Search by Student ID
3. Activate Student → Earn 20 TND → Student Can Learn
```

---

## 📱 Permit Types

| Type | Vehicle | Status |
|------|---------|--------|
| 🏍️ **Permit A** | Motorcycle | 🚧 Coming Soon |
| 🚗 **Permit B** | Car | ✅ Available |
| 🚛 **Permit C** | Truck | 🚧 Coming Soon |

---

## 🌍 Market

- **Target Market**: Tunisia
- **Target Audience**: Driving license candidates (ages 18-60)
- **Partners**: Tunisian driving schools
- **Language**: French & Arabic
- **Currency**: Tunisian Dinar (TND)

---

## 🔒 Why Schools Will Love It

1. **Digital Transformation** - Modernize school operations
2. **Extra Revenue** - 20 TND per student with zero overhead
3. **Student Management** - Easy tracking and activation
4. **Professional Image** - Modern app for students
5. **Calendar System** - Better student communication

---

## 🚀 Why Students Will Love It

1. **Modern Learning** - Interactive courses, not boring PDFs
2. **Practice Exams** - Real exam simulation with scoring
3. **Progress Tracking** - Know exactly where you stand
4. **Event Calendar** - Never miss a driving session
5. **Mobile First** - Learn anywhere, anytime

---

## 📈 Growth Potential

### Phase 1 (Current)
- Launch with Permit B content
- Partner with 10-20 schools in Tunis
- Target: 500-1,000 students in first 6 months

### Phase 2 (3-6 months)
- Add Permit A & C content
- Expand to other cities
- Target: 5,000+ students

### Phase 3 (1 year+)
- iOS version
- International expansion (Morocco, Algeria)
- White-label solution for schools

---

## 💻 Technical Highlights

### Architecture
- **Scalable**: Cloud-hosted with auto-scaling
- **Fast**: Optimized API with caching
- **Secure**: Industry-standard encryption
- **Reliable**: 99.9% uptime guarantee

### API Endpoints
```
Authentication: /api/auth/*
Students: /api/students/*
Schools: /api/schools/*
Courses: /api/courses/*
Exams: /api/exams/*
Events: /api/events/*
```

### Database
- PostgreSQL with optimized indexes
- Automated daily backups
- Revenue tracking table
- User activity logs

---

## 📞 Deployment

### Current Setup
- **Backend**: Live on Railway
- **URL**: https://codinyplatforme-v2-production.up.railway.app
- **Database**: PostgreSQL on Railway
- **CI/CD**: Auto-deploy on GitHub push

### Mobile App
- **Android**: APK ready for distribution
- **iOS**: Coming soon
- **Size**: ~50MB
- **Minimum**: Android 5.0+

---

## 📊 Revenue Projections

### Conservative Scenario
- 20 partner schools
- 50 students per school/year
- **Total**: 1,000 students/year
- **Platform Revenue**: 30,000 TND/year
- **School Revenue**: 20,000 TND/year/school

### Growth Scenario
- 100 partner schools
- 100 students per school/year
- **Total**: 10,000 students/year
- **Platform Revenue**: 300,000 TND/year
- **School Revenue**: 40,000 TND/year/school

---

## 🎯 Competitive Advantages

1. **School-Centric Model** - Schools control activation
2. **Fair Revenue Split** - Win-win for everyone
3. **Modern Technology** - Flutter = Native performance
4. **Full Tunisian Focus** - Local content, local signs
5. **Easy Integration** - Schools need zero tech knowledge

---

## 🛣 Roadmap

### Q1 2026
- ✅ Complete Permit B content
- ✅ School dashboard
- ✅ Revenue tracking
- 🚧 Official launch

### Q2 2026
- Permit A & C content
- Push notifications
- 20+ partner schools

### Q3-Q4 2026
- iOS version
- Offline mode
- Multi-language
- 50+ partner schools

---

## 👥 Team & Development

### Current State
- Fully functional MVP
- Backend deployed and stable
- Mobile app tested and working
- Ready for market testing

### Technology Choices
- **Flutter**: Fast development, native performance
- **Node.js**: Scalable, modern backend
- **PostgreSQL**: Reliable, proven database
- **Railway**: Easy deployment, auto-scaling

---

## 📝 Summary

**Codiny Platform** is a complete digital solution for driving license education in Tunisia. It modernizes how students learn and how schools manage their students, creating value for both sides.

**Key Numbers**:
- 3 permit types (A, B, C)
- 50 TND activation fee
- 20/30 TND revenue split
- 100% digital workflow
- 0 technical knowledge required for schools

**Status**: Ready for launch with Permit B content complete. Expanding to Permits A & C in next phase.

---

## 🔗 Links

- **Repository**: GitHub - CodinyPlatforme-v2
- **Backend**: https://codinyplatforme-v2-production.up.railway.app
- **Documentation**: See CAHIER_DES_CHARGES.md for full technical specs

---

## 📧 Next Steps

Interested in partnering or learning more?

1. **For Investors**: Contact for business plan and projections
2. **For Schools**: Contact for demo and partnership details
3. **For Developers**: See technical documentation in repository

---

*Last Updated: January 5, 2026*
*Version: 1.0 - MVP Ready*

---

**Built with ❤️ for Tunisian Drivers**
