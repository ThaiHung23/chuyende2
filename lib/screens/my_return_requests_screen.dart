import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../models/return_request.dart';

class MyReturnRequestsScreen extends StatelessWidget {
  const MyReturnRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final myRequests = orderProvider.returnRequests;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Lịch sử yêu cầu Trả / Đổi'),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          body: myRequests.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Bạn chưa có yêu cầu trả/đổi hàng nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                SizedBox(height: 8),
                Text('Vào Lịch sử đơn hàng để tạo yêu cầu',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: myRequests.length,
            itemBuilder: (context, index) {
              final req = myRequests[index];
              // Lấy tên sản phẩm từ order
              final order = orderProvider.orders.firstWhere(
                    (o) => o.id == req.orderId,
                orElse: () => throw Exception('Không tìm thấy đơn hàng'),
              );
              final mainItem = order.items.isNotEmpty ? order.items.first : null;
              final productName = mainItem?.shoe.name ?? 'Đơn hàng';

              return _buildRequestCard(context, req, productName);
            },
          ),
        );
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, ReturnRequest req, String productName) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(req.status).withOpacity(0.2),
          radius: 24,
          child: Icon(
            req.type == ReturnType.returnOnly ? Icons.receipt_long : Icons.swap_horiz,
            color: _getStatusColor(req.status),
            size: 28,
          ),
        ),
        title: Text(
          productName,  // 👈 Đã đổi thành tên sản phẩm
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loại: ${req.typeText}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(req.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(req.status),
                style: TextStyle(
                  color: _getStatusColor(req.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _buildInfoRow('Mã đơn hàng', '#${req.orderId.substring(0, 8)}...'),
                const SizedBox(height: 8),
                _buildInfoRow('Ngày gửi', DateFormat('dd/MM/yyyy HH:mm').format(req.requestDate)),
                const SizedBox(height: 8),
                _buildInfoRow('Lý do', req.reason),
                const SizedBox(height: 16),

                // Hiển thị trạng thái chi tiết
                if (req.status == 'Đang xử lý')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.hourglass_empty, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Yêu cầu đang được xử lý. Vui lòng chờ admin duyệt.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (req.status == 'Đã duyệt')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Yêu cầu đã được duyệt!',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          req.type == ReturnType.returnOnly
                              ? 'Vui lòng gửi hàng về địa chỉ: 123 Đường ABC, Quận 1, TP.HCM. Chúng tôi sẽ hoàn tiền sau khi kiểm tra hàng.'
                              : 'Chúng tôi sẽ liên hệ với bạn trong vòng 24h để xác nhận đổi hàng.',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                if (req.status == 'Từ chối')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Yêu cầu đã bị từ chối. Vui lòng liên hệ hotline 1900 xxxx để được hỗ trợ.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500))),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Đang xử lý': return '⏳ Đang chờ duyệt';
      case 'Đã duyệt': return '✅ Đã được duyệt';
      case 'Từ chối': return '❌ Bị từ chối';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã duyệt': return Colors.green;
      case 'Từ chối': return Colors.red;
      default: return Colors.orange;
    }
  }
}