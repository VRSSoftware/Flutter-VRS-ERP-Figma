import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/CatalogOrderData.dart';
import 'package:vrs_erp_figma/models/OrderMatrix.dart';
import 'package:vrs_erp_figma/models/catalog.dart';

class CreateOrderScreen extends StatefulWidget {
  final List<Catalog> catalogs;

  const CreateOrderScreen({Key? key, required this.catalogs}) : super(key: key);

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  List<CatalogOrderData> catalogOrderList = [];
  Map<String, Set<String>> selectedColors2 = {};
  Map<String, Map<String, Map<String, int>>> quantities = {};

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
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

          selectedColors2[item.styleKey] =
              item.shadeName.split(',').map((e) => e.trim()).toSet();

          quantities[item.styleKey] = {};
          for (var shade in selectedColors2[item.styleKey]!) {
            quantities[item.styleKey]![shade] = {};
          }
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
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                child: Text('BACK', style: GoogleFonts.montserrat()),
              ),
              TextButton(
                onPressed: () {
                  debugPrint('Quantities: $quantities');
                },
                child: Text('SAVE', style: GoogleFonts.montserrat()),
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
    final Set<String> selectedColors = selectedColors2[catalog.styleKey] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  catalog.fullImagePath.contains("http")
                      ? catalog.fullImagePath
                      : '${AppConstants.BASE_URL}/images${catalog.fullImagePath}',
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 60),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      catalog.styleCode,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Qty: ${_calculateCatalogQuantity(catalog.styleKey)}',
                      style: GoogleFonts.roboto(fontSize: 14),
                    ),
                    Text(
                      'Pending Qty: 0 | Wip Stock: 0',
                      style: GoogleFonts.roboto(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        ...selectedColors.map(
          (color) => Column(children: [_buildColorSection(catalogOrder, color), const SizedBox(height: 15)]),
        ),
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
    final styleKey = catalogOrder.catalog.styleKey;
    final allShades = catalogOrder.catalog.shadeName.split(',').map((e) => e.trim()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  shade,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: _getColorCode(shade),
                  ),
                ),
                const SizedBox(width: 5),
                IconButton(
                  icon: Icon(Icons.copy, size: 16, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: shade));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied "$shade" to clipboard')),
                    );
                  },
                ),
                const SizedBox(width: 5),
                IconButton(
                  icon: Icon(Icons.copy_all_outlined, size: 16, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () async {
                    // Show dialog and get selected shades and copyToAllStyles flag
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) => ShadeSelectionDialog(
                        shades: allShades.where((s) => s != shade).toList(),
                        sourceShade: shade,
                      ),
                    );

                    // If result is not null, process the copy
                    if (result != null) {
                      final selectedShades = result['selectedShades'] as Set<String>;
                      final copyToAllStyles = result['copyToAllStyles'] as bool;

                      setState(() {
                        final currentQuantities = quantities[styleKey]?[shade] ?? {};
                        debugPrint('Copying from $shade (style: $styleKey): $currentQuantities');

                        if (copyToAllStyles) {
                          // Copy to all shades of all styles
                          for (var targetCatalogOrder in catalogOrderList) {
                            final targetStyleKey = targetCatalogOrder.catalog.styleKey;
                            final targetShades = targetCatalogOrder.catalog.shadeName.split(',').map((e) => e.trim()).toList();
                            final validSizes = targetCatalogOrder.orderMatrix.sizes;

                            quantities[targetStyleKey] ??= {};
                            for (var targetShade in targetShades) {
                              quantities[targetStyleKey]!.putIfAbsent(targetShade, () => {});
                              quantities[targetStyleKey]![targetShade]!.clear();
                              // Only copy quantities for sizes that exist in the target style
                              currentQuantities.forEach((size, quantity) {
                                if (validSizes.contains(size)) {
                                  quantities[targetStyleKey]![targetShade]![size] = quantity;
                                }
                              });
                            }
                            debugPrint('Copied to style $targetStyleKey: ${quantities[targetStyleKey]}');
                          }
                        } else if (selectedShades.isNotEmpty) {
                          // Copy to selected shades within the current style
                          for (var targetShade in selectedShades) {
                            quantities[styleKey]!.putIfAbsent(targetShade, () => {});
                            quantities[styleKey]![targetShade]!.clear();
                            currentQuantities.forEach((size, quantity) {
                              quantities[styleKey]![targetShade]![size] = quantity;
                            });
                          }
                          debugPrint('Copied to shades $selectedShades in style $styleKey: ${quantities[styleKey]}');
                        } else {
                          debugPrint('No shades selected and copyToAllStyles not checked');
                        }
                      });
                    } else {
                      debugPrint('Dialog cancelled');
                    }
                  },
                ),
              ],
            ),
            Text(
              'Quantity: ${_calculateShadeQuantity(catalogOrder.catalog.styleKey, shade)}',
              style: GoogleFonts.roboto(),
            ),
            Row(
              children: [
                Text('Price: ', style: GoogleFonts.roboto()),
                Text(
                  '₹${_calculateShadePrice(catalogOrder, shade).toStringAsFixed(2)}',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildHeader("Size", 1),
                  _buildHeader("Qty", 2),
                  _buildHeader("Rate", 1),
                  _buildHeader("WIP", 1),
                  _buildHeader("Stock", 1),
                ],
              ),
              Divider(height: 1, color: Colors.grey.shade300),
              for (var size in sizes) ...[
                _buildSizeRow(catalogOrder, shade, size),
                Divider(height: 1, color: Colors.grey.shade300),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String text, int flex) => Expanded(
        flex: flex,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      );

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
    String stock = '0';
    if (shadeIndex != -1 && sizeIndex != -1) {
      final matrixData = matrix.matrix[shadeIndex][sizeIndex].split(',');
      rate = matrixData[0];
      stock = matrixData.length > 1 ? matrixData[1] : '0';
    }

    final quantity = _getQuantity(styleKey, shade, size);
    final TextEditingController controller = TextEditingController(text: quantity.toString());

    return Row(
      children: [
        _buildCell(size, 1),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    _setQuantity(styleKey, shade, size, quantity - 1);
                    controller.text = _getQuantity(styleKey, shade, size).toString();
                  },
                  icon: const Icon(Icons.remove, size: 20),
                ),
                SizedBox(
                  width: 25,
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: GoogleFonts.roboto(fontSize: 14),
                    onChanged: (value) {
                      final newQuantity = int.tryParse(value) ?? 0;
                      _setQuantity(styleKey, shade, size, newQuantity);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _setQuantity(styleKey, shade, size, quantity + 1);
                    controller.text = _getQuantity(styleKey, shade, size).toString();
                  },
                  icon: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
          ),
        ),
        _buildCell(rate, 1),
        _buildCell("0", 1),
        _buildCell(stock, 1),
      ],
    );
  }

  Widget _buildCell(String text, int flex) => Expanded(
        flex: flex,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(fontSize: 14),
          ),
        ),
      );
}

// Dialog to select shades for copying quantities
class ShadeSelectionDialog extends StatefulWidget {
  final List<String> shades;
  final String sourceShade;

  const ShadeSelectionDialog({Key? key, required this.shades, required this.sourceShade}) : super(key: key);

  @override
  _ShadeSelectionDialogState createState() => _ShadeSelectionDialogState();
}

class _ShadeSelectionDialogState extends State<ShadeSelectionDialog> {
  final Set<String> _selectedShades = {};
  bool _copyToAllStyles = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Copy Quantities',
        style: GoogleFonts.poppins(),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Copying from: ${widget.sourceShade}',
                style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
              ),
            ),
            CheckboxListTile(
              title: Text('Copy to all styles', style: GoogleFonts.roboto()),
              value: _copyToAllStyles,
              onChanged: (bool? value) {
                setState(() {
                  _copyToAllStyles = value ?? false;
                });
              },
            ),
            const Divider(),
            ...widget.shades.map((shade) {
              return CheckboxListTile(
                title: Text(shade, style: GoogleFonts.roboto()),
                value: _selectedShades.contains(shade),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedShades.add(shade);
                    } else {
                      _selectedShades.remove(shade);
                    }
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Cancel
          },
          child: Text('Cancel', style: GoogleFonts.montserrat()),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'selectedShades': _selectedShades,
              'copyToAllStyles': _copyToAllStyles,
            }); // Return selected shades and copyToAllStyles flag
          },
          child: Text('OK', style: GoogleFonts.montserrat()),
        ),
      ],
    );
  }
}