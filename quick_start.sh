#!/bin/bash

echo "🚽 ToiletPass 즉시 실행 스크립트"
echo "================================"

# 현재 디렉토리 확인
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ pubspec.yaml 파일을 찾을 수 없습니다."
    echo "toilet_pass_app 폴더에서 실행해주세요."
    exit 1
fi

# Flutter 설치 확인
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter가 설치되지 않았습니다."
    echo "FLUTTER_INSTALL.md 파일을 참고하여 Flutter를 먼저 설치해주세요."
    exit 1
fi

echo "✅ Flutter 설치 확인됨"

# 플랫폼 지원 활성화 (에러 무시)
echo "🔧 플랫폼 지원 활성화 중..."
flutter config --enable-web > /dev/null 2>&1
flutter config --enable-macos-desktop > /dev/null 2>&1

# 의존성 설치
echo "📦 의존성 설치 중..."
flutter pub get

# 사용 가능한 기기 확인
echo "📱 사용 가능한 기기 확인 중..."
DEVICES=$(flutter devices --machine 2>/dev/null)

if echo "$DEVICES" | grep -q "chrome"; then
    echo "🌐 Chrome 브라우저에서 실행합니다..."
    flutter run -d chrome
elif echo "$DEVICES" | grep -q "macos"; then
    echo "🖥️ macOS 데스크톱에서 실행합니다..."
    flutter run -d macos
else
    echo "📋 사용 가능한 기기 목록:"
    flutter devices
    echo ""
    echo "🎯 자동으로 첫 번째 기기에서 실행을 시도합니다..."
    flutter run
fi
