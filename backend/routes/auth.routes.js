const express = require('express');
const router = express.Router();

router.post('/register', (req, res) => {
  res.status(200).json({ message: 'Register endpoint - coming in Module 2' });
});

router.post('/login', (req, res) => {
  res.status(200).json({ message: 'Login endpoint - coming in Module 2' });
});

module.exports = router;