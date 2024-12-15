const express = require('express');
const multer = require('multer');
const axios = require('axios');
const fs = require('fs');
const path = require('path');
const FormData = require('form-data'); // For handling form-data
const db = require('../config/db'); // Database configuration

const router = express.Router();
const upload = multer({ dest: 'uploads/test/' }); // Multer setup for file uploads

// Route: Fetch image_url and category based on user_id
router.get('/images', (req, res) => {
  const userId = req.query.userId;

  // Validate query parameters
  if (!userId) {
    return res.status(400).json({
      success: false,
      message: 'Missing userId in the request query parameters',
    });
  }

  // SQL query to fetch image_url and category
  const query = 'SELECT image_url, category FROM vision_data WHERE user_id = ?';

  db.query(query, [userId], (err, result) => {
    if (err) {
      console.error('Database query error:', err);
      return res.status(500).json({
        success: false,
        message: 'Database query error',
        error: err.message,
      });
    }

    // Respond with the result (empty array if no data)
    res.status(200).json({
      success: true,
      message: result.length > 0 ? 'Data retrieved successfully' : 'No data found for the given userId',
      data: result,
    });
  });
});

module.exports = router;
