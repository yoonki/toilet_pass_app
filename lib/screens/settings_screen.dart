import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import '../models/place.dart';
import '../models/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, int> _statistics = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _dbHelper.getStatistics();
      setState(() => _statistics = stats);
    } catch (e) {
      _showSnackBar('통계를 불러오는데 실패했습니다: $e');
    }
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    
    try {
      final places = await _dbHelper.getAllPlaces();
      
      final exportData = {
        'version': '1.0',
        'export_date': DateTime.now().toIso8601String(),
        'app_name': 'ToiletPass',
        'places': places.map((place) => place.toMap()).toList(),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(exportData);
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'toilet_pass_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);
      
      _showSuccessDialog(
        '데이터 내보내기 완료',
        '백업 파일이 저장되었습니다:\n$fileName\n\n총 ${places.length}개의 장소가 백업되었습니다.',
      );
    } catch (e) {
      _showSnackBar('내보내기에 실패했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final data = json.decode(jsonString);

        if (data['places'] == null) {
          _showSnackBar('잘못된 백업 파일 형식입니다');
          return;
        }

        final shouldReplace = await _showImportDialog(data['places'].length);
        if (shouldReplace == null) return;

        setState(() => _isLoading = true);

        if (shouldReplace) {
          // 기존 데이터 삭제 후 가져오기
          await _clearAllData();
        }

        int importedCount = 0;
        for (var placeData in data['places']) {
          try {
            final place = Place.fromMap(placeData);
            await _dbHelper.insertPlace(place.copyWith(id: null));
            importedCount++;
          } catch (e) {
            print('장소 가져오기 실패: $e');
          }
        }

        _loadStatistics();
        _showSuccessDialog(
          '데이터 가져오기 완료',
          '$importedCount개의 장소가 성공적으로 가져왔습니다.',
        );
      }
    } catch (e) {
      _showSnackBar('가져오기에 실패했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showImportDialog(int placeCount) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('데이터 가져오기'),
          content: Text(
            '$placeCount개의 장소를 가져오시겠습니까?\n\n'
            '기존 데이터를 유지하고 추가할지, 기존 데이터를 삭제하고 교체할지 선택해주세요.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('추가'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('교체'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearAllData() async {
    final places = await _dbHelper.getAllPlaces();
    for (var place in places) {
      await _dbHelper.deletePlace(place.id!);
    }
  }

  Future<void> _showClearDataDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('모든 데이터 삭제'),
          content: Text(
            '모든 장소 데이터를 삭제하시겠습니까?\n\n'
            '⚠️ 이 작업은 되돌릴 수 없습니다.\n'
            '백업을 먼저 진행하는 것을 권장합니다.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('삭제'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() => _isLoading = true);
      try {
        await _clearAllData();
        _loadStatistics();
        _showSnackBar('모든 데이터가 삭제되었습니다');
      } catch (e) {
        _showSnackBar('데이터 삭제에 실패했습니다: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _showSuccessDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatisticsSection(),
                SizedBox(height: 24),
                _buildDataManagementSection(),
                SizedBox(height: 24),
                _buildAboutSection(),
              ],
            ),
          ),
    );
  }

  Widget _buildStatisticsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  '사용 통계',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildStatItem('전체 장소', _statistics['total']?.toString() ?? '0', Icons.place),
            _buildStatItem('즐겨찾기', _statistics['favorites']?.toString() ?? '0', Icons.favorite),
            Divider(),
            Text(
              '카테고리별 통계',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            _buildStatItem('카페', _statistics['cafe']?.toString() ?? '0', Icons.local_cafe),
            _buildStatItem('음식점', _statistics['restaurant']?.toString() ?? '0', Icons.restaurant),
            _buildStatItem('쇼핑몰', _statistics['shopping']?.toString() ?? '0', Icons.shopping_bag),
            _buildStatItem('오피스', _statistics['office']?.toString() ?? '0', Icons.business),
            _buildStatItem('병원', _statistics['hospital']?.toString() ?? '0', Icons.local_hospital),
            _buildStatItem('기타', _statistics['other']?.toString() ?? '0', Icons.more_horiz),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  '데이터 관리',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text('데이터 내보내기'),
              subtitle: Text('모든 장소 데이터를 JSON 파일로 백업'),
              onTap: _exportData,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.download),
              title: Text('데이터 가져오기'),
              subtitle: Text('JSON 백업 파일에서 데이터 복원'),
              onTap: _importData,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red),
              title: Text('모든 데이터 삭제'),
              subtitle: Text('저장된 모든 장소 데이터 삭제'),
              onTap: _showClearDataDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  '앱 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Text('🚽', style: TextStyle(fontSize: 24)),
              title: Text('ToiletPass'),
              subtitle: Text('버전 1.0.0'),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '개발자 정보',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('화장실 비밀번호 공유 앱', style: TextStyle(color: Colors.grey[600])),
                  Text('로컬 저장소 기반 완전 오프라인 지원', style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 16),
                  Text(
                    '💡 사용팁',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• 비밀번호를 탭하면 자동으로 복사됩니다', style: TextStyle(color: Colors.grey[600])),
                  Text('• 하트 아이콘으로 즐겨찾기 관리가 가능합니다', style: TextStyle(color: Colors.grey[600])),
                  Text('• 정기적으로 데이터를 백업하는 것을 권장합니다', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
