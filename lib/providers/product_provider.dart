import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';
import '../models/shoe.dart';

class ProductProvider with ChangeNotifier {
  List<Shoe> _products = [];
  String _searchQuery = '';
  String _selectedColor = 'All';
  String _selectedGender = 'All';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Shoe> get products => _products;

  // Getter lọc sản phẩm
  List<Shoe> get filteredProducts {
    return _products.where((p) {
      final matchSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchColor = _selectedColor == 'All' ||
          p.colors.any((c) => c.toLowerCase() == _selectedColor.toLowerCase());

      final matchGender = _selectedGender == 'All' ||
          p.gender.toLowerCase() == _selectedGender.toLowerCase();

      return matchSearch && matchColor && matchGender;
    }).toList();
  }

  String get selectedColor => _selectedColor;
  String get selectedGender => _selectedGender;

  void searchProducts(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setColorFilter(String color) {
    _selectedColor = color;
    notifyListeners();
  }

  void setGenderFilter(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedColor = 'All';
    _selectedGender = 'All';
    notifyListeners();
  }

  // Lấy dữ liệu thời gian thực từ Firebase
  void fetchProducts() {
    _firestore.collection('products').snapshots().listen((snapshot) {
      _products = snapshot.docs.map((doc) {
        final data = doc.data();
        return Shoe.fromJson({...data, 'id': doc.id});
      }).toList();

      notifyListeners();
    });
  }

  // ====================== THÊM SẢN PHẨM ======================
  Future<void> addProduct(Shoe shoe) async {
    try {
      await _firestore.collection('products').doc(shoe.id).set({
        'name': shoe.name,
        'brand': shoe.brand,
        'category': shoe.category,
        'price': shoe.price,
        'imageUrl': shoe.imageUrl,
        'description': shoe.description,
        'sizes': shoe.sizes,
        'colors': shoe.colors,
        'gender': shoe.gender,
        'stock': shoe.stock,
        'reviews': [],
      });
    } catch (e) {
      print('Lỗi thêm sản phẩm: $e');
      rethrow;
    }
  }

  // ====================== CẬP NHẬT SẢN PHẨM ======================
  Future<void> updateProduct(String id, Shoe newShoe) async {
    try {
      await _firestore.collection('products').doc(id).update({
        'name': newShoe.name,
        'brand': newShoe.brand,
        'category': newShoe.category,
        'price': newShoe.price,
        'imageUrl': newShoe.imageUrl,
        'description': newShoe.description,
        'sizes': newShoe.sizes,
        'colors': newShoe.colors,
        'gender': newShoe.gender,
        'stock': newShoe.stock,
      });
    } catch (e) {
      print('Lỗi cập nhật sản phẩm: $e');
      rethrow;
    }
  }

  // ====================== GIẢM TỒN KHO ======================
  Future<void> reduceStock(String productId, int quantity) async {
    try {
      final productRef = _firestore.collection('products').doc(productId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(productRef);
        if (!snapshot.exists) return;
        
        int currentStock = snapshot.data()?['stock'] ?? 0;
        int newStock = currentStock - quantity;
        if (newStock < 0) newStock = 0;
        
        transaction.update(productRef, {'stock': newStock});
      });
    } catch (e) {
      print('Lỗi cập nhật tồn kho: $e');
    }
  }

  // ====================== XÓA SẢN PHẨM ======================
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      print("Lỗi khi xóa: $e");
    }
  }

  // ====================== THÊM ĐÁNH GIÁ ======================
  Future<void> addReview(String productId, Review review) async {
    try {
      final productRef = _firestore.collection('products').doc(productId);

      // Chỉ cập nhật lên Firebase
      // Listener trong fetchProducts sẽ tự động nhận diện thay đổi và cập nhật UI
      await productRef.update({
        'reviews': FieldValue.arrayUnion([review.toJson()]),
      });

      // ĐÃ XÓA: phần thêm thủ công vào _products để tránh trùng lặp dữ liệu
    } catch (e) {
      print('Lỗi thêm review: $e');
      rethrow;
    }
  }
}