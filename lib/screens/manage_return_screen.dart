import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../models/return_request.dart';

class ManageReturnsScreen extends StatefulWidget {
  const ManageReturnsScreen({super.key});

  @override
  State<ManageReturnsScreen> createState() => _ManageReturnsScreenState();
}

class _ManageReturnsScreenState extends State<ManageReturnsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        // Phân loại yêu cầu theo trạng thái
        final pendingRequests = orderProvider.returnRequests.where((r) => r.status == 'Đang xử lý').toList();
        final approvedRequests = orderProvider.returnRequests.where((r) => r.status == 'Đã duyệt').toList();
        final rejectedRequests = orderProvider.returnRequests.where((r) => r.status == 'Từ chối').toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Quản lý Trả / Đổi hàng'),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: '⏳ Chờ xử lý (${pendingRequests.length})'),
                Tab(text: '✅ Đã duyệt (${approvedRequests.length})'),
                Tab(text: '❌ Từ chối (${rejectedRequests.length})'),
              ],
            ),
          ),
          body: orderProvider.returnRequests.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_horiz, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Chưa có yêu cầu nào từ khách hàng',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          )
              : TabBarView(
            controller: _tabController,
            children: [
              _buildRequestList(context, pendingRequests, orderProvider, showActions: true),
              _buildRequestList(context, approvedRequests, orderProvider, showActions: false),
              _buildRequestList(context, rejectedRequests, orderProvider, showActions: false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestList(BuildContext context, List<ReturnRequest> requests, OrderProvider orderProvider, {required bool showActions}) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Không có yêu cầu nào', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          // Lấy tên sản phẩm từ order
          final order = orderProvider.orders.firstWhere(
                (o) => o.id == req.orderId,
            orElse: () => throw Exception('Không tìm thấy đơn hàng'),
          );
          final mainItem = order.items.isNotEmpty ? order.items.first : null;
          final productName = mainItem?.shoe.name ?? 'Đơn hàng';

          return _buildRequestCard(context, req, orderProvider, productName, showActions: showActions);
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, ReturnRequest req, OrderProvider orderProvider, String productName, {required bool showActions}) {
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
                style: TextStyle(color: _getStatusColor(req.status), fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        trailing: showActions
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
              onPressed: () => _showConfirmDialog(context, req, orderProvider, 'Đã duyệt'),
              tooltip: 'Duyệt yêu cầu',
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
              onPressed: () => _showConfirmDialog(context, req, orderProvider, 'Từ chối'),
              tooltip: 'Từ chối yêu cầu',
            ),
          ],
        )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),

                _buildInfoSection(
                  icon: Icons.person,
                  title: 'Thông tin khách hàng',
                  children: [
                    _buildInfoRow('Họ tên', 'Đinh Thái Hùng'),
                    _buildInfoRow('Số điện thoại', '0392 790 228'),
                    _buildInfoRow('Email', 'dinhthaihung1234@gmail.com'),
                  ],
                ),

                const SizedBox(height: 12),

                _buildInfoSection(
                  icon: Icons.info_outline,
                  title: 'Chi tiết yêu cầu',
                  children: [
                    _buildInfoRow('Mã đơn hàng', '#${req.orderId.substring(0, 8)}...'),
                    _buildInfoRow('Ngày gửi', DateFormat('dd/MM/yyyy HH:mm').format(req.requestDate)),
                    _buildInfoRow('Loại yêu cầu', req.typeText),
                    _buildInfoRow('Lý do', req.reason, isLongText: true),
                  ],
                ),

                const SizedBox(height: 12),

                if (showActions)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lưu ý: Sau khi duyệt/từ chối, yêu cầu sẽ tự động chuyển sang tab tương ứng.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (!showActions && req.status == 'Đã duyệt')
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Đã xử lý vào lúc ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                            style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (!showActions && req.status == 'Từ chối')
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Đã từ chối vào lúc ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                            style: TextStyle(color: Colors.red.shade700, fontSize: 12),
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

  Widget _buildInfoSection({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.red.shade400),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLongText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontSize: 13, color: Colors.grey))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: isLongText ? FontWeight.normal : FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, ReturnRequest req, OrderProvider provider, String newStatus) {
    final isApprove = newStatus == 'Đã duyệt';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(isApprove ? Icons.check_circle : Icons.warning,
                color: isApprove ? Colors.green : Colors.orange, size: 32),
            const SizedBox(width: 12),
            Text(isApprove ? 'Duyệt yêu cầu' : 'Từ chối yêu cầu'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isApprove
                  ? 'Xác nhận duyệt yêu cầu ${req.typeText.toLowerCase()} này?'
                  : 'Xác nhận từ chối yêu cầu ${req.typeText.toLowerCase()} này?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mã đơn: #${req.orderId.substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('Lý do: ${req.reason}', style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            if (isApprove)
              const SizedBox(height: 12),
            if (isApprove)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sau khi duyệt, yêu cầu sẽ được chuyển sang tab "Đã duyệt" và khách hàng sẽ nhận được thông báo.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            if (!isApprove)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sau khi từ chối, yêu cầu sẽ được chuyển sang tab "Từ chối".',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              provider.updateReturnStatus(req.id, newStatus);
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isApprove
                      ? '✅ Đã duyệt yêu cầu thành công!'
                      : '❌ Đã từ chối yêu cầu!'),
                  backgroundColor: isApprove ? Colors.green : Colors.orange,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(isApprove ? 'Duyệt' : 'Từ chối'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Đang xử lý': return '⏳ Chờ xử lý';
      case 'Đã duyệt': return '✅ Đã duyệt';
      case 'Từ chối': return '❌ Từ chối';
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