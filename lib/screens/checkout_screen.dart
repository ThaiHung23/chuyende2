import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController(text: '123 Đường ABC, Hà Nội');

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán'), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Địa chỉ giao hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: _addressController, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 20),
            const Text('Phương thức thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const ListTile(leading: Icon(Icons.money), title: Text('Thanh toán khi nhận hàng (COD)'), trailing: Icon(Icons.check_circle, color: Colors.green)),
            const Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tổng tiền:'), Text('${cartProvider.totalPrice.toStringAsFixed(0)} VNĐ', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_addressController.text.isNotEmpty) {
                    orderProvider.addOrder(cartProvider.items, cartProvider.totalPrice, _addressController.text);
                    cartProvider.clearCart();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đặt hàng thành công!')));
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
                child: const Text('Xác nhận đặt hàng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}