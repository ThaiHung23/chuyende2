// lib/screens/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/shoe_card.dart';
import 'product_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    var displayedProducts = productProvider.filteredProducts;

    // Lọc thêm theo category (nếu muốn giữ)
    if (selectedCategory != 'All') {
      displayedProducts = displayedProducts
          .where((shoe) => shoe.category == selectedCategory)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cửa hàng'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context, productProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm giày...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => productProvider.searchProducts(value),
            ),
          ),

          // Filter Category
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Running', 'Basketball', 'Casual'].map((cat) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = selected ? cat : 'All';
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Hiển thị filter hiện tại
          if (productProvider.selectedColor != 'All' || productProvider.selectedGender != 'All')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  if (productProvider.selectedColor != 'All')
                    Chip(
                      label: Text('Màu: ${productProvider.selectedColor}'),
                      onDeleted: () => productProvider.setColorFilter('All'),
                    ),
                  if (productProvider.selectedGender != 'All')
                    Chip(
                      label: Text('Giới tính: ${productProvider.selectedGender}'),
                      onDeleted: () => productProvider.setGenderFilter('All'),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: productProvider.clearFilters,
                    child: const Text('Xóa tất cả'),
                  ),
                ],
              ),
            ),

          // Grid sản phẩm
          Expanded(
            child: displayedProducts.isEmpty
                ? const Center(child: Text('Không tìm thấy sản phẩm nào'))
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 320,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: displayedProducts.length,
              itemBuilder: (context, index) {
                final shoe = displayedProducts[index];
                return ShoeCard(
                  shoe: shoe,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(shoe: shoe),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, ProductProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Lọc theo màu sắc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Wrap(
                children: ['All', 'Đỏ', 'Đen', 'Trắng', 'Xanh', 'Vàng', 'Hồng'].map((color) {
                  return FilterChip(
                    label: Text(color),
                    selected: provider.selectedColor == color,
                    onSelected: (sel) {
                      provider.setColorFilter(sel ? color : 'All');
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Giới tính', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Wrap(
                children: ['All', 'Nam', 'Nữ', 'Unisex'].map((g) {
                  return FilterChip(
                    label: Text(g),
                    selected: provider.selectedGender == g,
                    onSelected: (sel) {
                      provider.setGenderFilter(sel ? g : 'All');
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}