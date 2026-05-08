import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/product_provider.dart';
import '../models/shoe.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});
  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý kho hàng'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            onPressed: () => _showAddProductDialog(context, productProvider),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: productProvider.products.length,
        itemBuilder: (context, index) {
          final shoe = productProvider.products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImage(shoe.imageUrl),
              ),
              title: Text(shoe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${shoe.brand} • ${shoe.category} • ${shoe.gender}'),
                  Text(
                    '${shoe.price.toStringAsFixed(0)} VNĐ',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Tồn kho: ${shoe.stock}',
                    style: TextStyle(
                      color: shoe.stock < 5 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditProductDialog(context, productProvider, shoe),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => productProvider.deleteProduct(shoe.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
      );
    } else if (imageUrl.startsWith('/') || imageUrl.contains('emulated')) {
      return Image.file(
        File(imageUrl),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
      );
    } else {
      return Image.asset(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
      );
    }
  }

  Widget _buildEditImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
      );
    } else if (imagePath.startsWith('/') || imagePath.contains('emulated')) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
      );
    }
  }

  // ====================== THÊM SẢN PHẨM (CÓ NHẬP URL) ======================
  void _showAddProductDialog(BuildContext context, ProductProvider provider) {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final categoryController = TextEditingController(text: 'Running');
    final priceController = TextEditingController();
    final stockController = TextEditingController(text: '0');
    final descriptionController = TextEditingController();
    final sizesController = TextEditingController(text: '38,39,40');
    final colorsController = TextEditingController(text: 'Đen,Trắng');
    final imageUrlController = TextEditingController(); // URL ảnh

    String selectedGender = 'Unisex';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Thêm sản phẩm mới'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ===== PHẦN NHẬP URL ẢNH =====
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.link, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'NHẬP URL ẢNH SẢN PHẨM',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageUrlController,
                          decoration: InputDecoration(
                            hintText: 'https://example.com/shoe-image.jpg',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '📌 Mẹo: Lên Google Images tìm ảnh giày -> Chuột phải -> Copy image address -> Dán vào đây',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hiển thị preview ảnh nếu có URL
                  if (imageUrlController.text.trim().isNotEmpty)
                    Column(
                      children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrlController.text.trim(),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Không thể tải ảnh', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  const Divider(),

                  // Thông tin sản phẩm
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên sản phẩm *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_bag),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: brandController,
                    decoration: const InputDecoration(
                      labelText: 'Thương hiệu *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.branding_watermark),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Danh mục *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Giới tính *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                      DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                      DropdownMenuItem(value: 'Unisex', child: Text('Unisex')),
                    ],
                    onChanged: (value) => setStateDialog(() => selectedGender = value!),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Giá (VNĐ) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: stockController,
                    decoration: const InputDecoration(
                      labelText: 'Số lượng tồn kho *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: sizesController,
                    decoration: const InputDecoration(
                      labelText: 'Size (cách nhau bằng dấu phẩy)',
                      hintText: '38,39,40,41',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.straighten),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: colorsController,
                    decoration: const InputDecoration(
                      labelText: 'Màu sắc (cách nhau bằng dấu phẩy)',
                      hintText: 'Đen,Trắng,Đỏ',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.palette),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  // Kiểm tra URL ảnh
                  if (imageUrlController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng nhập URL ảnh sản phẩm'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Kiểm tra các trường bắt buộc
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập tên sản phẩm'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (brandController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập thương hiệu'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (priceController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập giá'), backgroundColor: Colors.red),
                    );
                    return;
                  }

                  // Tạo sản phẩm mới
                  final newShoe = Shoe(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    brand: brandController.text.trim(),
                    category: categoryController.text.trim(),
                    price: double.tryParse(priceController.text.trim()) ?? 0,
                    stock: int.tryParse(stockController.text.trim()) ?? 0,
                    imageUrl: imageUrlController.text.trim(), // Lưu URL
                    description: descriptionController.text.trim(),
                    sizes: sizesController.text.split(',').map((e) => e.trim()).toList(),
                    colors: colorsController.text.split(',').map((e) => e.trim()).toList(),
                    gender: selectedGender,
                  );

                  // Thêm vào Firestore
                  provider.addProduct(newShoe);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Thêm sản phẩm thành công!'), backgroundColor: Colors.green),
                  );
                },
                child: const Text('THÊM SẢN PHẨM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ====================== SỬA SẢN PHẨM ======================
  void _showEditProductDialog(BuildContext context, ProductProvider provider, Shoe shoe) {
    final nameController = TextEditingController(text: shoe.name);
    final brandController = TextEditingController(text: shoe.brand);
    final categoryController = TextEditingController(text: shoe.category);
    final priceController = TextEditingController(text: shoe.price.toString());
    final stockController = TextEditingController(text: shoe.stock.toString());
    final descriptionController = TextEditingController(text: shoe.description);
    final sizesController = TextEditingController(text: shoe.sizes.join(','));
    final colorsController = TextEditingController(text: shoe.colors.join(','));
    final imageUrlController = TextEditingController(text: shoe.imageUrl);

    String selectedGender = shoe.gender == 'unisex' || shoe.gender.toLowerCase() == 'unisex'
        ? 'Unisex'
        : shoe.gender;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Sửa sản phẩm'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Phần URL ảnh
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.link, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'URL ẢNH SẢN PHẨM',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageUrlController,
                          decoration: const InputDecoration(
                            hintText: 'https://example.com/shoe-image.jpg',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Preview ảnh hiện tại
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildEditImage(shoe.imageUrl),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Divider(),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Tên sản phẩm', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: brandController,
                    decoration: const InputDecoration(labelText: 'Thương hiệu', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Danh mục', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(labelText: 'Giới tính', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                      DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                      DropdownMenuItem(value: 'Unisex', child: Text('Unisex')),
                    ],
                    onChanged: (value) => setStateDialog(() => selectedGender = value!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Giá (VNĐ)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: 'Số lượng tồn kho', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: sizesController,
                    decoration: const InputDecoration(labelText: 'Size (cách nhau bằng dấu phẩy)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: colorsController,
                    decoration: const InputDecoration(labelText: 'Màu sắc (cách nhau bằng dấu phẩy)', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  if (imageUrlController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập URL ảnh'), backgroundColor: Colors.red),
                    );
                    return;
                  }

                  final updatedShoe = Shoe(
                    id: shoe.id,
                    name: nameController.text,
                    brand: brandController.text,
                    category: categoryController.text,
                    price: double.tryParse(priceController.text) ?? shoe.price,
                    stock: int.tryParse(stockController.text) ?? shoe.stock,
                    imageUrl: imageUrlController.text.trim(),
                    description: descriptionController.text,
                    sizes: sizesController.text.split(',').map((e) => e.trim()).toList(),
                    colors: colorsController.text.split(',').map((e) => e.trim()).toList(),
                    gender: selectedGender,
                    reviews: shoe.reviews,
                  );

                  provider.updateProduct(shoe.id, updatedShoe);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Cập nhật thành công!'), backgroundColor: Colors.green),
                  );
                },
                child: const Text('LƯU'),
              ),
            ],
          );
        },
      ),
    );
  }
}