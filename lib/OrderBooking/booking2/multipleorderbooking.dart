// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:vrs_erp_figma/constants/app_constants.dart';
// import 'package:vrs_erp_figma/models/catalog.dart';

// class CatalogItem {
//   final String styleCode;
//   final String shadeName;
//   final String sizeName;
//   final int clQty;
//   final double mrp;
//   final double wsp;

//   CatalogItem({
//     required this.styleCode,
//     required this.shadeName,
//     required this.sizeName,
//     required this.clQty,
//     required this.mrp,
//     required this.wsp,
//   });

//   factory CatalogItem.fromJson(Map<String, dynamic> json) {
//     return CatalogItem(
//       styleCode: json['styleCode']?.toString() ?? '',
//       shadeName: json['shadeName']?.toString() ?? '',
//       sizeName: json['sizeName']?.toString() ?? '',
//       clQty: int.tryParse(json['clqty']?.toString() ?? '0') ?? 0,
//       mrp: double.tryParse(json['mrp']?.toString() ?? '0') ?? 0,
//       wsp: double.tryParse(json['wsp']?.toString() ?? '0') ?? 0,
//     );
//   }
// }

// class MultiCatalogBookingPage extends StatefulWidget {
//   final List<Catalog> catalogs;

//   const MultiCatalogBookingPage({super.key, required this.catalogs});

//   @override
//   State<MultiCatalogBookingPage> createState() => _MultiCatalogBookingPageState();
// }

// class _MultiCatalogBookingPageState extends State<MultiCatalogBookingPage> {
//   Map<String, List<CatalogItem>> catalogItemsMap = {};
//   Map<String, List<String>> sizesMap = {};
//   Map<String, List<String>> colorsMap = {};
//   Map<String, Map<String, Map<String, TextEditingController>>> controllersMap = {};
//   Map<String, String> styleCodeMap = {};
//   Map<String, Map<String, double>> sizeMrpMap = {};
//   Map<String, Map<String, double>> sizeWspMap = {};
//   Map<String, TextEditingController> noteControllersMap = {};
//   Map<String, bool> isLoadingMap = {};
//   Map<String, List<String>> copiedRowsMap = {};

//   String userId = "Admin";
//   String coBrId = "01";
//   String fcYrId = "24";
//   bool stockWise = true;

//   int maxSizes = 0;

//   @override
//   void initState() {
//     super.initState();
//     for (var catalog in widget.catalogs) {
//       isLoadingMap[catalog.styleCode] = true;
//       noteControllersMap[catalog.styleCode] = TextEditingController();
//       copiedRowsMap[catalog.styleCode] = [];
//       fetchCatalogData(catalog);
//     }
//   }

//   Future<void> fetchCatalogData(Catalog catalog) async {
//     final String apiUrl = '${AppConstants.BASE_URL}/catalog/GetOrderDetails';

//     final Map<String, dynamic> requestBody = {
//       "itemSubGrpKey": catalog.itemSubGrpKey.toString(),
//       "itemKey": catalog.itemKey.toString(),
//       "styleKey": catalog.styleKey.toString(),
//       "userId": userId,
//       "coBrId": coBrId,
//       "fcYrId": fcYrId,
//       "stockWise": stockWise,
//       "brandKey": null,
//       "shadeKey": null,
//       "styleSizeId": null,
//       "fromMRP": null,
//       "toMRP": null,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         final List data = jsonDecode(response.body);
//         if (data.isNotEmpty) {
//           final items = data.map((e) => CatalogItem.fromJson(e)).toList();
//           final uniqueSizes = items.map((e) => e.sizeName).toSet().toList()..sort();
//           final uniqueColors = items.map((e) => e.shadeName).toSet().toList();

//           Map<String, double> tempSizeMrpMap = {};
//           Map<String, double> tempSizeWspMap = {};
//           for (var item in items) {
//             tempSizeMrpMap[item.sizeName] = item.mrp;
//             tempSizeWspMap[item.sizeName] = item.wsp;
//           }

//           Map<String, Map<String, TextEditingController>> tempControllers = {};
//           for (var color in uniqueColors) {
//             tempControllers[color] = {};
//             for (var size in uniqueSizes) {
//               final match = items.firstWhere(
//                 (item) => item.shadeName == color && item.sizeName == size,
//                 orElse: () => CatalogItem(
//                   styleCode: catalog.styleCode,
//                   shadeName: color,
//                   sizeName: size,
//                   clQty: 0,
//                   mrp: tempSizeMrpMap[size] ?? 0,
//                   wsp: tempSizeWspMap[size] ?? 0,
//                 ),
//               );
//               final controller = TextEditingController();
//               controller.addListener(() => setState(() {}));
//               tempControllers[color]![size] = controller;
//             }
//           }

//           setState(() {
//             catalogItemsMap[catalog.styleCode] = items;
//             sizesMap[catalog.styleCode] = uniqueSizes;
//             colorsMap[catalog.styleCode] = uniqueColors;
//             styleCodeMap[catalog.styleCode] = catalog.styleCode;
//             sizeMrpMap[catalog.styleCode] = tempSizeMrpMap;
//             sizeWspMap[catalog.styleCode] = tempSizeWspMap;
//             controllersMap[catalog.styleCode] = tempControllers;
//             isLoadingMap[catalog.styleCode] = false;
//             if (uniqueSizes.length > maxSizes) {
//               maxSizes = uniqueSizes.length;
//             }
//           });
//         } else {
//           setState(() {
//             isLoadingMap[catalog.styleCode] = false;
//           });
//         }
//       } else {
//         debugPrint('Failed to fetch catalog data for ${catalog.styleCode}: ${response.statusCode}');
//         setState(() {
//           isLoadingMap[catalog.styleCode] = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching catalog data for ${catalog.styleCode}: $e');
//       setState(() {
//         isLoadingMap[catalog.styleCode] = false;
//       });
//     }
//   }

//   int getTotalQty(String styleCode) {
//     int total = 0;
//     final controllers = controllersMap[styleCode];
//     if (controllers != null) {
//       for (var row in controllers.values) {
//         for (var cell in row.values) {
//           total += int.tryParse(cell.text) ?? 0;
//         }
//       }
//     }
//     return total;
//   }

//   void _copyQtyInAllShade(String styleCode) {
//     final colors = colorsMap[styleCode] ?? [];
//     final sizes = sizesMap[styleCode] ?? [];
//     if (colors.isEmpty || sizes.isEmpty) return;

//     final sourceColor = colors.first;
//     final sourceSize = sizes.first;
//     final valueToCopy = controllersMap[styleCode]?[sourceColor]?[sourceSize]?.text ?? '';

//     for (var color in colors) {
//       for (var size in sizes) {
//         controllersMap[styleCode]?[color]?[size]?.text = valueToCopy;
//       }
//     }

//     setState(() {});
//   }

//   void _copySizeQtyInAllShade(String styleCode) {
//     final colors = colorsMap[styleCode] ?? [];
//     final sizes = sizesMap[styleCode] ?? [];
//     if (colors.isEmpty || sizes.isEmpty) return;

//     final sourceColor = colors.first;
//     for (var size in sizes) {
//       final valueToCopy = controllersMap[styleCode]?[sourceColor]?[size]?.text ?? '';
//       for (var color in colors) {
//         controllersMap[styleCode]?[color]?[size]?.text = valueToCopy;
//       }
//     }

//     setState(() {});
//   }

//   Color _getColorCode(String color) {
//     switch (color.toLowerCase()) {
//       case 'red':
//         return Colors.red;
//       case 'green':
//         return Colors.green;
//       case 'blue':
//         return Colors.blue;
//       case 'yellow':
//         return Colors.yellow[800]!;
//       case 'black':
//         return Colors.black;
//       case 'white':
//         return Colors.grey;
//       default:
//         return Colors.black;
//     }
//   }

//   String _getImageUrl(Catalog catalog) {
//     if (catalog.fullImagePath.startsWith('http')) {
//       return catalog.fullImagePath;
//     }
//     final imageName = catalog.fullImagePath.split('/').last.split('?').first;
//     return '${AppConstants.BASE_URL}/images/$imageName';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Book Multiple Items', style: TextStyle(color: Colors.white)),
//         backgroundColor: AppColors.primaryColor,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: widget.catalogs.isEmpty
//           ? const Center(child: Text("No items selected"))
//           : SingleChildScrollView(
//               child: Column(
//                 children: List.generate(widget.catalogs.length, (index) {
//                   final catalog = widget.catalogs[index];
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 24),
//                     child: _buildItemBookingSection(context, catalog),
//                   );
//                 }),
//               ),
//             ),
//       bottomNavigationBar: _buildBottomBar(),
//     );
//   }

//   Widget _buildItemBookingSection(BuildContext context, Catalog catalog) {
//     if (isLoadingMap[catalog.styleCode] == true) {
//       return const Center(child: CircularProgressIndicator());
//     } else if ((catalogItemsMap[catalog.styleCode] ?? []).isEmpty) {
//       return const Center(child: Text("Empty"));
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image section
//             Container(
//               margin: const EdgeInsets.only(left: 16, top: 8),
//               width: 100,
//               height: 100,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   _getImageUrl(catalog),
//                   fit: BoxFit.contain,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       color: Colors.grey.shade300,
//                       child: const Center(child: Icon(Icons.error)),
//                     );
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             // Style code, total qty, and copy menu
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       _buildPriceTag(context, catalog.styleCode),
//                       const SizedBox(width: 4),
//                       PopupMenuButton<String>(
//                         icon: const Icon(Icons.copy_outlined),
//                         onSelected: (value) {
//                           if (value == 'copy_qty_all_shade') {
//                             _copyQtyInAllShade(catalog.styleCode);
//                           } else if (value == 'copy_size_qty_all_shade') {
//                             _copySizeQtyInAllShade(catalog.styleCode);
//                           }
//                         },
//                         itemBuilder: (BuildContext context) => [
//                           const PopupMenuItem(
//                             value: 'copy_qty_all_shade',
//                             child: Text('Copy Qty in All Shade'),
//                           ),
//                           const PopupMenuItem(
//                             value: 'copy_size_qty_all_shade',
//                             child: Text('Copy Size Qty in All Shade'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     child: Text(
//                       'Total Qty: ${getTotalQty(catalog.styleCode)}',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.normal,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         _buildCatalogTable(catalog),
//         // const SizedBox(height: 16),
//         // _buildNoteField(catalog.styleCode),
//         // const SizedBox(height: 12),
//         // _buildTotalQtyField(catalog.styleCode),
//         // const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget _buildPriceTag(BuildContext context, String styleCode) {
//     final textScale = MediaQuery.of(context).textScaleFactor;
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//       child: SizedBox(
//         height: 35 * textScale,
//         width: 120 * textScale,
//         child: CustomPaint(
//           painter: PriceTagPaint(),
//           child: Center(
//             child: Text(
//               styleCode,
//               style: TextStyle(
//                 fontSize: 20 * textScale,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCatalogTable(Catalog catalog) {
//     final sizes = sizesMap[catalog.styleCode] ?? [];
//     final requiredTableWidth = 100 + (80 * maxSizes);
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade500),
//       ),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(minWidth: requiredTableWidth.toDouble()),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             child: Table(
//               border: TableBorder.symmetric(
//                 inside: BorderSide(color: Colors.grey.shade400, width: 1),
//               ),
//               columnWidths: _buildColumnWidths(),
//               children: [
//                 _buildPriceRow("MRP", sizeMrpMap[catalog.styleCode] ?? {}, FontWeight.w600, sizes),
//                 _buildPriceRow("WSP", sizeWspMap[catalog.styleCode] ?? {}, FontWeight.w400, sizes),
//                 _buildHeaderRow(catalog.styleCode, sizes),
//                 for (var i = 0; i < (colorsMap[catalog.styleCode]?.length ?? 0); i++)
//                   _buildQuantityRow(catalog, colorsMap[catalog.styleCode]![i], i, sizes),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Map<int, TableColumnWidth> _buildColumnWidths() {
//     const baseWidth = 100.0;
//     return {
//       0: const FixedColumnWidth(baseWidth),
//       for (int i = 0; i < maxSizes; i++)
//         (i + 1): const FixedColumnWidth(baseWidth * 0.8),
//     };
//   }

//   Widget _buildNoteField(String styleCode) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: TextField(
//         controller: noteControllersMap[styleCode],
//         decoration: const InputDecoration(
//           border: OutlineInputBorder(borderRadius: BorderRadius.zero),
//           contentPadding: EdgeInsets.all(16),
//           labelText: 'Note',
//         ),
//       ),
//     );
//   }

//   Widget _buildTotalQtyField(String styleCode) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: TextField(
//         readOnly: true,
//         controller: TextEditingController(text: getTotalQty(styleCode).toString()),
//         decoration: InputDecoration(
//           border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
//           contentPadding: const EdgeInsets.all(16),
//           labelText: 'Total Qty',
//           filled: true,
//           fillColor: const Color.fromARGB(255, 212, 214, 214),
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       color: Colors.white,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           ElevatedButton.icon(
//             icon: const Icon(Icons.add, color: Colors.white),
//             label: const Text(
//               'Submit All',
//               style: TextStyle(fontSize: 16, color: Colors.white),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: widget.catalogs.any((c) => getTotalQty(c.styleCode) > 0)
//                   ? AppColors.primaryColor
//                   : Colors.grey,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             onPressed: widget.catalogs.any((c) => getTotalQty(c.styleCode) > 0)
//                 ? _submitAllOrders
//                 : null,
//           ),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.close, color: AppColors.primaryColor),
//             label: const Text(
//               'Cancel',
//               style: TextStyle(fontSize: 16, color: AppColors.primaryColor),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 side: const BorderSide(color: AppColors.primaryColor, width: 2),
//               ),
//             ),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }

//   TableRow _buildPriceRow(String label, Map<String, double> sizePriceMap, FontWeight weight, List<String> sizes) {
//     return TableRow(
//       children: [
//         TableCell(
//           verticalAlignment: TableCellVerticalAlignment.middle,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(label, style: TextStyle(fontWeight: weight)),
//           ),
//         ),
//         ...List.generate(maxSizes, (index) {
//           if (index < sizes.length) {
//             final size = sizes[index];
//             final price = sizePriceMap[size] ?? 0.0;
//             return TableCell(
//               verticalAlignment: TableCellVerticalAlignment.middle,
//               child: Center(
//                 child: Text(
//                   price.toStringAsFixed(0),
//                   style: TextStyle(fontWeight: weight),
//                 ),
//               ),
//             );
//           } else {
//             return const TableCell(
//               verticalAlignment: TableCellVerticalAlignment.middle,
//               child: Center(child: Text('')),
//             );
//           }
//         }),
//       ],
//     );
//   }

//   TableRow _buildHeaderRow(String styleCode, List<String> sizes) {
//     return TableRow(
//       decoration: const BoxDecoration(
//         color: Color.fromARGB(255, 236, 212, 204),
//       ),
//       children: [
//         const TableCell(
//           verticalAlignment: TableCellVerticalAlignment.middle,
//           child: _TableHeaderCell(),
//         ),
//         ...List.generate(maxSizes, (index) {
//           if (index < sizes.length) {
//             return TableCell(
//               verticalAlignment: TableCellVerticalAlignment.middle,
//               child: Center(
//                 child: Text(
//                   sizes[index],
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             );
//           } else {
//             return const TableCell(
//               verticalAlignment: TableCellVerticalAlignment.middle,
//               child: Center(child: Text('')),
//             );
//           }
//         }),
//       ],
//     );
//   }

//   TableRow _buildQuantityRow(Catalog catalog, String color, int i, List<String> sizes) {
//     return TableRow(
//       children: [
//         TableCell(
//           verticalAlignment: TableCellVerticalAlignment.middle,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 GestureDetector(
//                   child: const Icon(Icons.copy_all, size: 12),
//                   onTap: () {
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AlertDialog(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           title: const Text('Select an Action'),
//                           content: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               GestureDetector(
//                                 onTap: () {
//                                   Navigator.of(context).pop();
//                                   final firstQty = controllersMap[catalog.styleCode]?[color]?.values.first.text;
//                                   for (var size in sizesMap[catalog.styleCode] ?? []) {
//                                     controllersMap[catalog.styleCode]?[color]?[size]?.text = firstQty ?? '0';
//                                   }
//                                   setState(() {});
//                                 },
//                                 child: Container(
//                                   width: double.infinity,
//                                   padding: const EdgeInsets.symmetric(vertical: 12),
//                                   margin: const EdgeInsets.only(bottom: 10),
//                                   decoration: BoxDecoration(
//                                     color: Colors.blue,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   alignment: Alignment.center,
//                                   child: const Text(
//                                     'Copy Qty in shade only',
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   Navigator.of(context).pop();
//                                   List<String> copiedRow = [];
//                                   for (var size in sizesMap[catalog.styleCode] ?? []) {
//                                     final qty = controllersMap[catalog.styleCode]?[color]?[size]?.text ?? '0';
//                                     copiedRow.add(qty);
//                                   }
//                                   copiedRowsMap[catalog.styleCode] = copiedRow;
//                                   setState(() {});
//                                 },
//                                 child: Container(
//                                   width: double.infinity,
//                                   padding: const EdgeInsets.symmetric(vertical: 12),
//                                   margin: const EdgeInsets.only(bottom: 10),
//                                   decoration: BoxDecoration(
//                                     color: Colors.blue,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   alignment: Alignment.center,
//                                   child: const Text(
//                                     'Copy Row',
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   Navigator.of(context).pop();
//                                   final copiedRow = copiedRowsMap[catalog.styleCode] ?? [];
//                                   for (int j = 0; j < (sizesMap[catalog.styleCode]?.length ?? 0); j++) {
//                                     controllersMap[catalog.styleCode]?[color]?[sizesMap[catalog.styleCode]![j]]?.text =
//                                         copiedRow[j];
//                                   }
//                                   setState(() {});
//                                 },
//                                 child: Container(
//                                   width: double.infinity,
//                                   padding: const EdgeInsets.symmetric(vertical: 12),
//                                   decoration: BoxDecoration(
//                                     color: Colors.green,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   alignment: Alignment.center,
//                                   child: const Text(
//                                     'Paste Row',
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//                 const SizedBox(width: 6),
//                 Flexible(
//                   child: Text(
//                     '$color ',
//                     style: TextStyle(
//                       color: _getColorCode(color),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         ...List.generate(maxSizes, (index) {
//           if (index < sizes.length) {
//             final size = sizes[index];
//             final controller = controllersMap[catalog.styleCode]?[color]?[size];
//             final originalQty = catalogItemsMap[catalog.styleCode]?.firstWhere(
//                   (item) => item.shadeName == color && item.sizeName == size,
//                   orElse: () => CatalogItem(
//                     styleCode: catalog.styleCode,
//                     shadeName: color,
//                     sizeName: size,
//                     clQty: 0,
//                     mrp: sizeMrpMap[catalog.styleCode]?[size] ?? 0,
//                     wsp: sizeWspMap[catalog.styleCode]?[size] ?? 0,
//                   ),
//                 ).clQty ?? 0;

//             return TableCell(
//               verticalAlignment: TableCellVerticalAlignment.middle,
//               child: Padding(
//                 padding: const EdgeInsets.all(4.0),
//                 child: TextField(
//                   controller: controller,
//                   keyboardType: TextInputType.number,
//                   textAlign: TextAlign.center,
//                   decoration: InputDecoration(
//                     contentPadding: const EdgeInsets.symmetric(vertical: 8),
//                     hintText: originalQty > 0 ? originalQty.toString() : '0',
//                     hintStyle: const TextStyle(color: Colors.grey),
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),
//             );
//           } else {
//             return const TableCell(
//               verticalAlignment: TableCellVerticalAlignment.middle,
//               child: Center(child: Text('')),
//             );
//           }
//         }),
//       ],
//     );
//   }

//   Future<void> _submitAllOrders() async {
//     List<Future> apiCalls = [];

//     for (var catalog in widget.catalogs) {
//       final controllers = controllersMap[catalog.styleCode];
//       final noteController = noteControllersMap[catalog.styleCode];
//       final styleCode = styleCodeMap[catalog.styleCode] ?? '';
//       final sizes = sizesMap[catalog.styleCode] ?? [];

//       if (controllers != null) {
//         for (var colorEntry in controllers.entries) {
//           String color = colorEntry.key;
//           for (var sizeEntry in colorEntry.value.entries) {
//             String size = sizeEntry.key;
//             String qty = sizeEntry.value.text;
//             if (qty.isNotEmpty && int.tryParse(qty) != null && int.parse(qty) > 0) {
//               final payload = {
//                 "userId": userId,
//                 "coBrId": coBrId,
//                 "fcYrId": fcYrId,
//                 "data": {
//                   "designcode": styleCode,
//                   "mrp": sizeMrpMap[catalog.styleCode]?[size]?.toStringAsFixed(0) ?? '0',
//                   "WSP": sizeWspMap[catalog.styleCode]?[size]?.toStringAsFixed(0) ?? '0',
//                   "size": size,
//                   "TotQty": getTotalQty(catalog.styleCode).toString(),
//                   "Note": noteController?.text ?? '',
//                   "color": color,
//                   "Qty": qty,
//                   "cobrid": coBrId,
//                   "user": userId.toLowerCase(),
//                   "barcode": "",
//                 },
//                 "typ": 0,
//               };

//               apiCalls.add(
//                 http.post(
//                   Uri.parse('${AppConstants.BASE_URL}/orderBooking/Insertsalesorderdetails'),
//                   headers: {'Content-Type': 'application/json'},
//                   body: jsonEncode(payload),
//                 ),
//               );
//             }
//           }
//         }
//       }
//     }

//     try {
//       final responses = await Future.wait(apiCalls);
//       if (responses.every((r) => r.statusCode == 200)) {
//         if (mounted) {
//           showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//               title: const Text("Success"),
//               content: const Text("All orders submitted successfully."),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     Navigator.pop(context);
//                   },
//                   child: const Text("OK"),
//                 ),
//               ],
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         showDialog(
//           context: context,
//           builder: (_) => AlertDialog(
//             title: const Text("Error"),
//             content: Text("Failed to submit orders: $e"),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("OK"),
//               ),
//             ],
//           ),
//         );
//       }
//     }
//   }
// }

// class _TableHeaderCell extends StatelessWidget {
//   const _TableHeaderCell();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 48,
//       child: CustomPaint(
//         painter: _DiagonalLinePainter(),
//         child: const Stack(
//           children: [
//             Positioned(
//               left: 12,
//               top: 20,
//               child: Text(
//                 'Shade',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                 ),
//               ),
//             ),
//             Positioned(
//               right: 14,
//               bottom: 20,
//               child: Text(
//                 'Size',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DiagonalLinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.grey.shade400
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;
//     canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class PriceTagPaint extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = AppColors.primaryColor
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.fill;

//     Path path = Path();

//     path
//       ..moveTo(0, size.height * .5)
//       ..lineTo(size.width * .13, 0)
//       ..lineTo(size.width, 0)
//       ..lineTo(size.width, size.height)
//       ..lineTo(size.width * .13, size.height)
//       ..lineTo(0, size.height * .5)
//       ..close();
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/catalog.dart';

class CatalogItem {
  final String styleCode;
  final String shadeName;
  final String sizeName;
  final int clQty;
  final double mrp;
  final double wsp;

  CatalogItem({
    required this.styleCode,
    required this.shadeName,
    required this.sizeName,
    required this.clQty,
    required this.mrp,
    required this.wsp,
  });

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      styleCode: json['styleCode']?.toString() ?? '',
      shadeName: json['shadeName']?.toString() ?? '',
      sizeName: json['sizeName']?.toString() ?? '',
      clQty: int.tryParse(json['clqty']?.toString() ?? '0') ?? 0,
      mrp: double.tryParse(json['mrp']?.toString() ?? '0') ?? 0,
      wsp: double.tryParse(json['wsp']?.toString() ?? '0') ?? 0,
    );
  }
}

class MultiCatalogBookingPage extends StatefulWidget {
  final List<Catalog> catalogs;

  const MultiCatalogBookingPage({super.key, required this.catalogs});

  @override
  State<MultiCatalogBookingPage> createState() =>
      _MultiCatalogBookingPageState();
}

class _MultiCatalogBookingPageState extends State<MultiCatalogBookingPage> {
  Map<String, List<CatalogItem>> catalogItemsMap = {};
  Map<String, List<String>> sizesMap = {};
  Map<String, List<String>> colorsMap = {};
  Map<String, Map<String, Map<String, TextEditingController>>> controllersMap =
      {};
  Map<String, String> styleCodeMap = {};
  Map<String, Map<String, double>> sizeMrpMap = {};
  Map<String, Map<String, double>> sizeWspMap = {};
  Map<String, TextEditingController> noteControllersMap = {};
  Map<String, bool> isLoadingMap = {};
  Map<String, List<String>> copiedRowsMap = {};

  String userId = "Admin";
  String coBrId = "01";
  String fcYrId = "24";
  bool stockWise = true;

  int maxSizes = 0;

  @override
  void initState() {
    super.initState();
    for (var catalog in widget.catalogs) {
      isLoadingMap[catalog.styleCode] = true;
      noteControllersMap[catalog.styleCode] = TextEditingController();
      copiedRowsMap[catalog.styleCode] = [];
      fetchCatalogData(catalog);
    }
  }

  Future<void> fetchCatalogData(Catalog catalog) async {
    final String apiUrl = '${AppConstants.BASE_URL}/catalog/GetOrderDetails';

    final Map<String, dynamic> requestBody = {
      "itemSubGrpKey": catalog.itemSubGrpKey.toString(),
      "itemKey": catalog.itemKey.toString(),
      "styleKey": catalog.styleKey.toString(),
      "userId": userId,
      "coBrId": coBrId,
      "fcYrId": fcYrId,
      "stockWise": stockWise,
      "brandKey": null,
      "shadeKey": null,
      "styleSizeId": null,
      "fromMRP": null,
      "toMRP": null,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final items = data.map((e) => CatalogItem.fromJson(e)).toList();
          final uniqueSizes =
              items.map((e) => e.sizeName).toSet().toList()..sort();
          final uniqueColors = items.map((e) => e.shadeName).toSet().toList();

          Map<String, double> tempSizeMrpMap = {};
          Map<String, double> tempSizeWspMap = {};
          for (var item in items) {
            tempSizeMrpMap[item.sizeName] = item.mrp;
            tempSizeWspMap[item.sizeName] = item.wsp;
          }

          Map<String, Map<String, TextEditingController>> tempControllers = {};
          for (var color in uniqueColors) {
            tempControllers[color] = {};
            for (var size in uniqueSizes) {
              final match = items.firstWhere(
                (item) => item.shadeName == color && item.sizeName == size,
                orElse:
                    () => CatalogItem(
                      styleCode: catalog.styleCode,
                      shadeName: color,
                      sizeName: size,
                      clQty: 0,
                      mrp: tempSizeMrpMap[size] ?? 0,
                      wsp: tempSizeWspMap[size] ?? 0,
                    ),
              );
              final controller = TextEditingController();
              controller.addListener(() => setState(() {}));
              tempControllers[color]![size] = controller;
            }
          }

          setState(() {
            catalogItemsMap[catalog.styleCode] = items;
            sizesMap[catalog.styleCode] = uniqueSizes;
            colorsMap[catalog.styleCode] = uniqueColors;
            styleCodeMap[catalog.styleCode] = catalog.styleCode;
            sizeMrpMap[catalog.styleCode] = tempSizeMrpMap;
            sizeWspMap[catalog.styleCode] = tempSizeWspMap;
            controllersMap[catalog.styleCode] = tempControllers;
            isLoadingMap[catalog.styleCode] = false;
            if (uniqueSizes.length > maxSizes) {
              maxSizes = uniqueSizes.length;
            }
          });
        } else {
          setState(() {
            isLoadingMap[catalog.styleCode] = false;
          });
        }
      } else {
        debugPrint(
          'Failed to fetch catalog data for ${catalog.styleCode}: ${response.statusCode}',
        );
        setState(() {
          isLoadingMap[catalog.styleCode] = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching catalog data for ${catalog.styleCode}: $e');
      setState(() {
        isLoadingMap[catalog.styleCode] = false;
      });
    }
  }

  int getTotalQty(String styleCode) {
    int total = 0;
    final controllers = controllersMap[styleCode];
    if (controllers != null) {
      for (var row in controllers.values) {
        for (var cell in row.values) {
          total += int.tryParse(cell.text) ?? 0;
        }
      }
    }
    return total;
  }

  int getTotalStock(String styleCode) {
    int total = 0;
    final items = catalogItemsMap[styleCode];
    if (items != null) {
      for (var item in items) {
        total += item.clQty;
      }
    }
    return total;
  }

  void _copyQtyInAllShade(String styleCode) {
    final colors = colorsMap[styleCode] ?? [];
    final sizes = sizesMap[styleCode] ?? [];
    if (colors.isEmpty || sizes.isEmpty) return;

    final sourceColor = colors.first;
    final sourceSize = sizes.first;
    final valueToCopy =
        controllersMap[styleCode]?[sourceColor]?[sourceSize]?.text ?? '';

    for (var color in colors) {
      for (var size in sizes) {
        controllersMap[styleCode]?[color]?[size]?.text = valueToCopy;
      }
    }

    setState(() {});
  }

  void _copySizeQtyInAllShade(String styleCode) {
    final colors = colorsMap[styleCode] ?? [];
    final sizes = sizesMap[styleCode] ?? [];
    if (colors.isEmpty || sizes.isEmpty) return;

    final sourceColor = colors.first;
    for (var size in sizes) {
      final valueToCopy =
          controllersMap[styleCode]?[sourceColor]?[size]?.text ?? '';
      for (var color in colors) {
        controllersMap[styleCode]?[color]?[size]?.text = valueToCopy;
      }
    }

    setState(() {});
  }

  void _deleteCatalog(Catalog catalog) {
    setState(() {
      // Remove catalog from the list
      widget.catalogs.removeWhere((c) => c.styleCode == catalog.styleCode);
      // Clean up associated state
      catalogItemsMap.remove(catalog.styleCode);
      sizesMap.remove(catalog.styleCode);
      colorsMap.remove(catalog.styleCode);
      controllersMap.remove(catalog.styleCode);
      styleCodeMap.remove(catalog.styleCode);
      sizeMrpMap.remove(catalog.styleCode);
      sizeWspMap.remove(catalog.styleCode);
      noteControllersMap[catalog.styleCode]?.dispose();
      noteControllersMap.remove(catalog.styleCode);
      isLoadingMap.remove(catalog.styleCode);
      copiedRowsMap.remove(catalog.styleCode);
    });
  }

  Color _getColorCode(String color) {
    switch (color.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow[800]!;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  String _getImageUrl(Catalog catalog) {
    if (catalog.fullImagePath.startsWith('http')) {
      return catalog.fullImagePath;
    }
    final imageName = catalog.fullImagePath.split('/').last.split('?').first;
    return '${AppConstants.BASE_URL}/images/$imageName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Book Multiple Items',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          widget.catalogs.isEmpty
              ? const Center(child: Text("No items selected"))
              : SingleChildScrollView(
                child: Column(
                  children: List.generate(widget.catalogs.length, (index) {
                    final catalog = widget.catalogs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _buildItemBookingSection(context, catalog),
                    );
                  }),
                ),
              ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildItemBookingSection(BuildContext context, Catalog catalog) {
    if (isLoadingMap[catalog.styleCode] == true) {
      return const Center(child: CircularProgressIndicator());
    } else if ((catalogItemsMap[catalog.styleCode] ?? []).isEmpty) {
      return const Center(child: Text("Empty"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Container(
              margin: const EdgeInsets.only(left: 16, top: 8),
              width: 100,
              height: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _getImageUrl(catalog),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.error)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Right section with text and actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Style code, copy icon, and delete icon in same row
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceTag(context, catalog.styleCode),
                      ),

                      // Copy IconButton
                      IconButton(
                        icon: const Icon(Icons.copy_outlined),
                        iconSize: 20, // Same size as delete icon
                        onPressed: () {
                          showMenu(
                            context: context,
                            position: const RelativeRect.fromLTRB(
                              100,
                              100,
                              0,
                              0,
                            ),
                            items: [
                              const PopupMenuItem(
                                value: 'copy_qty_all_shade',
                                child: Text('Copy Qty in All Shade'),
                              ),
                              const PopupMenuItem(
                                value: 'copy_size_qty_all_shade',
                                child: Text('Copy Size Qty in All Shade'),
                              ),
                            ],
                          ).then((value) {
                            if (value == 'copy_qty_all_shade') {
                              _copyQtyInAllShade(catalog.styleCode);
                            } else if (value == 'copy_size_qty_all_shade') {
                              _copySizeQtyInAllShade(catalog.styleCode);
                            }
                          });
                        },
                      ),

                      // Delete IconButton
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        iconSize: 24,
                        onPressed: () => _deleteCatalog(catalog),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  // Total Qty and Stock in same row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Text(
                          'Total Qty: ${getTotalQty(catalog.styleCode)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Total Stock: ${getTotalStock(catalog.styleCode)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCatalogTable(catalog),
        // const SizedBox(height: 16),
        // _buildNoteField(catalog.styleCode),
        // const SizedBox(height: 12),
        // _buildTotalQtyField(catalog.styleCode),
        // const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPriceTag(BuildContext context, String styleCode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        styleCode,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCatalogTable(Catalog catalog) {
    final sizes = sizesMap[catalog.styleCode] ?? [];
    final requiredTableWidth = 100 + (80 * maxSizes);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade500),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: requiredTableWidth.toDouble()),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Table(
              border: TableBorder.symmetric(
                inside: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
              columnWidths: _buildColumnWidths(),
              children: [
                _buildPriceRow(
                  "MRP",
                  sizeMrpMap[catalog.styleCode] ?? {},
                  FontWeight.w600,
                  sizes,
                ),
                _buildPriceRow(
                  "WSP",
                  sizeWspMap[catalog.styleCode] ?? {},
                  FontWeight.w400,
                  sizes,
                ),
                _buildHeaderRow(catalog.styleCode, sizes),
                for (
                  var i = 0;
                  i < (colorsMap[catalog.styleCode]?.length ?? 0);
                  i++
                )
                  _buildQuantityRow(
                    catalog,
                    colorsMap[catalog.styleCode]![i],
                    i,
                    sizes,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<int, TableColumnWidth> _buildColumnWidths() {
    const baseWidth = 100.0;
    return {
      0: const FixedColumnWidth(baseWidth),
      for (int i = 0; i < maxSizes; i++)
        (i + 1): const FixedColumnWidth(baseWidth * 0.8),
    };
  }

  Widget _buildNoteField(String styleCode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: noteControllersMap[styleCode],
        decoration: const InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
          contentPadding: EdgeInsets.all(16),
          labelText: 'Note',
        ),
      ),
    );
  }

  Widget _buildTotalQtyField(String styleCode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(
          text: getTotalQty(styleCode).toString(),
        ),
        decoration: InputDecoration(
          border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
          contentPadding: const EdgeInsets.all(16),
          labelText: 'Total Qty',
          filled: true,
          fillColor: const Color.fromARGB(255, 212, 214, 214),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Submit All',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  widget.catalogs.any((c) => getTotalQty(c.styleCode) > 0)
                      ? AppColors.primaryColor
                      : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed:
                widget.catalogs.any((c) => getTotalQty(c.styleCode) > 0)
                    ? _submitAllOrders
                    : null,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.close, color: AppColors.primaryColor),
            label: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, color: AppColors.primaryColor),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.primaryColor, width: 2),
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  TableRow _buildPriceRow(
    String label,
    Map<String, double> sizePriceMap,
    FontWeight weight,
    List<String> sizes,
  ) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(label, style: TextStyle(fontWeight: weight)),
          ),
        ),
        ...List.generate(maxSizes, (index) {
          if (index < sizes.length) {
            final size = sizes[index];
            final price = sizePriceMap[size] ?? 0.0;
            return TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(
                child: Text(
                  price.toStringAsFixed(0),
                  style: TextStyle(fontWeight: weight),
                ),
              ),
            );
          } else {
            return const TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(child: Text('')),
            );
          }
        }),
      ],
    );
  }

  TableRow _buildHeaderRow(String styleCode, List<String> sizes) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 236, 212, 204),
      ),
      children: [
        const TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: _TableHeaderCell(),
        ),
        ...List.generate(maxSizes, (index) {
          if (index < sizes.length) {
            return TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(
                child: Text(
                  sizes[index],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            return const TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(child: Text('')),
            );
          }
        }),
      ],
    );
  }

  TableRow _buildQuantityRow(
    Catalog catalog,
    String color,
    int i,
    List<String> sizes,
  ) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                GestureDetector(
                  child: const Icon(Icons.copy_all, size: 12),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: const Text('Select an Action'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  final firstQty =
                                      controllersMap[catalog.styleCode]?[color]
                                          ?.values
                                          .first
                                          .text;
                                  for (var size
                                      in sizesMap[catalog.styleCode] ?? []) {
                                    controllersMap[catalog
                                            .styleCode]?[color]?[size]
                                        ?.text = firstQty ?? '0';
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Copy Qty in shade only',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  List<String> copiedRow = [];
                                  for (var size
                                      in sizesMap[catalog.styleCode] ?? []) {
                                    final qty =
                                        controllersMap[catalog
                                                .styleCode]?[color]?[size]
                                            ?.text ??
                                        '0';
                                    copiedRow.add(qty);
                                  }
                                  copiedRowsMap[catalog.styleCode] = copiedRow;
                                  setState(() {});
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Copy Row',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  final copiedRow =
                                      copiedRowsMap[catalog.styleCode] ?? [];
                                  for (
                                    int j = 0;
                                    j <
                                        (sizesMap[catalog.styleCode]?.length ??
                                            0);
                                    j++
                                  ) {
                                    controllersMap[catalog
                                            .styleCode]?[color]?[sizesMap[catalog
                                            .styleCode]![j]]
                                        ?.text = copiedRow[j];
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Paste Row',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '$color ',
                    style: TextStyle(
                      color: _getColorCode(color),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ...List.generate(maxSizes, (index) {
          if (index < sizes.length) {
            final size = sizes[index];
            final controller = controllersMap[catalog.styleCode]?[color]?[size];
            final originalQty =
                catalogItemsMap[catalog.styleCode]
                    ?.firstWhere(
                      (item) =>
                          item.shadeName == color && item.sizeName == size,
                      orElse:
                          () => CatalogItem(
                            styleCode: catalog.styleCode,
                            shadeName: color,
                            sizeName: size,
                            clQty: 0,
                            mrp: sizeMrpMap[catalog.styleCode]?[size] ?? 0,
                            wsp: sizeWspMap[catalog.styleCode]?[size] ?? 0,
                          ),
                    )
                    .clQty ??
                0;

            return TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    hintText: originalQty > 0 ? originalQty.toString() : '0',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            );
          } else {
            return const TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(child: Text('')),
            );
          }
        }),
      ],
    );
  }

  Future<void> _submitAllOrders() async {
    List<Future> apiCalls = [];

    for (var catalog in widget.catalogs) {
      final controllers = controllersMap[catalog.styleCode];
      final noteController = noteControllersMap[catalog.styleCode];
      final styleCode = styleCodeMap[catalog.styleCode] ?? '';
      final sizes = sizesMap[catalog.styleCode] ?? [];

      if (controllers != null) {
        for (var colorEntry in controllers.entries) {
          String color = colorEntry.key;
          for (var sizeEntry in colorEntry.value.entries) {
            String size = sizeEntry.key;
            String qty = sizeEntry.value.text;
            if (qty.isNotEmpty &&
                int.tryParse(qty) != null &&
                int.parse(qty) > 0) {
              final payload = {
                "userId": userId,
                "coBrId": coBrId,
                "fcYrId": fcYrId,
                "data": {
                  "designcode": styleCode,
                  "mrp":
                      sizeMrpMap[catalog.styleCode]?[size]?.toStringAsFixed(
                        0,
                      ) ??
                      '0',
                  "WSP":
                      sizeWspMap[catalog.styleCode]?[size]?.toStringAsFixed(
                        0,
                      ) ??
                      '0',
                  "size": size,
                  "TotQty": getTotalQty(catalog.styleCode).toString(),
                  "Note": noteController?.text ?? '',
                  "color": color,
                  "Qty": qty,
                  "cobrid": coBrId,
                  "user": userId.toLowerCase(),
                  "barcode": "",
                },
                "typ": 0,
              };

              apiCalls.add(
                http.post(
                  Uri.parse(
                    '${AppConstants.BASE_URL}/orderBooking/Insertsalesorderdetails',
                  ),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(payload),
                ),
              );
            }
          }
        }
      }
    }

    try {
      final responses = await Future.wait(apiCalls);
      if (responses.every((r) => r.statusCode == 200)) {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Text("Success"),
                  content: const Text("All orders submitted successfully."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("Error"),
                content: Text("Failed to submit orders: $e"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    }
  }
}

class _TableHeaderCell extends StatelessWidget {
  const _TableHeaderCell();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      child: CustomPaint(
        painter: _DiagonalLinePainter(),
        child: const Stack(
          children: [
            Positioned(
              left: 12,
              top: 20,
              child: Text(
                'Shade',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            Positioned(
              right: 14,
              bottom: 20,
              child: Text(
                'Size',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
