import 'review.dart';

class Shoe {
  final String id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final String imageUrl;
  final String description;
  final List<String> sizes;
  final List<String> colors;
  final String gender;          // <-- THÊM: nam, nữ, unisex
  final List<Review> reviews;

  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    return reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;
  }

  Shoe({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.sizes,
    required this.colors,
    required this.gender,       // <-- required
    List<Review>? reviews,
  }) : reviews = reviews ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'category': category,
    'price': price,
    'imageUrl': imageUrl,
    'description': description,
    'sizes': sizes,
    'colors': colors,
    'gender': gender,
    'reviews': reviews.map((r) => r.toJson()).toList(),
  };

  factory Shoe.fromJson(Map<String, dynamic> json) => Shoe(
    id: json['id'],
    name: json['name'],
    brand: json['brand'],
    category: json['category'],
    price: json['price'].toDouble(),
    imageUrl: json['imageUrl'],
    description: json['description'],
    sizes: List<String>.from(json['sizes']),
    colors: List<String>.from(json['colors']),
    gender: json['gender'] ?? 'unisex',
    reviews: (json['reviews'] as List<dynamic>?)
        ?.map((r) => Review.fromJson(r))
        .toList() ??
        [],
  );
}