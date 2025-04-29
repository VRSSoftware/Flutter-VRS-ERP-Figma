import 'dart:io';
import 'dart:ui';
import 'dart:ui' as pw;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:vrs_erp_figma/catalog/filter.dart';
import 'package:vrs_erp_figma/catalog/imagezoom.dart';
import 'package:vrs_erp_figma/catalog/share_option_screen.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/catalog.dart';
import 'package:vrs_erp_figma/models/shade.dart';
import 'package:vrs_erp_figma/models/size.dart';
import 'package:vrs_erp_figma/models/style.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:vrs_erp_figma/services/app_services.dart';

class CatalogPage extends StatefulWidget {
  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String filterOption = 'New Arrival';
  int viewOption = 0;
  List<String> selectedStyles = [];
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
  String fromMRP="";
  String toMRP = "";


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

  // Fetch Catalog Items
  Future<void> _fetchCatalogItems() async {
    try {
      final items = await ApiService.fetchCatalogItem(
        itemSubGrpKey: itemSubGrpKey!,
        itemKey: itemKey!,
        cobr: coBr!,
      //  styleKey: selectedStyles.length==0 ? null : selectedStyles[0],
      shadeKey: selectedShades.length ==0? null : selectedShades.map((s) => s.shadeKey).join(','),
      sizeKey : selectedSize.length == 0 ? null : selectedSize.map((s) => s.itemSizeKey).join(','),
      fromMRP : fromMRP == "" ? null : fromMRP,
      toMRP : toMRP == ""? null : toMRP
      );
      setState(() {
        catalogItems = items;
      });
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
        title: Text('Catalog', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ), // <-- Back icon
          onPressed: () {
            Navigator.pop(context); // <-- Go back to previous screen
          },
        ),
        actions: [
          if (selectedItems.isNotEmpty) // Only show when items are selected
            IconButton(
              icon: Icon(Icons.share, color: Colors.white),
              onPressed: _showShareOptions,
            ),
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
          //     _buildStyleSelection(isLargeScreen),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 16.0 : 8.0,
                vertical: 8.0,
              ),
              child:
                  catalogItems.isEmpty
                      ? Center(child: CircularProgressIndicator())
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

  Widget _buildStyleSelection(bool isLargeScreen) {
    return Container(
      height: isLargeScreen ? 60 : 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: isLargeScreen ? 24 : 8),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: OutlinedButton(
                onPressed: () => setState(() => selectedStyles.clear()),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color:
                        selectedStyles.isEmpty
                            ? AppColors.primaryColor
                            : Colors.grey,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor:
                      selectedStyles.isEmpty
                          ? AppColors.primaryColor
                          : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 20 : 16,
                    vertical: isLargeScreen ? 16 : 12,
                  ),
                ),
                child: Text(
                  'ALL',
                  style: TextStyle(fontSize: isLargeScreen ? 14 : 12),
                ),
              ),
            ),
            ...styles.map((style) {
              bool isSelected = selectedStyles.contains(style.styleCode);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  onPressed:
                      () => setState(() {
                        if (isSelected) {
                          selectedStyles.remove(style.styleCode);
                        } else {
                          selectedStyles.add(style.styleCode);
                        }
                      }),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryColor : Colors.grey,
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor:
                        isSelected ? AppColors.primaryColor : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 20 : 16,
                      vertical: isLargeScreen ? 16 : 12,
                    ),
                  ),
                  child: Text(
                    style.styleCode,
                    style: TextStyle(fontSize: isLargeScreen ? 14 : 12),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
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
          onDoubleTap:
              () => _openImageZoom(
                context,
                item,
              ), // Add double tap to zoom functionality
          child: _buildItemCard(item, isLargeScreen),
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
              child: Stack(
                children: [
                  Padding(
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
                              _buildDetailText(
                                'MRP: ${item.mrp}',
                                isLargeScreen,
                              ),
                              _buildDetailText(
                                'WSP: ${item.wsp}',
                                isLargeScreen,
                              ),
                              _buildDetailText(
                                'Shade: ${item.shadeName}',
                                isLargeScreen,
                              ),
                            ],
                          ),
                        ),
                      ],
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
                ],
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

  Widget _buildItemCard(Catalog item, bool isLargeScreen) {
    bool isSelected = selectedItems.contains(item);

    return GestureDetector(
      onTap: () => _toggleItemSelection(item),
      onLongPress: () => _enableMultiSelect(item),
      onDoubleTap: () => _openImageZoom(context, item),
      child: Card(
        elevation: isSelected ? 8 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                ), // Reduced vertical padding
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

    // if (selectedShades.isNotEmpty) {
    //   filteredItems =
    //       filteredItems.where((item) {
    //         final shades = item.shadeName?.split(',') ?? [];
    //         return shades.any((shade) => selectedShades.contains(shade));
    //       }).toList();
    // }

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
    // Push FilterPage and wait for the selected filters
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FilterPage(),
        settings: RouteSettings(
          // Pass initial data as arguments
          arguments: {
            'itemKey': itemKey,
            'itemSubGrpKey': itemSubGrpKey,
            'coBr': coBr,
            'fcYrId': fcYrId,
            'styles': styles,
            'shades': shades,
            'sizes': sizes,
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

    // Handle the result after returning from the FilterPage
    if (result != null) {
      // The result will contain the selected filter values
      Map<String, dynamic> selectedFilters = result;

      // Example of how to handle the selected filters

      // var selectedShades = selectedFilters['shades'];
      // var selectedShade = selectedFilters['shades'];
      // var selectedSizes = selectedFilters['sizes'];
      // var fromMRP = selectedFilters['fromMRP'];
      // var toMRP = selectedFilters['toMRP'];
      // var fromDate = selectedFilters['fromDate'];
      // var toDate = selectedFilters['toDate'];
      // var shadeKeysString = selectedShades.map((s) => s.shadeKey).join(',');
      // var sizeKeysString = selectedSizes.map((s) => s.itemSizeKey).join(',');
      // print('Selected Styles: ${selectedFilters['styles']}');
      // print('Selected Shades: $selectedShades');
      // print('Selected Sizes: $selectedSizes');
      // print('From MRP: $fromMRP');
      // print('To MRP: $toMRP');
      // print('From Date: $fromDate');
      // print('To Date: $toDate');
      // print('Selected Shades (shadeKey): $shadeKeysString');
      // print('Selected Sizes (itemSizeKey): $sizeKeysString');
      setState(() {
        selectedStyles = selectedFilters['styles'];
      selectedSize =   selectedFilters['sizes'];
      selectedShades = selectedFilters['shades'];
      fromMRP = selectedFilters['fromMRP'];
      toMRP = selectedFilters['toMRP'];

      });

      _fetchCatalogItems();
      // You can now update the UI or make network calls based on the selected filters.
    }
  }

  Future<void> _shareSelectedItems({
    required String shareType,
    bool includeDesign = true,
    bool includeShade = true,
    bool includeRate = true,
    bool includeSize = true,
    bool includeProduct = true,
    bool includeRemark = true,
  }) async {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select items to share')),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Preparing items for sharing...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      final tempDir = await getTemporaryDirectory();
      List<String> filePaths = [];

      for (var item in selectedItems) {
        try {
          final imageUrl = _getImageUrl(item);
          if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
            final response = await http.get(Uri.parse(imageUrl));
            if (response.statusCode == 200) {
              final imageFile = File(
                '${tempDir.path}/share_${item.itemKey}_${DateTime.now().millisecondsSinceEpoch}.jpg',
              );
              await imageFile.writeAsBytes(response.bodyBytes);

              // Build text based on selected options in the new format
              String overlayText = '';
              if (includeProduct) overlayText += 'Product: ${item.itemName}\n';
              if (includeDesign) overlayText += 'Design: ${item.styleCode}\n';
              if (includeShade) overlayText += 'Shade: ${item.shadeName}\n';
              if (includeRate) overlayText += 'Rate: ₹${item.mrp}\n';
              if (includeSize) overlayText += 'Size: ${item.sizeName}\n';
              if (includeRemark && item.remark.isNotEmpty)
                overlayText += 'Remark: ${item.remark}\n';

              final overlayImageFile = await _overlayTextOnImage(
                imageFile,
                overlayText,
              );
              filePaths.add(overlayImageFile.path);
            }
          }
        } catch (e) {
          print('Error downloading image for ${item.itemName}: $e');
        }
      }

      if (filePaths.isNotEmpty) {
        if (shareType == 'pdf') {
          final pdf = pw.Document();
          for (var path in filePaths) {
            final image = pw.MemoryImage(File(path).readAsBytesSync());
            pdf.addPage(
              pw.Page(
                build:
                    (pw.Context context) => pw.Center(child: pw.Image(image)),
              ),
            );
          }
          final pdfFile = File(
            '${tempDir.path}/catalog_${DateTime.now().millisecondsSinceEpoch}.pdf',
          );
          await pdfFile.writeAsBytes(await pdf.save());
          await Share.shareXFiles([
            XFile(pdfFile.path),
          ], subject: 'Catalog Items PDF from VRS ERP');
        } else {
          await Share.shareFiles(
            filePaths,
            subject: 'Catalog Items from VRS ERP',
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No items available to share.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share items: ${e.toString()}')),
      );
    }
  }

  Future<File> _overlayTextOnImage(File imageFile, String fullText) async {
    final image = await decodeImageFromList(imageFile.readAsBytesSync());

    // Split the text into multiple lines based on the image width
    List<String> selectedTexts = [];
    selectedTexts.add("Product Details:");
    selectedTexts.add("${fullText}"); // Or pass dynamic text pieces here

    // Calculate total height needed (image height + text area height)
    double textAreaHeight = 0.0;
    const padding = 10.0;
    const lineHeight = 30.0; // Adjust for line height if needed

    // Create a list of TextPainters to calculate height required by the text
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

    // 1. Draw the original image at the top
    canvas.drawImage(image, Offset(0, 0), Paint());

    // Set text style
    final textBackgroundPaint = Paint()..color = Colors.black.withValues();

    // Calculate positions for text - starting below the image
    double yPos = image.height + padding;
    for (int i = 0; i < textPainters.length; i++) {
      final textPainter = textPainters[i];

      // Draw background box
      final rect = Rect.fromLTWH(
        padding,
        yPos,
        textPainter.width + padding,
        textPainter.height + padding,
      );
      canvas.drawRect(rect, textBackgroundPaint);

      // Draw the text
      textPainter.paint(canvas, Offset(padding + 5, yPos + 5));
      yPos += textPainter.height + lineHeight; // Move to next line position
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

  void _showShareOptions() {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select items to share')),
      );
      return;
    }

    bool includeDesign = true;
    bool includeShade = true;
    bool includeRate = true;
    bool includeSize = true;
    bool includeProduct = true;
    bool includeRemark = true;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ShareOptionsPage(
          onImageShare: () {
            Navigator.pop(context);
            _shareSelectedItems(
              shareType: 'image',
              includeDesign: includeDesign,
              includeShade: includeShade,
              includeRate: includeRate,
              includeSize: includeSize,
              includeProduct: includeProduct,
              includeRemark: includeRemark,
            );
          },
          onPDFShare: () {
            Navigator.pop(context);
            _shareSelectedItems(
              shareType: 'pdf',
              includeDesign: includeDesign,
              includeShade: includeShade,
              includeRate: includeRate,
              includeSize: includeSize,
              includeProduct: includeProduct,
              includeRemark: includeRemark,
            );
          },
          onWeblinkShare: () {
            Navigator.pop(context);
            _shareSelectedItems(shareType: 'pdf');
          },
          onVideoShare: () {
            Navigator.pop(context);
            _shareSelectedItems(shareType: 'pdf');
          },
          onQRCodeShare: () {
            Navigator.pop(context);
            _shareSelectedItems(shareType: 'pdf');
          },
          onToggleOptions: (design, shade, rate, size, product, remark) {
            includeDesign = design;
            includeShade = shade;
            includeRate = rate;
            includeSize = size;
            includeProduct = product;
            includeRemark = remark;
          },
        );
      },
    );
  }
}
