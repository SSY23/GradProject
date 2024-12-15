const express = require('express');
const multer = require('multer');
const axios = require('axios');
const fs = require('fs');
const path = require('path');
const FormData = require('form-data');  // form-data 패키지 임포트

const testUpload = require('multer')({ dest: 'uploads/test/' }); 
const db = require('../config/db'); 
const router = express.Router();

const REMOVE_BG_API_KEY = process.env.REMOVE_BG_API_KEY;
const STYLE_API_KEY = process.env.STYLE_API_KEY;

const analyzeImage = async (imageUrl) => {
  const endpoint = `https://vision.googleapis.com/v1/images:annotate?key=${STYLE_API_KEY}`;

  const requestBody = {
    "requests": [
      {
        "image": {
          "source": { "imageUri": imageUrl }
        }, 
        "features": [
          {
            "type": "LABEL_DETECTION",
            "maxResults": 10
          },
          {
            "type": "OBJECT_LOCALIZATION",
            "maxResults": 2
          },
          {
            "type": "IMAGE_PROPERTIES" // 색상 정보를 포함
          }
        ]
      }
    ]
  };

  try {
    const response = await axios.post(endpoint, requestBody, {
      headers: { "Content-Type": "application/json" }
    });

    // 반환 데이터 디버깅
    console.log('Google Vision API 응답:', response.data);

    return response.data.responses[0]; // 첫 번째 요청의 응답만 반환
  } catch (error) {
    console.error('Google Vision API 호출 실패:', error);
    throw new Error('Google Vision API 호출 실패');
  }
};


router.get('/images', (req, res) => {
  const userId = req.query.userId;

  // Query to fetch image URLs based on userId
  const query = 'SELECT image_url FROM vision_data WHERE user_id = ?';

  db.query(query, [userId], (err, result) => {
    if (err) {
      console.error('Database query error:', err);
      return res.status(500).json({
        success: false,
        message: 'Database query error',
        error: err.message // Return detailed error message
      });
    }

    // If no images are found, send an empty array, not an error
    res.status(200).json({
      success: true,
      message: result.length > 0 ? 'Images retrieved successfully' : 'No images found for the given userId',
      data: result // This will be an empty array if no images are found
    });
  });
});

router.post('/bgremoved', testUpload.single('image'), async (req, res) => {
  const imageFile = req.file;

  // 요청 유효성 검사
  if (!imageFile) {
    console.log('No image file received');  // 디버깅용 메시지
    return res.status(400).json({ error: '이미지 파일이 필요합니다.' });
  }

  console.log('Received image file:', imageFile);  // 디버깅용 메시지

  try {
    // remove.bg API 호출을 위한 FormData 생성
    const form = new FormData();
    form.append('image_file', fs.createReadStream(imageFile.path));

    // FormData의 헤더 추출
    const headers = form.getHeaders();
    headers['X-Api-Key'] = REMOVE_BG_API_KEY; // API 키 추가

    console.log('Calling remove.bg API with image:', imageFile.path);  // 디버깅용 메시지

    // remove.bg API 호출
    const removeBgResponse = await axios.post('https://api.remove.bg/v1.0/removebg', form, {
      headers: headers, 
      responseType: 'arraybuffer' // 이미지 데이터를 배열로 받음
    });

    console.log('remove.bg API response received');  // 디버깅용 메시지

    // 배경이 제거된 이미지 파일 경로 생성
    const bgRemovedPath = path.join('uploads/test', `bg-removed-${imageFile.filename}.jpg`);
    fs.writeFileSync(bgRemovedPath, removeBgResponse.data);
    console.log('Background removed image saved to:', bgRemovedPath);  // 디버깅용 메시지

    // 원본 이미지 파일 삭제 (더 이상 필요 없을 경우)
    fs.unlinkSync(imageFile.path);  // 원본 이미지 삭제
    console.log('Original image deleted:', imageFile.path);  // 디버깅용 메시지

    // 서버 URL을 동적으로 생성
    const serverUrl = req.protocol + '://' + req.get('host');

    // 배경이 제거된 이미지 URL 생성
    const bgRemovedImageUrl = `${serverUrl}/uploads/test/bg-removed-${imageFile.filename}.jpg`;
    
    const bgRemovedImageUrl2 = `https://localhost:3000/uploads/test/bg-removed-${imageFile.filename}.jpg`;

    // Google Vision API 호출
    const visionData = await analyzeImage(bgRemovedImageUrl2);

    // labels와 objects 데이터 추출
    const labels = visionData.labelAnnotations?.map((label) => label.description) || [];
    const objects = visionData.localizedObjectAnnotations?.map((obj) => obj.name) || [];
    const colors = visionData.imagePropertiesAnnotation?.dominantColors.colors.map((color) => ({
      red: color.color.red,
      green: color.color.green,
      blue: color.color.blue,
      score: color.score, // 색상의 비율
    })) || [];
    console.log('Labels:', labels); // 라벨 정보
    console.log('Objects:', objects); // 객체 정보
    console.log('Colors:', colors); // 색상 정보

    // 프론트엔드로 반환
    res.status(200).json({
      message: '이미지 처리 및 분석 완료',
      bg_removed_image_url: bgRemovedImageUrl,
    });
  } catch (error) {
    console.error('이미지 분석 실패:', error);
    res.status(500).json({ error: '이미지 분석에 실패했습니다.' });
  }
});

router.post('/styles', async (req, res) => {
  const { userId, imageUrl, styles } = req.body;

  // 요청 유효성 검사
  if (!userId || !imageUrl || !styles || !Array.isArray(styles) || styles.length === 0) {
    return res.status(400).json({ error: '모든 필드를 정확히 입력해 주세요.' });
  }

  try {
    // 스타일과 컬럼 매핑
    const styleMap = {
      minimal: '미니멀',
      casual: '캐주얼',
      lovely: '러블리',
      street: '스트릿',
      modern: '모던',
      vintage: '빈티지',
    };

    // 1. Vision 데이터 저장
    const [visionResult] = await db.execute(
      'INSERT INTO vision_data (user_id, image_url) VALUES (?, ?)',
      [userId, imageUrl]
    );
    const visionId = visionResult.insertId; // 생성된 vision_data ID

    // 2. Styles 데이터 저장
    const columns = Object.keys(styleMap);
    const values = columns.map((column) => (styles.includes(styleMap[column]) ? true : false));

    // 컬럼 업데이트 쿼리 생성
    const updateQuery = `
      UPDATE vision_data
      SET ${columns.map((col) => `${col} = ?`).join(', ')}
      WHERE id = ?;
    `;
    
    // 쿼리 실행
    await db.execute(updateQuery, [...values, visionId]);

    console.log('Vision data and styles successfully saved');

    // 응답
    res.status(201).json({
      message: 'Vision data and styles successfully saved!',
      vision_data: {
        id: visionId,
        user_id: userId,
        image_url: imageUrl,
        styles: columns.reduce((result, column, index) => {
          result[column] = values[index];
          return result;
        }, {}),
      },
    });
  } catch (error) {
    console.error('Error saving vision data and styles:', error);
    res.status(500).json({ error: 'Vision data와 스타일 저장에 실패했습니다.' });
  }
});

module.exports = router;