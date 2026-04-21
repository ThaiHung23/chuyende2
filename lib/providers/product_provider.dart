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

  // Getter lọc đầy đủ
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

  // Fetch products (giữ nguyên)
  void fetchProducts() {
    _firestore.collection('products').snapshots().listen((snapshot) {
      _products = snapshot.docs.map((doc) {
        final data = doc.data();
        return Shoe.fromJson({...data, 'id': doc.id}); // Đảm bảo id đúng
      }).toList();

      notifyListeners();
    });
  }

  // ====================== THÊM SẢN PHẨM ======================
  Future<void> addProduct(Shoe shoe) async {
    try {
      // Chỉ lưu lên Firebase, KHÔNG thêm thủ công vào list
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
        'reviews': [],
      });

      // KHÔNG CÓ DÒNG _products.add(shoe); nữa
      // Listener snapshots() sẽ tự cập nhật
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
      });

      // KHÔNG gán thủ công _products[index] = newShoe;
      // Listener sẽ tự cập nhật
    } catch (e) {
      print('Lỗi cập nhật sản phẩm: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      print("Lỗi khi xóa: $e");
    }
  }

  Future<void> addReview(String productId, Review review) async {
    try {
      final productRef = _firestore.collection('products').doc(productId);

      await productRef.update({
        'reviews': FieldValue.arrayUnion([review.toJson()]),
      });

      // Cập nhật lại danh sách local
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index].reviews.add(review);
        notifyListeners();
      }
    } catch (e) {
      print('Lỗi thêm review: $e');
      rethrow;
    }
  }
}