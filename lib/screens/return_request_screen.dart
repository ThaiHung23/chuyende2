import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/return_request.dart';

class ReturnRequestScreen extends StatefulWidget {
  final String orderId;
  const ReturnRequestScreen({super.key, required this.orderId});

  @override
  State<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends State<ReturnRequestScreen> {
  ReturnType _selectedType = ReturnType.returnOnly;
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedProductId; // Chỉ dùng khi đổi hàng

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final order = orderProvider.orders.firstWhere(
          (o) => o.id == widget.orderId,
      orElse: () => throw Exception('Không tìm thấy đơn hàng'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu cầu Trả / Đổi hàng'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Đơn hàng #${widget.orderId.substring(0, 8)}...',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Ngày đặt: ${order.date.day}/${order.date.month}/${order.date.year}'),
                    Text('Tổng tiền: ${order.total.toStringAsFixed(0)} VNĐ'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Loại yêu cầu:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text('Trả hàng (Hoàn tiền)'),
                    subtitle: const Text('Nhận lại tiền và trả lại sản phẩm'),
                    value: ReturnType.returnOnly,
                    groupValue: _selectedType,
                    onChanged: (value) => setState(() => _selectedType = value!),
                    activeColor: Colors.red,
                  ),
                  const Divider(height: 0),
                  RadioListTile(
                    title: const Text('Đổi hàng (Sang sản phẩm khác)'),
                    subtitle: const Text('Đổi sang sản phẩm khác cùng giá trị'),
                    value: ReturnType.exchange,
                    groupValue: _selectedType,
                    onChanged: (value) => setState(() => _selectedType = value!),
                    activeColor: Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('Lý do chi tiết:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ví dụ: Sai size, sản phẩm lỗi, không vừa chân, màu sắc không như mong muốn...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_reasonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập lý do chi tiết')),
                    );
                    return;
                  }

                  final request = ReturnRequest(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    orderId: widget.orderId,
                    type: _selectedType,
                    reason: _reasonController.text.trim(),
                  );

                  Provider.of<OrderProvider>(context, listen: false).addReturnRequest(request);

                  // Hiển thị thông báo thành công và quay lại
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Yêu cầu đã được gửi thành công! Admin sẽ xử lý trong thời gian sớm nhất.'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  Navigator.pop(context);
                },
                child: const Text('Gửi yêu cầu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}