import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'place.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // 웹과 데스크톱 플랫폼 지원
    if (kIsWeb) {
      // 웹에서는 메모리 데이터베이스 사용
      return await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: _onCreate,
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // 데스크톱에서는 FFI 사용
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // 데이터베이스 경로 설정
    String path;
    if (kIsWeb) {
      path = 'toilet_pass.db';
    } else {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'toilet_pass.db');
    }
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE places (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT,
        category TEXT NOT NULL,
        password TEXT NOT NULL,
        rating INTEGER DEFAULT 3,
        notes TEXT,
        image_path TEXT,
        is_favorite INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // CRUD Operations
  Future<int> insertPlace(Place place) async {
    final db = await database;
    return await db.insert('places', place.toMap());
  }

  Future<List<Place>> getAllPlaces() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'places',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Place.fromMap(maps[i]));
  }

  Future<List<Place>> searchPlaces(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'places',
      where: 'name LIKE ? OR address LIKE ? OR notes LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Place.fromMap(maps[i]));
  }

  Future<List<Place>> getPlacesByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'places',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Place.fromMap(maps[i]));
  }

  Future<List<Place>> getFavoritePlaces() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'places',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Place.fromMap(maps[i]));
  }

  Future<int> updatePlace(Place place) async {
    final db = await database;
    return await db.update(
      'places',
      place.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [place.id],
    );
  }

  Future<int> deletePlace(int id) async {
    final db = await database;
    return await db.delete(
      'places',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'places',
      {
        'is_favorite': isFavorite ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics
  Future<Map<String, int>> getStatistics() async {
    final db = await database;
    
    final totalCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM places')
    ) ?? 0;
    
    final favoriteCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM places WHERE is_favorite = 1')
    ) ?? 0;
    
    final categoryCount = await db.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM places 
      GROUP BY category
    ''');
    
    Map<String, int> categoryStats = {};
    for (var row in categoryCount) {
      categoryStats[row['category'] as String] = row['count'] as int;
    }
    
    return {
      'total': totalCount,
      'favorites': favoriteCount,
      ...categoryStats,
    };
  }
}
