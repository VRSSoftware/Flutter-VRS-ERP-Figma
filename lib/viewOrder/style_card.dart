import 'package:flutter/material.dart';// Adjust as per your project structure
import '../constants/app_constants.dart'; // Adjust as per your project structure

class StyleCard extends StatelessWidget {
  final String styleCode;
  final List<dynamic> items;
  final Map<String, Map<String, TextEditingController>> controllers;
  final VoidCallback onRemove;
  final VoidCallback updateTotals;
  final Color Function(String) getColor;

  const StyleCard({
    required this.styleCode,
    required this.items,
    required this.controllers,
    required this.onRemove,
    required this.updateTotals,
    required this.getColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstItem = items.first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderSection(firstItem),
            const SizedBox(height: 16),
            _buildPriceTable(context),
            _buildActionButtons(),
          ],
        ),
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
                styleCode,
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
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Image.network(
        _getImageUrl(imagePath),
        fit: BoxFit.fitWidth,
        loadingBuilder: (context, child, loadingProgress) =>
            loadingProgress == null
                ? child
                : const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error, stackTrace) => const _ImageErrorWidget(),
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
    final sizeDetails = _getSizeDetails(items);
    final sortedSizes = sizeDetails.keys.toList()..sort();
    final sortedShades = _getSortedShades(items);

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
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(label),
        ),
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
                    color: getColor(shade),
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
              controller: controllers[shade]?[size],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (_) => updateTotals(),
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

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          _buildActionButton(
            label: 'Update',
            icon: Icons.update,
            color: AppColors.primaryColor,
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            label: 'Remove',
            icon: Icons.delete,
            color: Colors.grey,
            onPressed: onRemove,
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

  /// Color resolver for shade names
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
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
