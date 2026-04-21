import 'package:flutter/material.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag, size: 100, color: Colors.red),
          SizedBox(height: 20),
          Text('Chào mừng bạn đến với cửa hàng!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Bạn có thể xem và mua giày thể thao',
              style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}