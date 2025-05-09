import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/catalog/imagezoom.dart';
import '../constants/app_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StyleCard extends StatefulWidget {
  final String styleCode;
  final List<dynamic> items;
  final Map<String, Map<String, TextEditingController>> controllers;
  final VoidCallback onRemove;
  final VoidCallback updateTotals;
  final Color Function(String) getColor;
  final VoidCallback onUpdate;

  const StyleCard({
    required this.styleCode,
    required this.items,
    required this.controllers,
    required this.onRemove,
    required this.updateTotals,
    required this.getColor,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  _StyleCardState createState() => _StyleCardState();
}

class _StyleCardState extends State<StyleCard> {
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = widget.items.first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderSection(firstItem),
            const SizedBox(height: 16),
            _buildPriceTable(context),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  void _openImageZoom(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageZoomScreen(imageUrl: _getImageUrl(imageUrl)),
      ),
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> firstItem) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (firstItem['fullImagePath'] != null)
          _buildItemImage(firstItem['fullImagePath']),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.styleCode,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              if (firstItem['itemSubGrpName'] != null)
                _buildDetailRow('Category:', firstItem['itemSubGrpName']),
              if (firstItem['itemName'] != null)
                _buildDetailRow('Product:', firstItem['itemName']),
              if (firstItem['brandName'] != null)
                _buildDetailRow('Brand:', firstItem['brandName']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemImage(String imagePath) {
    return GestureDetector(
      onDoubleTap: () => _openImageZoom(context, imagePath),
      child: Container(
        width: 100,
        height: 120,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Image.network(
          _getImageUrl(imagePath),
          fit: BoxFit.fitWidth,
          loadingBuilder:
              (context, child, loadingProgress) =>
                  loadingProgress == null
                      ? child
                      : const Center(child: CircularProgressIndicator()),
          errorBuilder:
              (context, error, stackTrace) => const _ImageErrorWidget(),
        ),
      ),
    );
  }

  String _getImageUrl(String fullImagePath) =>
      fullImagePath.startsWith('http')
          ? fullImagePath
          : '${AppConstants.BASE_URL}/images/${fullImagePath.split('/').last.split('?').first}';

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTable(BuildContext context) {
    final sizeDetails = _getSizeDetails(widget.items);
    final sortedSizes = sizeDetails.keys.toList()..sort();
    final sortedShades = _getSortedShades(widget.items);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 64,
        ),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
          columnWidths: _buildColumnWidths(sortedSizes),
          children: [
            _buildTableRow('MRP', sortedSizes, sizeDetails, 'mrp'),
            _buildTableRow('WSP', sortedSizes, sizeDetails, 'wsp'),
            _buildHeaderRow(sortedSizes),
            ...sortedShades.map((shade) => _buildShadeRow(shade, sortedSizes)),
          ],
        ),
      ),
    );
  }

  Map<String, Map<String, num>> _getSizeDetails(List<dynamic> items) {
    final details = <String, Map<String, num>>{};
    for (final item in items) {
      final size = item['sizeName']?.toString() ?? 'N/A';
      details[size] = {
        'mrp': (item['mrp'] as num?) ?? 0,
        'wsp': (item['wsp'] as num?) ?? 0,
      };
    }
    return details;
  }

  List<String> _getSortedShades(List<dynamic> items) =>
      items.map((e) => e['shadeName']?.toString() ?? '').toSet().toList()
        ..sort();

  Map<int, TableColumnWidth> _buildColumnWidths(List<String> sizes) => {
    0: const FixedColumnWidth(100),
    for (var i = 0; i < sizes.length; i++) i + 1: const FixedColumnWidth(80),
  };

  TableRow _buildTableRow(
    String label,
    List<String> sizes,
    Map<String, Map<String, num>> details,
    String key,
  ) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(padding: const EdgeInsets.all(8), child: Text(label)),
        ),
        ...sizes.map(
          (size) => TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Center(
              child: Text(
                '${details[size]?[key]?.toStringAsFixed(0) ?? '0'}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildHeaderRow(List<String> sizes) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade100),
      children: [
        const TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: _TableHeaderCell(),
        ),
        ...sizes.map(
          (size) => TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Center(
              child: Text(
                size,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildShadeRow(String shade, List<String> sizes) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  shade,
                  style: TextStyle(
                    color: widget.getColor(shade),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        ...sizes.map(
          (size) => Padding(
            padding: const EdgeInsets.all(4),
            child: TextField(
              controller: widget.controllers[shade]?[size],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (_) => widget.updateTotals(),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                hintText: '0',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Calculate total quantity for this specific style card
    int styleTotalQty = 0;
    widget.controllers.forEach((shade, sizes) {
      sizes.forEach((size, controller) {
        styleTotalQty += int.tryParse(controller.text) ?? 0;
      });
    });

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
          SizedBox(
            width: 350,
            child: TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Add total quantity display
          SizedBox(
            width: 350,
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Style Total Quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              controller: TextEditingController(text: styleTotalQty.toString())
                ..selection = TextSelection.collapsed(
                  offset: styleTotalQty.toString().length,
                ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionButton(
                label: 'Update',
                icon: Icons.update,
                color: AppColors.primaryColor,
                onPressed: () => _submitUpdate(context),
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                label: 'Remove',
                icon: Icons.delete,
                color: Colors.grey,
                onPressed: () => _submitDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 20, color: color),
        label: Text(label, style: TextStyle(color: color)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Future<void> _submitDelete(BuildContext context) async {
    List<Future> apiCalls = [];
    final sizeDetails = _getSizeDetails(widget.items);
    int totalQty = 0;
    List<String> updatedData = [];

    debugPrint('Submitting update for styleCode: ${widget.styleCode}');
    //updatedData.add('Shade: $shade, Size: $size, Qty: $qty');
    final payload = {
      "userId": "Admin",
      "coBrId": "01",
      "fcYrId": "24",
      "data": {
        "designcode": widget.styleCode,
        "mrp": '0',
        "WSP": '0',
        "size": '',
        "TotQty": totalQty.toString(),
        "Note": noteController.text,
        "color": "",
        "Qty": " ",
        "cobrid": "01",
        "user": "admin",
        "barcode": "",
      },
      "typ": 2,
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

    if (apiCalls.isEmpty) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("No Updates"),
              content: const Text("No quantities have been updated."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
      return;
    }

    if (noteController.text.isNotEmpty) {
      updatedData.add('Note: ${noteController.text}');
    }

    try {
      final responses = await Future.wait(apiCalls);
      if (responses.every((r) => r.statusCode == 200)) {
        debugPrint('Update successful for styleCode: ${widget.styleCode}');
        widget.onUpdate(); // Trigger refresh without removing card
      } else {
        debugPrint(
          'Update failed for some items: ${responses.map((r) => r.statusCode).toList()}',
        );
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("Error"),
                content: const Text("Failed to update some order details."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      debugPrint('Error during update: $e');
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Error"),
              content: Text("Failed to submit update: $e"),
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

  Future<void> _submitUpdate(BuildContext context) async {
    List<Future> apiCalls = [];
    final sizeDetails = _getSizeDetails(widget.items);
    int totalQty = 0;
    List<String> updatedData = [];

    debugPrint('Submitting update for styleCode: ${widget.styleCode}');
    //updatedData.add('Shade: $shade, Size: $size, Qty: $qty');
    final payload = {
      "userId": "Admin",
      "coBrId": "01",
      "fcYrId": "24",
      "data": {
        "designcode": widget.styleCode,
        "mrp": '0',
        "WSP": '0',
        "size": '',
        "TotQty": totalQty.toString(),
        "Note": noteController.text,
        "color": "",
        "Qty": " ",
        "cobrid": "01",
        "user": "admin",
        "barcode": "",
      },
      "typ": 1,
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
    for (var shadeEntry in widget.controllers.entries) {
      String shade = shadeEntry.key;
      for (var sizeEntry in shadeEntry.value.entries) {
        String size = sizeEntry.key;
        String qty = sizeEntry.value.text;
        if (qty.isNotEmpty && int.tryParse(qty) != null && int.parse(qty) > 0) {
          totalQty += int.parse(qty);
          updatedData.add('Shade: $shade, Size: $size, Qty: $qty');
          final payload = {
            "userId": "Admin",
            "coBrId": "01",
            "fcYrId": "24",
            "data": {
              "designcode": widget.styleCode,
              "mrp": sizeDetails[size]?['mrp']?.toStringAsFixed(0) ?? '0',
              "WSP": sizeDetails[size]?['wsp']?.toStringAsFixed(0) ?? '0',
              "size": size,
              "TotQty": totalQty.toString(),
              "Note": noteController.text,
              "color": shade,
              "Qty": qty,
              "cobrid": "01",
              "user": "admin",
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

    if (apiCalls.isEmpty) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("No Updates"),
              content: const Text("No quantities have been updated."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
      return;
    }

    if (noteController.text.isNotEmpty) {
      updatedData.add('Note: ${noteController.text}');
    }

    try {
      final responses = await Future.wait(apiCalls);
      if (responses.every((r) => r.statusCode == 200)) {
        debugPrint('Update successful for styleCode: ${widget.styleCode}');
        widget.onUpdate(); // Trigger refresh without removing card
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Success"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Order details updated successfully:"),
                  // const SizedBox(height: 8),
                  // Text(updatedData.join('\n')),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        debugPrint(
          'Update failed for some items: ${responses.map((r) => r.statusCode).toList()}',
        );
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("Error"),
                content: const Text("Failed to update some order details."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      debugPrint('Error during update: $e');
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Error"),
              content: Text("Failed to submit update: $e"),
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

class _ImageErrorWidget extends StatelessWidget {
  const _ImageErrorWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 40),
          SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
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
