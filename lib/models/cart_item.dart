import 'shoe.dart';

class CartItem {
  final Shoe shoe;
  final String size;
  final String color;
  int quantity;

  CartItem({
    required this.shoe,
    required this.size,
    required this.color,
    this.quantity = 1,
  });
}