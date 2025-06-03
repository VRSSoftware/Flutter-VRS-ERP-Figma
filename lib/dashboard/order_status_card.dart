import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/catalog/imagezoom.dart';

class OrderStatusCard extends StatelessWidget {
  final String productName;
  final String orderNo;
  final List<dynamic> items;
  final bool showImage;

  const OrderStatusCard({
    required this.productName,
    required this.orderNo,
    required this.items,
    required this.showImage,
    super.key,
  });

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
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(context),
            const SizedBox(height: 16),
            _buildOrderTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final firstItem = items.first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showImage &&
            firstItem['Style_Image'] != null &&
            firstItem['Style_Image'].isNotEmpty)
          _buildItemImage(context, firstItem['Style_Image']),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Order No:', orderNo),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemImage(BuildContext context, String imageUrl) {
    return GestureDetector(
      onDoubleTap: () => _openImageZoom(context, imageUrl),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 100),
        child: Image.network(
          _getImageUrl(imageUrl),
          fit: BoxFit.contain,
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

  void _openImageZoom(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageZoomScreen(imageUrl: _getImageUrl(imageUrl)),
      ),
    );
  }

  String _getImageUrl(String imagePath) =>
      imagePath.startsWith('http')
          ? imagePath
          : '${AppConstants.BASE_URL}/images/${imagePath.split('/').last.split('?').first}';

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

Widget _buildOrderTable(BuildContext context) {
  final Map<String, List<dynamic>> groupedItems = {};
  for (var item in items) {
    final color = item['Color'] ?? 'Unknown';
    groupedItems.putIfAbsent(color, () => []).add(item);
  }

  // Dynamically build table rows
  final List<TableRow> tableRows = [];

  // Table header
  tableRows.add(
    TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade100),
      children: [
        _buildTableHeader('Shade'),
        _buildTableHeader('Size'),
        _buildTableHeader('Party'),
        _buildTableHeader('Order Qty'),
        _buildTableHeader('Delv Qty'),
        _buildTableHeader('Settle Qty'),
        _buildTableHeader('Pending Qty'),
        _buildTableHeader('Order No'),
      ],
    ),
  );

  final entries = groupedItems.entries.toList();
  for (int groupIndex = 0; groupIndex < entries.length; groupIndex++) {
    final entry = entries[groupIndex];
    final isLastGroup = groupIndex == entries.length - 1;

    for (int i = 0; i < entry.value.length; i++) {
      final item = entry.value[i];
      tableRows.add(
        TableRow(
          children: [
            if (i == 0)
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    entry.key,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getColorCode(entry.key),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(),
            _buildTableCell(item['Size'] ?? ''),
            _buildTableCell(item['Party'] ?? ''),
            _buildTableCell(item['OrderQty']?.toString() ?? '0'),
            _buildTableCell(item['DelvQty']?.toString() ?? '0'),
            _buildTableCell(item['SettleQty']?.toString() ?? '0'),
            _buildTableCell(item['PendingQty']?.toString() ?? '0'),
            _buildTableCell(item['OrderNo'] ?? ''),
          ],
        ),
      );
    }

    if (!isLastGroup) {
      tableRows.add(
        TableRow(
          children: List.generate(
            8,
            (_) => Container(height: 1, color: const Color.fromARGB(255, 124, 124, 124)),
          ),
        ),
      );
    }
  }

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width - 64,
      ),
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300, width: 1),
        columnWidths: const {
          0: FixedColumnWidth(100),
          1: FixedColumnWidth(80),
          2: FixedColumnWidth(120),
          3: FixedColumnWidth(80),
          4: FixedColumnWidth(80),
          5: FixedColumnWidth(80),
          6: FixedColumnWidth(80),
          7: FixedColumnWidth(100),
        },
        children: tableRows,
      ),
    ),
  );
}

  Widget _buildTableHeader(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
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
