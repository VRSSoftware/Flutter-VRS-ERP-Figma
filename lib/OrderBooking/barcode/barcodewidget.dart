// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:http/http.dart' as http;
// import 'package:vrs_erp_figma/OrderBooking/barcode/barcode_scanner.dart';
// import 'package:vrs_erp_figma/constants/app_constants.dart';
// import 'package:vrs_erp_figma/services/app_services.dart';
// import 'package:vrs_erp_figma/OrderBooking/barcode/bookOnBarcode.dart';

// class BarcodeWiseWidget extends StatefulWidget {
//   final ValueChanged<String> onFilterPressed;
//   // final Set<String> activeFilters;

//   const BarcodeWiseWidget({
//     super.key,
//     required this.onFilterPressed,
//     // required this.activeFilters,
//   });

//   @override
//   State<BarcodeWiseWidget> createState() => _BarcodeWiseWidgetState();
// }

// class _BarcodeWiseWidgetState extends State<BarcodeWiseWidget> {
//   final TextEditingController _barcodeController = TextEditingController();
//   List<Map<String, dynamic>> _barcodeResults = [];
//   List<String> addedItems = [];
//   Map<String, bool> _filters = {
//     'WSP': true,
//     'Sizes': true,
//     'Shades': true,
//     'StyleCode': true,
//   };

//   @override
//   void dispose() {
//     _barcodeController.dispose();
//     super.dispose();
//   }

//   void _showFilterPopup(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Select Fields to Show'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children:
//                 _filters.keys.map((key) {
//                   return CheckboxListTile(
//                     title: Text(key),
//                     value: _filters[key],
//                     onChanged: (bool? value) {
//                       setState(() {
//                         _filters[key] = value ?? true;
//                       });
//                       Navigator.pop(context);
//                       _showFilterPopup(
//                         context,
//                       ); // Reopen dialog to show updated state
//                     },
//                   );
//                 }).toList(),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Done'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _scanBarcode() async {
//     final barcode = await Navigator.push<String>(
//       context,
//       MaterialPageRoute(builder: (context) => BarcodeScannerScreen()),
//     );

//     if (barcode != null && barcode.isNotEmpty) {
//       setState(() {
//         _barcodeController.text = barcode;
//       });
//     }
//   }

//   Future<void> _searchBarcode() async {
//     final barcode = _barcodeController.text.trim();
//     if (barcode.isEmpty) return;

//     FocusScope.of(context).unfocus(); // 👈 This removes the cursor

//     try {
//       final result = await ApiService.getBarcodeDetails(barcode);
//       debugPrint("Barcode Result: $result");

//       if (result is List && result.isNotEmpty) {
//         setState(() {
//           _barcodeResults = List<Map<String, dynamic>>.from(result);
//         });
//         widget.onFilterPressed(barcode);
//       } else {
//         setState(() {
//           _barcodeResults = [];
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No data found for this barcode')),
//         );
//       }
//     } catch (e) {
//       debugPrint("Error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to fetch barcode details')),
//       );
//     }
//   }

//   void _searchBarcode2() {}

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 controller: _barcodeController,
//                 decoration: InputDecoration(
//                   labelText: "Enter Barcode",
//                   labelStyle: const TextStyle(fontSize: 14),
//                   isDense: true,
//                   contentPadding: const EdgeInsets.symmetric(
//                     vertical: 6.0,
//                     horizontal: 14.0,
//                   ),
//                   filled: true,
//                   fillColor: const Color(0xFFF6F8FA),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(0),
//                     borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(0),
//                     borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             GestureDetector(
//               onTap: _scanBarcode,
//               child: Image.asset(
//                 'assets/images/barcode.png',
//                 width: 40,
//                 height: 40,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primaryColor,
//             minimumSize: const Size(80, 40),
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(0),
//             ),
//           ),
//           // onPressed: _searchBarcode2,
//           onPressed: () {
//             print(_barcodeController.text.trim());
//             showDialog(
//               context: context,
//               builder:
//                   (context) => Dialog(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(0),
//                     ),
//                     child: SizedBox(
//                       width: double.infinity,
//                       child: CatalogBookingTableBarcode(
//                         barcode: _barcodeController.text.trim(),
//                         onSuccess: () {
//                           Navigator.pop(context); // Close dialog on success
//                           // Optionally refresh parent data or show snackbar
//                         },
//                       ),
//                     ),
//                   ),
//             );
//           },
//           child: const Text("Search", style: TextStyle(color: Colors.white)),
//         ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/OrderBooking/barcode/barcode_scanner.dart';
import 'package:vrs_erp_figma/OrderBooking/barcode/bookonBarcode2.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';

class BarcodeWiseWidget extends StatefulWidget {
  final ValueChanged<String> onFilterPressed;

  const BarcodeWiseWidget({
    super.key,
    required this.onFilterPressed,
  });

  @override
  State<BarcodeWiseWidget> createState() => _BarcodeWiseWidgetState();
}

class _BarcodeWiseWidgetState extends State<BarcodeWiseWidget> {
  final TextEditingController _barcodeController = TextEditingController();
  List<Map<String, dynamic>> _barcodeResults = [];
  List<String> addedItems = [];
  Map<String, bool> _filters = {
    'WSP': true,
    'Sizes': true,
    'Shades': true,
    'StyleCode': true,
  };
  bool _noDataFound = false; // New state variable for no data

  @override
  void initState() {
    super.initState();
    _barcodeController.addListener(() {
      final text = _barcodeController.text.toUpperCase();
      if (_barcodeController.text != text) {
        _barcodeController.value = _barcodeController.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _showFilterPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Fields to Show'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _filters.keys.map((key) {
              return CheckboxListTile(
                title: Text(key),
                value: _filters[key],
                onChanged: (bool? value) {
                  setState(() {
                    _filters[key] = value ?? true;
                  });
                  Navigator.pop(context);
                  _showFilterPopup(context);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _scanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => BarcodeScannerScreen()),
    );

    if (barcode != null && barcode.isNotEmpty) {
      final upperBarcode = barcode.toUpperCase();
      setState(() {
        _barcodeController.text = upperBarcode;
        _noDataFound = false; // Reset no data flag
      });

      _validateAndNavigate(upperBarcode);
    }
  }

  void _validateAndNavigate(String barcode) async {
    if (barcode.isEmpty) {
      _showAlertDialog(context, 'Missing Barcode', 'Please enter or scan a barcode first.');
      return;
    }

    String upperBarcode = barcode.toUpperCase();
    print("Checking barcode: $upperBarcode, addedItems: $addedItems");
    if (addedItems.contains(upperBarcode)) {
      _showAlertDialog(context, 'Already Added', 'This barcode is already added');
      return;
    }

    print("Navigating to BookOnBarcode2 with barcode: $upperBarcode");
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BookOnBarcode2(
          barcode: upperBarcode,
          onSuccess: () {
            setState(() {
              addedItems.add(upperBarcode);
              print("Added barcode: $upperBarcode, addedItems: $addedItems");
              _barcodeController.clear();
              _noDataFound = false; // Reset no data flag on success
            });
          },
        ),
      ),
    );

    // Check the result from BookOnBarcode2
    if (result == false) {
      setState(() {
        _noDataFound = true; // Set no data flag
      });
    } else {
      setState(() {
        _noDataFound = false; // Reset no data flag
      });
    }
  }

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      labelText: "Enter Barcode",
                      labelStyle: const TextStyle(fontSize: 14),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 14.0,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F8FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _scanBarcode,
                  child: Image.asset(
                    'assets/images/barcode.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(80, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                onPressed: () {
                  _validateAndNavigate(_barcodeController.text.trim());
                },
                child: const Text("Search", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          // Show "No Data Found" message if applicable
          if (_noDataFound)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Center(
                child: Text(
                  "No Data Found",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          // Only show results if _barcodeResults is not empty
          if (_barcodeResults.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("Barcode Results:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  if (_filters['StyleCode'] == true)
                    const DataColumn(label: Text("Style Code")),
                  if (_filters['WSP'] == true)
                    const DataColumn(label: Text("WSP")),
                  if (_filters['Sizes'] == true)
                    const DataColumn(label: Text("Size")),
                  if (_filters['Shades'] == true)
                    const DataColumn(label: Text("Shade")),
                ],
                rows: _barcodeResults.map((result) {
                  return DataRow(cells: [
                    if (_filters['StyleCode'] == true)
                      DataCell(Text(result['StyleCode']?.toString() ?? '')),
                    if (_filters['WSP'] == true)
                      DataCell(Text(result['WSP']?.toString() ?? '')),
                    if (_filters['Sizes'] == true)
                      DataCell(Text(result['Size']?.toString() ?? '')),
                    if (_filters['Shades'] == true)
                      DataCell(Text(result['Shade']?.toString() ?? '')),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}