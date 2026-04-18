import 'cart_item.dart';

class Order {
  final String id;
  final DateTime date;
  final List<CartItem> items;
  final double total;
  String status;
  final String address;

  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    this.status = 'Đang xử lý',
    required this.address,
  });
}

