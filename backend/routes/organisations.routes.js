const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.status(200).json({ message: 'Organisations endpoint - coming in Module 4' });
});

module.exports = router;