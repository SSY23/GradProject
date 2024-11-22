const express = require('express');
const multer = require('multer');
const axios = require('axios');
const fs = require('fs');
const path = require('path');
const router = express.Router();

const REMOVE_BG_API_KEY = process.env.REMOVE_BG_API_KEY; // 바로 사용 가능

// Multer 설정 - /add 엔드포인트용 (원본 이미지 저장 디렉토리)
const addStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // 원본 이미지 저장 디렉토리
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + '-' + file.originalname); // 고유한 파일 이름 생성
  },
});
const addUpload = multer({ storage: addStorage });

// Multer 설정 - /test 엔드포인트용 (테스트 디렉토리)
const testStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/test/'); // 테스트용 이미지 저장 디렉토리
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + '-' + file.originalname); // 고유한 파일 이름 생성
  },
});
const testUpload = multer({ storage: testStorage });

// /closet/add 엔드포인트
router.post('/add', addUpload.single('image'), async (req, res) => {
  const { user_id, category, name, color, season } = req.body;
  const imageFile = req.file;

  // 요청 유효성 검사
  if (!user_id || !category || !name || !color || !season || !imageFile) {
    return res.status(400).json({ error: 'All fields are required.' });
  }

  try {
    // remove.bg API 호출
    const removeBgResponse = await axios({
      method: 'post',
      url: 'https://api.remove.bg/v1.0/removebg',
      headers: {
        'X-Api-Key': REMOVE_BG_API_KEY,
      },
      data: {
        image_file: fs.createReadStream(imageFile.path),
      },
      responseType: 'arraybuffer',
    });

    const bgRemovedPath = path.join('uploads', `bg-removed-${imageFile.filename}`);
    fs.writeFileSync(bgRemovedPath, removeBgResponse.data);

    // 새로운 아이템 데이터
    const newItem = {
      user_id,
      category,
      name,
      color,
      season: JSON.parse(season),
      original_image_url: `/uploads/${imageFile.filename}`,
      bg_removed_image_url: `/uploads/bg-removed-${imageFile.filename}`,
    };

    // 응답
    res.status(201).json({
      message: 'Item successfully added to the closet!',
      item: newItem,
    });
  } catch (error) {
    console.error('remove.bg API error:', error);
    res.status(500).json({ error: 'Failed to process the image.' });
  }
});

router.post('/test', testUpload.single('image'), async (req, res) => {
  const imageFile = req.file;

  // 요청 유효성 검사
  if (!imageFile) {
    console.log('No image file received');  // 디버깅용 메시지
    return res.status(400).json({ error: '이미지 파일이 필요합니다.' });
  }

  console.log('Received image file:', imageFile);  // 디버깅용 메시지

  try {
    // remove.bg API 호출
    console.log('Calling remove.bg API with image:', imageFile.path);  // 디버깅용 메시지

    const removeBgResponse = await axios({
      method: 'post',
      url: 'https://api.remove.bg/v1.0/removebg',
      headers: {
        'X-Api-Key': REMOVE_BG_API_KEY,
      },
      data: {
        image_file: fs.createReadStream(imageFile.path),
      },
      responseType: 'arraybuffer',
    });

    console.log('remove.bg API response received');  // 디버깅용 메시지

    // 배경이 제거된 이미지 파일 경로 생성
    const bgRemovedPath = path.join('uploads/test', `bg-removed-${imageFile.filename}`);
    fs.writeFileSync(bgRemovedPath, removeBgResponse.data);
    console.log('Background removed image saved to:', bgRemovedPath);  // 디버깅용 메시지

    // 원본 이미지 파일 삭제 (더 이상 필요 없을 경우)
    fs.unlinkSync(imageFile.path);  // 원본 이미지 삭제
    console.log('Original image deleted:', imageFile.path);  // 디버깅용 메시지

    // 응답
    res.status(200).json({
      message: '배경이 제거된 이미지가 성공적으로 처리되었습니다!',
      bg_removed_image_url: `/uploads/test/bg-removed-${imageFile.filename}`,
    });
  } catch (error) {
    console.error('remove.bg API error:', error);  // 디버깅용 메시지
    res.status(500).json({ error: '배경 제거에 실패했습니다.' });
  }
});

module.exports = router;
