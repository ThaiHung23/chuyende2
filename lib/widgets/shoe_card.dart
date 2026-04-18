import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shoe.dart';
import '../providers/wishlist_provider.dart';
import 'star_rating.dart';

class ShoeCard extends StatelessWidget {
  final Shoe shoe;
  final VoidCallback onTap;

  const ShoeCard({super.key, required this.shoe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final isFavorite = wishlistProvider.isInWishlist(shoe.id);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.1,
                  child: _buildImage(shoe.imageUrl),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      if (isFavorite) {
                        wishlistProvider.removeFromWishlist(shoe.id);
                      } else {
                        wishlistProvider.addToWishlist(shoe);
                      }
                    },
                  ),
                ),
              ],
            ),

            // Thông tin
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shoe.brand, style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    shoe.name,
                    style: const TextStyle(fontSize: 14.8, fontWeight: FontWeight.bold, height: 1.15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StarRating(rating: shoe.averageRating, size: 15),
                      const SizedBox(width: 5),
                      Text(
                        shoe.averageRating > 0 ? shoe.averageRating.toStringAsFixed(1) : '',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${shoe.price.toStringAsFixed(0)} VNĐ',
                    style: const TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, fit: BoxFit.cover);
    } else if (imageUrl.startsWith('/') || imageUrl.contains('emulated')) {
      return Image.file(File(imageUrl), fit: BoxFit.cover);
    } else {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    }
  }
}