// import 'package:flutter/material.dart';
// import 'package:vrs_erp_figma/constants/app_constants.dart';
// import 'package:vrs_erp_figma/dashboard/OrderDetails_page.dart';
// import 'package:vrs_erp_figma/dashboard/dashboard_filter.dart';
// import 'package:vrs_erp_figma/models/keyName.dart';
// import 'package:vrs_erp_figma/screens/drawer_screen.dart';
// import 'package:vrs_erp_figma/services/app_services.dart';
// import 'package:vrs_erp_figma/widget/bottom_navbar.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class OrderSummaryPage extends StatefulWidget {
//   const OrderSummaryPage({super.key});

//   @override
//   State<OrderSummaryPage> createState() => _OrderSummaryPageState();
// }

// class _OrderSummaryPageState extends State<OrderSummaryPage> {
//   DateTime fromDate = DateTime.now();
//   DateTime toDate = DateTime.now();
//   String selectedRange = 'Today';

//   // Declare variables for customer, city, salesman, and state
//   String? customer; // CustKey
//   String? city; // City
//   String? salesman; // SalesPerson
//   String? state; // State

//   // Variables to store API response data
//   String orderDocCount = '0';
//   String pendingQty = '0';
//   String packedDocCount = '0';
//   String cancelledQty = '0';
//   String invoicedDocCount = '0';
//   String invoicedQty = '0';
//   String orderQty = '0';
//   String pendingDocCount = '0';
//   String packedQty = '0';
//   String cancelledDocCount = '0';
//   String toBeReceived = '0';
//   String inHand = '0';

//   KeyName? selectedLedger;
//   KeyName? selectedSalesperson;
//   List<KeyName> ledgerList = [];
//   List<KeyName> salespersonList = [];
//   bool isLoadingLedgers = true;
//   bool isLoadingSalesperson = true;

//   @override
//   void initState() {
//     super.initState();
//     _updateDateRange('Today'); // Initialize with default range
//     _loadDropdownData();
//     _fetchOrderSummary(); // Fetch data on page load
//   }

//   Future<void> _loadDropdownData() async {
//     setState(() {
//       isLoadingLedgers = true;
//       isLoadingSalesperson = true;
//     });

//     try {
//       final fetchedLedgersResponse = await ApiService.fetchLedgers(
//         ledCat: 'w',
//         coBrId: UserSession.coBrId ?? '',
//       );
//       final fetchedSalespersonResponse = await ApiService.fetchLedgers(
//         ledCat: 's',
//         coBrId: UserSession.coBrId ?? '',
//       );

//       setState(() {
//         ledgerList = List<KeyName>.from(fetchedLedgersResponse['result'] ?? []);
//         salespersonList = List<KeyName>.from(
//           fetchedSalespersonResponse['result'] ?? [],
//         );
//         isLoadingLedgers = false;
//         isLoadingSalesperson = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoadingLedgers = false;
//         isLoadingSalesperson = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching dropdown data: $e')),
//       );
//     }
//   }

//   Future<void> _selectDate(BuildContext context, bool isFromDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: isFromDate ? fromDate : toDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isFromDate) {
//           fromDate = picked;
//         } else {
//           toDate = picked;
//         }
//         selectedRange = 'Custom'; // Switch to custom when dates are manually selected
//       });
//       _fetchOrderSummary(); // Fetch updated data after date change
//     }
//   }

//   void _updateDateRange(String range) {
//     final now = DateTime.now();
//     setState(() {
//       selectedRange = range;
//       switch (range) {
//         case 'Today':
//           fromDate = DateTime(now.year, now.month, now.day);
//           toDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
//           break;
//         case 'Yesterday':
//           final yesterday = now.subtract(const Duration(days: 1));
//           fromDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
//           toDate = DateTime(
//             yesterday.year,
//             yesterday.month,
//             yesterday.day,
//             23,
//             59,
//             59,
//           );
//           break;
//         case 'This Week':
//           final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
//           fromDate = DateTime(
//             firstDayOfWeek.year,
//             firstDayOfWeek.month,
//             firstDayOfWeek.day,
//           );
//           toDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
//           break;
//         case 'Previous Week':
//           final firstDayOfLastWeek = now.subtract(
//             Duration(days: now.weekday + 6),
//           );
//           fromDate = DateTime(
//             firstDayOfLastWeek.year,
//             firstDayOfLastWeek.month,
//             firstDayOfLastWeek.day,
//           );
//           toDate = DateTime(
//             firstDayOfLastWeek.year,
//             firstDayOfLastWeek.month,
//             firstDayOfLastWeek.day + 6,
//             23,
//             59,
//             59,
//           );
//           break;
//         case 'This Month':
//           fromDate = DateTime(now.year, now.month, 1);
//           toDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
//           break;
//         case 'Previous Month':
//           final firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
//           fromDate = firstDayOfLastMonth;
//           toDate = DateTime(now.year, now.month, 0, 23, 59, 59);
//           break;
//         case 'This Quarter':
//           final quarter = (now.month - 1) ~/ 3;
//           fromDate = DateTime(now.year, quarter * 3 + 1, 1);
//           toDate = DateTime(now.year, quarter * 3 + 4, 0, 23, 59, 59);
//           break;
//         case 'Previous Quarter':
//           final quarter = (now.month - 1) ~/ 3;
//           final prevQuarter = quarter == 0 ? 3 : quarter - 1;
//           final prevQuarterYear = quarter == 0 ? now.year - 1 : now.year;
//           fromDate = DateTime(prevQuarterYear, prevQuarter * 3 + 1, 1);
//           toDate = DateTime(
//             prevQuarterYear,
//             prevQuarter * 3 + 4,
//             0,
//             23,
//             59,
//             59,
//           );
//           break;
//         case 'This Year':
//           fromDate = DateTime(now.year, 1, 1);
//           toDate = DateTime(now.year, 12, 31, 23, 59, 59);
//           break;
//         case 'Previous Year':
//           fromDate = DateTime(now.year - 1, 1, 1);
//           toDate = DateTime(now.year - 1, 12, 31, 23, 59, 59);
//           break;
//         case 'Custom':
//           // Keep the existing custom dates
//           break;
//       }
//     });
//     _fetchOrderSummary(); // Fetch updated data after range change
//   }

//   // API call to fetch order summary
//   Future<void> _fetchOrderSummary() async {
//     const String apiUrl = '${AppConstants.BASE_URL}/orderRegister/order-details-dash'; // Replace with your API endpoint
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "FromDate": "${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}",
//           "ToDate": "${toDate.year}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}",
//           "CoBr_Id": "01",
//           "CustKey": customer,
//           "SalesPerson": salesman,
//           "State": state,
//           "City": city,
//           "orderType": null,
//           "Detail": null
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           orderDocCount = data['orderdoccount']?.toString() ?? '0';
//           pendingQty = data['pendingqty']?.toString() ?? '0';
//           packedDocCount = data['packeddoccount']?.toString() ?? '0';
//           cancelledQty = data['cancelledqty']?.toString() ?? '0';
//           invoicedDocCount = data['invoiceddoccount']?.toString() ?? '0';
//           invoicedQty = data['invoicedqty']?.toString() ?? '0';
//           orderQty = data['orderqty']?.toString() ?? '0';
//           pendingDocCount = data['pendingdoccount']?.toString() ?? '0';
//           packedQty = data['packedqty']?.toString() ?? '0';
//           cancelledDocCount = data['cancelleddoccount']?.toString() ?? '0';
//           toBeReceived = data['tobereceived']?.toString() ?? '0';
//           inHand = data['inhand']?.toString() ?? '0';
//         });
//       } else {
//         // Handle non-200 response
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load data: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       // Handle network or parsing errors
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: DrawerScreen(),
//       appBar: AppBar(
//         title: Text('Dashboard', style: TextStyle(color: AppColors.white)),
//         backgroundColor: AppColors.primaryColor,
//         elevation: 1,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: Icon(Icons.menu, color: AppColors.white),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Date Range Section
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Select Date Range',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       child: DropdownButton<String>(
//                         value: selectedRange,
//                         isExpanded: true,
//                         underline: const
//                         SizedBox(),
//                         items: <String>[
//                           'Custom',
//                           'Today',
//                           'Yesterday',
//                           'This Week',
//                           'Previous Week',
//                           'This Month',
//                           'Previous Month',
//                           'This Quarter',
//                           'Previous Quarter',
//                           'This Year',
//                           'Previous Year',
//                         ].map<DropdownMenuItem<String>>((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           if (newValue != null) {
//                             _updateDateRange(newValue);
//                           }
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'From Date',
//                                 style: TextStyle(fontWeight: FontWeight.w500),
//                               ),
//                               const SizedBox(height: 4),
//                               GestureDetector(
//                                 onTap: () => _selectDate(context, true),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 12,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     border: Border.all(color: Colors.grey),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         '${fromDate.day.toString().padLeft(2, '0')}/${fromDate.month.toString().padLeft(2, '0')}/${fromDate.year}',
//                                       ),
//                                       const Icon(
//                                         Icons.calendar_today,
//                                         size: 20,
//                                         color: Colors.grey,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'To Date',
//                                 style: TextStyle(fontWeight: FontWeight.w500),
//                               ),
//                               const SizedBox(height: 4),
//                               GestureDetector(
//                                 onTap: () => _selectDate(context, false),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 12,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     border: Border.all(color: Colors.grey),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         '${toDate.day.toString().padLeft(2, '0')}/${toDate.month.toString().padLeft(2, '0')}/${toDate.year}',
//                                       ),
//                                       const Icon(
//                                         Icons.calendar_today,
//                                         size: 20,
//                                         color: Colors.grey,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             // First Row of Cards
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildOrderCard('TOTAL ORDER', orderDocCount, orderQty, true),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildOrderCard('PENDING ORDER', pendingDocCount, pendingQty, true),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             // Second Row of Cards
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildOrderCard('PACKED ORDER', packedDocCount, packedQty, true),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildOrderCard('CANCELLED ORDER', cancelledDocCount, cancelledQty, true),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             // Third Row of Cards
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildOrderCard('INVOICED ORDER', invoicedDocCount, invoicedQty, true),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Container(), // Empty container for balance
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             // Inventory Summary Section
//             const Text(
//               'Inventory Summary',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(child: _buildOrderCard('IN HAND', inHand, '0', false)),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildOrderCard('TO BE RECEIVED', toBeReceived, '0', false),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 50),
//         child: FloatingActionButton(
//           backgroundColor: Colors.blue,
//           onPressed: () async {
//             await Navigator.push(
//               context,
//               PageRouteBuilder(
//                 pageBuilder: (
//                   context,
//                   animation,
//                   secondaryAnimation,
//                 ) =>
//                     DashboardFilterPage(
//                   ledgerList: ledgerList,
//                   salespersonList: salespersonList,
//                   onApplyFilters: ({
//                     KeyName? selectedLedger,
//                     KeyName? selectedSalesperson,
//                     DateTime? fromDate,
//                     DateTime? toDate,
//                     String? selectedState,
//                     String? selectedCity,
//                   }) {
//                     setState(() {
//                       this.selectedLedger = selectedLedger;
//                       this.selectedSalesperson = selectedSalesperson;
//                       this.fromDate = fromDate ?? this.fromDate;
//                       this.toDate = toDate ?? this.toDate;
//                       this.state = selectedState;
//                       this.city = selectedCity;
//                       this.customer = selectedLedger?.key;
//                       this.salesman = selectedSalesperson?.key;
//                       this.selectedRange = 'Custom'; // Default to Custom if dates are set
//                     });
//                     _fetchOrderSummary(); // Fetch updated data after applying filters
//                   },
//                 ),
//                 settings: RouteSettings(
//                   arguments: {
//                     'ledgerList': ledgerList,
//                     'salespersonList': salespersonList,
//                     'selectedLedger': selectedLedger,
//                     'selectedSalesperson': selectedSalesperson,
//                     'fromDate': fromDate,
//                     'toDate': toDate,
//                     'selectedDateRange': selectedRange,
//                   },
//                 ),
//                 transitionDuration: const Duration(milliseconds: 500),
//                 transitionsBuilder: (
//                   context,
//                   animation,
//                   secondaryAnimation,
//                   child,
//                 ) {
//                   return ScaleTransition(
//                     scale: animation,
//                     alignment: Alignment.bottomRight,
//                     child: FadeTransition(opacity: animation, child: child),
//                   );
//                 },
//               ),
//             );
//           },
//           tooltip: 'Filter Orders',
//           child: const Icon(Icons.filter_list, color: Colors.white),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationWidget(
//         currentIndex: 4, // Highlight Order icon
//         onTap: (index) {
//           if (index == 0) Navigator.pushNamed(context, '/home');
//           if (index == 1) Navigator.pushNamed(context, '/catalog');
//           if (index == 2) Navigator.pushNamed(context, '/orderbooking');
//           if (index == 3) Navigator.pushNamed(context, '/stockReport');
//           if (index == 4) return;
//         },
//       ),
//     );
//   }

// Future<void> _showOrderDetails(String orderType) async {
//   try {
//     // Convert orderType to camelCase to match API expectation (e.g., "TOTAL ORDER" -> "TotalOrder")
//     String formattedOrderType = orderType
//         .split(' ')
//         .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
//         .join('');

//     final response = await http.post(
//       Uri.parse('${AppConstants.BASE_URL}/report/getReportsDetail'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         "FromDate": "${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}",
//         "ToDate": "${toDate.year}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}",
//         "CoBr_Id": "01",
//         "CustKey": customer,
//         "SalesPerson": salesman,
//         "State": state,
//         "City": city,
//         "orderType": formattedOrderType,
//         "Detail": 1 // Added as per the sample API request
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       // Check if data is a List as per the API response format
//       if (data is List) {
//        Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => OrderDetailsPage(
//       orderDetails: List<Map<String, dynamic>>.from(data),
//       fromDate: fromDate,  // Pass fromDate
//       toDate: toDate,      // Pass toDate
//     ),
//   ),
// );
//       } else {
//         throw Exception('Unexpected response format: Expected a list');
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load order details: ${response.statusCode}')),
//       );
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error: $e')),
//     );
//   }
// }

//  Widget _buildOrderCard(String title, String value, String qty, bool showQty) {
//   return GestureDetector(
//     onTap: () {
//       String orderType = title.replaceAll(' ', '');
//       _showOrderDetails(orderType);
//     },
//     child: Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//               title,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               value,
//               style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//             ),
//             if (showQty) ...[
//               const SizedBox(height: 4),
//               Text('Qty: $qty', style: const TextStyle(fontSize: 14)),
//             ],
//           ],
//         ),
//       ),
//     ),
//   );
// }

// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/dashboard/OrderDetails_page.dart';
import 'package:vrs_erp_figma/dashboard/dashboard_filter.dart';
import 'package:vrs_erp_figma/dashboard/data.dart';
import 'package:vrs_erp_figma/models/keyName.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:vrs_erp_figma/services/app_services.dart';
import 'package:vrs_erp_figma/widget/bottom_navbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  String selectedRange = 'Today';

  String? customer;
  String? city;
  String? salesman;
  String? state;

  String orderDocCount = '0';
  String pendingQty = '0';
  String packedDocCount = '0';
  String cancelledQty = '0';
  String invoicedDocCount = '0';
  String invoicedQty = '0';
  String orderQty = '0';
  String pendingDocCount = '0';
  String packedQty = '0';
  String cancelledDocCount = '0';
  String toBeReceived = '0';
  String inHand = '0';

  KeyName? selectedLedger;
  KeyName? selectedSalesperson;
  KeyName selectedState = KeyName(key: '', name: 'All States');
  KeyName selectedCity = KeyName(key: '', name: 'All Cities');
  List<KeyName> ledgerList = [];
  List<KeyName> salespersonList = [];
  List<KeyName> statesList = [];
  List<KeyName> citiesList = [];
  bool isLoadingLedgers = true;
  bool isLoadingSalesperson = true;

  @override
  void initState() {
    super.initState();
    _updateDateRange('Today');
    _loadDropdownData();
    _fetchOrderSummary();
  }

  Future<void> _loadDropdownData() async {
    setState(() {
      isLoadingLedgers = true;
      isLoadingSalesperson = true;
    });

    try {
      final fetchedLedgersResponse = await ApiService.fetchLedgers(
        ledCat: 'w',
        coBrId: UserSession.coBrId ?? '',
      );
      final fetchedSalespersonResponse = await ApiService.fetchLedgers(
        ledCat: 's',
        coBrId: UserSession.coBrId ?? '',
      );
      final fetchedStatesResponse = await ApiService.fetchStates();
      final fetchedCitiesResponse = await ApiService.fetchCities(stateKey: "");

      // In your _loadDropdownData method, add default options:
      setState(() {
        ledgerList = [
          KeyName(key: '', name: 'All Customers'),
          ...List<KeyName>.from(fetchedLedgersResponse['result'] ?? []),
        ];
        salespersonList = [
          KeyName(key: '', name: 'All Salespersons'),
          ...List<KeyName>.from(fetchedSalespersonResponse['result'] ?? []),
        ];
        statesList = [
          KeyName(key: '', name: 'All States'),
          ...List<KeyName>.from(fetchedStatesResponse['result'] ?? []),
        ];
        citiesList = [
          KeyName(key: '', name: 'All Cities'),
          ...List<KeyName>.from(fetchedCitiesResponse['result'] ?? []),
        ];
        isLoadingLedgers = false;
        isLoadingSalesperson = false;
      });
    } catch (e) {
      setState(() {
        isLoadingLedgers = false;
        isLoadingSalesperson = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dropdown data: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? fromDate : toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
        selectedRange = 'Custom';
      });
      _fetchOrderSummary();
    }
  }

  void _updateDateRange(String range) {
    final now = DateTime.now();
    setState(() {
      selectedRange = range;
      switch (range) {
        case 'Today':
          fromDate = DateTime(now.year, now.month, now.day);
          toDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'Yesterday':
          final yesterday = now.subtract(const Duration(days: 1));
          fromDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
          toDate = DateTime(
            yesterday.year,
            yesterday.month,
            yesterday.day,
            23,
            59,
            59,
          );
          break;
        case 'This Week':
          final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
          fromDate = DateTime(
            firstDayOfWeek.year,
            firstDayOfWeek.month,
            firstDayOfWeek.day,
          );
          toDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'Previous Week':
          final firstDayOfLastWeek = now.subtract(
            Duration(days: now.weekday + 6),
          );
          fromDate = DateTime(
            firstDayOfLastWeek.year,
            firstDayOfLastWeek.month,
            firstDayOfLastWeek.day,
          );
          toDate = DateTime(
            firstDayOfLastWeek.year,
            firstDayOfLastWeek.month,
            firstDayOfLastWeek.day + 6,
            23,
            59,
            59,
          );
          break;
        case 'This Month':
          fromDate = DateTime(now.year, now.month, 1);
          toDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case 'Previous Month':
          final firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
          fromDate = firstDayOfLastMonth;
          toDate = DateTime(now.year, now.month, 0, 23, 59, 59);
          break;
        case 'This Quarter':
          final quarter = (now.month - 1) ~/ 3;
          fromDate = DateTime(now.year, quarter * 3 + 1, 1);
          toDate = DateTime(now.year, quarter * 3 + 4, 0, 23, 59, 59);
          break;
        case 'Previous Quarter':
          final quarter = (now.month - 1) ~/ 3;
          final prevQuarter = quarter == 0 ? 3 : quarter - 1;
          final prevQuarterYear = quarter == 0 ? now.year - 1 : now.year;
          fromDate = DateTime(prevQuarterYear, prevQuarter * 3 + 1, 1);
          toDate = DateTime(
            prevQuarterYear,
            prevQuarter * 3 + 4,
            0,
            23,
            59,
            59,
          );
          break;
        case 'This Year':
          fromDate = DateTime(now.year, 1, 1);
          toDate = DateTime(now.year, 12, 31, 23, 59, 59);
          break;
        case 'Previous Year':
          fromDate = DateTime(now.year - 1, 1, 1);
          toDate = DateTime(now.year - 1, 12, 31, 23, 59, 59);
          break;
        case 'Custom':
          break;
      }
    });
    _fetchOrderSummary();
  }

  Future<void> _fetchOrderSummary() async {
    const String apiUrl =
        '${AppConstants.BASE_URL}/orderRegister/order-details-dash';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "FromDate":
              "${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}",
          "ToDate":
              "${toDate.year}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}",
          "CoBr_Id": UserSession.coBrId ?? '01', // Provide default value
          "CustKey":
              UserSession.userType == 'C' ? UserSession.userLedKey : FilterData.selectedLedger?.key,
          "SalesPerson":
              UserSession.userType == 'S' ? UserSession.userLedKey : FilterData.selectedSalesperson?.key,
          "State":
              selectedState.key.isEmpty
                  ? null
                  : selectedState.key, // Handle empty key
          "City":
              selectedCity.key.isEmpty
                  ? null
                  : selectedCity.key, // Handle empty key
          "orderType": null,
          "Detail": null,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          orderDocCount = data['orderdoccount']?.toString() ?? '0';
          pendingQty = data['pendingqty']?.toString() ?? '0';
          packedDocCount = data['packeddoccount']?.toString() ?? '0';
          cancelledQty = data['cancelledqty']?.toString() ?? '0';
          invoicedDocCount = data['invoiceddoccount']?.toString() ?? '0';
          invoicedQty = data['invoicedqty']?.toString() ?? '0';
          orderQty = data['orderqty']?.toString() ?? '0';
          pendingDocCount = data['pendingdoccount']?.toString() ?? '0';
          packedQty = data['packedqty']?.toString() ?? '0';
          cancelledDocCount = data['cancelleddoccount']?.toString() ?? '0';
          toBeReceived = data['tobereceived']?.toString() ?? '0';
          inHand = data['inhand']?.toString() ?? '0';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.grey),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date Range',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: DropdownButton<String>(
                        value: selectedRange,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items:
                            <String>[
                              'Custom',
                              'Today',
                              'Yesterday',
                              'This Week',
                              'Previous Week',
                              'This Month',
                              'Previous Month',
                              'This Quarter',
                              'Previous Quarter',
                              'This Year',
                              'Previous Year',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _updateDateRange(newValue);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (selectedRange == 'Custom') ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'From Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _selectDate(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F7FA),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${fromDate.day.toString().padLeft(2, '0')}/${fromDate.month.toString().padLeft(2, '0')}/${fromDate.year}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'To Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _selectDate(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F7FA),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${toDate.day.toString().padLeft(2, '0')}/${toDate.month.toString().padLeft(2, '0')}/${toDate.year}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildOrderCard(
                    'TOTAL ORDER',
                    orderDocCount,
                    orderQty,
                    true,
                    const Color(0xFFF8E1D9),
                    Icons.shopping_cart,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOrderCard(
                    'PENDING ORDER',
                    pendingDocCount,
                    pendingQty,
                    true,
                    const Color(0xFFE6F0FA),
                    Icons.hourglass_empty,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOrderCard(
                    'PACKED ORDER',
                    packedDocCount,
                    packedQty,
                    true,
                    const Color(0xFFE8F5E9),
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOrderCard(
                    'CANCELLED ORDER',
                    cancelledDocCount,
                    cancelledQty,
                    true,
                    const Color(0xFFFFE6E6),
                    Icons.cancel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOrderCard(
                    'INVOICED ORDER',
                    invoicedDocCount,
                    invoicedQty,
                    true,
                    const Color(0xFFF3E8FF),
                    Icons.receipt,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Inventory Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOrderCard(
                    'IN HAND',
                    inHand,
                    '0',
                    false,
                    const Color(0xFFE0F7FA),
                    Icons.inventory,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOrderCard(
                    'TO BE RECEIVED',
                    toBeReceived,
                    '0',
                    false,
                    const Color(0xFFFFF9C4),
                    Icons.local_shipping,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        DashboardFilterPage(
                          ledgerList: ledgerList,
                          salespersonList: salespersonList,
                          onApplyFilters: ({
                            KeyName? selectedLedger,
                            KeyName? selectedSalesperson,
                            DateTime? fromDate,
                            DateTime? toDate,
                            KeyName? selectedState,
                            KeyName? selectedCity,
                          }) {
                          
                            


                            setState(() {
                              this.selectedLedger =
                                  selectedLedger;
                              this.selectedSalesperson =
                                  selectedSalesperson;
                              this.fromDate = fromDate ?? this.fromDate;
                              this.toDate = toDate ?? this.toDate;
                       
                              this.selectedCity =
                                  selectedCity ??
                                  KeyName(key: '', name: 'All Cities');
                             
                              selectedRange = 'Custom';
                            });
                            _fetchOrderSummary();
                          },
                        ),
                settings: RouteSettings(
                  arguments: {
                    'ledgerList': ledgerList,
                    'salespersonList': salespersonList,
                    'statesList': statesList,
                    'citiesList': citiesList,
                    //'selectedLedger': selectedLedger,
                    //'selectedSalesperson': selectedSalesperson,
                    'fromDate': fromDate,
                    'toDate': toDate,
                    'selectedDateRange': selectedRange,
                  },
                ),

              ),
            );
          },
          tooltip: 'Filter Orders',
          child: const Icon(Icons.filter_list, color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/catalog');
          if (index == 2) Navigator.pushNamed(context, '/orderbooking');
          if (index == 3) Navigator.pushNamed(context, '/stockReport');
          if (index == 4) return;
        },
      ),
    );
  }

  Future<void> _showOrderDetails(String orderType) async {
    try {
      String formattedOrderType = orderType
          .split(' ')
          .map(
            (word) => word[0].toUpperCase() + word.substring(1).toLowerCase(),
          )
          .join('');

      final response = await http.post(
        Uri.parse('${AppConstants.BASE_URL}/report/getReportsDetail'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "FromDate":
              "${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}",
          "ToDate":
              "${toDate.year}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}",
          "CoBr_Id": "01",
          "CustKey": customer,
          "SalesPerson": salesman,
          "State": state,
          "City": city,
          "orderType": formattedOrderType,
          "Detail": 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => OrderDetailsPage(
                    orderDetails: List<Map<String, dynamic>>.from(data),
                    fromDate: fromDate,
                    toDate: toDate,
                  ),
            ),
          );
        } else {
          throw Exception('Unexpected response format: Expected a list');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load order details: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

Widget _buildOrderCard(
    String title,
    String value,
    String qty,
    bool showQty,
    Color bgColor,
    IconData icon,
) {
  return SizedBox(
    width: 100, // Set a consistent width for all cards
    height: 200, // Optional: fixed height for uniformity
    child: GestureDetector(
      onTap: () {
        String orderType = title.replaceAll(' ', '');
        _showOrderDetails(orderType);
      },
      child: Card(
        elevation: 0,
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(90),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              if (showQty) ...[
                const SizedBox(height: 4),
                Text(
                  'Qty: $qty',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

}
