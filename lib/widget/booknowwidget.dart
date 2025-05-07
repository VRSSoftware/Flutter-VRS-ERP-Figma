import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/constants/app_constants.dart';

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

class CatalogBookingTable extends StatefulWidget {
  final String itemSubGrpKey;
  final String itemKey;
  final String styleKey;
  final VoidCallback onSuccess;

  const CatalogBookingTable({
    super.key,
    required this.itemSubGrpKey,
    required this.itemKey,
    required this.styleKey,
    required this.onSuccess,
  });

  @override
  State<CatalogBookingTable> createState() => _CatalogBookingTableState();
}

class _CatalogBookingTableState extends State<CatalogBookingTable> {
  List<CatalogItem> catalogItems = [];
  List<String> sizes = [];
  List<String> colors = [];
  Map<String, Map<String, TextEditingController>> controllers = {};
  String styleCode = '';
  double mrp = 0;
  double wsp = 0;

  String itemSubGrpKey = '';
  String itemKey = '';
  String styleKey = '';
  String userId = "Admin";
  String coBrId = "01";
  String fcYrId = "24";
  bool stockWise = true;
  bool isLoading = true;

  int get totalQty {
    int total = 0;
    for (var row in controllers.values) {
      for (var cell in row.values) {
        total += int.tryParse(cell.text) ?? 0;
      }
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    itemSubGrpKey = widget.itemSubGrpKey;
    itemKey = widget.itemKey;
    styleKey = widget.styleKey;
    fetchCatalogData();
  }

  Future<void> fetchCatalogData() async {
    const String apiUrl = '${AppConstants.BASE_URL}/catalog/GetOrderDetails';

    final Map<String, dynamic> requestBody = {
      "itemSubGrpKey": itemSubGrpKey,
      "itemKey": itemKey,
      "styleKey": styleKey,
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

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if(data.isNotEmpty){
      final items = data.map((e) => CatalogItem.fromJson(e)).toList();

      final uniqueSizes = items.map((e) => e.sizeName).toSet().toList()..sort();
      final uniqueColors = items.map((e) => e.shadeName).toSet().toList();

      setState(() {
        catalogItems = items;
        sizes = uniqueSizes;
        colors = uniqueColors;
        styleCode = items.first.styleCode;
        mrp = items.first.mrp;
        wsp = items.first.wsp;

        for (var color in colors) {
          controllers[color] = {};
          for (var size in sizes) {
            final match = items.firstWhere(
              (item) => item.shadeName == color && item.sizeName == size,
              orElse:
                  () => CatalogItem(
                    styleCode: styleCode,
                    shadeName: color,
                    sizeName: size,
                    clQty: 0,
                    mrp: mrp,
                    wsp: wsp,
                  ),
            );
            final controller = TextEditingController();
            controller.addListener(() => setState(() {}));
            controllers[color]![size] = controller;
          }
        }
        isLoading=false;
      });
      }
      else{
        setState(() {
           isLoading=false;
        });
      }
    } else {
      debugPrint('Failed to fetch catalog data: ${response.statusCode}');
    }
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

  @override
  Widget build(BuildContext context) {
    if ( isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    else if (catalogItems.isEmpty) {
      return const Center(child: Text("Empty"));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          styleCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPriceRow("MRP", mrp, FontWeight.w600),
                        _buildPriceRow("WSP", wsp, FontWeight.w500),
                        const SizedBox(height: 10),
                        _buildHeaderRow(),
                        const Divider(),
                        ...colors
                            .map((color) => _buildQuantityRow(color))
                            .toList(),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Note',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'TotalQty',
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            controller: TextEditingController(
                              text: totalQty.toString(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: SizedBox(
                            width: 120,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                       onPressed: () async {
  // Store all the API futures
  List<Future> apiCalls = [];

  for (var color in controllers.entries) {
    for (var size in color.value.entries) {
      String qty = size.value.text;
      if (qty.isNotEmpty && int.tryParse(qty) != null && int.parse(qty) > 0) {
        final payload = {
          "userId": userId,
          "coBrId": coBrId,
          "fcYrId": fcYrId,
          "data": {
            "designcode": styleCode,
            "mrp": mrp.toStringAsFixed(0),
            "WSP": wsp.toStringAsFixed(0),
            "size": size.key,
            "TotQty": totalQty.toString(),
            "Note": "n123",
            "color": color.key,
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
              '${AppConstants.BASE_URL}/orderBooking/Insertsalesorderdetails'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          ),
        );
      }
    }
  }

  try {
    // Wait for all API calls to complete
    final responses = await Future.wait(apiCalls);
    
    // Check if all responses are successful
    if (responses.every((r) => r.statusCode == 200)) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Booking submitted."),
            actions: [
              TextButton(
                onPressed: () {
                  // Close both dialogs and trigger update
                  Navigator.pop(context); // Close success dialog
                  Navigator.pop(context); // Close booking table
                  widget.onSuccess(); // Update parent state
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("Failed to submit: $e"),
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
},
                              child: const Text(
                                'Add',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double price, FontWeight weight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: TextStyle(fontWeight: weight)),
          ),
          ...sizes.map(
            (_) => SizedBox(
              width: 100,
              child: Center(
                child: Text(
                  price.toStringAsFixed(0),
                  style: TextStyle(fontWeight: weight),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        const SizedBox(
          width: 70,
          child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...sizes.map(
          (size) => SizedBox(
            width: 100,
            child: Center(
              child: Text(
                size,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityRow(String color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 70,
            child: Row(
              children: [
                Icon(Icons.circle, size: 12, color: _getColorCode(color)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    color,
                    style: TextStyle(
                      color: _getColorCode(color),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...sizes.map((size) {
            final controller = controllers[color]?[size];
            final originalQty =
                catalogItems
                    .firstWhere(
                      (item) =>
                          item.shadeName == color && item.sizeName == size,
                      orElse:
                          () => CatalogItem(
                            styleCode: styleCode,
                            shadeName: color,
                            sizeName: size,
                            clQty: 0,
                            mrp: mrp,
                            wsp: wsp,
                          ),
                    )
                    .clQty;

            return SizedBox(
              width: 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: originalQty > 0 ? originalQty.toString() : '',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
