const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.status(200).json({ message: 'Payments endpoint - coming in Module 6' });
});

module.exports = router;