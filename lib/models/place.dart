class Place {
  final int? id;
  final String name;
  final String address;
  final String category;
  final String password;
  final int rating;
  final String notes;
  final String? imagePath;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  Place({
    this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.password,
    this.rating = 3,
    this.notes = '',
    this.imagePath,
    this.isFavorite = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'category': category,
      'password': password,
      'rating': rating,
      'notes': notes,
      'image_path': imagePath,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      category: map['category'],
      password: map['password'],
      rating: map['rating'],
      notes: map['notes'] ?? '',
      imagePath: map['image_path'],
      isFavorite: map['is_favorite'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Place copyWith({
    int? id,
    String? name,
    String? address,
    String? category,
    String? password,
    int? rating,
    String? notes,
    String? imagePath,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      category: category ?? this.category,
      password: password ?? this.password,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
