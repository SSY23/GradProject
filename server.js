const express = require('express');
const cors = require('cors');
const path = require('path');
const http = require('http');
const WebSocket = require('ws');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

require('dotenv').config();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// WebSocket
wss.on('connection',(ws)=> {
  console.log('WebSocket 연결 성공');

  ws.on('message',(message) => {
    console.log('Received :', message);
    ws.send('메시지 수신 완료: ' + message);
  });

  ws.on('close',()=>{
    console.log('WebSocket 연결 종료');
  });
});

// 본 페이지
app.get('/', (req, res) => {
    res.send('Welcome to WEarly!');
  });
  
// 라우터 불러오기
const authRoutes = require('./routes/auth');
const weatherRoutes = require('./routes/weather');
const outfitRoutes = require('./routes/outfit');
const closetRoutes = require('./routes/closet');
//const tabletRoutes = require('./routes/tablet');

// 라우터 사용
app.use('/auth', authRoutes);
app.use('/weather', weatherRoutes);
app.use('/outfit', outfitRoutes);
app.use('/closet', closetRoutes);
app.use('/tablet', require('./routes/tablet')(wss));

// 서버 실행
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});

module.exports = { wss };