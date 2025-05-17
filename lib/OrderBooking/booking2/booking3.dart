import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/CatalogOrderData.dart';
import 'package:vrs_erp_figma/models/OrderMatrix.dart';
import 'package:vrs_erp_figma/models/catalog.dart';

class CreateOrderScreen3 extends StatefulWidget {
  final List<Catalog> catalogs;

  const CreateOrderScreen3({Key? key, required this.catalogs}) : super(key: key);

  @override
  State<CreateOrderScreen3> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen3> {
  List<CatalogOrderData> catalogOrderList = [];
  Map<String, String> selectedColors2 = {};
  Map<String, Map<String, Map<String, int>>> quantities = {};

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    final List<CatalogOrderData> tempList = [];

    for (var item in widget.catalogs) {
      final payload = {
        "itemSubGrpKey": item.itemSubGrpKey,
        "itemKey": item.itemKey,
        "styleKey": item.styleKey,
        "userId": "Admin",
        "coBrId": "01",
        "fcYrId": "24",
      };

      try {
        final response = await http.post(
          Uri.parse('${AppConstants.BASE_URL}/catalog/GetOrderDetails2'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final orderMatrix = OrderMatrix.fromJson(data);
          tempList.add(
            CatalogOrderData(catalog: item, orderMatrix: orderMatrix),
          );
          // Set the first shade as default if available
          final shades = item.shadeName.split(',');
          selectedColors2[item.styleKey] = shades.isNotEmpty ? shades[0] : '';
          quantities[item.styleKey] = shades.isNotEmpty ? {shades[0]: {}} : {};
        } else {
          debugPrint(
            'Failed to fetch order details for ${item.styleKey}: ${response.statusCode}',
          );
        }
      } catch (e) {
        debugPrint('Error fetching order details for ${item.styleKey}: $e');
      }
    }

    setState(() {
      catalogOrderList = tempList;
    });
  }

  int _getQuantity(String styleKey, String shade, String size) {
    return quantities[styleKey]?[shade]?[size] ?? 0;
  }

  void _setQuantity(String styleKey, String shade, String size, int value) {
    setState(() {
      quantities.putIfAbsent(styleKey, () => {});
      quantities[styleKey]!.putIfAbsent(shade, () => {});
      quantities[styleKey]![shade]![size] = value.clamp(0, 9999);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Order Booking',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.signal_cellular_alt),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Column(
            children: [
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Total: ₹${_calculateTotalPrice().toStringAsFixed(2)}',
                    style: GoogleFonts.roboto(color: Colors.white),
                  ),
                  const VerticalDivider(color: Colors.white),
                  Text(
                    'Total Item: ${catalogOrderList.length}',
                    style: GoogleFonts.roboto(color: Colors.white),
                  ),
                  const VerticalDivider(color: Colors.white, thickness: 2),
                  Text(
                    'Total Qty: ${_calculateTotalQuantity()}',
                    style: GoogleFonts.roboto(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      labelStyle: GoogleFonts.lora(),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          // Add copy logic here
                        },
                      ),
                    ),
                    style: GoogleFonts.roboto(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Rate',
                      labelStyle: GoogleFonts.lora(),
                      border: const OutlineInputBorder(),
                    ),
                    style: GoogleFonts.roboto(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            ...catalogOrderList.map(
              (catalogOrder) => Column(
                children: [buildOrderItem(catalogOrder), const Divider()],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'BACK',
                  style: GoogleFonts.montserrat(),
                ),
              ),
              TextButton(
                onPressed: () {
                  debugPrint('Quantities: $quantities');
                },
                child: Text(
                  'SAVE',
                  style: GoogleFonts.montserrat(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateTotalQuantity() {
    int total = 0;
    for (var styleKey in quantities.keys) {
      for (var shade in quantities[styleKey]!.keys) {
        for (var size in quantities[styleKey]![shade]!.keys) {
          total += quantities[styleKey]![shade]![size]!;
        }
      }
    }
    return total;
  }

  double _calculateTotalPrice() {
    double total = 0;
    for (var catalogOrder in catalogOrderList) {
      final styleKey = catalogOrder.catalog.styleKey;
      final matrix = catalogOrder.orderMatrix;
      for (var shade in quantities[styleKey]?.keys ?? []) {
        final shadeIndex = matrix.shades.indexOf(shade.toString().trim());
        if (shadeIndex == -1) continue;
        for (var size in quantities[styleKey]![shade]!.keys) {
          final sizeIndex = matrix.sizes.indexOf(size.trim());
          if (sizeIndex == -1) continue;
          final rate = double.tryParse(matrix.matrix[shadeIndex][sizeIndex].split(',')[0]) ?? 0;
          final quantity = quantities[styleKey]![shade]![size]!;
          total += rate * quantity;
        }
      }
    }
    return total;
  }

  Widget buildOrderItem(CatalogOrderData catalogOrder) {
    final catalog = catalogOrder.catalog;
    // Initialize with first shade if not already set
    if (!selectedColors2.containsKey(catalog.styleKey)) {
      final shades = catalog.shadeName.split(',');
      selectedColors2[catalog.styleKey] = shades.isNotEmpty ? shades[0] : '';
      quantities[catalog.styleKey] = shades.isNotEmpty ? {shades[0]: {}} : {};
    }
    String selectedColor = selectedColors2[catalog.styleKey]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            catalog.styleCode,
            style: GoogleFonts.amaranth(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          subtitle: Text(
            'Total Qty: ${_calculateCatalogQuantity(catalog.styleKey)}\n'
            'Wip Stock: 0\n'
            'Pending Qty: 0',
            style: GoogleFonts.roboto(),
          ),
          trailing: Image.network(
            catalog.fullImagePath.contains("http")
                ? catalog.fullImagePath
                : '${AppConstants.BASE_URL}/images${catalog.fullImagePath}',
            width: 70,
            height: 70,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Select Shade',
          style: GoogleFonts.lora(fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: catalog.shadeName.split(',').map((color) {
            final isSelected = selectedColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedColors2[catalog.styleKey] = '';
                    quantities[catalog.styleKey]?.clear();
                  } else {
                    selectedColors2[catalog.styleKey] = color;
                    quantities[catalog.styleKey]?.clear();
                    quantities[catalog.styleKey] = {color: {}};
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
                ),
                child: Text(
                  color,
                  style: GoogleFonts.roboto(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 15),
        if (selectedColor.isNotEmpty)
          _buildColorSection(catalogOrder, selectedColor),
        const SizedBox(height: 15),
      ],
    );
  }

  int _calculateCatalogQuantity(String styleKey) {
    int total = 0;
    for (var shade in quantities[styleKey]?.keys ?? []) {
      for (var size in quantities[styleKey]![shade]!.keys) {
        total += quantities[styleKey]![shade]![size]!;
      }
    }
    return total;
  }

  Widget _buildColorSection(CatalogOrderData catalogOrder, String shade) {
    final sizes = catalogOrder.orderMatrix.sizes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              shade,
              style: GoogleFonts.convergence(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 5,),
            GestureDetector(
              child: Icon(Icons.copy_all_outlined),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quantity: ${_calculateShadeQuantity(catalogOrder.catalog.styleKey, shade)}',
              style: GoogleFonts.roboto(),
            ),
            Row(
              children: [
                Text(
                  'Price: ',
                  style: GoogleFonts.roboto(),
                ),
                Text(
                  '${_calculateShadePrice(catalogOrder, shade).toStringAsFixed(2)}',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                "Size",
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "Rate",
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "WIP",
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "Stock",
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                "Qty",
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        for (var size in sizes) _buildSizeRow(catalogOrder, shade, size),
      ],
    );
  }

  int _calculateShadeQuantity(String styleKey, String shade) {
    int total = 0;
    for (var size in quantities[styleKey]?[shade]?.keys ?? []) {
      total += quantities[styleKey]![shade]![size]!;
    }
    return total;
  }

  double _calculateShadePrice(CatalogOrderData catalogOrder, String shade) {
    double total = 0;
    final styleKey = catalogOrder.catalog.styleKey;
    final matrix = catalogOrder.orderMatrix;
    final shadeIndex = matrix.shades.indexOf(shade.trim());
    if (shadeIndex == -1) return total;
    for (var size in quantities[styleKey]?[shade]?.keys ?? []) {
      final sizeIndex = matrix.sizes.indexOf(size.toString().trim());
      if (sizeIndex == -1) continue;
      final rate = double.tryParse(matrix.matrix[shadeIndex][sizeIndex].split(',')[0]) ?? 0;
      final quantity = quantities[styleKey]![shade]![size]!;
      total += rate * quantity;
    }
    return total;
  }

  Widget _buildSizeRow(CatalogOrderData catalogOrder, String shade, String size) {
    final matrix = catalogOrder.orderMatrix;
    final shadeIndex = matrix.shades.indexOf(shade.trim());
    final sizeIndex = matrix.sizes.indexOf(size.trim());
    final styleKey = catalogOrder.catalog.styleKey;

    String rate = '';
    if (shadeIndex != -1 && sizeIndex != -1) {
      final value = matrix.matrix[shadeIndex][sizeIndex];
      rate = value.split(',')[0];
    }

    final quantity = _getQuantity(styleKey, shade, size);
    final TextEditingController controller = TextEditingController(text: quantity.toString());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              size,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              rate,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "0",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "0",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    _setQuantity(styleKey, shade, size, quantity - 1);
                    controller.text = _getQuantity(styleKey, shade, size).toString();
                  },
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 40,
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: GoogleFonts.roboto(),
                    onChanged: (value) {
                      final newQuantity = int.tryParse(value) ?? 0;
                      _setQuantity(styleKey, shade, size , newQuantity);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _setQuantity(styleKey, shade, size, quantity + 1);
                    controller.text = _getQuantity(styleKey, shade, size).toString();
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}