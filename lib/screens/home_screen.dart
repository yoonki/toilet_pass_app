import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/place.dart';
import '../models/database_helper.dart';
import '../widgets/place_card.dart';
import '../widgets/search_bar.dart';
import 'add_place_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Place> _places = [];
  List<Place> _filteredPlaces = [];
  String _searchQuery = '';
  String _selectedCategory = 'all';
  bool _isLoading = false;
  late TabController _tabController;

  final List<Map<String, dynamic>> _categories = [
    {'key': 'all', 'name': '전체', 'icon': Icons.apps},
    {'key': 'cafe', 'name': '카페', 'icon': Icons.local_cafe},
    {'key': 'restaurant', 'name': '음식점', 'icon': Icons.restaurant},
    {'key': 'shopping', 'name': '쇼핑몰', 'icon': Icons.shopping_bag},
    {'key': 'office', 'name': '오피스', 'icon': Icons.business},
    {'key': 'hospital', 'name': '병원', 'icon': Icons.local_hospital},
    {'key': 'other', 'name': '기타', 'icon': Icons.place},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPlaces();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    setState(() => _isLoading = true);
    try {
      final places = await _dbHelper.getAllPlaces();
      setState(() {
        _places = places;
        _filterPlaces();
      });
    } catch (e) {
      _showSnackBar('데이터를 불러오는데 실패했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterPlaces() {
    List<Place> filtered = _places;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((place) =>
        place.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        place.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        place.notes.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_selectedCategory != 'all') {
      filtered = filtered.where((place) => place.category == _selectedCategory).toList();
    }

    setState(() => _filteredPlaces = filtered);
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _filterPlaces();
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    _filterPlaces();
  }

  Future<void> _copyPassword(String password) async {
    await Clipboard.setData(ClipboardData(text: password));
    _showSnackBar('비밀번호가 클립보드에 복사되었습니다: $password');
  }

  Future<void> _toggleFavorite(Place place) async {
    try {
      await _dbHelper.toggleFavorite(place.id!, !place.isFavorite);
      _loadPlaces();
      _showSnackBar(place.isFavorite ? '즐겨찾기에서 제거되었습니다' : '즐겨찾기에 추가되었습니다');
    } catch (e) {
      _showSnackBar('즐겨찾기 변경에 실패했습니다: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Future<void> _showAddPlaceDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPlaceScreen()),
    );
    if (result == true) {
      _loadPlaces();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('🚽'),
            SizedBox(width: 8),
            Text('ToiletPass'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.home), text: '홈'),
            Tab(icon: Icon(Icons.favorite), text: '즐겨찾기'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildHomeTab(),
              FavoritesScreen(onUpdate: _loadPlaces),
            ],
          ),
          // 중앙 하단 + 버튼
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: _buildCentralAddButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentralAddButton() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddPlaceDialog,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_location_alt,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(height: 4),
                Text(
                  '추가',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CustomSearchBar(onSearchChanged: _onSearchChanged),
              SizedBox(height: 16),
              _buildCategoryFilter(),
            ],
          ),
        ),
        _buildStatistics(),
        Expanded(
          child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _buildPlacesList(),
        ),
        SizedBox(height: 110), // 중앙 버튼 공간 확보
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['key'];
          
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'],
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  SizedBox(width: 4),
                  Text(category['name']),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) => _onCategorySelected(category['key']),
              selectedColor: Theme.of(context).primaryColor,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStatCard('전체', _places.length.toString(), Icons.apps),
          SizedBox(width: 16),
          _buildStatCard('검색결과', _filteredPlaces.length.toString(), Icons.search),
          SizedBox(width: 16),
          _buildStatCard(
            '즐겨찾기', 
            _places.where((p) => p.isFavorite).length.toString(), 
            Icons.favorite
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesList() {
    if (_filteredPlaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.add_location_alt,
              size: 80,
              color: Colors.grey[300],
            ),
            SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty 
                ? '검색 결과가 없습니다'
                : '아직 등록된 장소가 없습니다',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            if (_searchQuery.isEmpty) ...[
              Text(
                '하단의 + 버튼을 눌러\n첫 번째 화장실 정보를 등록해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 40),
              // 화살표로 버튼 위치 안내
              Icon(
                Icons.keyboard_arrow_down,
                size: 40,
                color: Colors.grey[400],
              ),
              Text(
                '여기를 눌러주세요',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPlaces,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _filteredPlaces.length,
        itemBuilder: (context, index) {
          final place = _filteredPlaces[index];
          return PlaceCard(
            place: place,
            onTap: () => _copyPassword(place.password),
            onFavoriteToggle: () => _toggleFavorite(place),
            onEdit: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPlaceScreen(place: place),
                ),
              );
              if (result == true) {
                _loadPlaces();
              }
            },
          );
        },
      ),
    );
  }
}
