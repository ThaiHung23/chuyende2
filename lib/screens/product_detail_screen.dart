import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart'; // Import thư viện chia sẻ
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
  int selectedFilterStar = 0; // 0: Tất cả, 1-5: Lọc theo sao
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // --- HÀM CHIA SẺ ---
  void _shareProduct(Shoe shoe) {
    final String text = '''
🔥 Xem ngay đôi giày cực chất: ${shoe.name}
👟 Thương hiệu: ${shoe.brand}
💰 Giá: ${shoe.price.toStringAsFixed(0)} VNĐ
⭐ Đánh giá: ${shoe.averageRating.toStringAsFixed(1)}/5.0

Tải app ngay để mua sắm!
''';
    Share.share(text, subject: 'Chia sẻ sản phẩm ${shoe.name}');
  }

  // --- HÀM LỌC REVIEW ---
  List<Review> getFilteredReviews(List<Review> allReviews) {
    if (selectedFilterStar == 0) return allReviews;
    return allReviews.where((r) => r.rating.toInt() == selectedFilterStar).toList();
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
                      // Header Brand & Favorite
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

                      // Rating Overview
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

                      // Chọn Size
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

                      // Chọn Màu
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
                      const SizedBox(height: 30),

                      // --- PHẦN PHÂN LOẠI ĐÁNH GIÁ ---
                      const Text('Đánh giá từ khách hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Tất cả'),
                              selected: selectedFilterStar == 0,
                              onSelected: (_) => setState(() => selectedFilterStar = 0),
                              selectedColor: Colors.red.withOpacity(0.2),
                            ),
                            const SizedBox(width: 8),
                            ...List.generate(5, (index) {
                              int star = 5 - index;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Row(
                                    children: [
                                      Text('$star'),
                                      const Icon(Icons.star, size: 14, color: Colors.amber),
                                    ],
                                  ),
                                  selected: selectedFilterStar == star,
                                  onSelected: (selected) => setState(() => selectedFilterStar = selected ? star : 0),
                                  selectedColor: Colors.red.withOpacity(0.2),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Danh sách đánh giá đã lọc
                      Builder(builder: (context) {
                        final filteredReviews = getFilteredReviews(currentShoe.reviews);
                        if (filteredReviews.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text('Không có đánh giá nào cho mức này.', style: TextStyle(color: Colors.grey)),
                            ),
                          );
                        }
                        return Column(
                          children: filteredReviews.map((review) => Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  StarRating(rating: review.rating, size: 18),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(review.comment),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${review.date.day}/${review.date.month}/${review.date.year}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          )).toList(),
                        );
                      }),

                      const SizedBox(height: 40),

                      // --- NÚT GIỎ HÀNG & MUA NGAY ---
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
                                    const SnackBar(content: Text('Đã thêm vào giỏ hàng!'), duration: Duration(seconds: 1)),
                                  );
                                } : null,
                                child: const Text('Thêm giỏ hàng', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                                } : null,
                                child: const Text('Mua ngay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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