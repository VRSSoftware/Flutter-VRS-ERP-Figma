import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';

import 'customerOrderDetailsPage.dart';

class OrderDetailsPage extends StatelessWidget {
  final List<Map<String, dynamic>> orderDetails;
    final DateTime fromDate;  // Add these
  final DateTime toDate;    // Add these


  const OrderDetailsPage({super.key, required this.orderDetails,
     required this.fromDate,  // Add these
    required this.toDate,
  });

  @override
  Widget build(BuildContext context) {
    int totalOrders = orderDetails.fold(0, (sum, item) => sum + (item['totalorder'] as int));
    int totalQuantity = orderDetails.fold(0, (sum, item) => sum + (item['totalqty'] as int));
    int totalAmount = orderDetails.fold(0, (sum, item) => sum + (item['totalamt'] as int));

    return Scaffold(
        backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text('Order Details', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  _buildSummaryCard('Total Orders', totalOrders.toString()),
                  const SizedBox(width: 8),
                  _buildSummaryCard('Total Qty', totalQuantity.toString()),
                  const SizedBox(width: 8),
                  _buildSummaryCard('Total Amount', '₹${totalAmount.toString()}'),
                ],
              ),
              const SizedBox(height: 20),
              ...orderDetails.map((order) {
                return Column(
                  children: [
                    _buildCustomerOrderCard(context,order),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Expanded(
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildCustomerOrderCard(BuildContext context,Map<String, dynamic> order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerOrderDetailsPage(
              custKey: order['cust_key'] ?? '',
              customerName: order['customernamewithcity'] ?? '',
              fromDate: fromDate,  // Pass fromDate
              toDate: toDate,      // Pass toDate
            ),
          ),
        );
      },
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Name and City
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                order['customernamewithcity'] ?? '',
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Table
            Table(
              border: TableBorder.all(color: Colors.grey.withOpacity(0.3)),
              columnWidths: const {
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color.fromARGB(255, 226, 240, 245)),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(
                        'TOTAL ORDER',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(
                        'TOTAL QTY',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(
                        'TOTAL AMOUNT',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(order['totalorder'].toString(), style: const TextStyle(fontSize: 12)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(order['totalqty'].toString(), style: const TextStyle(fontSize: 12)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text('₹${order['totalamt'].toString()}', style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),

            if (order['whatsappmobileno'] != null && order['whatsappmobileno'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      size: 12,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order['whatsappmobileno'].toString(),
                      overflow: TextOverflow.visible,
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
     ) );
  }
}
