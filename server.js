const express = require('express');
const cors = require('cors');
const path = require('path');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const port = 3000;

const server = http.createServer(app);
const io = new Server(server);

require('dotenv').config();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// WebSocket 연결 설정
io.on('connection', (socket) => {
  console.log('WebSocket 연결됨:', socket.id);

  socket.on('disconnect', () => {
    console.log('WebSocket 연결 해제됨:', socket.id);
  });
});

// WebSocket 객체를 다른 파일에서 사용 가능하도록 app에 추가
app.set('io', io);

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
//app.use('/tablet', tabletRoutes);

// 서버 실행
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});