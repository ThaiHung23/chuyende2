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
  // Chúng ta không cần biến searchQuery ở đây nữa vì đã có trong Provider
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    // BƯỚC 1: Lấy danh sách đã được lọc theo tìm kiếm từ Provider
    var displayedProducts = productProvider.filteredProducts;

    // BƯỚC 2: Tiếp tục lọc theo Danh mục (Category) nếu người dùng chọn
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
      ),
      body: Column(
        children: [
          // === Ô TÌM KIẾM ===
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  hintText: 'Tìm kiếm giày...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
              onChanged: (value) {
                // Chỉ cần gọi hàm này, UI sẽ tự động cập nhật nhờ notifyListeners()
                productProvider.searchProducts(value);
              },
            ),
          ),

          // === BỘ LỌC DANH MỤC ===
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

          // === GRID HIỂN THỊ SẢN PHẨM ===
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
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(shoe: shoe))
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}