const { Server } = require('socket.io');
const http = require('http');
const db = require('../config/db');
const app = require('../server');  // 이미 server.js에서 생성된 express app
const server = http.createServer(app);  // HTTP 서버 생성

const io = new Server(server);  // WebSocket 서버 생성

// WebSocket 연결 관리
io.on('connection', (socket) => {
  console.log('클라이언트 WebSocket 연결됨:', socket.id);

  socket.on('message', async (message) => {
    console.log('수신된 메시지:', message);
    try {
      const requestData = JSON.parse(message);
      const { action, userId } = requestData;

      if (action === 'fetch_clothes') {
        // 옷 데이터베이스 조회
        const [rows] = await db.execute(
          'SELECT image_url FROM vision_data WHERE user_id = ?',
          [userId]
        );

        // WebSocket으로 응답 전송
        rows.forEach((row) => {
          socket.send(
            JSON.stringify({
              imageUrl: row.image_url,
            })
          );
        });
      } else {
        socket.send(JSON.stringify({ error: 'Invalid action' }));
      }
    } catch (error) {
      console.error('WebSocket 메시지 처리 오류:', error);
      socket.send(JSON.stringify({ error: '서버 처리 오류 발생' }));
    }
  });

  socket.on('disconnect', () => {
    console.log('클라이언트 WebSocket 연결 종료:', socket.id);
  });

  socket.on('error', (error) => {
    console.error('WebSocket 에러:', error);
  });
});

// WebSocket 서버 실행
server.listen(3001, () => {
  console.log('WebSocket 서버가 3001 포트에서 실행 중입니다.');
});
