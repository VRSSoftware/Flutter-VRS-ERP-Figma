// import 'package:flutter/material.dart';
// import 'package:vrs_erp_figma/OrderBooking/barcode/barcode_scanner.dart';
// import 'package:vrs_erp_figma/OrderBooking/barcode/bookonBarcode2.dart';
// import 'package:vrs_erp_figma/constants/app_constants.dart';

// class BarcodeWiseWidget extends StatefulWidget {
//   final ValueChanged<String> onFilterPressed;

//   const BarcodeWiseWidget({super.key, required this.onFilterPressed});

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
//   bool _noDataFound = false; // New state variable for no data

//   @override
//   void initState() {
//     super.initState();
//     _barcodeController.addListener(() {
//       final text = _barcodeController.text.toUpperCase();
//       if (_barcodeController.text != text) {
//         _barcodeController.value = _barcodeController.value.copyWith(
//           text: text,
//           selection: TextSelection.collapsed(offset: text.length),
//         );
//       }
//     });
//   }

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
//                       _showFilterPopup(context);
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
//       final upperBarcode = barcode.toUpperCase();
//       setState(() {
//         _barcodeController.text = upperBarcode;
//         _noDataFound = false; // Reset no data flag
//       });

//       _validateAndNavigate(upperBarcode);
//     }
//   }

//   void _validateAndNavigate(String barcode) async {
//     if (barcode.isEmpty) {
//       _showAlertDialog(
//         context,
//         'Missing Barcode',
//         'Please enter or scan a barcode first.',
//       );
//       return;
//     }

//     String upperBarcode = barcode.toUpperCase();
//     print("Checking barcode: $upperBarcode, addedItems: $addedItems");
//     if (addedItems.contains(upperBarcode)) {
//       _showAlertDialog(
//         context,
//         'Already Added',
//         'This barcode is already added',
//       );
//       return;
//     }

//     print("Navigating to BookOnBarcode2 with barcode: $upperBarcode");
//     final result = await Navigator.push<bool>(
//       context,
//       MaterialPageRoute(
//         builder:
//             (context) => BookOnBarcode2(
//               barcode: upperBarcode,
//               onSuccess: () {
//                 setState(() {
//                   addedItems.add(upperBarcode);
//                   print(
//                     "Added barcode: $upperBarcode, addedItems: $addedItems",
//                   );
//                   _barcodeController.clear();
//                   _noDataFound = false; // Reset no data flag on success
//                 });
//               },
//               onCancel: () {
//                 _barcodeController
//                     .clear(); // This will clear the barcode text field
//               },
//             ),
//       ),
//     );

//     // Check the result from BookOnBarcode2
//     if (result == false) {
//       setState(() {
//         _noDataFound = true; // Set no data flag
//       });
//     } else {
//       setState(() {
//         _noDataFound = false; // Reset no data flag
//       });
//     }
//   }

//   void _showAlertDialog(BuildContext context, String title, String message) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text(title),
//             content: Text(message),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: _barcodeController,
//                     decoration: InputDecoration(
//                       labelText: "Enter Barcode",
//                       labelStyle: const TextStyle(fontSize: 14),
//                       isDense: true,
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 6.0,
//                         horizontal: 14.0,
//                       ),
//                       filled: true,
//                       fillColor: const Color(0xFFF6F8FA),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(0),
//                         borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(0),
//                         borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 GestureDetector(
//                   onTap: _scanBarcode,
//                   child: Image.asset(
//                     'assets/images/barcode.png',
//                     width: 40,
//                     height: 40,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 12.0,
//               vertical: 12.0,
//             ),
//             child: Center(
//               child: GestureDetector(
//                 onTap: () {
//                   _validateAndNavigate(_barcodeController.text.trim());
//                 },
//                 child: Container(
//                   height: 38,
//                   width: 140,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: AppColors.primaryColor,
//                       width: 1.5,
//                     ),
//                     borderRadius: BorderRadius.circular(0),
//                   ),
//                   child: Row(
//                     children: [
//                       // Left diagonal area with "SEARCH"
//                       Expanded(
//                         child: ClipPath(
//                           clipper: DiagonalClipper(),
//                           child: Container(
//                             color: AppColors.primaryColor,
//                             alignment: Alignment.center,
//                             child: const Text(
//                               'SEARCH',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                                 letterSpacing: 1.2,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       // Icon section
//                       Container(
//                         width: 38,
//                         alignment: Alignment.center,
//                         child: Icon(
//                           Icons.search,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           // Show "No Data Found" message if applicable
//           if (_noDataFound)
//             const Padding(
//               padding: EdgeInsets.all(12.0),
//               child: Center(
//                 child: Text(
//                   "No Data Found",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.red,
//                   ),
//                 ),
//               ),
//             ),
//           // Only show results if _barcodeResults is not empty
//           if (_barcodeResults.isNotEmpty) ...[
//             const Padding(
//               padding: EdgeInsets.all(12.0),
//               child: Text(
//                 "Barcode Results:",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columns: [
//                   if (_filters['StyleCode'] == true)
//                     const DataColumn(label: Text("Style Code")),
//                   if (_filters['WSP'] == true)
//                     const DataColumn(label: Text("WSP")),
//                   if (_filters['Sizes'] == true)
//                     const DataColumn(label: Text("Size")),
//                   if (_filters['Shades'] == true)
//                     const DataColumn(label: Text("Shade")),
//                 ],
//                 rows:
//                     _barcodeResults.map((result) {
//                       return DataRow(
//                         cells: [
//                           if (_filters['StyleCode'] == true)
//                             DataCell(
//                               Text(result['StyleCode']?.toString() ?? ''),
//                             ),
//                           if (_filters['WSP'] == true)
//                             DataCell(Text(result['WSP']?.toString() ?? '')),
//                           if (_filters['Sizes'] == true)
//                             DataCell(Text(result['Size']?.toString() ?? '')),
//                           if (_filters['Shades'] == true)
//                             DataCell(Text(result['Shade']?.toString() ?? '')),
//                         ],
//                       );
//                     }).toList(),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class DiagonalClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.lineTo(size.width - 20, 0);
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vrs_erp_figma/OrderBooking/barcode/barcode_scanner.dart';
import 'package:vrs_erp_figma/OrderBooking/barcode/bookonBarcode2.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';

class BarcodeWiseWidget extends StatefulWidget {
  final ValueChanged<String> onFilterPressed;

  const BarcodeWiseWidget({super.key, required this.onFilterPressed});

  @override
  State<BarcodeWiseWidget> createState() => _BarcodeWiseWidgetState();
}

class _BarcodeWiseWidgetState extends State<BarcodeWiseWidget> with WidgetsBindingObserver {
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode(); 
  
  List<Map<String, dynamic>> _barcodeResults = [];
  List<String> addedItems = [];
  Map<String, bool> _filters = {
    'WSP': true,
    'Sizes': true,
    'Shades': true,
    'StyleCode': true,
  };
  bool _noDataFound = false;
  bool _isInitialized = false; // Track initialization state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _barcodeController.addListener(_handleBarcodeInput);
    _isInitialized = true; // Mark initialization complete
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestFocus());
  }

  void _handleBarcodeInput() {
    final text = _barcodeController.text;
    final upperText = text.toUpperCase();
    if (text != upperText) {
      _barcodeController.value = _barcodeController.value.copyWith(
        text: upperText,
        selection: TextSelection.collapsed(offset: upperText.length),
      );
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      final barcode = _barcodeController.text.trim();
      if (barcode.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _barcodeController.clear();
          _validateAndNavigate(barcode);
        });
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _requestFocus());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isInitialized) {
      _requestFocus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    super.dispose();
  }

  void _requestFocus() {
    if (mounted && !_barcodeFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_barcodeFocusNode);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _barcodeFocusNode.hasFocus) {
          SystemChannels.textInput.invokeMethod('TextInput.show');
        }
      });
    }
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
        _noDataFound = false;
      });
      _validateAndNavigate(upperBarcode);
    }
  }

  void _validateAndNavigate(String barcode) async {
    if (barcode.isEmpty) {
      _showAlertDialog(
        context,
        'Missing Barcode',
        'Please enter or scan a barcode first.',
      );
      return;
    }

    String upperBarcode = barcode.toUpperCase();
    if (addedItems.contains(upperBarcode)) {
      _showAlertDialog(
        context,
        'Already Added',
        'This barcode is already added',
      );
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BookOnBarcode2(
          barcode: upperBarcode,
          onSuccess: () {
            setState(() {
              addedItems.add(upperBarcode);
              _barcodeController.clear();
              _noDataFound = false;
            });
          },
          onCancel: () {
            _barcodeController.clear();
          },
        ),
      ),
    );

    setState(() {
      _noDataFound = result == false;
    });
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
            child: Focus(
              canRequestFocus: _isInitialized, // Only request focus after initialization
              onKey: _handleKeyEvent,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      focusNode: _barcodeFocusNode,
                      autofocus: true,
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.none,
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 12.0,
            ),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _validateAndNavigate(_barcodeController.text.trim());
                },
                child: Container(
                  height: 38,
                  width: 140,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipPath(
                          clipper: DiagonalClipper(),
                          child: Container(
                            color: AppColors.primaryColor,
                            alignment: Alignment.center,
                            child: const Text(
                              'SEARCH',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 38,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.search,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
          if (_barcodeResults.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Barcode Results:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
                  return DataRow(
                    cells: [
                      if (_filters['StyleCode'] == true)
                        DataCell(Text(result['StyleCode']?.toString() ?? '')),
                      if (_filters['WSP'] == true)
                        DataCell(Text(result['WSP']?.toString() ?? '')),
                      if (_filters['Sizes'] == true)
                        DataCell(Text(result['Size']?.toString() ?? '')),
                      if (_filters['Shades'] == true)
                        DataCell(Text(result['Shade']?.toString() ?? '')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width - 20, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}