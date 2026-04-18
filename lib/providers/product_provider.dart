import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';
import '../models/shoe.dart';

class ProductProvider with ChangeNotifier {
  List<Shoe> _products = [];
  String _searchQuery = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Shoe> get products => _products;

  // Lọc sản phẩm theo tìm kiếm
  List<Shoe> get filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // ====================== CÁC HÀM XỬ LÝ LỖI CỦA BẠN ======================

  // Sửa lỗi ở HomeScreen & ShopScreen
  void searchProducts(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Sửa lỗi ở ProductDetailScreen
  Future<void> addReview(String productId, Review review) async {
    try {
      // Tìm đôi giày cần thêm review
      final shoeIndex = _products.indexWhere((p) => p.id == productId);
      if (shoeIndex != -1) {
        // Gửi lên Firebase: Cập nhật mảng reviews bằng FieldValue.arrayUnion
        await _firestore.collection('products').doc(productId).update({
          'reviews': FieldValue.arrayUnion([
            {
              'userName': review.userName,
              'rating': review.rating,
              'comment': review.comment,
              'date': review.date.toIso8601String(),
            }
          ])
        });
        // fetchProducts() sẽ tự động cập nhật lại UI nhờ listener snapshots
      }
    } catch (e) {
      print("Lỗi khi thêm review: $e");
    }
  }

  // ====================== KẾT NỐI FIREBASE ======================

  void fetchProducts() {
    _firestore.collection('products').snapshots().listen((snapshot) {
      _products = snapshot.docs.map((doc) {
        final data = doc.data();
        return Shoe(
          id: doc.id,
          name: data['name'] ?? '',
          brand: data['brand'] ?? '',
          category: data['category'] ?? 'Running',
          price: (data['price'] as num).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          description: data['description'] ?? '',
          sizes: List<String>.from(data['sizes'] ?? []),
          colors: List<String>.from(data['colors'] ?? []),
          reviews: (data['reviews'] as List<dynamic>?)
              ?.map((r) => Review(
            userName: r['userName'],
            rating: (r['rating'] as num).toDouble(),
            comment: r['comment'],
            date: DateTime.parse(r['date']),
          ))
              .toList() ?? [],
        );
      }).toList();
      notifyListeners();
    });
  }

  Future<void> addProduct(Shoe shoe) async {
    try {
      await _firestore.collection('products').add({
        'name': shoe.name,
        'brand': shoe.brand,
        'category': shoe.category,
        'price': shoe.price,
        'imageUrl': shoe.imageUrl,
        'description': shoe.description,
        'sizes': shoe.sizes,
        'colors': shoe.colors,
        'reviews': [], // Khởi tạo mảng review trống
      });
    } catch (e) {
      print("Lỗi khi thêm sản phẩm: $e");
    }
  }

  Future<void> updateProduct(String id, Shoe newShoe) async {
    try {
      await _firestore.collection('products').doc(id).update({
        'name': newShoe.name,
        'brand': newShoe.brand,
        'price': newShoe.price,
        'description': newShoe.description,
      });
    } catch (e) {
      print("Lỗi khi sửa: $e");
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      print("Lỗi khi xóa: $e");
    }
  }
}