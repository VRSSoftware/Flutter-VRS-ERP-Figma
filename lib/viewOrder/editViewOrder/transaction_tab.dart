import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vrs_erp_figma/models/CatalogOrderData.dart';
import 'package:vrs_erp_figma/viewOrder/editViewOrder/edit_order_data.dart';
import '../../constants/app_constants.dart';


class TransactionTab extends StatefulWidget {
  const TransactionTab({super.key});

  @override
  State<TransactionTab> createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab> {
  final Map<String, String> selectedShades = {};
  final Map<String, Map<String, Map<String, TextEditingController>>> controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var order in EditOrderData.data) {
      final styleKey = order.catalog.styleKey;
      final shades = order.orderMatrix.shades;
      final sizes = order.orderMatrix.sizes;

      selectedShades[styleKey] = shades.isNotEmpty ? shades.first : '';

      controllers.putIfAbsent(styleKey, () => {});
      for (var shade in shades) {
        controllers[styleKey]!.putIfAbsent(shade, () => {});
        for (var size in sizes) {
          controllers[styleKey]![shade]![size] =
              TextEditingController(text: _getMatrixValue(order, shade, size)['qty'].toString());
        }
      }
    }
  }

  Map<String, dynamic> _getMatrixValue(CatalogOrderData order, String shade, String size) {
    final shadeIndex = order.orderMatrix.shades.indexOf(shade);
    final sizeIndex = order.orderMatrix.sizes.indexOf(size);

    if (shadeIndex < 0 || sizeIndex < 0) {
      return {'mrp': 0, 'wsp': 0, 'qty': 0, 'stock': 0};
    }

    final matrixEntry = order.orderMatrix.matrix[shadeIndex][sizeIndex];
    final parts = matrixEntry.split(',');
    if (parts.length < 4) {
      return {'mrp': 0, 'wsp': 0, 'qty': 0, 'stock': 0};
    }

    return {
      'mrp': double.tryParse(parts[0]) ?? 0,
      'wsp': double.tryParse(parts[1]) ?? 0,
      'qty': int.tryParse(parts[2]) ?? 0,
      'stock': int.tryParse(parts[3]) ?? 0,
    };
  }

  void _updateQuantity(
    CatalogOrderData order,
    String shade,
    String size,
    String value,
  ) {
    final shadeIndex = order.orderMatrix.shades.indexOf(shade);
    final sizeIndex = order.orderMatrix.sizes.indexOf(size);

    if (shadeIndex < 0 || sizeIndex < 0) return;

    final matrixEntry = order.orderMatrix.matrix[shadeIndex][sizeIndex];
    final parts = matrixEntry.split(',');
    if (parts.length < 4) return;

    final newQty = int.tryParse(value) ?? 0;
    parts[2] = newQty.toString();

    setState(() {
      order.orderMatrix.matrix[shadeIndex][sizeIndex] = parts.join(',');
    });
  }

  Widget _buildHeader(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey[200],
        child: Text(
          label,
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSizeRow(
    CatalogOrderData order,
    String shade,
    String size,
  ) {
    final styleKey = order.catalog.styleKey;
    final value = _getMatrixValue(order, shade, size);

    final qtyController = controllers[styleKey]![shade]![size]!;

    return Row(
      children: [
        Expanded(flex: 1, child: Center(child: Text(size))),
        Expanded(
          flex: 2,
          child: TextField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (valueText) {
              _updateQuantity(order, shade, size, valueText);
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '0',
            ),
          ),
        ),
        Expanded(flex: 1, child: Center(child: Text(value['mrp'].toString()))),
        Expanded(flex: 1, child: Center(child: Text(value['wsp'].toString()))),
        Expanded(flex: 1, child: Center(child: Text(value['stock'].toString()))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...EditOrderData.data.map((order) {
            final styleKey = order.catalog.styleKey;
            final shades = order.orderMatrix.shades;
            final sizes = order.orderMatrix.sizes;
            final selectedShade = selectedShades[styleKey] ?? shades.first;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.network(
                      order.catalog.fullImagePath.contains("http")
                          ? order.catalog.fullImagePath
                          : '${AppConstants.BASE_URL}/images${order.catalog.fullImagePath}',
                      width: 60,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.error),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.catalog.styleCode,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              )),
                          const SizedBox(height: 4),
                          Text('Shades: ${shades.join(', ')}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 🔹 Shade Selector
                Wrap(
                  spacing: 8,
                  children: shades.map((shade) {
                    final isSelected = selectedShade == shade;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedShades[styleKey] = shade;
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
                          shade,
                          style: GoogleFonts.roboto(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),

                // 🔸 Size Matrix
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildHeader('Size', 1),
                        _buildHeader('Qty', 2),
                        _buildHeader('MRP', 1),
                        _buildHeader('WSP', 1),
                        _buildHeader('Stock', 1),
                      ],
                    ),
                    ...sizes.map((size) {
                      return Column(
                        children: [
                          _buildSizeRow(order, selectedShade, size),
                          Divider(height: 1, color: Colors.grey.shade300),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                const Divider(thickness: 1),
                const SizedBox(height: 15),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
