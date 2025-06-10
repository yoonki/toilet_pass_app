#!/bin/bash

# ToiletPass 프로젝트 셋업 스크립트

echo "🚽 ToiletPass Flutter 프로젝트 셋업을 시작합니다..."

# Flutter 설치 확인
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter가 설치되지 않았습니다."
    echo "Flutter 설치: https://flutter.dev/docs/get-started/install"
    echo "또는 FLUTTER_INSTALL.md 파일을 참고하세요."
    exit 1
fi

echo "✅ Flutter 설치 확인됨"

# 플랫폼 지원 활성화
echo "🔧 플랫폼 지원을 활성화합니다..."
flutter config --enable-web
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop

# 의존성 설치
echo "📦 의존성을 설치합니다..."
flutter pub get

# Flutter Doctor 실행
echo "🔍 Flutter 환경을 검사합니다..."
flutter doctor

# 사용 가능한 기기 확인
echo "📱 사용 가능한 기기를 확인합니다..."
flutter devices

echo ""
echo "🎉 설정이 완료되었습니다!"
echo ""
echo "📱 앱을 실행하려면:"
echo "   flutter run -d chrome    (Chrome 웹브라우저)"
echo "   flutter run -d macos     (macOS 데스크톱)"
echo "   flutter run              (사용 가능한 첫 번째 기기)"
echo ""
echo "🔧 빌드하려면:"
echo "   flutter build web        (웹 배포용)"
echo "   flutter build macos      (macOS 앱)"
echo ""
echo "📖 자세한 사용법은 GETTING_STARTED.md를 참고하세요."
