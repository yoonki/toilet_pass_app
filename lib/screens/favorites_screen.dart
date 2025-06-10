import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/place.dart';
import '../models/database_helper.dart';
import '../widgets/place_card.dart';
import 'add_place_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback? onUpdate;

  const FavoritesScreen({Key? key, this.onUpdate}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Place> _favoritePlaces = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final favorites = await _dbHelper.getFavoritePlaces();
      setState(() => _favoritePlaces = favorites);
    } catch (e) {
      _showSnackBar('즐겨찾기를 불러오는데 실패했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _copyPassword(String password) async {
    await Clipboard.setData(ClipboardData(text: password));
    _showSnackBar('비밀번호가 클립보드에 복사되었습니다: $password');
  }

  Future<void> _toggleFavorite(Place place) async {
    try {
      await _dbHelper.toggleFavorite(place.id!, false);
      _loadFavorites();
      if (widget.onUpdate != null) widget.onUpdate!();
      _showSnackBar('즐겨찾기에서 제거되었습니다');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : _buildFavoritesList(),
    );
  }

  Widget _buildFavoritesList() {
    if (_favoritePlaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              '즐겨찾기한 장소가 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '하트 아이콘을 눌러 즐겨찾기에 추가해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _favoritePlaces.length,
        itemBuilder: (context, index) {
          final place = _favoritePlaces[index];
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
                _loadFavorites();
                if (widget.onUpdate != null) widget.onUpdate!();
              }
            },
          );
        },
      ),
    );
  }
}
