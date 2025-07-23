import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
      print(
        "HHHHHHHHHHCustomer wise-order detailResponse body:${response.body}",
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
                case 'viewAll':
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
                    value: 'viewAll',
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

  Future<List<Map<String, dynamic>>> _fetchFullCustomerReport() async {
    try {
      final requestBody = {
        "FromDate": DateFormat('yyyy-MM-dd').format(widget.fromDate),
        "ToDate": DateFormat('yyyy-MM-dd').format(widget.toDate),
        "CustKey": widget.custKey,
        "CoBr_Id": UserSession.coBrId,
        "orderType": widget.orderType,
        "All": false, // Get full report
      };

      print("Request Body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse('${AppConstants.BASE_URL}/report/customer-wise1'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load report: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching full customer report: $e');
      return [];
    }
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

  void _handleViewAll() async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Generating report...')));

      final detailedData = await _fetchFullCustomerReport();

      if (detailedData.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No data available')));
        return;
      }

      // Generate and open PDF for the entire report
      await _generateAndOpenFullPdf(detailedData);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _generateAndOpenFullPdf(
    List<Map<String, dynamic>> detailedData,
  ) async {
    final pdf = await _generateFullCustomerPDF(detailedData);
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/customer_${widget.customerName}_orders.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }



Future<pw.Document> _generateFullCustomerPDF(List<Map<String, dynamic>> inputList) async {
  final pdf = pw.Document();

  // Grouping the data
  Map<String, List<List<dynamic>>> groupedData = {};
  for (var item in inputList) {
    String key = "${item['ItemName']}-${item['Style']}-${item['OrderNo']}-${item['Color']}";
    List<dynamic> values = [
      item['Size'],
      item['OrderQty'],
      item['DelvQty'],
      item['SettleQty'],
      item['PendingQty']
    ];
    groupedData.putIfAbsent(key, () => []).add(values);
  }

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(10),
    build: (context) {
      List<pw.Widget> widgets = [];

      int serial = 1;
      num totalOrder = 0;
      num totalDelv = 0;
      num totalSettle = 0;
      num totalPend = 0;

      // Add table header once
      widgets.add(
        pw.Container(
          color: PdfColors.grey200,
          child: pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FixedColumnWidth(100),
              2: const pw.FixedColumnWidth(90),
              3: const pw.FixedColumnWidth(60),
              // 4: const pw.FixedColumnWidth(200),
              4: const pw.FixedColumnWidth(30),
              5: const pw.FixedColumnWidth(30),
              6: const pw.FixedColumnWidth(30),
              7: const pw.FixedColumnWidth(30),
              8: const pw.FixedColumnWidth(30),
              9: const pw.FixedColumnWidth(30),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('No', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Item Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Order No.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Color', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: 
                    pw.Text('Size', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: 
                    pw.Text('Order Qty.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: 
                    pw.Text('Delv. Qty.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: 
                    pw.Text('Settle Qty.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: 
                    pw.Text('Pend. Qty.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),                
                  
                ],
              )
            ],
          ),
        ),
      );

      // Add data rows
      groupedData.forEach((key, rows) {
        final parts = key.split('-');
        final itemName = parts[0];
        final style = parts[1];
        final orderNo = parts[2];
        final color = parts[3];

        num entryOrder = 0, entryDelv = 0, entrySettle = 0, entryPend = 0;

        widgets.add(
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FixedColumnWidth(100),
              2: const pw.FixedColumnWidth(90),
              3: const pw.FixedColumnWidth(60),
              4: const pw.FixedColumnWidth(200),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    alignment: pw.Alignment.center,
                    child: pw.Text('$serial'),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(itemName),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text("$orderNo\n(${DateFormat('yyyy-MM-dd').format(DateTime.now())})"),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(color),
                  ),

                  // Subtable inside single cell
                  pw.Table(
                    border: pw.TableBorder.all(width: 0.5),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(40),
                      1: const pw.FixedColumnWidth(40),
                      2: const pw.FixedColumnWidth(40),
                      3: const pw.FixedColumnWidth(40),
                      4: const pw.FixedColumnWidth(40),
                    },
                    children: [
                      // Subtable header
                      // pw.TableRow(
                      //   decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      //   children: [
                      //     pw.Center(child: pw.Text('Size', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      //     pw.Center(child: pw.Text('Ord.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      //     pw.Center(child: pw.Text('Delv.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      //     pw.Center(child: pw.Text('Settle', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      //     pw.Center(child: pw.Text('Pend.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      //   ],
                      // ),
                      // Subtable rows
                      ...rows.map((row) {
                        entryOrder += row[1];
                        entryDelv += row[2];
                        entrySettle += row[3];
                        entryPend += row[4];
                        return pw.TableRow(
                          children: row.map((val) {
                            return pw.Container(
                              padding: const pw.EdgeInsets.all(4),
                              alignment: pw.Alignment.center,
                              child: pw.Text(val.toString()),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

        // Update totals
        totalOrder += entryOrder;
        totalDelv += entryDelv;
        totalSettle += entrySettle;
        totalPend += entryPend;
        serial++;
      });

      // Total Summary Row
      widgets.add(
        pw.SizedBox(height: 10),
      );

      widgets.add(
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(50),
              1: const pw.FixedColumnWidth(50),
              2: const pw.FixedColumnWidth(50),
              3: const pw.FixedColumnWidth(50),
              4: const pw.FixedColumnWidth(50),
            },
            border: pw.TableBorder.all(width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Center(child: pw.Text("Total")),
                  pw.Center(child: pw.Text("$totalOrder")),
                  pw.Center(child: pw.Text("$totalDelv")),
                  pw.Center(child: pw.Text("$totalSettle")),
                  pw.Center(child: pw.Text("$totalPend")),
                ],
              )
            ],
          ),
        ),
      );

      return widgets;
    },
  ));

  return pdf;
}



// Future<pw.Document> _generateFullCustomerPDF(List<Map<String, dynamic>> inputList) async {
//   final pdf = pw.Document();

//   // Grouping the data
//   Map<String, List<List<dynamic>>> groupedData = {};
//   for (var item in inputList) {
//     String key = "${item['ItemName']}-${item['Style']}-${item['OrderNo']}-${item['Color']}";
//     List<dynamic> values = [
//       item['Size'],
//       item['OrderQty'],
//       item['DelvQty'],
//       item['SettleQty'],
//       item['PendingQty']
//     ];
//     groupedData.putIfAbsent(key, () => []).add(values);
//   }


//   pdf.addPage(pw.MultiPage(
//     pageFormat: PdfPageFormat.a4,
//     margin: const pw.EdgeInsets.all(10),
//     build: (context) {
//       List<pw.Widget> widgets = [];

//       int serial = 1;
//       num totalOrder = 0;
//       num totalDelv = 0;
//       num totalSettle = 0;
//       num totalPend = 0;

//       groupedData.forEach((key, rows) {
//         final parts = key.split('-');
//         final itemName = parts[0];
//         final style = parts[1];
//         final orderNo = parts[2];
//         final color = parts[3];

//         num entryOrder = 0, entryDelv = 0, entrySettle = 0, entryPend = 0;

//         widgets.add(
//           pw.Table(
//             border: pw.TableBorder.all(width: 0.5),
//             columnWidths: {
//               0: const pw.FixedColumnWidth(30), // No
//               1: const pw.FixedColumnWidth(100), // Item Name
//               2: const pw.FixedColumnWidth(90), // Order No
//               3: const pw.FixedColumnWidth(60), // Color
//               4: const pw.FixedColumnWidth(200), // Sub Table
//             },
//             children: [
//               // Main row (header)
//               pw.TableRow(
//                 children: [
//                   pw.Container(
//                     padding: const pw.EdgeInsets.all(4),
//                     alignment: pw.Alignment.center,
//                     child: pw.Text('$serial'),
//                   ),
//                   pw.Container(
//                     padding: const pw.EdgeInsets.all(4),
//                     child: pw.Text(itemName),
//                   ),
//                   pw.Container(
//                     padding: const pw.EdgeInsets.all(4),
//                     child: pw.Text("$orderNo\n(${DateFormat('yyyy-MM-dd').format(DateTime.now())})"),
//                   ),
//                   pw.Container(
//                     padding: const pw.EdgeInsets.all(4),
//                     child: pw.Text(color),
//                   ),
//                   // Subtable column
//                   pw.Table(
//                     border: pw.TableBorder.all(width: 0.5),
//                     columnWidths: {
//                       0: const pw.FixedColumnWidth(40),
//                       1: const pw.FixedColumnWidth(40),
//                       2: const pw.FixedColumnWidth(40),
//                       3: const pw.FixedColumnWidth(40),
//                       4: const pw.FixedColumnWidth(40),
//                     },
//                     children: [
       
//                       ...rows.map((row) {
//                         entryOrder += row[1];
//                         entryDelv += row[2];
//                         entrySettle += row[3];
//                         entryPend += row[4];
//                         return pw.TableRow(
//                           children: row.map((val) {
//                             return pw.Container(
//                               padding: const pw.EdgeInsets.all(4),
//                               alignment: pw.Alignment.center,
//                               child: pw.Text(val.toString()),
//                             );
//                           }).toList(),
//                         );
//                       }).toList(),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );

//         // Update global totals
//         totalOrder += entryOrder;
//         totalDelv += entryDelv;
//         totalSettle += entrySettle;
//         totalPend += entryPend;

//        // widgets.add(pw.SizedBox(height: 10));
//         serial++;
//       });

//       // Total Summary Row
//       widgets.add(
//         pw.Container(
//           alignment: pw.Alignment.centerRight,
//           child: pw.Table(
//             columnWidths: {
//               0: const pw.FixedColumnWidth(50),
//               1: const pw.FixedColumnWidth(50),
//               2: const pw.FixedColumnWidth(50),
//               3: const pw.FixedColumnWidth(50),
//             },
//             border: pw.TableBorder.all(width: 0.5),
//             children: [
//               pw.TableRow(
//                 decoration: const pw.BoxDecoration(color: PdfColors.grey300),
//                 children: [
//                   pw.Center(child: pw.Text("Total")),
//                   pw.Center(child: pw.Text("$totalOrder")),
//                   pw.Center(child: pw.Text("$totalDelv")),
//                   pw.Center(child: pw.Text("$totalSettle")),
//                   pw.Center(child: pw.Text("$totalPend")),
//                 ],
//               )
//             ],
//           ),
//         ),
//       );

//       return widgets;
//     },
//   ));

//   return pdf;
// }





  // Future<pw.Document> _generateFullCustomerPDF(
  //   List<Map<String, dynamic>> detailedData,
  // ) async {
  //   final pdf = pw.Document();

  //   final fromDate = DateFormat('dd-MM-yyyy').format(widget.fromDate);
  //   final toDate = DateFormat('dd-MM-yyyy').format(widget.toDate);
  //   print(detailedData[0]);

  //   // Group data by ItemName + OrderNo + Color
  //   Map<String, List<Map<String, dynamic>>> groupedData = {};
  //   for (var item in detailedData) {
  //     print("aaaaaaaa");
  //     print(item);
  //     String key = '${item['ItemName']}_${item['OrderNo']}_${item['Color']}';
  //     groupedData.putIfAbsent(key, () => []).add(item);
  //   }

  //   // Function to get image URL
  //   String _getImageUrl(Map<String, dynamic> item) {
  //     print("ooooooooooooooooooooooooooooooooooo");
  //     print(UserSession.onlineImage);
  //     if (UserSession.onlineImage == '0') {
  //       final imagePath = item['Style_Image'] ?? '';
  //       final imageName = imagePath.split('/').last.split('?').first;
  //       if (imageName.isEmpty) {
  //         return '';
  //       }
  //       return '${AppConstants.BASE_URL}/images/$imageName';
  //     } else if (UserSession.onlineImage == '1') {
  //       return item['Style_Image'] ?? '';
  //     }
  //     return '';
  //   }

  //   // Function to load image for PDF
  //   Future<pw.ImageProvider?> _loadImage(String imageUrl) async {
  //     if (imageUrl.isEmpty) return null;
  //     try {
  //       final response = await http.get(Uri.parse(imageUrl));
  //       if (response.statusCode == 200) {
  //         return pw.MemoryImage(response.bodyBytes);
  //       }
  //     } catch (e) {
  //       print('Error loading image $imageUrl: $e');
  //     }
  //     return null;
  //   }

  //   // Precompute table rows with images
  //   List<pw.TableRow> tableRows = [];

  //   // Add table header
  //   tableRows.add(
  //     pw.TableRow(
  //       decoration: const pw.BoxDecoration(color: PdfColors.grey200),
  //       children: [
  //         pw.Padding(
  //           padding: const pw.EdgeInsets.all(4),
  //           child: pw.Text(
  //             'No',
  //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //         pw.Padding(
  //           padding: const pw.EdgeInsets.all(4),
  //           child: pw.Text(
  //             _appBarViewChecked ? 'Image/ItemName' : 'ItemName',
  //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //         pw.Padding(
  //           padding: const pw.EdgeInsets.all(4),
  //           child: pw.Text(
  //             'Order No.',
  //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //         pw.Padding(
  //           padding: const pw.EdgeInsets.all(4),
  //           child: pw.Text(
  //             'Color',
  //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //         pw.Padding(
  //           padding: const pw.EdgeInsets.all(4),
  //           child: pw.Text(
  //             'Size',
  //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //         pw.Padding(
  //           padding: const pw.EdgeInsets.all(4),
  //           child: pw.Text(
  //             'Order Qty.',
  //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //         pw.Padding(
  //           padding: const pw.EdgeInsets.all(4),
  //           child: pw.Text(
  //             'Delv. Qty.',
  //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //         pw.Padding(
  //           padding: const pw.EdgeInsets.all(4),
  //           child: pw.Text(
  //             'Settle Qty.',
  //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //         pw.Padding(
  //           padding: const pw.EdgeInsets.all(4),
  //           child: pw.Text(
  //             'Pend. Qty.',
  //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );

  //   // Generate data rows
  //   for (var entry in groupedData.entries) {
  //     final groupItems = entry.value;
  //     final groupRows = await Future.wait(
  //       List.generate(groupItems.length, (i) async {
  //         final item = groupItems[i];
  //         final isFirstRow = i == 0;
  //         final isLastRow = i == groupItems.length - 1;
  //         final groupIndex = groupedData.keys.toList().indexOf(entry.key) + 1;

  //         // Load image and display both image and ItemName for the first row if _appBarViewChecked is true
  //         pw.Widget itemNameCell;
  //         if (_appBarViewChecked && isFirstRow) {
  //           final imageUrl = _getImageUrl(item);
  //           final image = await _loadImage(imageUrl);
  //           itemNameCell = pw.Container(
  //             height:
  //                 60.0 *
  //                 groupItems
  //                     .length, // Increased height to accommodate both image and text
  //             child: pw.Column(
  //               mainAxisAlignment: pw.MainAxisAlignment.center,
  //               children: [
  //                 image != null
  //                     ? pw.Container(
  //                       height: 40,
  //                       child: pw.Image(image, fit: pw.BoxFit.contain),
  //                     )
  //                     : pw.Container(
  //                       height: 40,
  //                       alignment: pw.Alignment.center,
  //                       child: pw.Text(
  //                         '📷', // Unicode camera icon as a placeholder
  //                         style: pw.TextStyle(
  //                           fontSize: 20,
  //                           color: PdfColors.grey,
  //                         ),
  //                       ),
  //                     ),
  //                 pw.SizedBox(height: 4),
  //                 pw.Text(
  //                   item['ItemName']?.toString() ?? '',
  //                   style: const pw.TextStyle(fontSize: 10),
  //                 ),
  //               ],
  //             ),
  //           );
  //         } else {
  //           itemNameCell =
  //               isFirstRow
  //                   ? pw.Text(item['ItemName']?.toString() ?? '')
  //                   : pw.Text('');
  //         }

  //         // Custom border to remove horizontal lines within the group, except for the last row
  //         final border = pw.TableBorder(
  //           left: const pw.BorderSide(),
  //           right: const pw.BorderSide(),
  //           top: isFirstRow ? const pw.BorderSide() : pw.BorderSide.none,
  //           bottom: isLastRow ? const pw.BorderSide() : pw.BorderSide.none,
  //         );

  //         return pw.TableRow(
  //           decoration: pw.BoxDecoration(border: border),
  //           children: [
  //             pw.Padding(
  //               padding: const pw.EdgeInsets.all(4),
  //               child: pw.Text(isFirstRow ? groupIndex.toString() : ''),
  //             ),
  //             pw.Padding(
  //               padding: const pw.EdgeInsets.all(4),
  //               child: itemNameCell,
  //             ),
  //             pw.Padding(
  //               padding: const pw.EdgeInsets.all(4),
  //               child: pw.Text(
  //                 isFirstRow
  //                     ? '${item['OrderNo'] ?? ''}\n(${item['OrderDate'] ?? ''})'
  //                     : '',
  //               ),
  //             ),
  //             pw.Padding(
  //               padding: const pw.EdgeInsets.all(4),
  //               child: pw.Text(
  //                 isFirstRow ? item['Color']?.toString() ?? '' : '',
  //               ),
  //             ),
  //             pw.Padding(
  //               padding: const pw.EdgeInsets.all(4),
  //               child: pw.Text(item['Size']?.toString() ?? ''),
  //             ),
  //             pw.Padding(
  //               padding: const pw.EdgeInsets.all(4),
  //               child: pw.Text((item['OrderQty'] ?? 0).toString()),
  //             ),
  //             pw.Padding(
  //               padding: const pw.EdgeInsets.all(4),
  //               child: pw.Text((item['DelvQty'] ?? 0).toString()),
  //             ),
  //             pw.Padding(
  //               padding: const pw.EdgeInsets.all(4),
  //               child: pw.Text((item['SettleQty'] ?? 0).toString()),
  //             ),
  //             pw.Padding(
  //               padding: const pw.EdgeInsets.all(4),
  //               child: pw.Text((item['PendingQty'] ?? 0).toString()),
  //             ),
  //           ],
  //         );
  //       }),
  //     );
  //     tableRows.addAll(groupRows);
  //   }

  //   // Add total row
  //   tableRows.add(
  //     pw.TableRow(
  //       decoration: const pw.BoxDecoration(color: PdfColors.grey200),
  //       children: [
  //         pw.Padding(
  //           padding: const pw.EdgeInsets.all(4),
  //           child: pw.Text(
  //             'Total',
  //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //         for (int i = 0; i < 4; i++) pw.Text(''),
  //         pw.Padding(
  //           padding: const pw.EdgeInsets.all(4),
  //           child: pw.Text(
  //             detailedData
  //                 .fold<int>(
  //                   0,
  //                   (sum, item) =>
  //                       sum + ((item['OrderQty'] ?? 0) as num).toInt(),
  //                 )
  //                 .toString(),
  //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //         pw.Padding(
  //           padding: const pw.EdgeInsets.all(4),
  //           child: pw.Text(
  //             detailedData
  //                 .fold<int>(
  //                   0,
  //                   (sum, item) =>
  //                       sum + ((item['DelvQty'] ?? 0) as num).toInt(),
  //                 )
  //                 .toString(),
  //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //         pw.Padding(
  //           padding: const pw.EdgeInsets.all(4),
  //           child: pw.Text(
  //             detailedData
  //                 .fold<int>(
  //                   0,
  //                   (sum, item) =>
  //                       sum + ((item['SettleQty'] ?? 0) as num).toInt(),
  //                 )
  //                 .toString(),
  //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //         pw.Padding(
  //           padding: const pw.EdgeInsets.all(4),
  //           child: pw.Text(
  //             detailedData
  //                 .fold<int>(
  //                   0,
  //                   (sum, item) =>
  //                       sum + ((item['PendingQty'] ?? 0) as num).toInt(),
  //                 )
  //                 .toString(),
  //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );

  //   pdf.addPage(
  //     pw.MultiPage(
  //       pageFormat: PdfPageFormat.a4,
  //       build: (context) {
  //         return [
  //           // Blue Header
  //           pw.Container(
  //             color: PdfColors.blue,
  //             padding: const pw.EdgeInsets.all(10),
  //             child: pw.Column(
  //               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //               children: [
  //                 pw.Row(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                   children: [
  //                     pw.Expanded(
  //                       child: pw.Column(
  //                         crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                         children: [
  //                           pw.Text(
  //                             'Order Register - Party Wise',
  //                             style: pw.TextStyle(
  //                               fontSize: 16,
  //                               fontWeight: pw.FontWeight.bold,
  //                               color: PdfColors.white,
  //                             ),
  //                           ),
  //                           pw.Text(
  //                             UserSession.coBrName ?? 'VRS Software Pvt Ltd',
  //                             style: pw.TextStyle(
  //                               fontSize: 14,
  //                               fontWeight: pw.FontWeight.bold,
  //                               color: PdfColors.white,
  //                             ),
  //                           ),
  //                           pw.Text(
  //                             '1234567890',
  //                             style: pw.TextStyle(
  //                               fontSize: 12,
  //                               color: PdfColors.white,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     pw.Text(
  //                       'Print Date: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now())}',
  //                       style: pw.TextStyle(
  //                         fontSize: 10,
  //                         color: PdfColors.white,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 pw.SizedBox(height: 5),
  //                 pw.Text(
  //                   'Date: $fromDate to $toDate',
  //                   style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           pw.SizedBox(height: 10),

  //           // Party Name
  //           pw.Text(
  //             widget.customerName.toUpperCase(),
  //             style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
  //           ),
  //           pw.SizedBox(height: 10),

  //           // Table
  //           pw.Table(
  //             border: pw.TableBorder.all(),
  //             columnWidths: {
  //               0: pw.FixedColumnWidth(25), // No
  //               1: pw.FixedColumnWidth(
  //                 100,
  //               ), // ItemName (or Image/ItemName if checked)
  //               2: pw.FixedColumnWidth(75), // Order No.
  //               3: pw.FixedColumnWidth(50), // Color
  //               4: pw.FixedColumnWidth(40), // Size
  //               5: pw.FixedColumnWidth(50), // Order Qty.
  //               6: pw.FixedColumnWidth(50), // Delv. Qty.
  //               7: pw.FixedColumnWidth(50), // Settle Qty.
  //               8: pw.FixedColumnWidth(50), // Pend. Qty.
  //             },
  //             children: tableRows,
  //           ),
  //         ];
  //       },
  //     ),
  //   );

  //   return pdf;
  // }

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not make a call')));
    }
  }

  void _showContactOptions(BuildContext context, String phoneNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent, // Make background transparent for rounded bottom
      isScrollControlled: true,
      builder:
          (context) => SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(0),
                  bottom: Radius.circular(0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 0),
                    child: Column(
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
                      Icon(
                        Icons.receipt_long,
                        size: 16,
                        color: Colors.blue[700],
                      ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: 16,
                          color: deliveryColor,
                        ),
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
                  child:
                      (order['WhatsAppMobileNo'] != null &&
                              order['WhatsAppMobileNo']
                                  .toString()
                                  .trim()
                                  .isNotEmpty)
                          ? GestureDetector(
                            onTap:
                                () => _showContactOptions(
                                  context,
                                  order['WhatsAppMobileNo'].toString(),
                                ),
                            child: Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  size: 12,
                                  color: Colors.green,
                                ),
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
                          : Row(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.whatsapp,
                                size: 12,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: _buildTextWithMarquee(
                                  'xxxxx xxxxx',
                                  GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
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
                  orderType: widget.orderType, // Pass orderType from widget
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
  final String orderType;

  const _OrderPopupMenu({
    required this.order,
    required this.viewChecked,
    required this.onViewCheckedChanged,
    required this.onDownload,
    required this.onWhatsApp,
    required this.onView,
    required this.orderType,
  });

  Future<List<Map<String, dynamic>>> _fetchCustomerWiseReport(int docId) async {
    try {
      final requestBody = {
        "CoBr_Id": UserSession.coBrId,
        "orderType": orderType,
        "DocId": docId,
        "All": true,
      };

      print("📤 Request Body:\n${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse('${AppConstants.BASE_URL}/report/customer-wise'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("📥 Response Body:\n${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load report: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching report: $e');
      return [];
    }
  }

  Future<void> _generateAndOpenPdf(BuildContext context) async {
    // Fetch detailed data
    final detailedData = await _fetchCustomerWiseReport(order['OrderId'] ?? 0);

    final pdf = await _generatePDF(order, detailedData); // Pass detailed data
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/order_${order['OrderNo']}.pdf');
    await file.writeAsBytes(await pdf.save());

    // Open the PDF
    await OpenFile.open(file.path);
  }

  Future<pw.Document> _generatePDF(
    Map<String, dynamic> orderData,
    List<Map<String, dynamic>> detailedData,
  ) async {
    final pdf = pw.Document();

    final fromDate = DateFormat('dd-MM-yyyy').format(
      DateFormat('yyyy-MM-dd').parse(
        detailedData.isNotEmpty ? detailedData[0]['FromDate'] : '2025-07-17',
      ),
    );
    final toDate = DateFormat('dd-MM-yyyy').format(
      DateFormat('yyyy-MM-dd').parse(
        detailedData.isNotEmpty ? detailedData[0]['ToDate'] : '2025-07-17',
      ),
    );

    // Group data by ItemName + OrderNo + Color
    Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in detailedData) {
      String key = '${item['ItemName']}_${item['OrderNo']}_${item['Color']}';
      groupedData.putIfAbsent(key, () => []).add(item);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            // Blue Header
            pw.Container(
              color: PdfColors.blue,
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              'Order Register - Party Wise',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.Text(
                              UserSession.coBrName ?? 'VRS Software Pvt Ltd',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.Text(
                              '1234567890',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Text(
                        'Print Date: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now())}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Date: $fromDate to $toDate',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Party Name
            pw.Text(
              (detailedData.isNotEmpty
                          ? detailedData[0]['Party'] ??
                              orderData['CustomerName']
                          : orderData['CustomerName'])
                      ?.toString()
                      .toUpperCase() ??
                  '',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),

            // Table Header
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FixedColumnWidth(25), // No
                1: pw.FixedColumnWidth(100), // ItemName
                2: pw.FixedColumnWidth(75), // Order No.
                3: pw.FixedColumnWidth(50), // Color
                4: pw.FixedColumnWidth(40), // Size
                5: pw.FixedColumnWidth(50), // Order Qty.
                6: pw.FixedColumnWidth(50), // Delv. Qty.
                7: pw.FixedColumnWidth(50), // Settle Qty.
                8: pw.FixedColumnWidth(50), // Pend. Qty.
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'No',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'ItemName',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Order No.',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Color',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Size',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Order Qty.',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Delv. Qty.',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Settle Qty.',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Pend. Qty.',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                // Grouped Data Rows
                for (var entry in groupedData.entries)
                  ...List<pw.TableRow>.generate(entry.value.length, (i) {
                    final item = entry.value[i];
                    final isFirstRow = i == 0;
                    final groupIndex =
                        groupedData.keys.toList().indexOf(entry.key) + 1;

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            isFirstRow ? groupIndex.toString() : '',
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            isFirstRow
                                ? item['ItemName']?.toString() ?? ''
                                : '',
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            isFirstRow
                                ? '${item['OrderNo'] ?? ''}\n(${item['OrderDate'] ?? ''})'
                                : '',
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            isFirstRow ? item['Color']?.toString() ?? '' : '',
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(item['Size']?.toString() ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text((item['OrderQty'] ?? 0).toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text((item['DelvQty'] ?? 0).toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text((item['SettleQty'] ?? 0).toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text((item['PendingQty'] ?? 0).toString()),
                        ),
                      ],
                    );
                  }),

                // Total Row
                // Total Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    for (int i = 0; i < 4; i++) pw.Text(''),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        detailedData
                            .fold<int>(
                              0,
                              (sum, item) =>
                                  sum +
                                  ((item['OrderQty'] ?? 0) as num).toInt(),
                            )
                            .toString(),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        detailedData
                            .fold<int>(
                              0,
                              (sum, item) =>
                                  sum + ((item['DelvQty'] ?? 0) as num).toInt(),
                            )
                            .toString(),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        detailedData
                            .fold<int>(
                              0,
                              (sum, item) =>
                                  sum +
                                  ((item['SettleQty'] ?? 0) as num).toInt(),
                            )
                            .toString(),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        detailedData
                            .fold<int>(
                              0,
                              (sum, item) =>
                                  sum +
                                  ((item['PendingQty'] ?? 0) as num).toInt(),
                            )
                            .toString(),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
      onSelected: (String value) async {
        switch (value) {
          case 'download':
            onDownload();
            break;
          case 'whatsapp':
            onWhatsApp();
            break;
          case 'view':
            await _generateAndOpenPdf(context); // Generate and open PDF
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
