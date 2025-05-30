import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';

class OrderDetailsPage extends StatelessWidget {
  final List<Map<String, dynamic>> orderDetails;

  const OrderDetailsPage({super.key, required this.orderDetails});

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    int totalOrders = orderDetails.fold(0, (sum, item) => sum + (item['totalorder'] as int));
    int totalQuantity = orderDetails.fold(0, (sum, item) => sum + (item['totalqty'] as int));
    int totalAmount = orderDetails.fold(0, (sum, item) => sum + (item['totalamt'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard('Total Orders', totalOrders.toString()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('Total Qty', totalQuantity.toString()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('Total Amount', '₹${totalAmount.toString()}'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Customer Order Details
            ...orderDetails.map((order) {
              return Column(
                children: [
                  _buildCustomerOrderCard(order),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerOrderCard(Map<String, dynamic> order) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Name and City
            Text(
              order['customernamewithcity'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),

            // Order Details Table
            Table(
              border: TableBorder.all(color: Colors.grey.withOpacity(0.3)),
              children: [
                // Header Row
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFFE3F2FD)),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('TOTAL ORDER', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('TOTAL QTY', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('TOTAL AMOUNT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                // Data Row
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(order['totalorder'].toString()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(order['totalqty'].toString()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('₹${order['totalamt'].toString()}'),
                    ),
                  ],
                ),
              ],
            ),

            // WhatsApp Numbers (if available)
            if (order['whatsappmobileno'] != null && order['whatsappmobileno'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  order['whatsappmobileno'].toString(),
                  style: const TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}