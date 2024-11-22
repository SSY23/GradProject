# GradProject


** 프로젝트 디렉토리 구조 **

GradProject/
│
├── config/                    # 설정 파일들
│   └── db.js                  # 데이터베이스 연결 설정
│
├── controllers/               # 컨트롤러 (추가 예정)
│
├── node_modules/              # Node.js 관련 모듈
│
├── routes/                    # API 라우트
│   ├── auth/                  # 인증 관련 라우트
│   ├── closet/                # 옷장 관련 라우트
│   ├── outfit/                # 옷차림 관련 라우트
│   ├── weather/               # 날씨 관련 라우트
│   ├── auth.js                # 인증 라우트
│   ├── closet.js              # 옷장 라우트
│   ├── outfit.js              # 옷차림 라우트
│   └── weather.js             # 날씨 라우트
│
├── uploads/                   # 업로드된 파일들
│
├── .env                       # 환경 변수 파일
├── .gitignore                 # Git 무시 파일
├── package.json               # 프로젝트 의존성 및 설정
├── package-lock.json          # 의존성 고정 파일
├── README.md                  # 프로젝트 설명
└── server.js                  # 서버 설정 및 실행
