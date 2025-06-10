# 🚽 ToiletPass

화장실 비밀번호를 저장하고 공유하는 Flutter 앱입니다.

## 🚀 시작하기

### 필수 조건
- Flutter SDK 3.0.0 이상
- Dart 3.0.0 이상
- Android Studio / Xcode (플랫폼별)

### 설치 및 실행

1. **의존성 설치**
```bash
flutter pub get
```

2. **앱 실행**
```bash
# Android
flutter run

# iOS  
flutter run -d ios

# 특정 기기 지정
flutter devices
flutter run -d [device-id]
```

3. **빌드**
```bash
# Android APK
flutter build apk

# iOS
flutter build ios
```

## 📱 주요 기능

- **로컬 저장소**: SQLite 기반 완전 오프라인 지원
- **사진 첨부**: 카메라/갤러리에서 사진 추가
- **검색 및 필터**: 카테고리별 분류 및 텍스트 검색  
- **즐겨찾기**: 자주 사용하는 장소 북마크
- **데이터 백업**: JSON 파일로 내보내기/가져오기
- **비밀번호 복사**: 원터치 클립보드 복사

## 🏗️ 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── place.dart           # 장소 모델
│   └── database_helper.dart # SQLite 헬퍼
├── screens/                  # 화면
│   ├── home_screen.dart     # 홈 화면
│   ├── add_place_screen.dart # 장소 추가/수정
│   ├── favorites_screen.dart # 즐겨찾기
│   └── settings_screen.dart  # 설정
├── widgets/                  # 위젯
│   ├── place_card.dart      # 장소 카드
│   └── search_bar.dart      # 검색바
└── utils/                    # 유틸리티
    └── constants.dart        # 상수
```

## 🔧 문제 해결

### 권한 오류
Android에서 카메라나 저장소 권한 오류가 발생하면:
1. 앱 설정에서 권한 허용
2. 앱 재시작

### 빌드 오류
```bash
flutter clean
flutter pub get
flutter run
```

### 데이터베이스 초기화
설정 > 모든 데이터 삭제로 데이터베이스 재설정 가능

## 📄 라이선스

MIT License

## 🤝 기여하기

1. Fork 프로젝트
2. Feature 브랜치 생성
3. 변경사항 커밋
4. Pull Request 생성

## 📞 연락처

이슈나 문의사항이 있으시면 GitHub Issues를 이용해주세요.
