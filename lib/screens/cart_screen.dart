import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart'; // Đảm bảo đã import OrderProvider
import 'checkout_screen.dart';
import 'product_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // --- HÀM XỬ LÝ THANH TOÁN QR (Để lưu vào lịch sử đơn hàng) ---
  void _processQRPayment(BuildContext context, double total) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    const String bankId = "MB";
    const String accountNo = "0392790228";
    const String accountName = "DINH THAI HUNG";
    final String description = "DH${DateTime.now().millisecondsSinceEpoch}";

    final String qrUrl = "https://img.vietqr.io/image/$bankId-$accountNo-compact2.png"
        "?amount=${total.toInt()}"
        "&addInfo=$description"
        "&accountName=$accountName";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Thanh toán Online QR', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Vui lòng quét mã bên dưới'),
            const SizedBox(height: 15),
            CachedNetworkImage(
              imageUrl: qrUrl,
              placeholder: (context, url) => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 10),
            Text('Tổng: ${total.toStringAsFixed(0)} VNĐ',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              // LƯU LỊCH SỬ CHO THANH TOÁN ONLINE
              orderProvider.addOrder(cartProvider.items, cartProvider.totalPrice, "Chuyển khoản QR");
              cartProvider.clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thanh toán QR thành công!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Xác nhận đã chuyển tiền'),
          ),
        ],
      ),
    );
  }

  // --- MENU CHỌN PHƯƠNG THỨC ---
  void _showPaymentMenu(BuildContext context, double total) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Chọn phương thức thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping, color: Colors.green),
            title: const Text('Thanh toán khi nhận hàng (COD)'),
            // subtitle: const Text('GIỮ NGUYÊN LOGIC CŨ'),
            onTap: () {
              Navigator.pop(context);
              // GIỮ NGUYÊN LOGIC CŨ CỦA BẠN: Chuyển sang màn hình Checkout
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner, color: Colors.blue),
            title: const Text('Thanh toán Online qua mã QR'),
            onTap: () {
              Navigator.pop(context);
              _processQRPayment(context, total);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng'), backgroundColor: Colors.red, foregroundColor: Colors.white),
      body: cartProvider.items.isEmpty
          ? const Center(child: Text('Giỏ hàng trống', style: TextStyle(fontSize: 18)))
          : ListView.builder(
        itemCount: cartProvider.items.length,
        itemBuilder: (context, index) {
          final item = cartProvider.items[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImage(item.shoe.imageUrl),
            ),
            title: Text(item.shoe.name, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text('${item.size} - ${item.color} × ${item.quantity}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => cartProvider.updateQuantity(item, item.quantity - 1),
                ),
                Text('${item.quantity}'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => cartProvider.updateQuantity(item, item.quantity + 1),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => cartProvider.removeFromCart(item),
                ),
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductDetailScreen(shoe: item.shoe)),
            ),
          );
        },
      ),
      bottomNavigationBar: cartProvider.items.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng:', style: TextStyle(fontSize: 18)),
                Text(
                  '${cartProvider.totalPrice.toStringAsFixed(0)} VNĐ',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () => _showPaymentMenu(context, cartProvider.totalPrice),
                child: const Text('Thanh toán', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(imageUrl: imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.broken_image));
    } else if (imageUrl.startsWith('/') || imageUrl.contains('emulated')) {
      return Image.file(File(imageUrl), width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    } else {
      return Image.asset(imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    }
  }
}