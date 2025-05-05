import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vrs_erp_figma/catalog/filter.dart';
import 'package:vrs_erp_figma/catalog/imagezoom.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/catalog.dart';
import 'package:vrs_erp_figma/models/shade.dart';
import 'package:vrs_erp_figma/models/size.dart';
import 'package:vrs_erp_figma/models/style.dart';

import 'package:vrs_erp_figma/services/app_services.dart';
import 'package:vrs_erp_figma/widget/booknowwidget.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int viewOption = 0;
  List<Style> selectedStyles = [];
  List<Shade> selectedShades = [];
  List<Sizes> selectedSize = [];
  List<Catalog> catalogItems = [];
  List<Style> styles = [];
  List<Shade> shades = [];
  List<Sizes> sizes = [];
  String? itemKey;
  String? itemSubGrpKey;
  String? coBr;
  String? fcYrId;
  List<Catalog> selectedItems = [];
  String fromMRP = "";
  String toMRP = "";
  String WSPfrom = "";
  String WSPto = "";
  bool isLoading = true;
  List<String> addedItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        setState(() {
          itemKey = args['itemKey']?.toString();
          itemSubGrpKey = args['itemSubGrpKey']?.toString();
          coBr = args['coBr']?.toString();
          fcYrId = args['fcYrId']?.toString();
        });

        if (coBr != null && fcYrId != null) {
          _fetchAddedItems(coBr!, fcYrId!);
        }

        // Only fetch catalog items after setting the arguments
        if (itemSubGrpKey != null && itemKey != null && coBr != null) {
          _fetchCatalogItems();
        }

        if (itemKey != null) {
          _fetchStylesByItemKey(itemKey!);
          _fetchShadesByItemKey(itemKey!);
          _fetchStylesSizeByItemKey(itemKey!);
        }
      }
    });
  }

  Future<void> _fetchAddedItems(String coBrId, String userId) async {
    try {
      final barcode = ''; // Replace with the actual barcode value if available
      final addedItemsList = await ApiService.fetchAddedItems(
        coBrId: coBrId,
        userId: userId,
        fcYrId: fcYrId!,
        barcode: barcode,
      );
      setState(() {
        addedItems = addedItemsList; // Store the fetched added items
      });
      print("abcddddddddddddddddddddd");
      print(addedItems);
    } catch (e) {
      print('Failed to fetch added items: $e');
    }
  }

  // Fetch Catalog Items
  Future<void> _fetchCatalogItems() async {
    try {
      setState(() {
        catalogItems = [];
        isLoading = true;
      });
      // final items = await ApiService.fetchCatalogItem(
      final result = await ApiService.fetchCatalogItem(
        itemSubGrpKey: itemSubGrpKey!,
        itemKey: itemKey!,
        cobr: coBr!,
        styleKey:
            selectedStyles.length == 1 ? selectedStyles[0].styleKey : null,
        shadeKey:
            selectedShades.length == 0
                ? null
                : selectedShades.map((s) => s.shadeKey).join(','),
        sizeKey:
            selectedSize.length == 0
                ? null
                : selectedSize.map((s) => s.itemSizeKey).join(','),
        fromMRP: fromMRP == "" ? null : fromMRP,
        toMRP: toMRP == "" ? null : toMRP,
      );

      int status = result["statusCode"];
      if(status == 200)
        setState(() {
          isLoading = false;
        });
      
      final items = result["catalogs"];

      if (selectedStyles.isEmpty && WSPfrom == "" && WSPto == "") {
        setState(() {
          catalogItems = items;
        });
      } else {
        final selectedStyleKeys =
            selectedStyles.map((style) => style.styleKey).toSet();

        List<Catalog> filtredCatlogs =
            items
                .where(
                  (catalog) => selectedStyleKeys.contains(catalog.styleKey),
                )
                .toList();
        if (WSPfrom == "" && WSPto == "") {
          setState(() {
            catalogItems = filtredCatlogs;
          });
        } else {
          double? wspFrom = double.tryParse(WSPfrom);
          double? wspTo = double.tryParse(WSPto);

          List<Catalog> wspFilteredCatalogs = filtredCatlogs;

          if (wspFrom != null && wspTo != null) {
            wspFilteredCatalogs =
                wspFilteredCatalogs
                    .where(
                      (catalog) =>
                          catalog.wsp >= wspFrom && catalog.wsp <= wspTo,
                    )
                    .toList();
          } else if (wspFrom != null) {
            wspFilteredCatalogs =
                wspFilteredCatalogs
                    .where((catalog) => catalog.wsp >= wspFrom)
                    .toList();
          } else if (wspTo != null) {
            wspFilteredCatalogs =
                wspFilteredCatalogs
                    .where((catalog) => catalog.wsp <= wspTo)
                    .toList();
          }

          setState(() {
            catalogItems = wspFilteredCatalogs;
          });
        }
      }
    } catch (e) {
      print('Failed to load catalog items: $e');
    }
  }

  // Fetch Styles by Item Key
  Future<void> _fetchStylesByItemKey(String itemKey) async {
    try {
      final fetchedStyles = await ApiService.fetchStylesByItemKey(itemKey);
      setState(() {
        styles = fetchedStyles;
      });
    } catch (e) {
      print('Failed to load styles: $e');
    }
  }

  Future<void> _fetchShadesByItemKey(String itemKey) async {
    try {
      final fetchedShades = await ApiService.fetchShadesByItemKey(itemKey);
      setState(() {
        shades = fetchedShades;
      });
    } catch (e) {
      print('Failed to load shades: $e');
    }
  }

  // Fetch Style Sizes by Item Key
  Future<void> _fetchStylesSizeByItemKey(String itemKey) async {
    try {
      final fetchedSizes = await ApiService.fetchStylesSizeByItemKey(itemKey);
      setState(() {
        sizes = fetchedSizes;
      });
    } catch (e) {
      print('Failed to load sizes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Order Book', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // Cart icon
          IconButton(
            icon: const Icon(
              CupertinoIcons.cart_badge_plus,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/viewOrder');
            },
          ),

          // View option toggle icon
          IconButton(
            icon: Icon(
              viewOption == 0
                  ? Icons.grid_on
                  : viewOption == 1
                  ? Icons.view_list
                  : Icons.expand,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                viewOption = (viewOption + 1) % 3;
              });
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 16.0 : 8.0,
                vertical: 8.0,
              ),
              child:isLoading
                      ? Center(child: CircularProgressIndicator()) : 
                      catalogItems.isEmpty ? Center(child: Text("No Item Available"),) 
                      : LayoutBuilder(
                        builder: (context, constraints) {
                          if (viewOption == 0) {
                            return _buildGridView(
                              constraints,
                              isLargeScreen,
                              isPortrait,
                            );
                          } else if (viewOption == 1) {
                            return _buildListView(constraints, isLargeScreen);
                          }
                          return _buildExpandedView(isLargeScreen);
                        },
                      ),
            ),
          ),
          _buildBottomButtons(isLargeScreen),
        ],
      ),
    );
  }

  Widget _buildGridView(
    BoxConstraints constraints,
    bool isLargeScreen,
    bool isPortrait,
  ) {
    final filteredItems = _getFilteredItems();
    final crossAxisCount =
        isPortrait
            ? (isLargeScreen ? 3 : 2)
            : (constraints.maxWidth ~/ 300).clamp(3, 4);

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filteredItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isLargeScreen ? 14.0 : 8.0,
        mainAxisSpacing: isLargeScreen ? 1.0 : 8.0,
        childAspectRatio: _getChildAspectRatio(constraints, isLargeScreen),
      ),
      itemBuilder: (context, index) {
        final item = filteredItems[index];

        return GestureDetector(
          onDoubleTap: () => _openImageZoom(context, item),
          child: _buildItemCard(item, isLargeScreen, addedItems),
        );
      },
    );
  }

  double _getChildAspectRatio(BoxConstraints constraints, bool isLargeScreen) {
    if (constraints.maxWidth > 1000) return 0.75;
    if (constraints.maxWidth > 600) return 0.7;
    return 0.65;
  }

  Widget _buildListView(BoxConstraints constraints, bool isLargeScreen) {
    final filteredItems = _getFilteredItems();
    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        bool isSelected = selectedItems.contains(item);

        return GestureDetector(
          onTap: () => _toggleItemSelection(item),
          onLongPress: () => _enableMultiSelect(item),
          onDoubleTap: () => _openImageZoom(context, item),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Card(
              elevation: isSelected ? 8 : 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isSelected ? Colors.blue.shade50 : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(isLargeScreen ? 12.0 : 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _getImageUrl(item),
                          fit: BoxFit.cover,
                          height: isLargeScreen ? 120 : 100,
                          width: isLargeScreen ? 120 : 100,
                        ),
                      ),
                    ),
                    SizedBox(width: isLargeScreen ? 16 : 8),
                    Flexible(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.itemName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isLargeScreen ? 18 : 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          _buildDetailText(
                            'Style: ${item.styleCode}',
                            isLargeScreen,
                          ),
                          _buildDetailText('MRP: ${item.mrp}', isLargeScreen),
                          _buildDetailText('WSP: ${item.wsp}', isLargeScreen),
                          _buildDetailText(
                            'Shade: ${item.shadeName}',
                            isLargeScreen,
                          ),
                          SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              onPressed:
                                  () => _showBookingDialog(context, item),
                              child: Text(
                                'BOOK NOW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isLargeScreen ? 14 : 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedView(bool isLargeScreen) {
    final filteredItems = _getFilteredItems();
    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        bool isSelected = selectedItems.contains(item);

        return GestureDetector(
          onTap: () => _toggleItemSelection(item),
          onLongPress: () => _enableMultiSelect(item),
          onDoubleTap: () => _openImageZoom(context, item),
          child: Card(
            elevation: isSelected ? 8 : 4,
            margin: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: isLargeScreen ? 16 : 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: isSelected ? Colors.blue.shade50 : Colors.white,
            child: Stack(
              children: [
                Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 5 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _getImageUrl(item),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isLargeScreen ? 24 : 20,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildDetailText(
                            'Style: ${item.styleCode}',
                            isLargeScreen,
                          ),
                          _buildDetailText('MRP: ${item.mrp}', isLargeScreen),
                          _buildDetailText('WSP: ${item.wsp}', isLargeScreen),
                          _buildDetailText(
                            'Shade: ${item.shadeName}',
                            isLargeScreen,
                          ),
                          SizedBox(height: 12),

                          // 👇 BOOK NOW Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              onPressed:
                                  () => _showBookingDialog(context, item),
                              child: Text(
                                'BOOK NOW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isLargeScreen ? 14 : 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailText(String text, bool isLargeScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isLargeScreen ? 16 : 14,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  void _openImageZoom(BuildContext context, Catalog item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageZoomScreen(imageUrl: _getImageUrl(item)),
      ),
    );
  }

  Widget _buildItemCard(
    Catalog item,
    bool isLargeScreen,
    List<String> addedItems,
  ) {
    bool isSelected = selectedItems.contains(item);

    return GestureDetector(
      onTap: () => _toggleItemSelection(item),
      onLongPress: () => _enableMultiSelect(item),
      onDoubleTap: () => _openImageZoom(context, item),
      child: Card(
        elevation: isSelected ? 8 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 68,
                  ), // Added space for the button
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight - 18, // Avoid overflow
                    ),
                    child: SingleChildScrollView(
                      // Wrap Column in SingleChildScrollView for scrolling
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.network(
                              _getImageUrl(item),
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 140,
                                  width: double.infinity,
                                  color: Colors.grey.shade300,
                                  child: const Center(child: Icon(Icons.error)),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(isLargeScreen ? 10 : 8),
                            child: Text(
                              item.styleCode,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isLargeScreen ? 16 : 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              item.itemName,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 14 : 13,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'MRP ₹${item.mrp}  WSP ₹${item.wsp}',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 13 : 12,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 3,
                  left: 8,
                  right: 8,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        addedItems.contains(item.styleCode)
                            ? Colors.green
                            : AppColors.primaryColor,
                      ),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed:
                        addedItems.contains(item.styleCode)
                            ? null
                            : () => _showBookingDialog(context, item),
                    child: Text(
                      addedItems.contains(item.styleCode)
                          ? 'Added'
                          : 'BOOK NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLargeScreen ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomButtons(bool isLargeScreen) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 24 : 12,
          vertical: 12,
        ),
        color: Colors.white,
        child:
            isLargeScreen
                ? Row(children: _buildButtonChildren(isLargeScreen))
                : Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildButtonChildren(isLargeScreen),
                ),
      ),
    );
  }

  List<Widget> _buildButtonChildren(bool isLargeScreen) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showFilterDialog,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primaryColor),
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 24 : 16,
                  vertical: 12,
                ),
              ),
              icon: Icon(Icons.filter_list, size: isLargeScreen ? 24 : 20),
              label: Text(
                'Filter',
                style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Catalog> _getFilteredItems() {
    var filteredItems = catalogItems;

    if (selectedStyles.isNotEmpty) {
      filteredItems =
          filteredItems
              .where((item) => selectedStyles.contains(item.styleCode))
              .toList();
    }

    return filteredItems;
  }

  String _getImageUrl(Catalog catalog) {
    if (catalog.fullImagePath.startsWith('http')) {
      return catalog.fullImagePath;
    }
    final imageName = catalog.fullImagePath.split('/').last.split('?').first;
    return '${AppConstants.BASE_URL}/images/$imageName';
  }

  void _showFilterDialog() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FilterPage(),
        settings: RouteSettings(
          arguments: {
            'itemKey': itemKey,
            'itemSubGrpKey': itemSubGrpKey,
            'coBr': coBr,
            'fcYrId': fcYrId,
            'styles': styles,
            'shades': shades,
            'sizes': sizes,
            'selectedShades': selectedShades,
            'selectedSizes': selectedSize,
            'fromMRP': fromMRP,
            'toMRP': toMRP,
          },
        ),
        transitionDuration: Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final begin = Offset(0.0, 1.0);
          final end = Offset.zero;
          final curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );

    if (result != null) {
      Map<String, dynamic> selectedFilters = result;

      setState(() {
        selectedStyles = selectedFilters['styles'];
        selectedSize = selectedFilters['sizes'];
        selectedShades = selectedFilters['shades'];
        fromMRP = selectedFilters['fromMRP'];
        toMRP = selectedFilters['toMRP'];
      });

      _fetchCatalogItems();
    }
  }

  Future<File> _overlayTextOnImage(File imageFile, String fullText) async {
    final image = await decodeImageFromList(imageFile.readAsBytesSync());

    List<String> selectedTexts = [];
    selectedTexts.add("Product Details:");
    selectedTexts.add("${fullText}");

    double textAreaHeight = 0.0;
    const padding = 10.0;
    const lineHeight = 30.0;

    List<TextPainter> textPainters = [];
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    for (String text in selectedTexts) {
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: null,
      );
      textPainter.layout(minWidth: 0, maxWidth: image.width - 2 * padding);
      textPainters.add(textPainter);
      textAreaHeight += textPainter.height + lineHeight;
    }

    double totalHeight = image.height.toDouble() + textAreaHeight;

    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(
      pictureRecorder,
      Rect.fromPoints(
        Offset(0, 0),
        Offset(image.width.toDouble(), totalHeight),
      ),
    );

    canvas.drawImage(image, Offset(0, 0), Paint());

    final textBackgroundPaint = Paint()..color = Colors.black.withValues();

    double yPos = image.height + padding;
    for (int i = 0; i < textPainters.length; i++) {
      final textPainter = textPainters[i];

      final rect = Rect.fromLTWH(
        padding,
        yPos,
        textPainter.width + padding,
        textPainter.height + padding,
      );
      canvas.drawRect(rect, textBackgroundPaint);

      textPainter.paint(canvas, Offset(padding + 5, yPos + 5));
      yPos += textPainter.height + lineHeight;
    }

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(image.width, totalHeight.toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    final outputFile = File(
      '${(await getTemporaryDirectory()).path}/image_with_text_below.png',
    );
    await outputFile.writeAsBytes(buffer);

    return outputFile;
  }

  void _toggleItemSelection(Catalog item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
    });
  }

  void _enableMultiSelect(Catalog item) {
    setState(() {
      if (!selectedItems.contains(item)) {
        selectedItems.add(item);
      }
    });
  }

  void _showBookingDialog(BuildContext context, Catalog item) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: EdgeInsets.all(16),
            child: CatalogBookingTable(
              itemSubGrpKey: item.itemSubGrpKey.toString() ?? '',
              itemKey: item.itemKey.toString() ?? '',
              styleKey: item.styleKey.toString() ?? '',
            ),
          ),
    );
  }
}
