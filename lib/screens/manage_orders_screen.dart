import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../providers/order_provider.dart';
import '../models/cart_item.dart';
import '../models/return_request.dart';
import 'return_request_screen.dart';

class ManageOrdersScreen extends StatelessWidget {
  final bool isAdmin;
  const ManageOrdersScreen({super.key, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Quản lý đơn hàng' : 'Lịch sử đơn hàng'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: isAdmin
            ? [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {},
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Tất cả')),
              const PopupMenuItem(value: 'Đang xử lý', child: Text('Đang xử lý')),
              const PopupMenuItem(value: 'Đã thanh toán', child: Text('Đã thanh toán')),
              const PopupMenuItem(value: 'Đang giao', child: Text('Đang giao')),
              const PopupMenuItem(value: 'Đã giao', child: Text('Đã giao')),
              const PopupMenuItem(value: 'Đã hủy', child: Text('Đã hủy')),
            ],
          ),
        ]
            : null,
      ),
      body: orderProvider.orders.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Chưa có đơn hàng nào', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orderProvider.orders.length,
        itemBuilder: (context, index) {
          final order = orderProvider.orders[index];
          final mainItem = order.items.isNotEmpty ? order.items.first : null;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: isAdmin
                ? _buildAdminOrderTile(context, order, mainItem, orderProvider)
                : _buildCustomerOrderTile(context, order, mainItem, orderProvider),
          );
        },
      ),
    );
  }

  // ==================== ADMIN: HIỂN THỊ VÀ XỬ LÝ ĐƠN HÀNG ====================
  Widget _buildAdminOrderTile(BuildContext context, dynamic order, dynamic mainItem, OrderProvider orderProvider) {
    return ExpansionTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildProductImage(mainItem?.shoe.imageUrl ?? ''),
      ),
      title: Text(
        mainItem?.shoe.name ?? 'Đơn hàng',
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mã đơn: #${order.id.substring(0, 8)}...'),
          Text('Ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(order.date)}'),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(color: _getStatusColor(order.status), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const Spacer(),
              Text(
                '${order.total.toStringAsFixed(0)} VNĐ',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📦 Thông tin giao hàng:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(order.address)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('🛍️ Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...order.items.map((CartItem item) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildProductImage(item.shoe.imageUrl, width: 50, height: 50),
                ),
                title: Text(item.shoe.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text('Size: ${item.size} | Màu: ${item.color} | SL: ${item.quantity}'),
                trailing: Text('${(item.shoe.price * item.quantity).toStringAsFixed(0)}đ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng cộng:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${order.total.toStringAsFixed(0)} VNĐ',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 16),

              if (order.status != 'Đã giao' && order.status != 'Đã hủy')
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚡ Cập nhật trạng thái:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatusButton(
                            context: context,
                            status: 'Đang xử lý',
                            currentStatus: order.status,
                            orderId: order.id,
                            orderProvider: orderProvider,
                            color: Colors.orange,
                          ),
                          _buildStatusButton(
                            context: context,
                            status: 'Đã thanh toán',
                            currentStatus: order.status,
                            orderId: order.id,
                            orderProvider: orderProvider,
                            color: Colors.purple,
                          ),
                          _buildStatusButton(
                            context: context,
                            status: 'Đang giao',
                            currentStatus: order.status,
                            orderId: order.id,
                            orderProvider: orderProvider,
                            color: Colors.blue,
                          ),
                          _buildStatusButton(
                            context: context,
                            status: 'Đã giao',
                            currentStatus: order.status,
                            orderId: order.id,
                            orderProvider: orderProvider,
                            color: Colors.green,
                          ),
                          if (order.status == 'Đang xử lý')
                            _buildStatusButton(
                              context: context,
                              status: 'Đã hủy',
                              currentStatus: order.status,
                              orderId: order.id,
                              orderProvider: orderProvider,
                              color: Colors.red,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== KHÁCH HÀNG: HIỂN THỊ LỊCH SỬ ĐƠN HÀNG ====================
  Widget _buildCustomerOrderTile(BuildContext context, dynamic order, dynamic mainItem, OrderProvider orderProvider) {
    final existingRequest = orderProvider.returnRequests.cast<ReturnRequest?>().firstWhere(
          (r) => r?.orderId == order.id,
      orElse: () => null,
    );
    final isCompleted = order.status == 'Đã giao';

    // Lấy tên sản phẩm
    final productName = mainItem?.shoe.name ?? 'Đơn hàng';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOrderDetail(context, order, orderProvider, existingRequest, isCompleted),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildProductImage(mainItem?.shoe.imageUrl ?? '', width: 60, height: 60),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('Mã đơn: #${order.id.substring(0, 8)}...', style: const TextStyle(fontSize: 12)),
                    Text('Ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(order.date)}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(color: _getStatusColor(order.status), fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${order.total.toStringAsFixed(0)}đ',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                    if (existingRequest != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRequestStatusColor(existingRequest.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                size: 12,
                                color: _getRequestStatusColor(existingRequest.status),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Đã gửi yêu cầu ${existingRequest.typeText}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getRequestStatusColor(existingRequest.status),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Các hàm helper (giữ nguyên)
  Widget _buildStatusButton({
    required BuildContext context,
    required String status,
    required String currentStatus,
    required String orderId,
    required OrderProvider orderProvider,
    required Color color,
  }) {
    final isSelected = currentStatus == status;

    bool isDisabled = false;
    if (currentStatus == 'Đã giao' && status != 'Đã giao') isDisabled = true;
    if (currentStatus == 'Đã hủy') isDisabled = true;
    if (currentStatus == 'Đã thanh toán' && status == 'Đang xử lý') isDisabled = true;
    if (currentStatus == 'Đang giao' && (status == 'Đang xử lý' || status == 'Đã thanh toán')) isDisabled = true;

    return ElevatedButton(
      onPressed: isDisabled || isSelected
          ? null
          : () {
        _showConfirmUpdateStatus(context, orderId, currentStatus, status, orderProvider);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.white,
        foregroundColor: isSelected ? Colors.white : color,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: const Size(0, 32),
      ),
      child: Text(status, style: const TextStyle(fontSize: 12)),
    );
  }

  void _showConfirmUpdateStatus(BuildContext context, String orderId, String oldStatus, String newStatus, OrderProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận cập nhật'),
        content: Text('Bạn có chắc chắn muốn cập nhật trạng thái đơn hàng từ "$oldStatus" thành "$newStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.updateOrderStatus(orderId, newStatus);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Đã cập nhật trạng thái thành "$newStatus"'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetail(BuildContext context, dynamic order, OrderProvider orderProvider, ReturnRequest? existingRequest, bool isCompleted) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Đơn hàng #${order.id.substring(0, 8)}...'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [const Icon(Icons.calendar_today, size: 16), const SizedBox(width: 8), Text('Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(order.date)}')]),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.location_on, size: 16), const SizedBox(width: 8), Expanded(child: Text('Địa chỉ: ${order.address}'))]),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.info_outline, size: 16), const SizedBox(width: 8), Text('Trạng thái: '), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: _getStatusColor(order.status).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(order.status, style: TextStyle(color: _getStatusColor(order.status), fontSize: 12, fontWeight: FontWeight.w500)))]),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('🛍️ Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...order.items.map((CartItem item) => ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildProductImage(item.shoe.imageUrl, width: 45, height: 45)), title: Text(item.shoe.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)), subtitle: Text('Size: ${item.size} | Màu: ${item.color} | SL: ${item.quantity}'), trailing: Text('${(item.shoe.price * item.quantity).toStringAsFixed(0)}đ', style: const TextStyle(fontWeight: FontWeight.bold)))),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tổng cộng:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text('${order.total.toStringAsFixed(0)} VNĐ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red))]),
              const SizedBox(height: 16),
              if (existingRequest != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: _getRequestStatusColor(existingRequest.status).withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: _getRequestStatusColor(existingRequest.status).withOpacity(0.3))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(existingRequest.type == ReturnType.returnOnly ? Icons.receipt_long : Icons.swap_horiz, color: _getRequestStatusColor(existingRequest.status), size: 20), const SizedBox(width: 8), Text('Yêu cầu ${existingRequest.typeText}', style: TextStyle(fontWeight: FontWeight.bold, color: _getRequestStatusColor(existingRequest.status)))]), const SizedBox(height: 8), _buildInfoRow('Trạng thái', _getRequestStatusText(existingRequest.status)), _buildInfoRow('Ngày gửi', DateFormat('dd/MM/yyyy HH:mm').format(existingRequest.requestDate)), _buildInfoRow('Lý do', existingRequest.reason)]),
                ),
              if (isCompleted && existingRequest == null)
                const SizedBox(height: 16),
              if (isCompleted && existingRequest == null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Yêu cầu Trả / Đổi hàng'),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange), foregroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ReturnRequestScreen(orderId: order.id)));
                    },
                  ),
                ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng'))],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 65, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))), const SizedBox(width: 8), Expanded(child: Text(value, style: const TextStyle(fontSize: 13)))]),
    );
  }

  Widget _buildProductImage(String imageUrl, {double width = 60, double height = 60}) {
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, width: width, height: height, fit: BoxFit.cover);
    } else if (imageUrl.startsWith('/') || imageUrl.contains('emulated')) {
      return Image.file(File(imageUrl), width: width, height: height, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    } else {
      return Image.asset(imageUrl, width: width, height: height, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đang xử lý': return Colors.orange;
      case 'Đã thanh toán': return Colors.purple;
      case 'Đang giao': return Colors.blue;
      case 'Đã giao': return Colors.green;
      case 'Đã hủy': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getRequestStatusColor(String status) {
    switch (status) {
      case 'Đã duyệt': return Colors.green;
      case 'Từ chối': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _getRequestStatusText(String status) {
    switch (status) {
      case 'Đang xử lý': return '⏳ Đang chờ duyệt';
      case 'Đã duyệt': return '✅ Đã được duyệt';
      case 'Từ chối': return '❌ Bị từ chối';
      default: return status;
    }
  }
}