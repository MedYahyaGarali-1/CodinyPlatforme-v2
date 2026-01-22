module.exports = {
  secret: process.env.JWT_SECRET,
  accessTokenExpiry: '1h', // Access token expires in 1 hour
  refreshTokenExpiry: '30d', // Refresh token expires in 30 days
};
