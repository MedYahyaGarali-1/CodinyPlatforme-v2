module.exports = {
  secret: process.env.JWT_SECRET,
  expiresIn: '1h', // 1 hour for security
};
