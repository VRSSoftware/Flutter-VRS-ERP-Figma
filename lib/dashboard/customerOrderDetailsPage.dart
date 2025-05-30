import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/constants/app_constants.dart';

class CustomerOrderDetailsPage extends StatefulWidget {
  final String custKey;
  final String customerName;
  final DateTime fromDate;
  final DateTime toDate;

  const CustomerOrderDetailsPage({
    super.key,
    required this.custKey,
    required this.customerName,
    required this.fromDate,
    required this.toDate,
  });

  @override
  State<CustomerOrderDetailsPage> createState() => _CustomerOrderDetailsPageState();
}

class _CustomerOrderDetailsPageState extends State<CustomerOrderDetailsPage> {
  List<Map<String, dynamic>> orderDetails = [];
  bool isLoading = true;
  int totalOrders = 0;
  int totalQuantity = 0;
  int totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.BASE_URL}/report/getReportsDetail'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "FromDate": DateFormat('yyyy-MM-dd').format(widget.fromDate),
          "ToDate": DateFormat('yyyy-MM-dd').format(widget.toDate),
          "CoBr_Id": "01",
          "CustKey": widget.custKey,
          "SalesPerson": null,
          "State": null,
          "City": null,
          "orderType": "TotalOrder",
          "Detail": 2
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            orderDetails = List<Map<String, dynamic>>.from(data);
            totalOrders = orderDetails.length;
            totalQuantity = orderDetails.fold(0, (sum, item) => sum + (int.tryParse(item['TotalQty'].toString()) ?? 0));
            totalAmount = orderDetails.fold(0, (sum, item) => sum + (int.tryParse(item['TotalAmt'].toString()) ?? 0));
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load order details: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      // Show error message using ScaffoldMessenger
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Summary cards
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
                    
                    // Customer name
                    Text(
                      widget.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // List of orders
                    ...orderDetails.map((order) {
                      return _buildOrderCard(order);
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
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    // Format order date and time
    String formattedDateTime = '';
    try {
      final date = DateFormat('yyyy-MM-dd').parse(order['OrderDate']);
      formattedDateTime = '${DateFormat('dd/MM/yyyy').format(date)} ${order['Created_Time']}';
    } catch (e) {
      formattedDateTime = '${order['OrderDate']} ${order['Created_Time']}';
    }

    // Format delivery date
    String formattedDeliveryDate = '';
    try {
      final date = DateFormat('yyyy-MM-dd').parse(order['DlvDate']);
      formattedDeliveryDate = DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      formattedDeliveryDate = order['DlvDate'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order type and order number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['Order_Type'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order['OrderNo'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Order date and time
            Text(
              formattedDateTime,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 10),
            
            // Quantity and amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Qty: ${order['TotalQty']}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Amount: ₹${order['TotalAmt']}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Delivery status and date
            Text(
              order['DeliveryType'] ?? '',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'Delivery Date: $formattedDeliveryDate',
              style: const TextStyle(fontSize: 12),
            ),
            
            // WhatsApp number if available
            if (order['WhatsAppMobileNo'] != null && order['WhatsAppMobileNo'].toString().isNotEmpty)
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
                      order['WhatsAppMobileNo'].toString(),
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}