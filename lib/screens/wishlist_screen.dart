import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/shoe_card.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Yêu thích'),
      //   backgroundColor: Colors.red,
      // ),
      body: wishlistProvider.items.isEmpty
          ? const Center(
        child: Text(
          'Chưa có sản phẩm yêu thích nào',
          style: TextStyle(fontSize: 16),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 335,           // ← Giống Home để đồng bộ
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: wishlistProvider.items.length,
        itemBuilder: (context, index) {
          final shoe = wishlistProvider.items[index];
          return ShoeCard(
            shoe: shoe,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductDetailScreen(shoe: shoe)),
            ),
          );
        },
      ),
    );
  }
}