import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/models/catalog.dart';

class ImageZoomScreen1 extends StatelessWidget {
  final String imageUrl;
  final Catalog item;
  final bool showShades;
  final bool showMRP;
  final bool showWSP;
  final bool showSizes;
  final bool showProduct;
  final bool showRemark;
  final bool isLargeScreen;

  const ImageZoomScreen1({
    super.key,
    required this.imageUrl,
    required this.item,
    required this.showShades,
    required this.showMRP,
    required this.showWSP,
    required this.showSizes,
    required this.showProduct,
    required this.showRemark,
    required this.isLargeScreen,
  });

  // Text style for values
  TextStyle _valueTextStyle() {
    return TextStyle(
      fontSize: isLargeScreen ? 16 : 14,
      color: Colors.grey[800],
      fontWeight: FontWeight.w400,
    );
  }

  // Text style for labels
  Widget _buildLabelText(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: isLargeScreen ? 16 : 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  // Spacer row for consistent spacing
  TableRow _buildSpacerRow() {
    return const TableRow(
      children: [
        SizedBox(height: 12),
        SizedBox(height: 12),
        SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Split shades with null safety
    List<String> shades = item.shadeName.isNotEmpty
        ? item.shadeName.split(',').map((shade) => shade.trim()).toList().cast<String>()
        : [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        title: Text(
          item.styleCode,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: isLargeScreen ? 22 : 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImage(
                    imageUrl: imageUrl,
                    tag: 'fullscreen-${item.styleCode}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
       body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section with Fixed Zoom Box
                Hero(
                  tag: 'fullscreen-${item.styleCode}',
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: ClipRect(
                        child: SizedBox(
                          height: constraints.maxHeight * 0.7,
                          width: double.infinity,
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 1.0,
                            maxScale: 4.0,
                            boundaryMargin: EdgeInsets.zero,
                            constrained: true,
                            child: GestureDetector(
                              onDoubleTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImage(
                                      imageUrl: imageUrl,
                                      tag: 'fullscreen-${item.styleCode}',
                                    ),
                                  ),
                                );
                              },
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Description Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FixedColumnWidth(12),
                      2: FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      // 1. Design
                      TableRow(
                        children: [
                          _buildLabelText('Design'),
                          const Text(':'),
                          Text(
                            item.styleCodeWithcount,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: isLargeScreen ? 18 : 16,
                            ),
                          ),
                        ],
                      ),
                      _buildSpacerRow(),

                      // 2. Brand
                      TableRow(
                        children: [
                          _buildLabelText('Brand'),
                          const Text(':'),
                          Text(
                            item.brandName,
                            style: _valueTextStyle(),
                          ),
                        ],
                      ),
                      _buildSpacerRow(),

                      // 3. Shade
                      if (showShades && shades.isNotEmpty)
                        TableRow(
                          children: [
                            _buildLabelText('Shade'),
                            const Text(':'),
                            Text(
                              shades.join(', '),
                              style: _valueTextStyle(),
                            ),
                          ],
                        ),
                      if (showShades && shades.isNotEmpty) _buildSpacerRow(),

                      // 4. MRP
                      if (showMRP)
                        TableRow(
                          children: [
                            _buildLabelText('MRP'),
                            const Text(':'),
                            Text(
                              item.mrp.toStringAsFixed(2),
                              style: _valueTextStyle(),
                            ),
                          ],
                        ),
                      if (showMRP) _buildSpacerRow(),

                      // 5. WSP
                      if (showWSP)
                        TableRow(
                          children: [
                            _buildLabelText('WSP'),
                            const Text(':'),
                            Text(
                              item.wsp.toStringAsFixed(2),
                              style: _valueTextStyle(),
                            ),
                          ],
                        ),
                      if (showWSP) _buildSpacerRow(),

                      // 6. Size
                      if (item.sizeWithMrp.isNotEmpty && showSizes)
                        TableRow(
                          children: [
                            _buildLabelText('Size'),
                            const Text(':'),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                item.sizeWithMrp,
                                style: _valueTextStyle(),
                              ),
                            ),
                          ],
                        ),
                      if (item.sizeWithMrp.isNotEmpty && showSizes) _buildSpacerRow(),

                      // 7. Product
                      if (showProduct)
                        TableRow(
                          children: [
                            _buildLabelText('Product'),
                            const Text(':'),
                            Text(
                              item.itemName,
                              style: _valueTextStyle(),
                            ),
                          ],
                        ),
                      if (showProduct) _buildSpacerRow(),

                      // 8. Quantity (clqty)
                      TableRow(
                        children: [
                          _buildLabelText('Quantity'),
                          const Text(':'),
                          Text(
                            item.clqty.toString(),
                            style: _valueTextStyle(),
                          ),
                        ],
                      ),
                      _buildSpacerRow(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const FullScreenImage({
    super.key,
    required this.imageUrl,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: SizedBox.expand( // Ensure the content takes up the full screen
          child: Hero(
            tag: tag,
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0, // Initial scale: image fits the screen
              maxScale: 5.0, // Allow zooming up to 5x
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain, // Maintain aspect ratio, fill screen
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}