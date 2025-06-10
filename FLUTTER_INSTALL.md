# 🚀 Flutter 설치 가이드 (macOS)

## 자동 설치 스크립트 실행

터미널에서 다음 명령어를 순서대로 실행하세요:

### 1단계: Homebrew로 Flutter 설치 (권장)
```bash
# Homebrew가 없다면 먼저 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Flutter 설치
brew install --cask flutter
```

### 2단계: PATH 환경변수 설정
```bash
# zsh 사용자 (기본)
echo 'export PATH="$PATH:/opt/homebrew/bin/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# bash 사용자인 경우
echo 'export PATH="$PATH:/opt/homebrew/bin/flutter/bin"' >> ~/.bash_profile
source ~/.bash_profile
```

### 3단계: Flutter 설치 확인
```bash
flutter --version
flutter doctor
```

---

## 수동 설치 방법

### 1단계: Flutter SDK 다운로드
```bash
cd ~/Downloads
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.16.5-stable.zip -o flutter.zip
unzip flutter.zip
sudo mv flutter /opt/
```

### 2단계: PATH 설정
```bash
echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

### 3단계: 의존성 설치
```bash
# Xcode Command Line Tools 설치
xcode-select --install

# CocoaPods 설치 (iOS 개발용)
sudo gem install cocoapods
```

---

## Flutter 설치 후 검증

```bash
# Flutter 버전 확인
flutter --version

# 개발 환경 검사
flutter doctor

# 필요한 라이센스 승인
flutter doctor --android-licenses
```

## 일반적인 문제 해결

### 문제 1: PATH 인식 안됨
```bash
# 터미널 재시작 또는
source ~/.zshrc

# PATH 확인
echo $PATH
```

### 문제 2: Android 관련 경고
```bash
# Android Studio 설치 (선택사항)
brew install --cask android-studio

# 또는 Android SDK만 설치
brew install --cask android-commandlinetools
```

### 문제 3: iOS 관련 경고 (macOS만)
```bash
# Xcode 설치 (App Store에서)
# CocoaPods 설치
sudo gem install cocoapods
pod setup
```

---

## 빠른 설치 명령어 (복사해서 실행)

```bash
# 1. Homebrew + Flutter 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && brew install --cask flutter

# 2. PATH 설정
echo 'export PATH="$PATH:/opt/homebrew/bin/flutter/bin"' >> ~/.zshrc && source ~/.zshrc

# 3. 확인
flutter doctor
```

설치 완료 후 다시 `./setup.sh` 실행하세요! 🎉
