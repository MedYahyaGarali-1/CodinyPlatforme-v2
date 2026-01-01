require('dotenv').config();
const authService = require('./services/auth.service');

console.log('authService:', authService);
console.log('Keys:', Object.keys(authService));
console.log('login:', authService.login);
console.log('register:', authService.register);
console.log('Type of login:', typeof authService.login);
