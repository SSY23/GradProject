const express = require('express');
const router = express.Router();
const db = require('../config/db'); // 데이터베이스 설정 파일

module.exports = (wss) => {
  // WebSocket 연결 시
  wss.on('connection', (ws) => {
    console.log('WebSocket 연결됨');

    // 클라이언트로부터 메시지를 받을 때
    ws.on('message', async (message) => {
      console.log('수신된 메시지:', message);
      try {
        const requestData = JSON.parse(message);
        const { action, userId } = requestData;

        if (action === 'fetch_clothes') {
          // 데이터베이스에서 옷 이미지 URL을 가져오는 로직
          const [rows] = await db.execute(
            'SELECT image_url FROM vision_data WHERE user_id = ?',
            [userId]
          );

          if (rows.length > 0) {
            // WebSocket으로 결과 전송
            rows.forEach((row) => {
              ws.send(
                JSON.stringify({
                  action: 'fetch_clothes',
                  success: true,
                  imageUrl: row.image_url,
                })
              );
            });
          } else {
            // 옷장이 비었을 때 처리
            ws.send(
              JSON.stringify({
                action: 'fetch_clothes',
                success: false,
                error: 'No clothes found for this user',
              })
            );
          }
        } else {
          // 알 수 없는 action 처리
          ws.send(
            JSON.stringify({
              error: 'Invalid action',
            })
          );
        }
      } catch (error) {
        console.error('WebSocket 메시지 처리 오류:', error);
        ws.send(
          JSON.stringify({
            error: '서버 처리 오류 발생',
          })
        );
      }
    });

    // WebSocket 연결 종료 시
    ws.on('close', () => {
      console.log('WebSocket 연결 종료');
    });

    // WebSocket 에러 시
    ws.on('error', (error) => {
      console.error('WebSocket 에러:', error);
    });
  });

  return router;
};
