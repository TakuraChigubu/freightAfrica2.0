const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.status(200).json({ message: 'Users endpoint - coming in Module 3' });
});

module.exports = router;