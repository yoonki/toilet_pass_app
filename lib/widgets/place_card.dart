import 'package:flutter/material.dart';
import 'dart:io';
import '../models/place.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onEdit;

  const PlaceCard({
    Key? key,
    required this.place,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _getCategoryIcon(place.category),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                place.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (place.address.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  place.address,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          place.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: place.isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: onFavoriteToggle,
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.grey[600]),
                        onPressed: onEdit,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      place.password,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.copy,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  _buildRatingStars(place.rating),
                  Spacer(),
                  _buildCategoryChip(place.category),
                ],
              ),
              if (place.notes.isNotEmpty) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          place.notes,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (place.imagePath != null && place.imagePath!.isNotEmpty) ...[
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(place.imagePath!),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData iconData;
    Color color;
    
    switch (category) {
      case 'cafe':
        iconData = Icons.local_cafe;
        color = Colors.brown;
        break;
      case 'restaurant':
        iconData = Icons.restaurant;
        color = Colors.orange;
        break;
      case 'shopping':
        iconData = Icons.shopping_bag;
        color = Colors.purple;
        break;
      case 'office':
        iconData = Icons.business;
        color = Colors.blue;
        break;
      case 'hospital':
        iconData = Icons.local_hospital;
        color = Colors.red;
        break;
      default:
        iconData = Icons.place;
        color = Colors.grey;
    }
    
    return Icon(iconData, color: color, size: 20);
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget _buildCategoryChip(String category) {
    String categoryName;
    Color backgroundColor;
    Color textColor;
    
    switch (category) {
      case 'cafe':
        categoryName = '☕ 카페';
        backgroundColor = Colors.brown.withOpacity(0.1);
        textColor = Colors.brown;
        break;
      case 'restaurant':
        categoryName = '🍽️ 음식점';
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'shopping':
        categoryName = '🛍️ 쇼핑몰';
        backgroundColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        break;
      case 'office':
        categoryName = '🏢 오피스';
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case 'hospital':
        categoryName = '🏥 병원';
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      default:
        categoryName = '📍 기타';
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        categoryName,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
