import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/place.dart';
import '../models/database_helper.dart';

class AddPlaceScreen extends StatefulWidget {
  final Place? place; // 수정 모드일 때 전달

  const AddPlaceScreen({Key? key, this.place}) : super(key: key);

  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _passwordController;
  late TextEditingController _notesController;
  
  String _selectedCategory = 'cafe';
  int _rating = 3;
  String? _imagePath;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'key': 'cafe', 'name': '☕ 카페', 'icon': Icons.local_cafe, 'color': Colors.brown},
    {'key': 'restaurant', 'name': '🍽️ 음식점', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'key': 'shopping', 'name': '🛍️ 쇼핑몰', 'icon': Icons.shopping_bag, 'color': Colors.purple},
    {'key': 'office', 'name': '🏢 오피스', 'icon': Icons.business, 'color': Colors.blue},
    {'key': 'hospital', 'name': '🏥 병원', 'icon': Icons.local_hospital, 'color': Colors.red},
    {'key': 'other', 'name': '📍 기타', 'icon': Icons.place, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    
    // 수정 모드인지 확인하고 초기값 설정
    final place = widget.place;
    _nameController = TextEditingController(text: place?.name ?? '');
    _addressController = TextEditingController(text: place?.address ?? '');
    _passwordController = TextEditingController(text: place?.password ?? '');
    _notesController = TextEditingController(text: place?.notes ?? '');
    
    if (place != null) {
      _selectedCategory = place.category;
      _rating = place.rating;
      _imagePath = place.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // 웹에서는 이미지 기능 제한
    if (kIsWeb) {
      _showSnackBar('웹 브라우저에서는 사진 기능을 사용할 수 없습니다');
      return;
    }

    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '사진 선택',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildImageOptionCard(
                      icon: Icons.photo_camera,
                      title: '카메라로 촬영',
                      subtitle: '새로운 사진 촬영',
                      onTap: () async {
                        Navigator.of(context).pop();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.camera,
                          maxWidth: 1024,
                          maxHeight: 1024,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          setState(() => _imagePath = image.path);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildImageOptionCard(
                      icon: Icons.photo_library,
                      title: '갤러리에서 선택',
                      subtitle: '기존 사진 선택',
                      onTap: () async {
                        Navigator.of(context).pop();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1024,
                          maxHeight: 1024,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          setState(() => _imagePath = image.path);
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (_imagePath != null) ...[
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: _buildImageOptionCard(
                    icon: Icons.delete,
                    title: '사진 삭제',
                    subtitle: '현재 사진 제거',
                    color: Colors.red,
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() => _imagePath = null);
                    },
                  ),
                ),
              ],
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color ?? Theme.of(context).primaryColor,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePlace() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final place = Place(
        id: widget.place?.id,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        category: _selectedCategory,
        password: _passwordController.text.trim(),
        rating: _rating,
        notes: _notesController.text.trim(),
        imagePath: _imagePath,
        isFavorite: widget.place?.isFavorite ?? false,
        createdAt: widget.place?.createdAt,
      );

      if (widget.place == null) {
        await _dbHelper.insertPlace(place);
        _showSnackBar('✅ 새로운 장소가 성공적으로 저장되었습니다!');
      } else {
        await _dbHelper.updatePlace(place);
        _showSnackBar('✅ 장소 정보가 성공적으로 수정되었습니다!');
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      _showSnackBar('❌ 저장에 실패했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: message.startsWith('✅') 
          ? Colors.green 
          : message.startsWith('❌') 
            ? Colors.red 
            : Theme.of(context).primaryColor,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.place != null;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isEditMode ? '🏢 장소 정보 수정' : '🆕 새로운 장소 추가',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (isEditMode)
            IconButton(
              icon: Icon(Icons.delete_forever, color: Colors.red),
              onPressed: _showDeleteDialog,
              tooltip: '장소 삭제',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 상단 안내 메시지
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      isEditMode ? Icons.edit_location : Icons.add_location_alt,
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      isEditMode ? '장소 정보를 수정하세요' : '새로운 화장실 정보를 등록하세요',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      isEditMode 
                        ? '기존 정보를 수정하여 더 정확한 정보로 업데이트하세요'
                        : '상호명과 비밀번호는 필수 입력 항목입니다',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // 입력 폼
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!kIsWeb) ...[
                      _buildSectionTitle('📷 사진 추가 (선택사항)'),
                      _buildImageSection(),
                      SizedBox(height: 32),
                    ],
                    
                    _buildSectionTitle('🏪 기본 정보'),
                    SizedBox(height: 16),
                    _buildNameField(),
                    SizedBox(height: 20),
                    _buildAddressField(),
                    SizedBox(height: 32),
                    
                    _buildSectionTitle('🏷️ 카테고리 선택'),
                    SizedBox(height: 16),
                    _buildCategorySelection(),
                    SizedBox(height: 32),
                    
                    _buildSectionTitle('🔐 화장실 비밀번호'),
                    SizedBox(height: 16),
                    _buildPasswordField(),
                    SizedBox(height: 32),
                    
                    _buildSectionTitle('⭐ 평점 (깨끗함, 편의성 등)'),
                    SizedBox(height: 16),
                    _buildRatingSection(),
                    SizedBox(height: 32),
                    
                    _buildSectionTitle('📝 추가 메모 (선택사항)'),
                    SizedBox(height: 16),
                    _buildNotesField(),
                    SizedBox(height: 40),
                    
                    _buildSaveButton(),
                  ],
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: _imagePath != null
        ? Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(_imagePath!),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: _pickImage,
                  ),
                ),
              ),
            ],
          )
        : InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    '화장실 사진 추가하기',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '입구나 화장실 위치를 보여주는 사진을 추가하면\n다른 사람들이 찾기 더 쉬워집니다',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: '상호명 (필수)',
        hintText: '예: 스타벅스 강남역점, 맥도날드 홍대점',
        prefixIcon: Icon(Icons.store, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '상호명을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: '주소 (선택사항)',
        hintText: '예: 서울시 강남구 강남대로 123',
        prefixIcon: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildCategorySelection() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = _selectedCategory == category['key'];
        
        return InkWell(
          onTap: () => setState(() => _selectedCategory = category['key']),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? category['color'].withOpacity(0.1) : Colors.grey[50],
              border: Border.all(
                color: isSelected ? category['color'] : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'],
                  color: isSelected ? category['color'] : Colors.grey[600],
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  category['name'],
                  style: TextStyle(
                    color: isSelected ? category['color'] : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      style: TextStyle(fontSize: 16, fontFamily: 'monospace'),
      decoration: InputDecoration(
        labelText: '화장실 비밀번호 (필수)',
        hintText: '예: 1234, #1234*, *1004#, 0000',
        prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        helperText: '숫자, 기호 등 실제 화장실 비밀번호를 정확히 입력하세요',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '화장실 비밀번호를 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 12),
          Text(
            _getRatingText(_rating),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.amber[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '깨끗함, 편의성, 접근성 등을 종합적으로 평가해주세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return '😞 매우 불만족';
      case 2: return '😐 불만족';
      case 3: return '🙂 보통';
      case 4: return '😊 만족';
      case 5: return '🤩 매우 만족';
      default: return '보통';
    }
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 4,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: '추가 메모',
        hintText: '예: 2층에 위치, 비밀번호 입력 후 #누르기, 카운터에서 열쇠 받기',
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 60),
          child: Icon(Icons.note_add, color: Theme.of(context).primaryColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        helperText: '화장실 위치, 사용법, 특이사항 등을 자유롭게 작성하세요',
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _savePlace,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: _isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text('저장 중...', style: TextStyle(fontSize: 16)),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.place == null ? Icons.add_circle : Icons.update,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  widget.place == null ? '새 장소 저장하기' : '수정사항 저장하기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Future<void> _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('장소 삭제'),
            ],
          ),
          content: Text(
            '이 장소를 정말 삭제하시겠습니까?\n\n삭제된 데이터는 복구할 수 없습니다.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                '취소',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                '삭제',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await _dbHelper.deletePlace(widget.place!.id!);
        _showSnackBar('✅ 장소가 성공적으로 삭제되었습니다');
        Navigator.of(context).pop(true);
      } catch (e) {
        _showSnackBar('❌ 삭제에 실패했습니다: $e');
      }
    }
  }
}
