import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoe_store_app/screens/wishlist_screen.dart';
import '../providers/product_provider.dart';
import '../widgets/shoe_card.dart';
import '../widgets/banner_carousel.dart';
import 'shop_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const ShopScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.red,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Cửa hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Giỏ hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    // SỬA TẠI ĐÂY: Lấy danh sách đã lọc từ getter 'filteredProducts' trong Provider
    final displayedProducts = productProvider.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anh em chat Store'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Ô TÌM KIẾM ===
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  // Gọi hàm search để cập nhật từ khóa trong Provider
                  productProvider.searchProducts(value);
                },
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm giày thể thao...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      productProvider.searchProducts('');
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),

            // Banner
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: BannerCarousel(),
            ),

            const SizedBox(height: 20),

            // Tiêu đề
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _searchController.text.isEmpty ? 'Sản phẩm nổi bật' : 'Kết quả tìm kiếm',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // Grid sản phẩm
            displayedProducts.isEmpty && _searchController.text.isNotEmpty
                ? const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('Không tìm thấy sản phẩm nào', style: TextStyle(fontSize: 16))),
            )
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                    MaterialPageRoute(builder: (_) => ProductDetailScreen(shoe: shoe)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}