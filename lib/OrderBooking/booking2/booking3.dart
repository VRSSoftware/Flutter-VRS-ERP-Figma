import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/CatalogOrderData.dart';
import 'package:vrs_erp_figma/models/OrderMatrix.dart';
import 'package:vrs_erp_figma/models/catalog.dart';

class CreateOrderScreen3 extends StatefulWidget {
  final List<Catalog> catalogs;

  const CreateOrderScreen3({Key? key, required this.catalogs})
      : super(key: key);

  @override
  State<CreateOrderScreen3> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen3> {
  List<CatalogOrderData> catalogOrderList = [];
  Map<String, String> selectedColors2 = {};
  Map<String, Map<String, Map<String, int>>> quantities = {};
  final Map<String, TextEditingController> _controllers = {};
  bool isLoading = true;
  final Set<String> _copiedShades = {}; // Format: "styleKey:shade"

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Color _getColorCode(String color) {
    switch (color.toLowerCase().trim()) {
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
    setState(() {
      isLoading = true;
    });
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
          final shades = item.shadeName.split(',').map((s) => s.trim()).toList();
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
      isLoading = false;
    });
  }

  int _getQuantity(String styleKey, String shade, String size) {
    return quantities[styleKey]?[shade.trim()]?[size] ?? 0;
  }

  void _setQuantity(String styleKey, String shade, String size, int value) {
    setState(() {
      quantities.putIfAbsent(styleKey, () => {});
      quantities[styleKey]!.putIfAbsent(shade.trim(), () => {});
      quantities[styleKey]![shade.trim()]![size] = value.clamp(0, 99999);
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
      body: isLoading
          ? Stack(
              children: [
                Container(color: Colors.black.withOpacity(0.2)),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Please Wait...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 12),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  ...catalogOrderList.map(
                    (catalogOrder) => Column(
                      children: [
                        buildOrderItem(catalogOrder),
                        const Divider(),
                      ],
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
                  _copiedShades.clear();
                  setState(() {});
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
        if (shadeIndex == -1) {
          debugPrint('Shade not found: $shade');
          continue;
        }
        for (var size in quantities[styleKey]![shade]!.keys) {
          final sizeIndex = matrix.sizes.indexOf(size.toString().trim());
          if (sizeIndex == -1) {
            debugPrint('Size not found: $size');
            continue;
          }
          final rate =
              double.tryParse(
                matrix.matrix[shadeIndex][sizeIndex].split(',')[0],
              ) ??
              0;
          final quantity = quantities[styleKey]![shade]![size]!;
          total += rate * quantity;
        }
      }
    }
    return total;
  }

  double _calculateCatalogPrice(String styleKey) {
    double total = 0;
    for (var catalogOrder in catalogOrderList) {
      if (catalogOrder.catalog.styleKey == styleKey) {
        final matrix = catalogOrder.orderMatrix;
        for (var shade in quantities[styleKey]?.keys ?? []) {
          final shadeIndex = matrix.shades.indexOf(shade.toString().trim());
          if (shadeIndex == -1) {
            debugPrint('Shade not found: $shade');
            continue;
          }
          for (var size in quantities[styleKey]![shade]!.keys) {
            final sizeIndex = matrix.sizes.indexOf(size.toString().trim());
            if (sizeIndex == -1) {
              debugPrint('Size not found: $size');
              continue;
            }
            final rate =
                double.tryParse(
                  matrix.matrix[shadeIndex][sizeIndex].split(',')[0],
                ) ??
                0;
            final quantity = quantities[styleKey]![shade]![size]!;
            total += rate * quantity;
          }
        }
      }
    }
    return total;
  }

  Widget buildOrderItem(CatalogOrderData catalogOrder) {
    final catalog = catalogOrder.catalog;
    if (!selectedColors2.containsKey(catalog.styleKey)) {
      final shades = catalog.shadeName.split(',').map((s) => s.trim()).toList();
      selectedColors2[catalog.styleKey] = shades.isNotEmpty ? shades[0] : '';
      quantities[catalog.styleKey] ??= {};
      if (shades.isNotEmpty) {
        quantities[catalog.styleKey]!.putIfAbsent(shades[0], () => {});
      }
    }
    String selectedColor = selectedColors2[catalog.styleKey]!;

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
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.error, size: 60),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          catalog.styleCode,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.copy_all_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onPressed: () async {
                            setState(() {
                              _copiedShades.add('${catalog.styleKey}:$selectedColor');
                            });

                            final result = await showDialog<Map<String, dynamic>>(
                              context: context,
                              builder: (context) => ShadeSelectionDialog(
                                shades: catalog.shadeName.split(',').map((s) => s.trim()).toList(),
                                sourceShade: selectedColor,
                                dialogType: 'styleCopy',
                              ),
                            );

                            if (result != null) {
                              final selectedShades =
                                  result['selectedShades'] as Set<String>;

                              setState(() {
                                final currentQuantities =
                                    quantities[catalog.styleKey]?[selectedColor] ?? {};
                                debugPrint(
                                  'Copying from $selectedColor (style: ${catalog.styleKey}): $currentQuantities',
                                );

                                if (selectedShades.isNotEmpty) {
                                  for (var targetCatalogOrder in catalogOrderList) {
                                    if (targetCatalogOrder.catalog.styleKey !=
                                        catalog.styleKey) {
                                      final targetStyleKey =
                                          targetCatalogOrder.catalog.styleKey;
                                      final targetShades = targetCatalogOrder
                                          .catalog
                                          .shadeName
                                          .split(',')
                                          .map((s) => s.trim())
                                          .toList();
                                      final validSizes =
                                          targetCatalogOrder.orderMatrix.sizes;

                                      quantities[targetStyleKey] ??= {};
                                      for (var targetShade in targetShades) {
                                        if (selectedShades.contains(targetShade)) {
                                          quantities[targetStyleKey]!.putIfAbsent(
                                            targetShade,
                                            () => {},
                                          );
                                          quantities[targetStyleKey]![targetShade]!.clear();
                                          currentQuantities.forEach((size, quantity) {
                                            if (validSizes.contains(size)) {
                                              quantities[targetStyleKey]![targetShade]![size] =
                                                  quantity;
                                            }
                                          });
                                          _copiedShades.add('$targetStyleKey:$targetShade');
                                        }
                                      }
                                      debugPrint(
                                        'Copied to style $targetStyleKey: ${quantities[targetStyleKey]}',
                                      );
                                    }
                                  }
                                }

                                debugPrint(
                                  'Copied to shades $selectedShades in other styles',
                                );
                              });
                            } else {
                              setState(() {
                                _copiedShades.remove('${catalog.styleKey}:$selectedColor');
                              });
                              debugPrint('Dialog cancelled');
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Qty: ${_calculateCatalogQuantity(catalog.styleKey)}',
                      style: GoogleFonts.roboto(fontSize: 14),
                    ),
                    Text(
                      'Total Price: ₹${_calculateCatalogPrice(catalog.styleKey).toStringAsFixed(2)}',
                      style: GoogleFonts.roboto(fontSize: 14, color: Colors.green),
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
            final trimmedColor = color.trim();
            final isSelected = selectedColor == trimmedColor;
            final isCopySelected = _copiedShades.contains('${catalog.styleKey}:$trimmedColor');

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColors2[catalog.styleKey] = trimmedColor;
                  quantities[catalog.styleKey] ??= {};
                  quantities[catalog.styleKey]!.putIfAbsent(
                    trimmedColor,
                    () => {},
                  );
                });
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                    child: Text(
                      trimmedColor,
                      style: GoogleFonts.roboto(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  if (isCopySelected)
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
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
    final styleKey = catalogOrder.catalog.styleKey;
    final allShades = catalogOrder.catalog.shadeName.split(',').map((s) => s.trim()).toList();

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
                  icon: const Icon(
                    Icons.copy_all_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    setState(() {
                      _copiedShades.add('$styleKey:$shade');
                    });

                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) => ShadeSelectionDialog(
                        shades: allShades,
                        sourceShade: shade,
                        dialogType: 'shadeCopy',
                      ),
                    );

                    if (result != null) {
                      final selectedShades =
                          result['selectedShades'] as Set<String>;

                      setState(() {
                        final currentQuantities =
                            quantities[styleKey]?[shade] ?? {};
                        debugPrint(
                          'Copying from $shade (style: $styleKey): $currentQuantities',
                        );

                        for (var targetShade in selectedShades) {
                          if (targetShade != shade) {
                            quantities[styleKey]!.putIfAbsent(
                              targetShade,
                              () => {},
                            );
                            quantities[styleKey]![targetShade]!.clear();
                            currentQuantities.forEach((size, quantity) {
                              quantities[styleKey]![targetShade]![size] =
                                  quantity;
                            });
                            _copiedShades.add('$styleKey:$targetShade');
                          }
                        }

                        debugPrint(
                          'Copied to shades $selectedShades in style $styleKey: ${quantities[styleKey]}',
                        );
                      });
                    } else {
                      setState(() {
                        _copiedShades.remove('$styleKey:$shade');
                      });
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
                _buildSizeRow(catalogOrder, shade, size.toString()),
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
    for (var size in quantities[styleKey]?[shade.trim()]?.keys ?? []) {
      total += quantities[styleKey]![shade.trim()]![size]!;
    }
    return total;
  }

  double _calculateShadePrice(CatalogOrderData catalogOrder, String shade) {
    double total = 0;
    final styleKey = catalogOrder.catalog.styleKey;
    final matrix = catalogOrder.orderMatrix;
    final shadeIndex = matrix.shades.indexOf(shade.trim());
    if (shadeIndex == -1) {
      debugPrint('Shade not found: $shade');
      return total;
    }
    for (var size in quantities[styleKey]?[shade.trim()]?.keys ?? []) {
      final sizeIndex = matrix.sizes.indexOf(size.toString().trim());
      if (sizeIndex == -1) {
        debugPrint('Size not found: $size');
        continue;
      }
      final rate =
          double.tryParse(matrix.matrix[shadeIndex][sizeIndex].split(',')[0]) ??
          0;
      final quantity = quantities[styleKey]![shade.trim()]![size]!;
      total += rate * quantity;
    }
    return total;
  }

  Widget _buildSizeRow(
    CatalogOrderData catalogOrder,
    String shade,
    String size,
  ) {
    final matrix = catalogOrder.orderMatrix;
    final shadeIndex = matrix.shades.indexOf(shade.trim());
    final sizeIndex = matrix.sizes.indexOf(size.toString().trim());
    final styleKey = catalogOrder.catalog.styleKey;

    String rate = '';
    String stock = '0';
    if (shadeIndex != -1 && sizeIndex != -1) {
      final matrixData = matrix.matrix[shadeIndex][sizeIndex].split(',');
      rate = matrixData[0];
      stock = matrixData.length > 1 ? matrixData[1] : '0';
    } else {
      debugPrint('Invalid shade or size: shade=$shade, size=$size');
    }

    final quantity = _getQuantity(styleKey, shade, size);
    final controllerKey = '$styleKey-${shade.trim()}-$size';
    final controller = _controllers.putIfAbsent(
      controllerKey,
      () => TextEditingController(text: quantity.toString()),
    );
    if (controller.text != quantity.toString()) {
      controller.text = quantity.toString();
    }

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
                    controller.text =
                        _getQuantity(styleKey, shade, size).toString();
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    onChanged: (value) {
                      final newQuantity =
                          int.tryParse(value.isEmpty ? '0' : value) ?? 0;
                      _setQuantity(styleKey, shade, size, newQuantity);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _setQuantity(styleKey, shade, size, quantity + 1);
                    controller.text =
                        _getQuantity(styleKey, shade, size).toString();
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

class ShadeSelectionDialog extends StatefulWidget {
  final List<String> shades;
  final String sourceShade;
  final String dialogType; // 'shadeCopy' or 'styleCopy'

  const ShadeSelectionDialog({
    Key? key,
    required this.shades,
    required this.sourceShade,
    required this.dialogType,
  }) : super(key: key);

  @override
  _ShadeSelectionDialogState createState() => _ShadeSelectionDialogState();
}

class _ShadeSelectionDialogState extends State<ShadeSelectionDialog> {
  late Set<String> _selectedShades;

  @override
  void initState() {
    super.initState();
    _selectedShades = widget.dialogType == 'styleCopy'
        ? Set.from(widget.shades.map((s) => s.trim()))
        : {widget.sourceShade.trim()};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        widget.dialogType == 'styleCopy'
            ? 'Copy Size Qty to Other Styles'
            : 'Copy Quantities',
        style: GoogleFonts.poppins(),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...widget.shades.map((shade) {
              final trimmedShade = shade.trim();
              final isSourceShade = trimmedShade == widget.sourceShade.trim();
              return CheckboxListTile(
                title: Text(trimmedShade, style: GoogleFonts.roboto()),
                value: _selectedShades.contains(trimmedShade),
                onChanged: isSourceShade && widget.dialogType == 'styleCopy'
                    ? null
                    : (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedShades.add(trimmedShade);
                          } else {
                            _selectedShades.remove(trimmedShade);
                          }
                        });
                      },
                activeColor: isSourceShade ? Colors.grey : null,
                checkColor: isSourceShade ? Colors.white : null,
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel', style: GoogleFonts.montserrat()),
        ),
        TextButton(
          onPressed: () {
            final resultShades = widget.dialogType == 'styleCopy'
                ? _selectedShades.difference({widget.sourceShade.trim()})
                : _selectedShades;
            Navigator.pop(context, {
              'selectedShades': resultShades,
              'copyToOtherStyles': widget.dialogType == 'styleCopy',
            });
          },
          child: Text('OK', style: GoogleFonts.montserrat()),
        ),
      ],
    );
  }
}