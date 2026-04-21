import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart'; // 1. Import thư viện chia sẻ
import '../models/shoe.dart';
import '../models/review.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/star_rating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Shoe shoe;
  const ProductDetailScreen({super.key, required this.shoe});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedSize;
  String? selectedColor;
  double userRating = 5.0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Hàm thực hiện chia sẻ
  void _shareProduct(Shoe shoe) {
    final String text = '''
🔥 Kiểm tra ngay sản phẩm cực hot: ${shoe.name}
👟 Thương hiệu: ${shoe.brand}
💰 Giá bán: ${shoe.price.toStringAsFixed(0)} VNĐ
⭐ Đánh giá: ${shoe.averageRating.toStringAsFixed(1)}/5.0

Xem chi tiết tại ứng dụng Shoe Store!
''';

    Share.share(text, subject: 'Chia sẻ giày ${shoe.name}');
  }

  Widget buildProductImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: 320,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 80),
      );
    } else if (imageUrl.startsWith('/') || imageUrl.contains('emulated')) {
      return Image.file(
        File(imageUrl),
        height: 320,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: Colors.red),
      );
    } else {
      return Image.asset(
        imageUrl,
        height: 320,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80),
      );
    }
  }

  void _showReviewDialog() {
    userRating = 5.0;
    _commentController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đánh giá sản phẩm'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Bạn đánh giá bao nhiêu sao?', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 12),
                    FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () => setStateDialog(() => userRating = (index + 1).toDouble()),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                (index + 1) <= userRating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 45,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _commentController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Viết nhận xét của bạn...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final comment = _commentController.text.trim();
                if (comment.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập nhận xét')),
                  );
                  return;
                }

                final newReview = Review(
                  userName: 'Khách hàng',
                  rating: userRating,
                  comment: comment,
                  date: DateTime.now(),
                );

                Provider.of<ProductProvider>(context, listen: false)
                    .addReview(widget.shoe.id, newReview);

                Navigator.pop(context);
                setState(() {});

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cảm ơn bạn đã đánh giá!')),
                );
              },
              child: const Text('Gửi đánh giá'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final currentShoe = productProvider.products.firstWhere(
              (s) => s.id == widget.shoe.id,
          orElse: () => widget.shoe,
        );

        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        final wishlistProvider = Provider.of<WishlistProvider>(context);
        final isFavorite = wishlistProvider.isInWishlist(currentShoe.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(currentShoe.name),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            actions: [
              // 2. Nút chia sẻ trên AppBar
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareProduct(currentShoe),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildProductImage(currentShoe.imageUrl),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(currentShoe.brand, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                          IconButton(
                            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                            onPressed: () {
                              if (isFavorite) {
                                wishlistProvider.removeFromWishlist(currentShoe.id);
                              } else {
                                wishlistProvider.addToWishlist(currentShoe);
                              }
                            },
                          ),
                        ],
                      ),
                      Text(currentShoe.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('${currentShoe.price.toStringAsFixed(0)} VNĐ',
                          style: const TextStyle(fontSize: 22, color: Colors.red, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          StarRating(rating: currentShoe.averageRating, size: 22),
                          const SizedBox(width: 8),
                          Text('${currentShoe.averageRating.toStringAsFixed(1)} (${currentShoe.reviews.length} đánh giá)'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(currentShoe.description, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 24),
                      const Text('Chọn size:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Wrap(
                        spacing: 8,
                        children: currentShoe.sizes.map((size) => ChoiceChip(
                          label: Text(size),
                          selected: selectedSize == size,
                          onSelected: (selected) => setState(() => selectedSize = selected ? size : null),
                          selectedColor: Colors.red.withOpacity(0.2),
                          checkmarkColor: Colors.red,
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Chọn màu:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Wrap(
                        spacing: 8,
                        children: currentShoe.colors.map((color) => ChoiceChip(
                          label: Text(color),
                          selected: selectedColor == color,
                          onSelected: (selected) => setState(() => selectedColor = selected ? color : null),
                          selectedColor: Colors.red.withOpacity(0.2),
                          checkmarkColor: Colors.red,
                        )).toList(),
                      ),
                      const SizedBox(height: 30),

                      // Nút Viết đánh giá
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.rate_review),
                          label: const Text('Viết đánh giá'),
                          onPressed: _showReviewDialog,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 3. Nút Chia sẻ thêm ở dưới mô tả (Tùy chọn)
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: TextButton.icon(
                      //     icon: const Icon(Icons.ios_share),
                      //     label: const Text('Chia sẻ với bạn bè'),
                      //     onPressed: () => _shareProduct(currentShoe),
                      //   ),
                      // ),

                      const SizedBox(height: 30),
                      const Text('Đánh giá từ khách hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (currentShoe.reviews.isEmpty)
                        const Text('Chưa có đánh giá nào. Hãy là người đầu tiên!'),
                      ...currentShoe.reviews.map((review) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              StarRating(rating: review.rating, size: 18),
                            ],
                          ),
                          subtitle: Text(review.comment),
                        ),
                      )).toList(),

                      const SizedBox(height: 40),

                      // --- PHẦN 2 NÚT BẤM KẾT NỐI VỚI CART_SCREEN ---
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: (selectedSize != null && selectedColor != null)
                                    ? () {
                                  cartProvider.addToCart(currentShoe, selectedSize!, selectedColor!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã thêm vào giỏ hàng!'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                                    : null,
                                child: const Text(
                                  'Thêm giỏ hàng',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                onPressed: (selectedSize != null && selectedColor != null)
                                    ? () {
                                  cartProvider.addToCart(currentShoe, selectedSize!, selectedColor!);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CartScreen()),
                                  );
                                }
                                    : null,
                                child: const Text(
                                  'Mua ngay',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}