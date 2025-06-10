class AppConstants {
  // 앱 정보
  static const String appName = 'ToiletPass';
  static const String appVersion = '1.0.0';
  
  // 카테고리
  static const Map<String, String> categories = {
    'cafe': '☕ 카페',
    'restaurant': '🍽️ 음식점',
    'shopping': '🛍️ 쇼핑몰',
    'office': '🏢 오피스빌딩',
    'hospital': '🏥 병원',
    'other': '📍 기타',
  };
  
  // 색상
  static const Map<String, int> categoryColors = {
    'cafe': 0xFF795548,      // Brown
    'restaurant': 0xFFFF9800, // Orange
    'shopping': 0xFF9C27B0,   // Purple
    'office': 0xFF2196F3,     // Blue
    'hospital': 0xFFF44336,   // Red
    'other': 0xFF9E9E9E,      // Grey
  };
  
  // 기본값
  static const int defaultRating = 3;
  static const String defaultCategory = 'cafe';
  
  // 파일 관련
  static const String backupFilePrefix = 'toilet_pass_backup_';
  static const String backupFileExtension = '.json';
  
  // 메시지
  static const String passwordCopiedMessage = '비밀번호가 클립보드에 복사되었습니다';
  static const String favoriteAddedMessage = '즐겨찾기에 추가되었습니다';
  static const String favoriteRemovedMessage = '즐겨찾기에서 제거되었습니다';
  static const String placeSavedMessage = '장소가 저장되었습니다';
  static const String placeUpdatedMessage = '장소 정보가 수정되었습니다';
  static const String placeDeletedMessage = '장소가 삭제되었습니다';
}
