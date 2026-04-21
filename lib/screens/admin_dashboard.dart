import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings, size: 100, color: Colors.orange),
          SizedBox(height: 20),
          Text('Bảng điều khiển Admin',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text('Quản lý sản phẩm, đơn hàng, khách hàng...',
              style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}