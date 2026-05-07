import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/shoe.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + (item.shoe.price * item.quantity));

  void addToCart(Shoe shoe, String size, String color) {
    if (shoe.stock <= 0) return; // Không thêm nếu hết hàng

    final existingIndex = _items.indexWhere((item) =>
    item.shoe.id == shoe.id && item.size == size && item.color == color);

    if (existingIndex >= 0) {
      // Chỉ tăng số lượng nếu chưa vượt quá tồn kho
      if (_items[existingIndex].quantity < shoe.stock) {
        _items[existingIndex].quantity++;
      }
    } else {
      _items.add(CartItem(shoe: shoe, size: size, color: color));
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void updateQuantity(CartItem item, int newQuantity) {
    if (newQuantity > 0) {
      // Kiểm tra tồn kho khi cập nhật số lượng trực tiếp
      if (newQuantity <= item.shoe.stock) {
        item.quantity = newQuantity;
      }
    } else {
      removeFromCart(item);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}