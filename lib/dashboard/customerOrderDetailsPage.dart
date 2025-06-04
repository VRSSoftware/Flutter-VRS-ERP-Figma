// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:marquee/marquee.dart';
// import 'package:vrs_erp_figma/constants/app_constants.dart';
// import 'package:vrs_erp_figma/dashboard/data.dart';

// class CustomerOrderDetailsPage extends StatefulWidget {
//   final String custKey;
//   final String customerName;
//   final DateTime fromDate;
//   final DateTime toDate;
//   final String orderType;

//   const CustomerOrderDetailsPage({
//     super.key,
//     required this.custKey,
//     required this.customerName,
//     required this.fromDate,
//     required this.toDate,
//     required this.orderType,
//   });

//   @override
//   State<CustomerOrderDetailsPage> createState() =>
//       _CustomerOrderDetailsPageState();
// }

// class _CustomerOrderDetailsPageState extends State<CustomerOrderDetailsPage> {
//   List<Map<String, dynamic>> orderDetails = [];
//   bool isLoading = true;
//   int totalOrders = 0;
//   int totalQuantity = 0;
//   int totalAmount = 0;
//   // App bar checkbox state
//   bool _appBarViewChecked = false;
//   // Per-order checkbox states
//   Map<String, bool> _orderViewChecked = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchOrderDetails();
//   }

//   Future<void> _fetchOrderDetails() async {
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConstants.BASE_URL}/report/getReportsDetail'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "FromDate": DateFormat('yyyy-MM-dd').format(widget.fromDate),
//           "ToDate": DateFormat('yyyy-MM-dd').format(widget.toDate),
//           "CoBr_Id": UserSession.coBrId,
//           "CustKey": widget.custKey,
//           // "CustKey":
//           //   UserSession.userType == 'C'
//           //       ? UserSession.userLedKey
//           //       : FilterData.selectedLedgers!.isNotEmpty
//           //       ? FilterData.selectedLedgers!.map((b) => b.key).join(',')
//           //       : null,
//         "SalesPerson":
//             UserSession.userType == 'S'
//                 ? UserSession.userLedKey
//                 : FilterData.selectedSalespersons!.isNotEmpty == true
//                 ? FilterData.selectedSalespersons!.map((b) => b.key).join(',')
//                 : null,
//         "State":
//             FilterData.selectedStates!.isNotEmpty == true
//                 ? FilterData.selectedStates!.map((b) => b.key).join(',')
//                 : null,
//         "City":
//             FilterData.selectedCities!.isNotEmpty == true
//                 ? FilterData.selectedCities!.map((b) => b.key).join(',')
//                 : null,
//           // "SalesPerson": null,
//           // "State": null,
//           // "City": null,
//           "orderType": widget.orderType,
//           // "orderType": "TotalOrder",
//           "Detail": 2,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data is List) {
//           setState(() {
//             orderDetails = List<Map<String, dynamic>>.from(data);
//             totalOrders = orderDetails.length;
//             totalQuantity = orderDetails.fold(
//               0,
//               (sum, item) =>
//                   sum + (int.tryParse(item['TotalQty'].toString()) ?? 0),
//             );
//             totalAmount = orderDetails.fold(
//               0,
//               (sum, item) =>
//                   sum + (int.tryParse(item['TotalAmt'].toString()) ?? 0),
//             );
//             isLoading = false;
//           });
//         } else {
//           throw Exception('Unexpected response format');
//         }
//       } else {
//         throw Exception('Failed to load order details: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: $e')));
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           'Order Details',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: AppColors.primaryColor,
//         elevation: 1,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         // RESTORED APP BAR ACTIONS
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (String value) {
//               switch (value) {
//                 case 'download':
//                   _handleDownloadAll();
//                   break;
//                 case 'whatsapp':
//                   _handleWhatsAppShareAll();
//                   break;
//                 case 'view':
//                   _handleViewAll();
//                   break;
//                 case 'withImage':
//                   // Already handled by state change
//                   break;
//               }
//             },
//             itemBuilder:
//                 (BuildContext context) => <PopupMenuEntry<String>>[
//                   const PopupMenuItem<String>(
//                     value: 'download',
//                     child: ListTile(
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 16.0,
//                         vertical: 0.0,
//                       ),
//                       leading: Icon(
//                         Icons.download,
//                         size: 20,
//                         color: Colors.blue,
//                       ),
//                       title: Text('Download All'),
//                     ),
//                   ),
//                   const PopupMenuItem<String>(
//                     value: 'whatsapp',
//                     child: ListTile(
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 16.0,
//                         vertical: 0.0,
//                       ),
//                       leading: FaIcon(
//                         FontAwesomeIcons.whatsapp,
//                         size: 20,
//                         color: Colors.green,
//                       ),
//                       title: Text('WhatsApp All'),
//                     ),
//                   ),
//                   const PopupMenuItem<String>(
//                     value: 'view',
//                     child: ListTile(
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 16.0,
//                         vertical: 0.0,
//                       ),
//                       leading: FaIcon(
//                         FontAwesomeIcons.eye,
//                         size: 20,
//                         color: Colors.green,
//                       ),
//                       title: Text('View All'),
//                     ),
//                   ),
//                   PopupMenuItem<String>(
//                     value: 'withImage',
//                     child: StatefulBuilder(
//                       builder: (BuildContext context, StateSetter setState) {
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16.0,
//                             vertical: 8.0,
//                           ),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 20,
//                                 alignment: Alignment.centerLeft,
//                                 child: Checkbox(
//                                   value: _appBarViewChecked,
//                                   onChanged: (bool? newValue) {
//                                     setState(() {
//                                       _appBarViewChecked = newValue ?? false;
//                                     });
//                                     this.setState(() {
//                                       _appBarViewChecked = newValue ?? false;
//                                     });
//                                   },
//                                   materialTapTargetSize:
//                                       MaterialTapTargetSize.shrinkWrap,
//                                   visualDensity: const VisualDensity(
//                                     horizontal: -4,
//                                     vertical: -4,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 22),
//                               const Text('With Image'),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//           ),
//         ],
//       ),
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12.0,
//                   vertical: 12.0,
//                 ),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       // Summary cards
//                       Row(
//                         children: [
//                           _buildSummaryCard(
//                             'Total Orders',
//                             totalOrders.toString(),
//                           ),
//                           const SizedBox(width: 8),
//                           _buildSummaryCard(
//                             'Total Qty',
//                             totalQuantity.toString(),
//                           ),
//                           const SizedBox(width: 8),
//                           _buildSummaryCard(
//                             'Total Amount',
//                             '₹${totalAmount.toString()}',
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),

//                       // Customer name

//                       // Inside your widget:
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           const Icon(
//                             Icons.person,
//                             color: Colors.blue,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             widget.customerName,
//                             style: GoogleFonts.ubuntu(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue,
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 20),

//                       // List of orders with individual menus
//                       ...orderDetails.map((order) {
//                         return _buildOrderCard(order);
//                       }).toList(),
//                     ],
//                   ),
//                 ),
//               ),
//     );
//   }

//   // App bar handlers (for all orders)
//   void _handleDownloadAll() {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Downloading all orders...')));
//   }

//   void _handleWhatsAppShareAll() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Sharing all orders via WhatsApp ${_appBarViewChecked ? 'with images' : ''}',
//         ),
//       ),
//     );
//   }

//   void _handleViewAll() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Viewing all orders ${_appBarViewChecked ? 'with images' : ''}',
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderCard(Map<String, dynamic> order) {
//     // Format dates in standard dd/MM/yyyy HH:mm format
//     String formattedDateTime = '';
//     try {
//       final date = DateFormat('yyyy-MM-dd').parse(order['OrderDate']);
//       formattedDateTime = '${DateFormat('dd/MM/yyyy HH:mm').format(date)}';
//     } catch (e) {
//       formattedDateTime =
//           '${order['OrderDate']} ${order['Created_Time'] ?? 'N/A'}';
//     }

//     String formattedDeliveryDate = '';
//     try {
//       final date = DateFormat('yyyy-MM-dd').parse(order['DlvDate']);
//       formattedDeliveryDate = DateFormat('dd/MM/yyyy').format(date);
//     } catch (e) {
//       formattedDeliveryDate = order['DlvDate'] ?? 'N/A';
//     }

//     // Helper function to conditionally wrap text in Marquee if value is long
//     Widget _buildTextWithMarquee(
//       String text,
//       TextStyle style, {
//       double maxWidth = 100.0,
//     }) {
//       const int lengthThreshold = 15; // Adjust threshold as needed
//       if (text.length > lengthThreshold) {
//         return SizedBox(
//           width: maxWidth, // Adjust width based on available space
//           height: 20.0, // Fixed height for marquee
//           child: Marquee(
//             text: text,
//             style: style,
//             scrollAxis: Axis.horizontal,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             blankSpace: 20.0, // Space between scrolling repetitions
//             velocity: 50.0, // Scrolling speed
//             pauseAfterRound: const Duration(
//               seconds: 1,
//             ), // Pause after each scroll
//             startPadding: 10.0, // Initial padding
//             accelerationDuration: const Duration(seconds: 1),
//             accelerationCurve: Curves.linear,
//             decelerationDuration: const Duration(milliseconds: 500),
//             decelerationCurve: Curves.linear,
//           ),
//         );
//       }
//       return Text(text, style: style);
//     }

//     // Determine icon and text color based on DeliveryType
//     Color deliveryIconColor;
//     Color deliveryTextColor;
//     Color deliveryBorderColor;
//     String deliveryType = order['DeliveryType']?.toString() ?? 'N/A';
//     switch (deliveryType) {
//       case 'Approved':
//         deliveryIconColor = Colors.teal;
//         deliveryTextColor = Colors.teal;
//         deliveryBorderColor = Colors.teal;
//         break;
//       case 'Partially Delivered':
//         deliveryIconColor = Colors.orange;
//         deliveryTextColor = Colors.orange;
//         deliveryBorderColor = Colors.orange;
//         break;
//       case 'Delivered':
//         deliveryIconColor = Colors.blue;
//         deliveryTextColor = Colors.blue;
//         deliveryBorderColor = Colors.blue;
//         break;
//       case 'Completed':
//         deliveryIconColor = Colors.green;
//         deliveryTextColor = Colors.green;
//         deliveryBorderColor = Colors.green;
//         break;
//       case 'Partially Completed':
//         deliveryIconColor = Colors.greenAccent;
//         deliveryTextColor = Colors.greenAccent;
//         deliveryBorderColor = Colors.greenAccent;
//         break;
//       default:
//         deliveryIconColor = Colors.grey;
//         deliveryTextColor = Colors.grey;
//         deliveryBorderColor = Colors.grey;
//     }

//     return Container(
//       width: double.infinity, // Use full width of the card
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: Colors.blueGrey.shade100),
//         borderRadius: BorderRadius.circular(0),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // First row: OrderNo, Order_Type, and DeliveryType as tags
//             Row(
//               mainAxisAlignment:
//                   MainAxisAlignment
//                       .spaceBetween, // Spread items across full width
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8.0,
//                     vertical: 4.0,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.indigo.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(0),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.receipt_long,
//                         size: 16,
//                         color: Colors.indigo,
//                       ),
//                       const SizedBox(width: 6),
//                       _buildTextWithMarquee(
//                         '${order['OrderNo'] ?? 'N/A'}',
//                         const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.indigo,
//                         ),
//                         maxWidth: 100.0, // Adjust based on your layout
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8.0,
//                     vertical: 4.0,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.amber.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(0),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.category, size: 16, color: Colors.amber),
//                       const SizedBox(width: 6),
//                       _buildTextWithMarquee(
//                         '${order['Order_Type'] ?? 'N/A'}',
//                         const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.amber,
//                         ),
//                         maxWidth: 100.0,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8.0,
//                     vertical: 4.0,
//                   ),
//                   decoration: BoxDecoration(
//                     color: deliveryTextColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(0),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.local_shipping,
//                         size: 16,
//                         color: deliveryIconColor,
//                       ),
//                       const SizedBox(width: 6),
//                       _buildTextWithMarquee(
//                         deliveryType,
//                         TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: deliveryTextColor,
//                         ),
//                         maxWidth: 100.0,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             // Second row: Qty, Amount, and WhatsAppMobileNo without tags
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildTextWithMarquee(
//                   'Quantity: ${order['TotalQty'] ?? '0'}',
//                   const TextStyle(fontSize: 13, color: Colors.purple),
//                   maxWidth: 100.0,
//                 ),
//                 _buildTextWithMarquee(
//                   'Amount: ₹${order['TotalAmt'] ?? '0.00'}',
//                   const TextStyle(fontSize: 13, color: Colors.deepOrange),
//                   maxWidth: 100.0,
//                 ),
//                 Row(
//                   children: [
//                     const FaIcon(
//                       FontAwesomeIcons.whatsapp,
//                       size: 13,
//                       color: Colors.green,
//                     ),
//                     const SizedBox(width: 4),
//                     _buildTextWithMarquee(
//                       order['WhatsAppMobileNo']?.toString() != null &&
//                               order['WhatsAppMobileNo']!.toString().isNotEmpty
//                           ? '${order['WhatsAppMobileNo']}'
//                           : 'xxxxxxxxxx',
//                       const TextStyle(fontSize: 13, color: Colors.green),
//                       maxWidth: 100.0,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             // Third row: Formatted DateTime, Delivery Date, and OrderPopupMenu
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: Row(
//                     children: [
//                       RichText(
//                         text: TextSpan(
//                           children: [
//                             const TextSpan(
//                               text: 'Ordered: ',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.bold,
//                                 color:
//                                     Colors
//                                         .grey, // Static "Ordered" text in grey
//                               ),
//                             ),
//                             TextSpan(
//                               text: formattedDateTime,
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color:
//                                     Colors.blue, // Dynamic value retains blue
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       RichText(
//                         text: TextSpan(
//                           children: [
//                             const TextSpan(
//                               text: 'Delivery: ',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.bold,
//                                 color:
//                                     Colors
//                                         .grey, // Static "Ordered" text in grey
//                               ),
//                             ),
//                             TextSpan(
//                               text: formattedDeliveryDate,
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                                 color:
//                                     Colors.blue, // Dynamic value retains blue
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 _OrderPopupMenu(
//                   order: order,
//                   viewChecked: _orderViewChecked[order['OrderNo']] ?? false,
//                   onViewCheckedChanged: (value) {
//                     setState(() {
//                       _orderViewChecked[order['OrderNo']] = value;
//                     });
//                   },
//                   onDownload: () => _handleOrderDownload(order),
//                   onWhatsApp: () => _handleOrderWhatsAppShare(order),
//                   onView: () => _handleOrderView(order),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _handleOrderDownload(Map<String, dynamic> order) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Downloading order: ${order['OrderNo']}')),
//     );
//   }

//   void _handleOrderWhatsAppShare(Map<String, dynamic> order) {
//     final withImage = _orderViewChecked[order['OrderNo']] ?? false;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Sharing order ${order['OrderNo']} via WhatsApp ${withImage ? 'with image' : ''}',
//         ),
//       ),
//     );
//   }

//   void _handleOrderView(Map<String, dynamic> order) {
//     final withImage = _orderViewChecked[order['OrderNo']] ?? false;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Viewing order ${order['OrderNo']} ${withImage ? 'with image' : ''}',
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryCard(String title, String value) {
//     // Determine colors based on card type
//     Color cardColor;
//     Color textColor;
//     IconData iconData;

//     switch (title) {
//       case 'Total Orders':
//         cardColor = Colors.indigo.withOpacity(0.1);
//         textColor = Colors.indigo;
//         iconData = Icons.receipt_long;
//         break;
//       case 'Total Qty':
//         cardColor = Colors.amber.withOpacity(0.1);
//         textColor = Colors.amber;
//         iconData = Icons.format_list_numbered;
//         break;
//       case 'Total Amount':
//         cardColor = Colors.green.withOpacity(0.1);
//         textColor = Colors.green;
//         iconData = Icons.currency_rupee;
//         break;
//       default:
//         cardColor = Colors.blueGrey.withOpacity(0.1);
//         textColor = Colors.blueGrey;
//         iconData = Icons.info;
//     }

//     return Expanded(
//       child: Container(
//         height: 115,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.blueGrey.shade100),
//           borderRadius: BorderRadius.circular(0),
//           // boxShadow: [
//           //   BoxShadow(
//           //     color: Colors.grey.withOpacity(0.1),
//           //     blurRadius: 3,
//           //     offset: const Offset(0, 2),
//           //   ),
//           // ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6.0),
//                 decoration: BoxDecoration(
//                   color: cardColor,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(iconData, size: 20, color: textColor),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 title == 'Total Amount' ? '$value' : value,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: textColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Reusable popup menu widget for orders
// class _OrderPopupMenu extends StatelessWidget {
//   final Map<String, dynamic> order;
//   final bool viewChecked;
//   final ValueChanged<bool> onViewCheckedChanged;
//   final VoidCallback onDownload;
//   final VoidCallback onWhatsApp;
//   final VoidCallback onView;

//   const _OrderPopupMenu({
//     required this.order,
//     required this.viewChecked,
//     required this.onViewCheckedChanged,
//     required this.onDownload,
//     required this.onWhatsApp,
//     required this.onView,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<String>(
//       icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
//       onSelected: (String value) {
//         switch (value) {
//           case 'download':
//             onDownload();
//             break;
//           case 'whatsapp':
//             onWhatsApp();
//             break;
//           case 'view':
//             onView();
//             break;
//           case 'withImage':
//             break;
//         }
//       },
//       itemBuilder:
//           (BuildContext context) => <PopupMenuEntry<String>>[
//             const PopupMenuItem<String>(
//               value: 'download',
//               child: ListTile(
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16.0,
//                   vertical: 0.0,
//                 ),
//                 leading: Icon(Icons.download, size: 20, color: Colors.blue),
//                 title: Text('Download'),
//               ),
//             ),
//             const PopupMenuItem<String>(
//               value: 'whatsapp',
//               child: ListTile(
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16.0,
//                   vertical: 0.0,
//                 ),
//                 leading: FaIcon(
//                   FontAwesomeIcons.whatsapp,
//                   size: 20,
//                   color: Colors.green,
//                 ),
//                 title: Text('WhatsApp'),
//               ),
//             ),
//             const PopupMenuItem<String>(
//               value: 'view',
//               child: ListTile(
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16.0,
//                   vertical: 0.0,
//                 ),
//                 leading: FaIcon(
//                   FontAwesomeIcons.eye,
//                   size: 20,
//                   color: Colors.green,
//                 ),
//                 title: Text('View'),
//               ),
//             ),
//             PopupMenuItem<String>(
//               value: 'withImage',
//               child: StatefulBuilder(
//                 builder: (BuildContext context, StateSetter setState) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16.0,
//                       vertical: 8.0,
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 20,
//                           alignment: Alignment.centerLeft,
//                           child: Checkbox(
//                             value: viewChecked,
//                             onChanged: (bool? newValue) {
//                               setState(() {
//                                 onViewCheckedChanged(newValue ?? false);
//                               });
//                             },
//                             materialTapTargetSize:
//                                 MaterialTapTargetSize.shrinkWrap,
//                             visualDensity: const VisualDensity(
//                               horizontal: -4,
//                               vertical: -4,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 22),
//                         const Text('With Image'),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/dashboard/data.dart';

class CustomerOrderDetailsPage extends StatefulWidget {
  final String custKey;
  final String customerName;
  final DateTime fromDate;
  final DateTime toDate;
  final String orderType;

  const CustomerOrderDetailsPage({
    super.key,
    required this.custKey,
    required this.customerName,
    required this.fromDate,
    required this.toDate,
    required this.orderType,
  });

  @override
  State<CustomerOrderDetailsPage> createState() =>
      _CustomerOrderDetailsPageState();
}

class _CustomerOrderDetailsPageState extends State<CustomerOrderDetailsPage> {
  List<Map<String, dynamic>> orderDetails = [];
  bool isLoading = true;
  int totalOrders = 0;
  int totalQuantity = 0;
  int totalAmount = 0;
  bool _appBarViewChecked = false;
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
          "CoBr_Id": UserSession.coBrId,
          "CustKey": widget.custKey,
          "SalesPerson":
              UserSession.userType == 'S'
                  ? UserSession.userLedKey
                  : FilterData.selectedSalespersons!.isNotEmpty
                  ? FilterData.selectedSalespersons!.map((b) => b.key).join(',')
                  : null,
          "State":
              FilterData.selectedStates!.isNotEmpty
                  ? FilterData.selectedStates!.map((b) => b.key).join(',')
                  : null,
          "City":
              FilterData.selectedCities!.isNotEmpty
                  ? FilterData.selectedCities!.map((b) => b.key).join(',')
                  : null,
          "orderType": widget.orderType,
          "Detail": 2,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            orderDetails = List<Map<String, dynamic>>.from(data);
            totalOrders = orderDetails.length;
            totalQuantity = orderDetails.fold(
              0,
              (sum, item) =>
                  sum + (int.tryParse(item['TotalQty'].toString()) ?? 0),
            );
            totalAmount = orderDetails.fold(
              0,
              (sum, item) =>
                  sum + (int.tryParse(item['TotalAmt'].toString()) ?? 0),
            );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Customer Wise - Order Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
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
                  break;
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'download',
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 0.0,
                      ),
                      leading: Icon(
                        Icons.download,
                        size: 18,
                        color: Colors.blue[700],
                      ),
                      title: Text(
                        'Download All',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'whatsapp',
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 0.0,
                      ),
                      leading: Icon(
                        Icons.share,
                        size: 18,
                        color: Colors.blue[700],
                      ),
                      title: Text(
                        'Share All',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'view',
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 0.0,
                      ),
                      leading: Icon(
                        Icons.visibility,
                        size: 18,
                        color: Colors.blue[700],
                      ),
                      title: Text(
                        'View All',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'withImage',
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 6.0,
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _appBarViewChecked,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _appBarViewChecked = newValue ?? false;
                                  });
                                  this.setState(() {
                                    _appBarViewChecked = newValue ?? false;
                                  });
                                },
                                activeColor: Colors.blue[700],
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: const VisualDensity(
                                  horizontal: -4,
                                  vertical: -4,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'With Image',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
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
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Orders',
                              totalOrders.toString(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Qty',
                              totalQuantity.toString(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Amount',
                              '₹${totalAmount.toString()}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.blue[700], size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.customerName,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[900],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...orderDetails
                          .map((order) => _buildOrderCard(order))
                          .toList(),
                    ],
                  ),
                ),
              ),
    );
  }

  void _handleDownloadAll() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Downloading all orders...')));
  }

  void _handleWhatsAppShareAll() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sharing all orders ${_appBarViewChecked ? 'with images' : ''}',
        ),
      ),
    );
  }

  void _handleViewAll() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Viewing all orders ${_appBarViewChecked ? 'with images' : ''}',
        ),
      ),
    );
  }

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
    backgroundColor: Colors.transparent, // Make background transparent for rounded bottom
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(0), bottom: Radius.circular(0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 0),
              child: Column(
                children: [
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
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
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


Widget _buildOrderCard(Map<String, dynamic> order) {
  String formattedDateTime = '';
  try {
    final date = DateFormat('yyyy-MM-dd').parse(order['OrderDate']);
    formattedDateTime = DateFormat('dd/MM/yyyy HH:mm').format(date);
  } catch (e) {
    formattedDateTime =
        '${order['OrderDate']} ${order['Created_Time'] ?? 'N/A'}';
  }

  String formattedDeliveryDate = '';
  try {
    final date = DateFormat('yyyy-MM-dd').parse(order['DlvDate']);
    formattedDeliveryDate = DateFormat('dd/MM/yyyy').format(date);
  } catch (e) {
    formattedDeliveryDate = order['DlvDate'] ?? 'N/A';
  }

  Widget _buildTextWithMarquee(String text, TextStyle style) {
    final maxWidth = MediaQuery.of(context).size.width / 5;
    const int lengthThreshold = 12;
    if (text.length > lengthThreshold) {
      return SizedBox(
        width: maxWidth,
        height: 18.0,
        child: Marquee(
          text: text,
          style: style,
          scrollAxis: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          blankSpace: 16.0,
          velocity: 50.0,
          pauseAfterRound: const Duration(seconds: 1),
          startPadding: 8.0,
          accelerationDuration: const Duration(seconds: 1),
          accelerationCurve: Curves.linear,
          decelerationDuration: const Duration(milliseconds: 500),
          decelerationCurve: Curves.linear,
        ),
      );
    }
    return Text(text, style: style, overflow: TextOverflow.ellipsis);
  }

  Color deliveryColor;
  String deliveryType = order['DeliveryType']?.toString() ?? 'N/A';
  switch (deliveryType) {
    case 'Approved':
      deliveryColor = Colors.blue[700]!;
      break;
    case 'Partially Delivered':
      deliveryColor = Colors.blue[400]!;
      break;
    case 'Delivered':
      deliveryColor = Colors.blue[900]!;
      break;
    case 'Completed':
      deliveryColor = Colors.blue[600]!;
      break;
    case 'Partially Completed':
      deliveryColor = Colors.blue[300]!;
      break;
    default:
      deliveryColor = Colors.grey[600]!;
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color.fromARGB(255, 196, 195, 195)),
      borderRadius: BorderRadius.circular(0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIRST ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.receipt_long, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildTextWithMarquee(
                        '${order['OrderNo'] ?? 'N/A'}',
                        GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.category, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildTextWithMarquee(
                        '${order['Order_Type'] ?? 'N/A'}',
                        GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping, size: 16, color: deliveryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildTextWithMarquee(
                          deliveryType,
                          GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: deliveryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Row(
        children: [
          Text(
            'Qty: ',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.blue[700],
            ),
          ),
          Expanded(
            child: _buildTextWithMarquee(
              '${order['TotalQty'] ?? '0'}',
              GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 6),
    Expanded(
      child: Row(
        children: [
          Text(
            'Amt: ₹',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.blue[700],
            ),
          ),
          Expanded(
            child: _buildTextWithMarquee(
              '${order['TotalAmt'] ?? '0.00'}',
              GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 6),
    Expanded(
      child: (order['WhatsAppMobileNo'] != null &&
              order['WhatsAppMobileNo'].toString().trim().isNotEmpty)
          ? GestureDetector(
              onTap: () => _showContactOptions(
                context,
                order['WhatsAppMobileNo'].toString(),
              ),
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.whatsapp,
                      size: 12, color: Colors.green),
                  const SizedBox(width: 3),
                  Expanded(
                    child: _buildTextWithMarquee(
                      order['WhatsAppMobileNo'].toString(),
                      GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            )
          :     Row( children: [
                  const FaIcon(FontAwesomeIcons.whatsapp,
                      size: 12, color: Colors.green),
                  const SizedBox(width: 3),
                  Expanded(
                    child: _buildTextWithMarquee(
              'xxxxx xxxxx',
              GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.green,
              ),
            ),)
            ],
              ),
    ),
  ],
),

          const SizedBox(height: 8),


          // FOURTH ROW - Ordered + Delivery Date + Popup Menu
          Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Ordered: ',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    TextSpan(
                      text: formattedDateTime,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Delivery: ',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    TextSpan(
                      text: formattedDeliveryDate,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
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
      SnackBar(
        content: Text(
          'Sharing order ${order['OrderNo']} ${withImage ? 'with image' : ''}',
        ),
      ),
    );
  }

  void _handleOrderView(Map<String, dynamic> order) {
    final withImage = _orderViewChecked[order['OrderNo']] ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Viewing order ${order['OrderNo']} ${withImage ? 'with image' : ''}',
        ),
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
}

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
      icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
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
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'download',
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 0.0,
                ),
                leading: Icon(
                  Icons.download,
                  size: 18,
                  color: Colors.blue[700],
                ),
                title: Text(
                  'Download',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'whatsapp',
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 0.0,
                ),
                leading: Icon(Icons.share, size: 18, color: Colors.blue[700]),
                title: Text('Share', style: GoogleFonts.poppins(fontSize: 12)),
              ),
            ),
            PopupMenuItem<String>(
              value: 'view',
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 0.0,
                ),
                leading: Icon(
                  Icons.visibility,
                  size: 18,
                  color: Colors.blue[700],
                ),
                title: Text('View', style: GoogleFonts.poppins(fontSize: 12)),
              ),
            ),
            PopupMenuItem<String>(
              value: 'withImage',
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: viewChecked,
                          onChanged: (bool? newValue) {
                            setState(() {
                              onViewCheckedChanged(newValue ?? false);
                            });
                          },
                          activeColor: Colors.blue[700],
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -4,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'With Image',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
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
