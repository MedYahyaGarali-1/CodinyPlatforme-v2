const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth.routes');
const studentRoutes = require('./routes/student.routes');
const onboardingRoutes = require('./routes/onboarding.routes');
const schoolRoutes = require('./routes/school.routes');
const subscriptionRoutes = require('./routes/subscription.routes');
const adminRoutes = require('./routes/admin.routes');
const examRoutes = require('./routes/exam.routes');

const app = express();

app.use(cors());
app.use(express.json());
app.use('/auth', authRoutes);
app.use('/students', studentRoutes);
app.use('/students', onboardingRoutes);
app.use('/schools', schoolRoutes);
app.use('/subscriptions', subscriptionRoutes);
app.use('/admin', adminRoutes);
app.use('/exams', examRoutes);

app.get('/', (req, res) => {
  res.send('Driving Exam API is running');
});

module.exports = app;

