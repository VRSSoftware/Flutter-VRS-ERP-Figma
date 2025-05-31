import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
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
  // App bar checkbox state
  bool _appBarViewChecked = false;
  // Per-order checkbox states
  Map<String, bool> _orderViewChecked = {};

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
        // RESTORED APP BAR ACTIONS
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String value) {
              switch (value) {
                case 'download':
                  _handleDownloadAll();
                  break;
                case 'whatsapp':
                  _handleWhatsAppShareAll();
                  break;
                case 'view':
                  _handleViewAll();
                  break;
                case 'withImage':
                  // Already handled by state change
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'download',
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                  leading: Icon(Icons.download, size: 20, color: Colors.blue),
                  title: Text('Download All'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'whatsapp',
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                  leading: FaIcon(FontAwesomeIcons.whatsapp, size: 20, color: Colors.green),
                  title: Text('WhatsApp All'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'view',
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                  leading: FaIcon(FontAwesomeIcons.eye, size: 20, color: Colors.green),
                  title: Text('View All'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'withImage',
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            alignment: Alignment.centerLeft,
                            child: Checkbox(
                              value: _appBarViewChecked,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _appBarViewChecked = newValue ?? false;
                                });
                                this.setState(() {
                                  _appBarViewChecked = newValue ?? false;
                                });
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            ),
                          ),
                          const SizedBox(width: 22),
                          const Text('With Image'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
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
                    
                    // List of orders with individual menus
                    ...orderDetails.map((order) {
                      return _buildOrderCard(order);
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  // App bar handlers (for all orders)
  void _handleDownloadAll() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading all orders...')),
    );
  }

  void _handleWhatsAppShareAll() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing all orders via WhatsApp ${_appBarViewChecked ? 'with images' : ''}')),
    );
  }

  void _handleViewAll() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing all orders ${_appBarViewChecked ? 'with images' : ''}')),
    );
  }
Widget _buildOrderCard(Map<String, dynamic> order) {
  // Format dates in standard dd/MM/yyyy HH:mm format
  String formattedDateTime = '';
  try {
    final date = DateFormat('yyyy-MM-dd').parse(order['OrderDate']);
    formattedDateTime = '${DateFormat('dd/MM/yyyy HH:mm').format(date)}';
  } catch (e) {
    formattedDateTime = '${order['OrderDate']} ${order['Created_Time'] ?? 'N/A'}';
  }

  String formattedDeliveryDate = '';
  try {
    final date = DateFormat('yyyy-MM-dd').parse(order['DlvDate']);
    formattedDeliveryDate = DateFormat('dd/MM/yyyy').format(date);
  } catch (e) {
    formattedDeliveryDate = order['DlvDate'] ?? 'N/A';
  }

  // Helper function to conditionally wrap text in Marquee if value is long
  Widget _buildTextWithMarquee(String text, TextStyle style, {double maxWidth = 100.0}) {
    const int lengthThreshold = 15; // Adjust threshold as needed
    if (text.length > lengthThreshold) {
      return SizedBox(
        width: maxWidth, // Adjust width based on available space
        height: 20.0, // Fixed height for marquee
        child: Marquee(
          text: text,
          style: style,
          scrollAxis: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          blankSpace: 20.0, // Space between scrolling repetitions
          velocity: 50.0, // Scrolling speed
          pauseAfterRound: const Duration(seconds: 1), // Pause after each scroll
          startPadding: 10.0, // Initial padding
          accelerationDuration: const Duration(seconds: 1),
          accelerationCurve: Curves.linear,
          decelerationDuration: const Duration(milliseconds: 500),
          decelerationCurve: Curves.linear,
        ),
      );
    }
    return Text(text, style: style);
  }

  return Container(
    width: double.infinity, // Use full width of the card
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.blueGrey.shade100),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: OrderNo, Order_Type, and DeliveryType as tags
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spread items across full width
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      size: 16,
                      color: Colors.indigo,
                    ),
                    const SizedBox(width: 6),
                    _buildTextWithMarquee(
                      '${order['OrderNo'] ?? 'N/A'}',
                      const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                      maxWidth: 100.0, // Adjust based on your layout
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.category,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 6),
                    _buildTextWithMarquee(
                      '${order['Order_Type'] ?? 'N/A'}',
                      const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                      maxWidth: 100.0,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_shipping,
                      size: 16,
                      color: Colors.teal,
                    ),
                    const SizedBox(width: 6),
                    _buildTextWithMarquee(
                      '${order['DeliveryType'] ?? 'N/A'}',
                      const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                      maxWidth: 100.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Second row: Qty, Amount, and WhatsAppMobileNo without tags
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTextWithMarquee(
                'Quantity: ${order['TotalQty'] ?? '0'}',
                const TextStyle(
                  fontSize: 13,
                  color: Colors.purple,
                ),
                maxWidth: 100.0,
              ),
              _buildTextWithMarquee(
                'Amount: ₹${order['TotalAmt'] ?? '0.00'}',
                const TextStyle(
                  fontSize: 13,
                  color: Colors.deepOrange,
                ),
                maxWidth: 100.0,
              ),
              Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    size: 13,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  _buildTextWithMarquee(
                    '${order['WhatsAppMobileNo']?.toString() ?? '-'}',
                    const TextStyle(
                      fontSize: 13,
                      color: Colors.green,
                    ),
                    maxWidth: 100.0,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Third row: Formatted DateTime, Delivery Date, and OrderPopupMenu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                   RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Ordered: ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey, // Static "Ordered" text in grey
                            ),
                          ),
                          TextSpan(
                            text: formattedDateTime,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue, // Dynamic value retains blue
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Delivery: ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey, // Static "Ordered" text in grey
                            ),
                          ),
                          TextSpan(
                            text: formattedDeliveryDate,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue, // Dynamic value retains blue
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _OrderPopupMenu(
                order: order,
                viewChecked: _orderViewChecked[order['OrderNo']] ?? false,
                onViewCheckedChanged: (value) {
                  setState(() {
                    _orderViewChecked[order['OrderNo']] = value;
                  });
                },
                onDownload: () => _handleOrderDownload(order),
                onWhatsApp: () => _handleOrderWhatsAppShare(order),
                onView: () => _handleOrderView(order),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
 
  void _handleOrderDownload(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading order: ${order['OrderNo']}')),
    );
  }

  void _handleOrderWhatsAppShare(Map<String, dynamic> order) {
    final withImage = _orderViewChecked[order['OrderNo']] ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing order ${order['OrderNo']} via WhatsApp ${withImage ? 'with image' : ''}')),
    );
  }

  void _handleOrderView(Map<String, dynamic> order) {
    final withImage = _orderViewChecked[order['OrderNo']] ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing order ${order['OrderNo']} ${withImage ? 'with image' : ''}')),
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
}
  // Reusable popup menu widget for orders
  class _OrderPopupMenu extends StatelessWidget {
    final Map<String, dynamic> order;
    final bool viewChecked;
    final ValueChanged<bool> onViewCheckedChanged;
    final VoidCallback onDownload;
    final VoidCallback onWhatsApp;
    final VoidCallback onView;

    const _OrderPopupMenu({
      required this.order,
      required this.viewChecked,
      required this.onViewCheckedChanged,
      required this.onDownload,
      required this.onWhatsApp,
      required this.onView,
    });

    @override
    Widget build(BuildContext context) {
      return PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
        onSelected: (String value) {
          switch (value) {
            case 'download':
              onDownload();
              break;
            case 'whatsapp':
              onWhatsApp();
              break;
            case 'view':
              onView();
              break;
            case 'withImage':
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'download',
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              leading: Icon(Icons.download, size: 20, color: Colors.blue),
              title: Text('Download'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'whatsapp',
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              leading: FaIcon(FontAwesomeIcons.whatsapp, size: 20, color: Colors.green),
              title: Text('WhatsApp'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'view',
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              leading: FaIcon(FontAwesomeIcons.eye, size: 20, color: Colors.green),
              title: Text('View'),
            ),
          ),
          PopupMenuItem<String>(
            value: 'withImage',
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        alignment: Alignment.centerLeft,
                        child: Checkbox(
                          value: viewChecked,
                          onChanged: (bool? newValue) {
                            setState(() {
                              onViewCheckedChanged(newValue ?? false);
                            });
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        ),
                      ),
                      const SizedBox(width: 22),
                      const Text('With Image'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
  }
