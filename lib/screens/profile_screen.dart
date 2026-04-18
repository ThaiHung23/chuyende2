import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';

import 'manage_products_screen.dart';
import 'manage_orders_screen.dart';
import 'manage_return_screen.dart';
import 'my_return_requests_screen.dart';
import 'report_screen.dart';
import 'chat_screen.dart';
import 'return_request_screen.dart';       // Import màn hình tạo yêu cầu

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Avatar
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.red.shade100,
              child: const Icon(Icons.person, size: 70, color: Colors.red),
            ),
            const SizedBox(height: 12),

            Text(
              isAdmin ? 'Quản trị viên' : 'Đinh Thái Hùng',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // ==================== THÔNG TIN KHÁCH HÀNG ====================
            if (!isAdmin)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.person_outline),
                          title: Text('Họ và tên'),
                          subtitle: Text('Đinh Thái Hùng'),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.phone),
                          title: Text('Số điện thoại'),
                          subtitle: Text('0392 790 228'),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.email_outlined),
                          title: Text('Email'),
                          subtitle: Text('dinhthaihung1234@gmail.com'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // ==================== MENU CHUNG ====================
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Lịch sử đơn hàng'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageOrdersScreen(isAdmin: false)),
              ),
            ),

            // ==================== TRẢ / ĐỔI HÀNG (KHÁCH HÀNG) ====================
            if (!isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.orange),
                title: const Text('Tạo yêu cầu Trả / Đổi'),
                subtitle: const Text('Gửi yêu cầu trả hoặc đổi sản phẩm'),
                onTap: () {
                  _showSelectOrderDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.blue),
                title: const Text('Lịch sử yêu cầu'),
                subtitle: const Text('Xem trạng thái các yêu cầu đã gửi'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyReturnRequestsScreen()),
                  );
                },
              ),
            ],

            // ==================== ADMIN MENU ====================
            if (isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text('Quản lý sản phẩm'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageProductsScreen())),
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Quản lý đơn hàng'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageOrdersScreen(isAdmin: true)),
                ),
              ),

              // Quản lý yêu cầu Trả/Đổi (Admin)
              Consumer<OrderProvider>(
                builder: (context, provider, child) {
                  final pendingCount = provider.returnRequests
                      .where((r) => r.status == 'Đang xử lý')
                      .length;

                  return ListTile(
                    leading: const Icon(Icons.swap_horiz, color: Colors.orange),
                    title: Text('Quản lý Trả / Đổi hàng $pendingCount'),
                    subtitle: const Text('Duyệt yêu cầu từ khách hàng'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ManageReturnsScreen()),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Báo cáo bán hàng'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen())),
              ),
            ],

            // ==================== CHAT ====================
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline, color: Colors.green),
              title: const Text('Tin nhắn'),
              subtitle: const Text('Hỗ trợ 24/7'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
            ),

            const Divider(),

            // ==================== ĐĂNG XUẤT ====================
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất'),
              onTap: () {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Hàm hiển thị dialog chọn đơn hàng để trả/đổi (CHỈ HIỂN THỊ ĐƠN CHƯA CÓ YÊU CẦU)
  void _showSelectOrderDialog(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    // Lấy danh sách đơn hàng đã giao
    final completedOrders = orderProvider.orders.where((order) =>
    order.status == 'Đã giao'
    ).toList();

    // Lấy danh sách orderId đã có yêu cầu
    final requestedOrderIds = orderProvider.returnRequests.map((r) => r.orderId).toList();

    // Lọc ra những đơn hàng CHƯA có yêu cầu
    final availableOrders = completedOrders.where((order) =>
    !requestedOrderIds.contains(order.id)
    ).toList();

    if (availableOrders.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Thông báo'),
          content: const Text('Bạn không có đơn hàng nào đủ điều kiện để yêu cầu trả/đổi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chọn đơn hàng cần trả/đổi'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableOrders.length,
            itemBuilder: (context, index) {
              final order = availableOrders[index];
              final mainItem = order.items.isNotEmpty ? order.items.first : null;

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: mainItem != null
                      ? _buildProductImage(mainItem.shoe.imageUrl, width: 50, height: 50)
                      : const Icon(Icons.image_not_supported, size: 50),
                ),
                title: Text(
                  mainItem?.shoe.name ?? 'Đơn hàng',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Ngày: ${order.date.day}/${order.date.month}/${order.date.year}\nTổng: ${order.total.toStringAsFixed(0)}đ',
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReturnRequestScreen(orderId: order.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

// Helper hiển thị ảnh
  Widget _buildProductImage(String imageUrl, {double width = 60, double height = 60}) {
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, width: width, height: height, fit: BoxFit.cover);
    } else if (imageUrl.startsWith('/') || imageUrl.contains('emulated')) {
      return Image.file(File(imageUrl), width: width, height: height, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    } else {
      return Image.asset(imageUrl, width: width, height: height, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    }
  }
}