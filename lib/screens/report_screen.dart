import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io'; // THÊM IMPORT NÀY
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../models/shoe.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  // Widget hiển thị ảnh - ĐÃ SỬA LỖI CHO FILE LOCAL
  Widget _buildProductImage(Shoe? shoe, {double size = 50}) {
    if (shoe == null) {
      return _buildFallbackImage(size);
    }

    String? imageUrl = shoe.imageUrl;
    print('🔍 Đang xử lý ảnh: $imageUrl');

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildFallbackImage(size);
    }

    // TRƯỜNG HỢP 1: Đường dẫn file local (bắt đầu bằng /data/ hoặc /storage/)
    if (imageUrl.startsWith('/data/') ||
        imageUrl.startsWith('/storage/') ||
        imageUrl.startsWith('file://')) {

      // Xóa prefix file:// nếu có
      String filePath = imageUrl;
      if (filePath.startsWith('file://')) {
        filePath = filePath.substring(7);
      }

      final file = File(filePath);

      // Kiểm tra file có tồn tại không
      if (file.existsSync()) {
        print('✅ File tồn tại: $filePath');
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('❌ Lỗi load file: $error');
              return _buildFallbackImage(size);
            },
          ),
        );
      } else {
        print('⚠️ File không tồn tại: $filePath');
        return _buildFallbackImage(size);
      }
    }

    // TRƯỜNG HỢP 2: Ảnh asset
    if (imageUrl.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Lỗi load asset: $imageUrl');
            return _buildFallbackImage(size);
          },
        ),
      );
    }

    // TRƯỜNG HỢP 3: Ảnh network
    if (imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildLoadingImage(size),
          errorWidget: (context, url, error) {
            print('❌ Lỗi load network: $url');
            return _buildFallbackImage(size);
          },
        ),
      );
    }

    // TRƯỜNG HỢP 4: Không xác định
    print('⚠️ Đường dẫn không xác định: $imageUrl');
    return _buildFallbackImage(size);
  }

  // Ảnh fallback khi không có ảnh
  Widget _buildFallbackImage(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        size: size * 0.5,
        color: Colors.grey[400],
      ),
    );
  }

  // Loading placeholder
  Widget _buildLoadingImage(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: size * 0.3,
          height: size * 0.3,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    // DEBUG: Kiểm tra file có tồn tại không
    if (orders.isNotEmpty && orders.first.items.isNotEmpty) {
      final shoe = orders.first.items.first.shoe;
      final imageUrl = shoe.imageUrl;
      if (imageUrl != null && imageUrl.startsWith('/data/')) {
        final file = File(imageUrl);
        print('🔍 Kiểm tra file: ${file.existsSync()}');
      }
    }

    // 1. Tính toán tổng quan
    final totalSales = orders.fold(0.0, (sum, order) => sum + order.total);
    final totalOrders = orders.length;

    // 2. Tính toán doanh thu 7 ngày gần nhất
    final List<double> dailyRevenue = List.filled(7, 0.0);
    final now = DateTime.now();
    for (var order in orders) {
      final difference = now.difference(order.date).inDays;
      if (difference >= 0 && difference < 7) {
        dailyRevenue[6 - difference] += order.total;
      }
    }

    // 3. Tính toán mặt hàng bán chạy
    final Map<String, int> productSalesCount = {};
    final Map<String, Shoe> productDetails = {};

    for (var order in orders) {
      for (var item in order.items) {
        final shoeId = item.shoe.id;
        productSalesCount[shoeId] = (productSalesCount[shoeId] ?? 0) + item.quantity;
        productDetails[shoeId] = item.shoe;
      }
    }

    final topSellingProducts = productSalesCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    // Xác định maxY cho biểu đồ
    double maxRev = dailyRevenue.isEmpty ? 1000000 : dailyRevenue.reduce((a, b) => a > b ? a : b);
    if (maxRev == 0) maxRev = 1000000;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Báo cáo kinh doanh',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với 2 card thống kê
            Stack(
              children: [
                Container(
                  height: 60,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      _buildSummaryCard(
                        'Tổng doanh thu',
                        currencyFormat.format(totalSales),
                        Icons.payments_rounded,
                        Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _buildSummaryCard(
                        'Tổng đơn hàng',
                        '$totalOrders',
                        Icons.local_shipping_rounded,
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // --- Biểu đồ doanh thu ---
                  const Text(
                    'Biểu đồ doanh thu (7 ngày)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 260,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxRev * 1.3,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => Colors.redAccent,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                currencyFormat.format(rod.toY),
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final date = now.subtract(Duration(days: 6 - value.toInt()));
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateFormat('dd/MM').format(date),
                                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: dailyRevenue[index],
                                color: Colors.redAccent,
                                width: 18,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Mặt hàng bán chạy ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mặt hàng bán chạy',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Xem tất cả',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),

                  if (topSellingProducts.isEmpty)
                    _buildEmptyBox('Chưa có dữ liệu bán hàng')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: topSellingProducts.length > 3 ? 3 : topSellingProducts.length,
                      itemBuilder: (context, index) {
                        final entry = topSellingProducts[index];
                        final shoe = productDetails[entry.key]!;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: _buildProductImage(shoe, size: 60),
                            title: Text(
                              shoe.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Text(
                              'Đã bán: ${entry.value} sản phẩm',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: Text(
                              currencyFormat.format(shoe.price * entry.value),
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),

                  // --- Đơn hàng gần đây ---
                  const Text(
                    'Đơn hàng gần đây',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (orders.isEmpty)
                    _buildEmptyBox('Chưa có đơn hàng nào')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length > 5 ? 5 : orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[orders.length - 1 - index];
                        final firstItem = order.items.isNotEmpty ? order.items.first : null;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              _buildProductImage(firstItem?.shoe, size: 55),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      firstItem?.shoe.name ?? 'Đơn hàng mới',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Mã: #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}',
                                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                    ),
                                    Text(
                                      DateFormat('dd/MM HH:mm').format(order.date),
                                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currencyFormat.format(order.total),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      order.status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getStatusColor(order.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget card thống kê
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị khi không có dữ liệu
  Widget _buildEmptyBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, size: 40, color: Colors.grey[200]),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Lấy màu sắc theo trạng thái đơn hàng
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Hoàn thành':
      case 'Đã giao':
        return Colors.green;
      case 'Đang xử lý':
        return Colors.orange;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}