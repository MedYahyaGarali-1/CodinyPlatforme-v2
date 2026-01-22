const authService = require('../services/auth.service');

async function register(req, res) {
  try {
    const { name, identifier, password } = req.body;

    if (!name || !identifier || !password) {
      return res.status(400).json({ message: 'Missing fields' });
    }

    const user = await authService.register({
      name,
      identifier,
      password,
    });

    res.status(201).json({ user });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
}

async function login(req, res) {
  try {
    const { identifier, password } = req.body;

    if (!identifier || !password) {
      return res.status(400).json({ message: 'Missing fields' });
    }

    const result = await authService.login({
      identifier,
      password,
    });

    res.json(result);
  } catch (err) {
    res.status(401).json({ message: err.message });
  }
}

async function refreshToken(req, res) {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ message: 'Refresh token required' });
    }

    const result = await authService.refreshAccessToken(refreshToken);

    res.json(result);
  } catch (err) {
    res.status(401).json({ message: err.message });
  }
}

module.exports = {
  register,
  login,
  refreshToken,
};
