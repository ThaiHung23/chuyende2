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
              subtitle: Text('${shoe.brand} • ${shoe.category} • ${shoe.gender} • ${shoe.price.toStringAsFixed(0)} VNĐ'),
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
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40));
    } else if (imageUrl.startsWith('/') || imageUrl.contains('emulated')) {
      return Image.file(File(imageUrl), width: 60, height: 60, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40));
    } else {
      return Image.asset(imageUrl, width: 60, height: 60, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40));
    }
  }

  Widget _buildEditImage(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return Image.network(imagePath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50));
    } else if (imagePath.startsWith('/') || imagePath.contains('emulated')) {
      return Image.file(File(imagePath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50));
    } else {
      return Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50));
    }
  }

  // ====================== THÊM SẢN PHẨM ======================
  void _showAddProductDialog(BuildContext context, ProductProvider provider) {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final categoryController = TextEditingController(text: 'Running');
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    final sizesController = TextEditingController(text: '38,39,40');
    final colorsController = TextEditingController(text: 'Đen,Trắng');

    String selectedGender = 'Unisex';
    String? selectedImagePath;

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
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setStateDialog(() => selectedImagePath = image.path);
                      }
                    },
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                      child: selectedImagePath == null
                          ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 50, color: Colors.grey), Text('Chọn ảnh')])
                          : Image.file(File(selectedImagePath!), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên sản phẩm *')),
                  TextField(controller: brandController, decoration: const InputDecoration(labelText: 'Thương hiệu *')),
                  TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Danh mục *')),

                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(labelText: 'Giới tính *'),
                    items: ['Nam', 'Nữ', 'Unisex'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (value) => setStateDialog(() => selectedGender = value!),
                  ),

                  TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Giá (VNĐ) *'), keyboardType: TextInputType.number),
                  TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Mô tả'), maxLines: 2),
                  TextField(controller: sizesController, decoration: const InputDecoration(labelText: 'Size')),
                  TextField(controller: colorsController, decoration: const InputDecoration(labelText: 'Màu sắc')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty || brandController.text.isEmpty || priceController.text.isEmpty || selectedImagePath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đầy đủ *')));
                    return;
                  }

                  final newShoe = Shoe(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    brand: brandController.text,
                    category: categoryController.text,
                    price: double.tryParse(priceController.text) ?? 0,
                    imageUrl: selectedImagePath!,
                    description: descriptionController.text,
                    sizes: sizesController.text.split(',').map((e) => e.trim()).toList(),
                    colors: colorsController.text.split(',').map((e) => e.trim()).toList(),
                    gender: selectedGender,
                  );

                  provider.addProduct(newShoe);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thêm thành công!')));
                },
                child: const Text('Thêm'),
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
    final descriptionController = TextEditingController(text: shoe.description);
    final sizesController = TextEditingController(text: shoe.sizes.join(','));
    final colorsController = TextEditingController(text: shoe.colors.join(','));

    // FIX: Chuẩn hóa giá trị gender để khớp với dropdown
    String selectedGender = shoe.gender == 'unisex' || shoe.gender.toLowerCase() == 'unisex'
        ? 'Unisex'
        : shoe.gender;

    String? newImagePath = shoe.imageUrl;

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
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) setStateDialog(() => newImagePath = image.path);
                    },
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                      child: _buildEditImage(newImagePath!),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên sản phẩm')),
                  TextField(controller: brandController, decoration: const InputDecoration(labelText: 'Thương hiệu')),
                  TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Danh mục')),

                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(labelText: 'Giới tính'),
                    items: ['Nam', 'Nữ', 'Unisex'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (value) => setStateDialog(() => selectedGender = value!),
                  ),

                  TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Giá (VNĐ)'), keyboardType: TextInputType.number),
                  TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Mô tả'), maxLines: 2),
                  TextField(controller: sizesController, decoration: const InputDecoration(labelText: 'Size')),
                  TextField(controller: colorsController, decoration: const InputDecoration(labelText: 'Màu sắc')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty || brandController.text.isEmpty) return;

                  final updatedShoe = Shoe(
                    id: shoe.id,
                    name: nameController.text,
                    brand: brandController.text,
                    category: categoryController.text,
                    price: double.tryParse(priceController.text) ?? shoe.price,
                    imageUrl: newImagePath!,
                    description: descriptionController.text,
                    sizes: sizesController.text.split(',').map((e) => e.trim()).toList(),
                    colors: colorsController.text.split(',').map((e) => e.trim()).toList(),
                    gender: selectedGender,
                    reviews: shoe.reviews,
                  );

                  provider.updateProduct(shoe.id, updatedShoe);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }
}