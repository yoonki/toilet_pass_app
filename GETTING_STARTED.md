# 🚽 ToiletPass 실행 가이드 (업데이트)

## ⚡ 빠른 시작

### 1단계: Flutter 설치 확인 및 플랫폼 활성화
```bash
flutter --version
flutter doctor

# 웹 및 데스크톱 플랫폼 활성화
flutter config --enable-web
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
```

### 2단계: 프로젝트 의존성 설치
```bash
cd toilet_pass_app
flutter pub get
```

### 3단계: 앱 실행 (다양한 플랫폼)
```bash
# 🌐 Chrome 웹브라우저에서 실행 (권장)
flutter run -d chrome

# 🖥️ macOS 데스크톱에서 실행
flutter run -d macos

# 📱 Android 에뮬레이터/기기 (Android Studio 설치 시)
flutter run -d android

# 📱 iOS 시뮬레이터 (Xcode 설치 시, macOS만)
flutter run -d ios

# 🔍 사용 가능한 모든 기기 확인
flutter devices

# 🎯 자동으로 첫 번째 사용 가능한 기기에서 실행
flutter run
```

## 🌐 웹 브라우저에서 실행 (가장 쉬운 방법)

웹 브라우저에서 실행하면 별도의 모바일 기기나 에뮬레이터 없이도 바로 테스트할 수 있습니다:

```bash
# Chrome에서 실행
flutter run -d chrome

# 웹 배포 버전 빌드
flutter build web

# 빌드된 웹 파일 위치: build/web/
```

**웹 버전 제한사항:**
- 카메라/갤러리 기능 제한됨 (사진 첨부 불가)
- 파일 시스템 접근 제한
- 나머지 모든 기능은 정상 작동

## 🖥️ macOS 데스크톱에서 실행

완전한 기능을 사용하려면 macOS 앱으로 실행하세요:

```bash
# macOS 데스크톱 앱으로 실행
flutter run -d macos

# macOS 앱 빌드
flutter build macos

# 빌드된 앱 위치: build/macos/Build/Products/Release/
```

## 📱 Android/iOS에서 실행

### Android (Android Studio 필요)
```bash
# Android Studio 설치
brew install --cask android-studio

# Android 가상 기기 생성 후
flutter run -d android
```

### iOS (Xcode 필요, macOS만)
```bash
# iOS 시뮬레이터 열기
open -a Simulator

# iOS에서 실행
flutter run -d ios
```

## 🔧 문제 해결

### "No supported devices connected" 오류
```bash
# 1. 웹 및 데스크톱 플랫폼 활성화
flutter config --enable-web
flutter config --enable-macos-desktop

# 2. 의존성 재설치
flutter clean
flutter pub get

# 3. Chrome에서 실행 시도
flutter run -d chrome
```

### 웹에서 SQLite 오류
프로젝트가 자동으로 웹에서는 메모리 데이터베이스를 사용하도록 설정되어 있습니다.

### macOS 권한 문제
macOS에서 실행 시 권한 관련 다이얼로그가 나타나면 '허용'을 선택하세요.

## 🎯 첫 사용법

1. **+** 버튼으로 새 장소 추가
2. 장소 정보 입력 (상호명, 비밀번호 필수)
3. 저장 후 홈 화면에서 확인
4. 비밀번호 부분을 탭하면 자동 복사
5. 하트 아이콘으로 즐겨찾기 추가

## 📊 데이터 관리

### 백업하기
설정 > 데이터 관리 > 데이터 내보내기

### 복원하기  
설정 > 데이터 관리 > 데이터 가져오기

## 🌟 플랫폼별 추천 사용법

### 웹 브라우저 (Chrome)
- 빠른 테스트와 데모용
- 사진 기능 제외한 모든 기능 사용 가능
- 브라우저 북마크에 추가하여 PWA처럼 사용

### macOS 데스크톱
- 완전한 기능 사용 (사진 포함)
- 큰 화면에서 편리한 데이터 관리
- 백업/복원 기능 원활

### 모바일 (Android/iOS)
- 실제 사용 환경과 동일
- GPS 및 카메라 완전 지원
- 최적의 사용자 경험

## 🐛 버그 리포트

문제 발생 시 다음 정보와 함께 이슈 등록:
- 플랫폼 (웹/macOS/Android/iOS)
- Flutter 버전 (`flutter --version`)
- 오류 메시지
- 재현 방법

---

## 🚀 즉시 시작하기

**가장 빠른 방법:**
```bash
cd toilet_pass_app
chmod +x setup.sh
./setup.sh
flutter run -d chrome
```

즐거운 ToiletPass 사용되세요! 🎉
