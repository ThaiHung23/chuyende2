import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final totalSales = orderProvider.orders.fold(0.0, (sum, order) => sum + order.total);
    final orderCount = orderProvider.orders.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo bán hàng'), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(title: const Text('Tổng số đơn hàng'), trailing: Text('$orderCount đơn')),
            ),
            Card(
              child: ListTile(title: const Text('Tổng doanh thu'), trailing: Text('${totalSales.toStringAsFixed(0)} VNĐ')),
            ),
            const SizedBox(height: 30),
            const Text('Doanh thu 7 ngày gần nhất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 5000000,
                  barGroups: List.generate(7, (index) {
                    final value = (index + 1) * 650000.0;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(toY: value, color: Colors.red, width: 18, borderRadius: BorderRadius.circular(6)),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text('T${value.toInt() + 1}'))),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Danh sách đơn hàng gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: orderProvider.orders.length,
                itemBuilder: (context, index) {
                  final order = orderProvider.orders[index];
                  return ListTile(
                    title: Text('Đơn #${order.id.substring(0, 8)}'),
                    subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(order.date)),
                    trailing: Text('${order.total.toStringAsFixed(0)} VNĐ'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}