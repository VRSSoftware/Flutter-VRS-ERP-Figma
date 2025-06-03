import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/dashboard/customerOrderDetailsPage.dart';
import 'package:vrs_erp_figma/dashboard/orderStatus.dart';

class OrderDetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> orderDetails;
  final DateTime fromDate;
  final DateTime toDate;

  const OrderDetailsPage({
    super.key,
    required this.orderDetails,
    required this.fromDate,
    required this.toDate,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  @override
  Widget build(BuildContext context) {
    int totalOrders = widget.orderDetails.fold(
      0,
      (sum, item) => sum + (item['totalorder'] as int),
    );
    int totalQuantity = widget.orderDetails.fold(
      0,
      (sum, item) => sum + (item['totalqty'] as int),
    );
    int totalAmount = widget.orderDetails.fold(
      0,
      (sum, item) => sum + (item['totalamt'] as int),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Colors.white, size: 24),
            tooltip: 'Order Status',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderStatus()),
              );
            },
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String value) {
              switch (value) {
                case 'download':
                  _handleDownload();
                  break;
                case 'whatsapp':
                  _handleWhatsAppShare();
                  break;
                case 'view':
                  _handleView();
                  break;
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'download',
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 0.0,
                      ),
                      leading: Icon(
                        Icons.download,
                        size: 20,
                        color: Colors.blue,
                      ),
                      title: Text('Download'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'whatsapp',
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 0.0,
                      ),
                      leading: FaIcon(
                        FontAwesomeIcons.whatsapp,
                        size: 20,
                        color: Colors.green,
                      ),
                      title: Text('WhatsApp'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'view',
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 0.0,
                      ),
                      leading: FaIcon(
                        FontAwesomeIcons.eye,
                        size: 18,
                        color: Colors.blue,
                      ),
                      title: Text('View'),
                    ),
                  ),
                ],
          ),
        ],
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
                  _buildSummaryCard(
                    'Total Amount',
                    '₹${totalAmount.toString()}',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...widget.orderDetails.map((order) {
                return Column(
                  children: [
                    _buildCustomerOrderCard(context, order),
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

  void _handleDownload() {
    // Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download functionality will be implemented here'),
      ),
    );
  }

  void _handleWhatsAppShare() {
    // Implement WhatsApp share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('WhatsApp share functionality will be implemented here'),
      ),
    );
  }

  void _handleView() {
    // Implement WhatsApp share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('view functionality will be implemented here'),
      ),
    );
  }

  // Widget _buildSummaryCard(String title, String value) {
  //   return Expanded(
  //     child: Container(
  //       height: 90,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         border: Border.all(color: Colors.grey.shade300),
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(10.0),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Text(
  //               title,
  //               overflow: TextOverflow.visible,
  //               style: const TextStyle(
  //                 fontSize: 13,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             const SizedBox(height: 6),
  //             Text(
  //               value,
  //               overflow: TextOverflow.visible,
  //               style: const TextStyle(
  //                 fontSize: 15,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildSummaryCard(String title, String value) {
    // Determine colors based on card type
    Color cardColor;
    Color textColor;
    IconData iconData;

    switch (title) {
      case 'Total Orders':
        cardColor = Colors.indigo.withOpacity(0.1);
        textColor = Colors.indigo;
        iconData = Icons.receipt_long;
        break;
      case 'Total Qty':
        cardColor = Colors.amber.withOpacity(0.1);
        textColor = Colors.amber;
        iconData = Icons.format_list_numbered;
        break;
      case 'Total Amount':
        cardColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        iconData = Icons.currency_rupee;
        break;
      default:
        cardColor = Colors.blueGrey.withOpacity(0.1);
        textColor = Colors.blueGrey;
        iconData = Icons.info;
    }

    return Expanded(
      child: Container(
        height: 115,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blueGrey.shade100),
          borderRadius: BorderRadius.circular(0),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(0.1),
          //     blurRadius: 3,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: 20, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title == 'Total Amount' ? '$value' : value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerOrderCard(
    BuildContext context,
    Map<String, dynamic> order,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CustomerOrderDetailsPage(
                  custKey: order['cust_key'] ?? '',
                  customerName: order['customernamewithcity'] ?? '',
                  fromDate: widget.fromDate,
                  toDate: widget.toDate,
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
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 226, 240, 245),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Text(
                          'TOTAL ORDER',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Text(
                          'TOTAL QTY',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Text(
                          'TOTAL AMOUNT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          order['totalorder'].toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          order['totalqty'].toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          '₹${order['totalamt'].toString()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (order['whatsappmobileno'] != null &&
                  order['whatsappmobileno'].toString().isNotEmpty)
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
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
