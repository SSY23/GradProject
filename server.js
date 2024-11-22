const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const port = 3000;

require('dotenv').config();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// 본 페이지
app.get('/', (req, res) => {
    res.send('Welcome to WEarly!');
  });
  
// 라우터 불러오기
const authRoutes = require('./routes/auth');
const weatherRoutes = require('./routes/weather');
//const outfitRoutes = require('./routes/outfit');
const closetRoutes = require('./routes/closet');

// 라우터 사용
app.use('/auth', authRoutes);
app.use('/weather', weatherRoutes);
//app.use('/outfit', outfitRoutes);
app.use('/closet', closetRoutes);



// 서버 실행
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
