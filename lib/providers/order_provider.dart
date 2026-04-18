import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/return_request.dart';   // Import ReturnRequest

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];
  final List<ReturnRequest> _returnRequests = [];   // Chỉ khai báo 1 lần

  List<Order> get orders => _orders;
  List<ReturnRequest> get returnRequests => _returnRequests;

  // ==================== ĐƠN HÀNG ====================
  void addOrder(List<CartItem> cartItems, double total, String address) {
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      items: List.from(cartItems),
      total: total,
      address: address,
    );
    _orders.add(order);
    notifyListeners();
  }

  // Thêm phương thức này vào class OrderProvider nếu chưa có
  void updateOrderStatus(String id, String newStatus) {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index != -1) {
      _orders[index].status = newStatus;
      notifyListeners();
    }
  }

  // ==================== YÊU CẦU TRẢ / ĐỔI HÀNG ====================
  void addReturnRequest(ReturnRequest request) {
    _returnRequests.add(request);
    notifyListeners();
  }

  void updateReturnStatus(String id, String newStatus) {
    final index = _returnRequests.indexWhere((r) => r.id == id);
    if (index != -1) {
      _returnRequests[index].status = newStatus;
      notifyListeners();
    }
  }

  // Xóa tất cả yêu cầu (nếu cần reset)
  void clearReturnRequests() {
    _returnRequests.clear();
    notifyListeners();
  }

}