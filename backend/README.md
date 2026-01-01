# Codiny Platform Backend

Backend API for the Codiny Platform - A comprehensive driving exam training platform for students and schools in Tunisia.

## Features

- 🔐 JWT Authentication (Students, Schools, Admin)
- 👨‍🎓 Student Management
- 🏫 School Management
- 📚 Course & Exam System
- 💰 Subscription & Payment Tracking
- 📊 Financial Reports for Schools
- 📅 Student Calendar Management

## Tech Stack

- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **PostgreSQL** - Database
- **JWT** - Authentication
- **bcrypt** - Password hashing

## Prerequisites

- Node.js (v18 or higher)
- PostgreSQL (v13 or higher)

## Installation

1. Clone the repository
```bash
git clone <your-repo-url>
cd backend
```

2. Install dependencies
```bash
npm install
```

3. Set up environment variables
```bash
cp .env.example .env
# Edit .env with your database credentials
```

4. Start the server
```bash
# Development mode
npm run dev

# Production mode
npm start
```

## Environment Variables

```env
# Server
PORT=3000
NODE_ENV=production

# Database (Railway provides DATABASE_URL automatically)
DATABASE_URL=postgresql://user:password@host:5432/database

# Or use individual params for local development
DB_HOST=localhost
DB_PORT=5432
DB_NAME=driving_exam
DB_USER=postgres
DB_PASSWORD=yourpassword

# JWT
JWT_SECRET=your_super_secret_key
```

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login
- `GET /auth/me` - Get current user

### Students (Protected)
- `GET /students/me` - Get student profile
- `GET /students/courses` - Get student courses
- `GET /students/exams` - Get student exams

### Schools (Protected)
- `GET /schools/me` - Get school profile
- `GET /schools/students` - Get school students
- `POST /schools/students/activate` - Activate student subscription

### Admin (Protected)
- `GET /admin/schools` - Get all schools
- `POST /admin/schools` - Create new school
- `GET /admin/students` - Get all students

## Deployment

### Railway.app (Recommended)

1. Push to GitHub
```bash
git add .
git commit -m "Ready for deployment"
git push origin main
```

2. Visit [railway.app](https://railway.app)
3. Click "New Project" → "Deploy from GitHub"
4. Select your repository
5. Add PostgreSQL database
6. Set environment variables (JWT_SECRET)
7. Deploy! 🚀

Railway automatically provides `DATABASE_URL` from the PostgreSQL service.

## Database Schema

- **users** - User accounts (students, schools, admin)
- **students** - Student profiles & subscription info
- **schools** - School profiles
- **courses** - Course content
- **exams** - Exam questions & results
- **subscriptions** - Payment & subscription tracking
- **student_events** - Calendar events for students

## Payment Logic

### School-Linked Students
- Payment: 50 TND cash at school
- Platform receives: 30 TND
- School receives: 20 TND
- Activation: School activates via dashboard

### Independent Students
- Payment: 50 TND online (to be implemented)
- Platform receives: 50 TND
- Activation: Automatic after payment verification

## Security

- ✅ JWT token authentication (1-hour expiry)
- ✅ Password hashing with bcrypt
- ✅ Role-based access control
- ✅ Schools can only activate their own students
- ✅ Schools cannot activate independent students

## License

ISC

## Support

For issues or questions, contact: [Your Email]
