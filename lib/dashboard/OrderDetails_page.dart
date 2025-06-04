import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/dashboard/customerOrderDetailsPage.dart';
import 'package:vrs_erp_figma/dashboard/orderStatus.dart';
import 'package:url_launcher/url_launcher.dart';
class OrderDetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> orderDetails;
  final DateTime fromDate;
  final DateTime toDate;
  final String orderType;

  const OrderDetailsPage({
    super.key,
    required this.orderDetails,
    required this.fromDate,
    required this.toDate,
    required this.orderType,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}



class _OrderDetailsPageState extends State<OrderDetailsPage> {

  Future<void> _launchWhatsApp(String phoneNumber) async {
  final whatsappUrl = "https://wa.me/$phoneNumber";
  if (await canLaunch(whatsappUrl)) {
    await launch(whatsappUrl);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not launch WhatsApp')),
    );
  }
}

Future<void> _makePhoneCall(String phoneNumber) async {
  final phoneUrl = "tel:$phoneNumber";
  if (await canLaunch(phoneUrl)) {
    await launch(phoneUrl);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not make a call')),
    );
  }
}  

void _showContactOptions(BuildContext context, String phoneNumber) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ), 
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Colors.green,
            ),
            title: const Text('Message on WhatsApp'),
            onTap: () {
              Navigator.pop(context);
              _launchWhatsApp(phoneNumber);
            },
          ),
          ListTile(
            leading: const Icon(Icons.call, color: Colors.blue),
            title: const Text('Call'),
            onTap: () {
              Navigator.pop(context);
              _makePhoneCall(phoneNumber);
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.grey),
            title: const Text('Cancel'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}

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
                  Expanded(child: _buildSummaryCard('Total Orders', '15')),
                  SizedBox(width: 8),
                  Expanded(child: _buildSummaryCard('Total Qty', '200')),
                  SizedBox(width: 8),
                  Expanded(child: _buildSummaryCard('Total Amount', '₹5000')),
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

  
  Widget _buildSummaryCard(String title, String value) {
    IconData iconData;
    switch (title) {
      case 'Total Orders':
        iconData = Icons.receipt_long;
        break;
      case 'Total Qty':
        iconData = Icons.format_list_numbered;
        break;
      case 'Total Amount':
        iconData = Icons.currency_rupee;
        break;
      default:
        iconData = Icons.info;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 182, 181, 181)!),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 20, color: Colors.blue[700]),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.blue[900],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
                  orderType: widget.orderType,
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
    child: GestureDetector(
      onTap: () => _showContactOptions(
        context,
        order['whatsappmobileno'].toString(),
      ),
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
  ),
            ],
          ),
        ),
      ),
    );
  }
}
