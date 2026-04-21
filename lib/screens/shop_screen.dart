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

    // ✅ GIỮ NGUYÊN LOGIC FILTER
    if (selectedCategory != 'All') {
      displayedProducts = displayedProducts
          .where((shoe) => shoe.category == selectedCategory)
          .toList();
    }

    return Scaffold(
      // ❌ XÓA AppBar CỬA HÀNG

      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 10),

            // 🔥 SEARCH + CATEGORY (CÙNG HÀNG)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [

                  // 🔍 SEARCH
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Tìm kiếm giày...',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) =>
                                  productProvider.searchProducts(value), // giữ nguyên
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 🎯 CATEGORY FILTER
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 45,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: ['All', 'Running', 'Basketball', 'Casual']
                            .map((cat) {
                          final isSelected = selectedCategory == cat;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = isSelected ? 'All' : cat;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange.shade100
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.orange
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🎛 FILTER HIỆN TẠI (GIỮ NGUYÊN)
            if (productProvider.selectedColor != 'All' ||
                productProvider.selectedGender != 'All')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    if (productProvider.selectedColor != 'All')
                      Chip(
                        label:
                        Text('Màu: ${productProvider.selectedColor}'),
                        onDeleted: () =>
                            productProvider.setColorFilter('All'),
                      ),
                    if (productProvider.selectedGender != 'All')
                      Chip(
                        label:
                        Text('Giới tính: ${productProvider.selectedGender}'),
                        onDeleted: () =>
                            productProvider.setGenderFilter('All'),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: productProvider.clearFilters,
                      child: const Text('Xóa tất cả'),
                    ),
                  ],
                ),
              ),

            // 🛍 PRODUCT GRID (GIỮ NGUYÊN)
            Expanded(
              child: displayedProducts.isEmpty
                  ? const Center(child: Text('Không tìm thấy sản phẩm nào'))
                  : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
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
                        builder: (_) =>
                            ProductDetailScreen(shoe: shoe),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // 🔘 NÚT FILTER (GIỮ CHỨC NĂNG ICON CŨ)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.filter_list),
        onPressed: () =>
            _showFilterBottomSheet(context, productProvider),
      ),
    );
  }

  // 🔽 GIỮ NGUYÊN BOTTOM SHEET
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
              const Text('Lọc theo màu sắc',
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Wrap(
                children: ['All', 'Đỏ', 'Đen', 'Trắng', 'Xanh', 'Vàng', 'Hồng']
                    .map((color) {
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
              const Text('Giới tính',
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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