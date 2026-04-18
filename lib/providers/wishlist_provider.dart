import 'package:flutter/material.dart';
import '../models/shoe.dart';

class WishlistProvider with ChangeNotifier {
  final List<Shoe> _items = [];

  List<Shoe> get items => List.unmodifiable(_items);

  void addToWishlist(Shoe shoe) {
    if (!_items.any((s) => s.id == shoe.id)) {
      _items.add(shoe);
      notifyListeners();
    }
  }

  void removeFromWishlist(String id) {
    _items.removeWhere((shoe) => shoe.id == id);
    notifyListeners();
  }

  bool isInWishlist(String id) {
    return _items.any((shoe) => shoe.id == id);
  }
}