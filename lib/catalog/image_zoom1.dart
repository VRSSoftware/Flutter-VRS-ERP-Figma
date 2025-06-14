import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/catalog.dart';

class ImageZoomScreen1 extends StatelessWidget {
  final List<String> imageUrls;
  final Catalog item;
  final bool showShades;
  final bool showMRP;
  final bool showWSP;
  final bool showSizes;
  final bool showProduct;
  final bool showRemark;
  final bool isLargeScreen;

  const ImageZoomScreen1({
    Key? key,
    required this.imageUrls,
    required this.item,
    required this.showShades,
    required this.showMRP,
    required this.showWSP,
    required this.showSizes,
    required this.showProduct,
    required this.showRemark,
    required this.isLargeScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shades = item.shadeName.split(',').map((s) => s.trim()).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.styleCodeWithcount,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                final imageUrl = imageUrls[index];
                return InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Center(child: Icon(Icons.error)),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            child:
                                const Center(child: Icon(Icons.image_not_supported)),
                          ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FixedColumnWidth(8),
                2: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    Text(
                      'Design',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(':'),
                    Text(
                      item.styleCodeWithcount,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: isLargeScreen ? 20 : 16,
                      ),
                    ),
                  ],
                ),
                if (showShades && shades.isNotEmpty) ...[
                  TableRow(
                    children: [
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(
                        'Shade',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(':'),
                      Text(
                        shades.join(', '),
                        style: TextStyle(
                          fontSize: isLargeScreen ? 14 : 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
                if (showMRP) ...[
                  TableRow(
                    children: [
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(
                        'MRP',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(':'),
                      Text(
                        item.mrp.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: isLargeScreen ? 14 : 13,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
                if (showWSP) ...[
                  TableRow(
                    children: [
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(
                        'WSP',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(':'),
                      Text(
                        item.wsp.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: isLargeScreen ? 14 : 13,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
                if (item.sizeName.isNotEmpty && showSizes) ...[
                  TableRow(
                    children: [
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(
                        'Size',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(':'),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          item.sizeDetails, // Adjust based on your size display logic
                          style: TextStyle(
                            fontSize: isLargeScreen ? 14 : 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (showProduct) ...[
                  TableRow(
                    children: [
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(
                        'Product',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(':'),
                      Text(
                        item.itemName,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 14 : 13,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
                if (showRemark) ...[
                  TableRow(
                    children: [
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(
                        'Remark',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(':'),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          item.remark?.trim().isNotEmpty == true
                              ? item.remark!
                              : '--',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 14 : 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}