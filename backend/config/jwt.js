module.exports = {
  secret: process.env.JWT_SECRET,
  expiresIn: '30d', // 30 days - users stay logged in for a month
};
