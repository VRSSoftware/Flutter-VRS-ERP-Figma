import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:ui' as pw;
import 'package:auto_size_text/auto_size_text.dart';
// import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:installed_apps/installed_apps.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:vrs_erp_figma/catalog/download_options.dart';
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
import 'package:vrs_erp_figma/widget/bottom_navbar.dart';

class CatalogPage extends StatefulWidget {
  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String filterOption = 'New Arrival';
  int viewOption = 0;
  List<Style> selectedStyles = [];
  List<Shade> selectedShades = [];
  List<Catalog> catalogItems = [];
  List<Style> styles = [];
  List<Shade> shades = [];
  List<Sizes> sizes = [];
  String? itemKey;
  String? itemSubGrpKey;
  String? coBr;
  String? fcYrId;
  List<Catalog> selectedItems = [];
  List<Sizes> selectedSize = [];
  String fromMRP = "";
  String toMRP = "";
  String WSPto = "";
  String WSPfrom = "";
  String? itemNamee;
  bool showWSP = true;
  bool showSizes = true;
  bool showMRP = true;
  bool showShades = true;
  bool isLoading = true;

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
          itemNamee = args['itemName']?.toString();
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

  String toTitleCase(String text) {
    if (text.isEmpty) return text;

    return text
        .toLowerCase()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
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
        title: Text(
          toTitleCase(itemNamee!),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (selectedItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.download, color: Colors.white),
              onPressed: _showDownloadOptions,
            ),
          if (selectedItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.share, color: Colors.white),
              onPressed: _showShareOptions,
            ),
          IconButton(
            icon: Icon(
              viewOption == 0
                  ? CupertinoIcons.square_grid_2x2_fill
                  : viewOption == 1
                  ? CupertinoIcons.list_bullet_below_rectangle
                  : CupertinoIcons.rectangle_expand_vertical,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                viewOption = (viewOption + 1) % 3;
              });
            },
          ),
          // Three-dot menu
          Builder(
            builder:
                (context) => IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Reduced border radius
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ), // Border color
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: StatefulBuilder(
                              builder: (context, setStateDialog) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Options",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildToggleRow("Show MRP", showMRP, (val) {
                                      setState(() => showMRP = val);
                                      setStateDialog(() {});
                                    }),
                                    _buildToggleRow("Show WSP", showWSP, (val) {
                                      setState(() => showWSP = val);
                                      setStateDialog(() {});
                                    }),
                                    _buildToggleRow("Show Sizes", showSizes, (
                                      val,
                                    ) {
                                      setState(() => showSizes = val);
                                      setStateDialog(() {});
                                    }),
                                    _buildToggleRow("Show Shades", showShades, (
                                      val,
                                    ) {
                                      setState(() => showShades = val);
                                      setStateDialog(() {});
                                    }),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        child: Text("Close"),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
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
              child:
                  isLoading
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterDialog,
        backgroundColor: AppColors.primaryColor,
        child: Icon(Icons.filter_alt_outlined, color: Colors.white),

        tooltip: 'Filter',
      ),

      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/home');
          if (index == 1) return;
          if (index == 2) Navigator.pushNamed(context, '/orderbooking');
        },
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

        // Split shades by comma and trim any extra spaces
        List<String> shades =
            item.shadeName.split(',').map((shade) => shade.trim()).toList();

        return GestureDetector(
          onTap: () {
            if (selectedItems.length == 0)
              _openImageZoom(context, item);
            else
              _toggleItemSelection(item);
          },
          onLongPress: () {
            if (selectedItems.length == 0) _toggleItemSelection(item);
          },
          // onTap: () => _toggleItemSelection(item),
          // onLongPress: () => _enableMultiSelect(item),
          // onDoubleTap: () => _openImageZoom(context, item),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
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
                        /// Image section (fixed width)
                        Flexible(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _getImageUrl(item),
                              fit: BoxFit.cover,
                              height: isLargeScreen ? 120 : 100,
                              width: isLargeScreen ? 120 : 100,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/default.png',
                                  fit: BoxFit.cover,
                                  height: isLargeScreen ? 120 : 100,
                                  width: isLargeScreen ? 120 : 100,
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: isLargeScreen ? 16 : 8),

                        /// Details section (remaining width)
                        Flexible(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// Item Name
                              Text(
                                item.styleCode,
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isLargeScreen ? 18 : 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),

                              /// Row 1: Style, MRP, WSP in a single row
                              // Row 1: Style, MRP, WSP in a single row
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Expanded(
                              //       child: _buildDetailText(
                              //         'Style',
                              //         item.styleCode,
                              //         isLargeScreen,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (showMRP)
                                    Expanded(
                                      child: _buildDetailText(
                                        'MRP',
                                        item.mrp.toStringAsFixed(2),
                                        isLargeScreen,
                                      ),
                                    ),
                                  if (showWSP)
                                    Expanded(
                                      child: _buildDetailText(
                                        'WSP',
                                        item.wsp.toStringAsFixed(2),
                                        isLargeScreen,
                                      ),
                                    ),
                                ],
                              ),

                              if (item.sizeName.isNotEmpty && showSizes)
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Size : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        item.sizeDetails,
                                      ), // Data remains normal
                                    ],
                                  ),
                                ),

                              // const SizedBox(height: 4),
                              const SizedBox(height: 4),
                              if (showShades)
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailText(
                                        'Shades',
                                        '',
                                        isLargeScreen,
                                      ),
                                      Text(
                                        shades.join(
                                          ', ',
                                        ), // Join shades with a comma
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 14 : 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
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

        // Split shades by comma and trim any extra spaces
        List<String> shades =
            item.shadeName.split(',').map((shade) => shade.trim()).toList();

        return GestureDetector(
          onTap: () {
            if (selectedItems.length == 0)
              _openImageZoom(context, item);
            else
              _toggleItemSelection(item);
          },
          onLongPress: () {
            if (selectedItems.length == 0) _toggleItemSelection(item);
          },
          // onTap: () => _toggleItemSelection(item),
          // onLongPress: () => _enableMultiSelect(item),
          // onDoubleTap: () => _openImageZoom(context, item),
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
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/default.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Item Name
                          Text(
                            item.styleCode,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: isLargeScreen ? 22 : 18,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),

                          /// Row 2: Style, MRP, WSP
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Expanded(
                              //   child: _buildDetailText(
                              //     'Style', // The label
                              //     item.styleCode, // The value
                              //     isLargeScreen, // The boolean indicating large screen size
                              //   ),
                              // ),
                              if (showMRP)
                                Expanded(
                                  child: _buildDetailText(
                                    'MRP', // The label
                                    item.mrp.toStringAsFixed(
                                      2,
                                    ), // Convert to string if necessary
                                    isLargeScreen, // The boolean indicating large screen size
                                  ),
                                ),
                              if (showWSP)
                                Expanded(
                                  child: _buildDetailText(
                                    'WSP', // The label
                                    item.wsp.toStringAsFixed(
                                      2,
                                    ), // Convert to string if necessary
                                    isLargeScreen, // The boolean indicating large screen size
                                  ),
                                ),
                            ],
                          ),

                          // Add Sizes Row here
                          if (item.sizeName.isNotEmpty && showSizes)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Size : ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(item.sizeDetails), // Data remains normal
                                ],
                              ),
                            ),
                          const SizedBox(height: 4),
                          if (showShades)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailText('Shades', '', isLargeScreen),
                                  Text(
                                    shades.join(
                                      ', ',
                                    ), // Join shades with a comma
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 14 : 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
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

  Widget _buildDetailText(String label, String value, bool isLargeScreen) {
    return AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
      maxLines: 1,
      minFontSize: 10,
      style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
      overflow: TextOverflow.ellipsis,
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
    List<String> shades =
        item.shadeName.split(',').map((s) => s.trim()).toList();

    return GestureDetector(
      // onTap: () => _toggleItemSelection(item),
      // onLongPress: () => _enableMultiSelect(item),
      // onDoubleTap: () => _openImageZoom(context, item),
      onTap: () {
        if (selectedItems.length == 0)
          _openImageZoom(context, item);
        else
          _toggleItemSelection(item);
      },
      onLongPress: () {
        if (selectedItems.length == 0) _toggleItemSelection(item);
      },

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
                    fit: BoxFit.cover, // Fits width and crops height
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 140,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: Image.asset(
                          'assets/images/default.png',
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),

                // Info section
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 12 : 10,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.styleCode,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          fontSize: isLargeScreen ? 18 : 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (showMRP)
                            Expanded(
                              child: _buildDetailText(
                                'MRP',
                                item.mrp.toStringAsFixed(2),
                                isLargeScreen,
                              ),
                            ),
                          if (showWSP)
                            Expanded(
                              child: _buildDetailText(
                                'WSP',
                                item.wsp.toStringAsFixed(2),
                                isLargeScreen,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      if (item.sizeName.isNotEmpty && showSizes)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Size : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(item.sizeDetails), // Data remains normal
                            ],
                          ),
                        ),

                      const SizedBox(height: 4),
                      if (showShades)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shade : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(shades.join(', ')), // Data remains normal
                            ],
                          ),
                        ),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     _buildDetailText('Shades', '', isLargeScreen),
                      //     Flexible(
                      //       child: Text(
                      //         shades.join(', '),
                      //         style: TextStyle(
                      //           fontSize: isLargeScreen ? 14 : 13,
                      //           color: Colors.grey[700],
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ],
            ),

            // Checkmark if selected
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

  Widget _buildFilterButton(String label, bool isLargeScreen) {
    return OutlinedButton(
      onPressed: () => setState(() => filterOption = label),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: filterOption == label ? AppColors.primaryColor : Colors.grey,
        ),
        backgroundColor: Colors.white,
        foregroundColor:
            filterOption == label ? AppColors.primaryColor : Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(
          vertical: isLargeScreen ? 16 : 12,
          horizontal: isLargeScreen ? 24 : 16,
        ),
      ),
      child: Text(label, style: TextStyle(fontSize: isLargeScreen ? 16 : 14)),
    );
  }

  List<Catalog> _getFilteredItems() {
    var filteredItems = catalogItems;

    // if (selectedStyles.isNotEmpty) {
    //   filteredItems =
    //       filteredItems
    //           .where((item) => selectedStyles.contains(item.styleCode))
    //           .toList();
    // }

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
            'selectedStyles': selectedStyles,
            'fromMRP': fromMRP,
            'toMRP': toMRP,
            'WSPfrom': WSPfrom,
            'WSPto': WSPto,
          },
        ),
        transitionDuration: Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: animation,
            alignment: Alignment.bottomRight, // Open from bottom right corner
            child: FadeTransition(opacity: animation, child: child),
          );
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
        //selectedStyles = selectedFilters['selectedStyles'];
        selectedStyles = selectedFilters['styles'];
        selectedSize = selectedFilters['sizes'];
        selectedShades = selectedFilters['shades'];
        fromMRP = selectedFilters['fromMRP'];
        toMRP = selectedFilters['toMRP'];
        WSPfrom = selectedFilters['WSPfrom'];
        WSPto = selectedFilters['WSPto'];
      });
      print("aaaaaaaa  ${selectedFilters['styles']}");
      print("aaaaaaaa  ${selectedFilters['WSPfrom']}");
      print("aaaaaaaa  ${selectedFilters['WSPto']}");
      if (!(selectedStyles.length == 0 &&
          selectedSize.length == 0 &&
          selectedShades == 0 &&
          fromMRP == "" &&
          toMRP == "" &&
          WSPfrom == "" &&
          WSPto == ""))
        _fetchCatalogItems();
    }
  }

  Future<void> _shareSelectedItemsPDF({
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
              Text('Generating PDF from server...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final apiUrl = '${AppConstants.BASE_URL}/pdf/generate';
      List<Map<String, dynamic>> catalogItems = [];

      for (var item in selectedItems) {
        Map<String, dynamic> catalogItem = {};
        catalogItem['fullImagePath'] = item.fullImagePath;
        if (includeDesign) catalogItem['design'] = item.itemName;
        if (includeShade) catalogItem['shade'] = item.shadeName;
        if (includeRate) catalogItem['rate'] = item.mrp.toString();
        if (includeSize) catalogItem['sizeDetails'] = item.sizeDetails;
        if (includeProduct) catalogItem['product'] = item.itemName;
        if (includeRemark) catalogItem['remark'] = item.remark;

        catalogItems.add(catalogItem);
      }
      // Prepare request body
      final requestBody = {
        "company": "VRS Software",
        "createdBy": "admin",
        "mobile": "",
        "catalogItems": catalogItems,
      };
      print("ssssssss");
      print(selectedItems.map((item) => item.itemKey).toList());
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print("ddddddddddddddddd");
        final file = File(
          '${tempDir.path}/catalog_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles([
          XFile(file.path),
        ], subject: 'Catalog PDF from VRS ERP');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share items: ${e.toString()}')),
      );
    }
  }

  Future<void> _shareSelectedWhatsApp({
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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Row(
      //       children: [
      //         CircularProgressIndicator(),
      //         SizedBox(width: 16),
      //         Text('Sending to WhatsApp...'),
      //       ],
      //     ),
      //     duration: Duration(seconds: 3),
      //   ),
      // );

      // Show the dialog to enter the mobile number
      String mobileNo = await _showMobileNumberDialog();

      // Proceed only if a valid mobile number is entered
      if (mobileNo.isNotEmpty) {
        // Loop through selected items and send each one
        for (var item in selectedItems) {
          final response = await http.get(
            Uri.parse('${AppConstants.BASE_URL}/images${item.fullImagePath}'),
          );

          // Check if the request was successful
          if (response.statusCode == 200) {
            // Convert the image to bytes
            final imageBytes = response.bodyBytes;

            // Format the caption dynamically for each item
            String caption = '';

            if (includeDesign) caption += '*Design*\t\t: ${item.styleCode}\n';
            if (includeShade) caption += '*Shade*\t\t: ${item.shadeName}\n';
            if (includeRate) caption += '*MRP*\t\t\t: ${item.mrp.toString()}\n';
            if (includeSize)
              caption += '*Sizes*\t\t\t: ${formatSizes(item.sizeDetails)}\n';
            if (includeProduct) caption += '*Product*\t: ${item.itemName}\n';
            if (includeRemark) caption += '*Remark*\t\t: ${item.remark}\n';

            // Convert the image to Base64
            String imageBase64 = base64Encode(imageBytes);

            // Send the image as a file
            bool result = await sendWhatsAppFile(
              fileBytes: imageBytes,
              mobileNo:
                  mobileNo, // Use the mobile number obtained from the dialog
              fileType: 'image',
              caption: caption,
            );

            if (result) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Images sent successfully...')),
              );
              setState(() {
                selectedItems = [];
              });
              print("Image for ${item.itemName} sent successfully.");
            } else {
              print("Failed to send the image for ${item.itemName}.");
            }
          } else {
            print(
              "Failed to download the image for ${item.itemName}. Status Code: ${response.statusCode}",
            );
          }
        }
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share items: ${e.toString()}')),
      );
    }
  }

  Future<String> _showMobileNumberDialog() async {
    TextEditingController controller = TextEditingController();

    // Show the dialog and return the value from Navigator.pop
    String mobileNo =
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text('Enter Mobile Number'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      hintText: 'Enter a 10-digit mobile number',
                    ),
                    autofocus: true, // Open the keyboard automatically
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please enter a 10-digit mobile number.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop(''); // Return empty string on cancel
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    String inputMobileNo = controller.text.trim();
                    if (inputMobileNo.length == 10 &&
                        int.tryParse(inputMobileNo) != null) {
                      Navigator.of(
                        context,
                      ).pop(inputMobileNo); // Return valid mobile number
                    } else {
                      // Show validation message if not valid
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please enter a valid 10-digit mobile number',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        ) ??
        ''; // Default to empty string if dialog is dismissed or cancelled

    return mobileNo;
  }

  String formatSizes(String input) {
    // Regular expression to match the size (any word before the opening parenthesis)
    RegExp regExp = RegExp(r'(\w+)(?=\s?\()');

    // Replace each match (size) with *size*
    return input.replaceAllMapped(regExp, (match) {
      return '*${match.group(0)}*'; // Add * before and after the size
    });
  }

  Future<bool> sendWhatsAppFile({
    required List<int> fileBytes,
    required String mobileNo,
    required String fileType,
    String? caption,
  }) async {
    try {
      String fileBase64 = base64Encode(fileBytes);

      final response = await http.post(
        Uri.parse("http://node4.wabapi.com/v4/postfile.php"),
        body: {
          'data': fileBase64,
          'filename': fileType == 'image' ? 'catalog.jpg' : 'catalog.pdf',
          'key': AppConstants.whatsappKey,
          'number': '91$mobileNo', // Add country code before mobile number
          'caption': caption ?? 'Please find the file attached.',
        },
      );

      if (response.statusCode == 200) {
        // Successfully sent
        print('File sent successfully');
        return true;
      } else {
        print('Failed to send file');
        return false;
      }
    } catch (e) {
      print('Error sending file: $e');
      return false;
    }
  }

  // Future<void> _shareSelectedWhatsApp({
  //   required String shareType,
  //   bool includeDesign = true,
  //   bool includeShade = true,
  //   bool includeRate = true,
  //   bool includeSize = true,
  //   bool includeProduct = true,
  //   bool includeRemark = true,
  // }) async {
  //   if (selectedItems.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select items to share')),
  //     );
  //     return;
  //   }

  //   try {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Row(
  //           children: [
  //             CircularProgressIndicator(),
  //             SizedBox(width: 16),
  //             Text('Sending to WhatsApp...'),
  //           ],
  //         ),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );

  //     // List<Map<String, dynamic>> catalogItems = [];

  //     // for (var item in selectedItems) {
  //     //   Map<String, dynamic> catalogItem = {};
  //     //   catalogItem['fullImagePath'] = item.fullImagePath;
  //     //   if (includeDesign)
  //     //     catalogItem['design'] = item.itemName; // Or design related to item
  //     //   if (includeShade) catalogItem['shade'] = item.shadeName;
  //     //   if (includeRate) catalogItem['rate'] = item.mrp.toString();
  //     //   if (includeSize)
  //     //     catalogItem['size'] =
  //     //         item.sizeName; // You can modify this to combine size details if needed
  //     //   if (includeProduct)
  //     //     catalogItem['product'] =
  //     //         item.itemName; // Or any other field representing product
  //     //   if (includeRemark) catalogItem['remark'] = item.remark;

  //     //   catalogItems.add(catalogItem);
  //     // }
  //     if (Platform.isAndroid) //return false; // Only supported on Android
  //     {
  //       bool? appIsInstalled = await InstalledApps.isAppInstalled(
  //         'com.whatsapp',
  //       );
  //       bool isInstalled = false;

  //       //await DeviceApps.isAppInstalled('com.whatsapp');

  //       // If you want to check for WhatsApp Business as well:
  //       // bool isBusinessInstalled = await DeviceApps.isAppInstalled('com.whatsapp.w4b');

  //       print("appIsInstalledddddddddddddd");
  //       print(appIsInstalled);
  //       String imageUrl = '${AppConstants.BASE_URL}/images${selectedItems[0].fullImagePath}';
  //       final response = await http.get(Uri.parse(imageUrl));
  //       if (response.statusCode != 200) {
  //         throw Exception('Failed to download image');
  //       }

  //       // 2. Get external directory for file access
  //       final tempDir = await getExternalStorageDirectory();
  //       final file = File('${tempDir!.path}/shared_image.jpg');

  //       // 3. Write image bytes to file
  //       await file.writeAsBytes(response.bodyBytes);

  //       // 4. Share via platform channel
  //       const platform = MethodChannel('com.whatsapp');

  //       if (selectedItems.length == 1) {
  //         await platform.invokeMethod('shareToWhatsApp', {
  //           'imagePath': file.path,
  //           // 'caption': '*Style*\t\t: ${selectedItems[0].styleCode} \n*Sizes*\t\t: ${selectedItems[0].sizeDetails}',
  //           'caption': '*Design*\t\t\t: ${selectedItems[0].styleCode}'+
  //                       '\n*Shade*\t\t\t: ${selectedItems[0].shadeName}'+
  //                       '\n*MRP*\t\t\t\t: ${selectedItems[0].mrp.toString()}'+
  //                       '\n*Sizes*\t\t\t\t: ${selectedItems[0].sizeDetails}'+
  //                       '\n*Product*\t\t: ${selectedItems[0].itemName} '+
  //                       '\n*Remark*\t\t\t: ${selectedItems[0].remark}' ,

  //           // 'test' : 'test1'
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to share items: ${e.toString()}')),
  //     );
  //   }
  // }

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

      // Prepare request data
      final List<Map<String, String>> catalogItems =
          selectedItems.map((item) {
            return {
              'fullImagePath': _getImageUrl(item),
              'design': includeDesign ? item.styleCode : '',
              'shade': includeShade ? item.shadeName : '',
              'rate': includeRate ? item.mrp.toString() : '',
              'size': includeSize ? item.sizeDetails : '',
              'product': includeProduct ? item.itemName : '',
              'remark': includeRemark ? item.remark : '',
            };
          }).toList();

      // Call backend API
      final response = await http.post(
        Uri.parse('${AppConstants.BASE_URL}/image/generate-and-share'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'catalogItems': catalogItems,
          'includeDesign': includeDesign,
          'includeShade': includeShade,
          'includeRate': includeRate,
          'includeSize': includeSize,
          'includeProduct': includeProduct,
          'includeRemark': includeRemark,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        final tempDir = await getTemporaryDirectory();
        List<String> filePaths = [];

        for (var imageData in responseData) {
          try {
            final imageBytes = base64Decode(imageData['image']);
            final file = File(
              '${tempDir.path}/share_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
            await file.writeAsBytes(imageBytes);
            filePaths.add(file.path);
          } catch (e) {
            print('Error saving image: $e');
          }
        }

        if (filePaths.isNotEmpty) {
          await Share.shareFiles(
            filePaths,
            //subject: 'Catalog Items from VRS ERP',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Items shared successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No valid images to share')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate images: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share items: ${e.toString()}')),
      );
      print('Error in _shareSelectedItems: $e');
    }
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
          onWhatsAppShare: () {
            Navigator.pop(context);
            _shareSelectedWhatsApp(
              shareType: 'WhatsApp',
              includeDesign: includeDesign,
              includeShade: includeShade,
              includeRate: includeRate,
              includeSize: includeSize,
              includeProduct: includeProduct,
              includeRemark: includeRemark,
            );
          },
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
            _shareSelectedItemsPDF(
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
            //  Navigator.pop(context);
            //  _shareSelectedItems(shareType: 'image');
          },
          onVideoShare: () {
            //  Navigator.pop(context);
            //  _shareSelectedItems(shareType: 'image');
          },
          onQRCodeShare: () {
            //  Navigator.pop(context);
            //   _shareSelectedItems(shareType: 'image');
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

  // Add these methods to your _CatalogPageState class
  Future<void> _handleDownloadOption(
    String option, {
    bool includeDesign = true,
    bool includeShade = true,
    bool includeRate = true,
    bool includeSize = true,
    bool includeProduct = true,
    bool includeRemark = true,
  }) async {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select items to download')),
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
              Text('Preparing download...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final now = DateTime.now();
      final timestamp =
          '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}';

      if (option == 'pdf') {
        // Keep the existing PDF logic unchanged
        final apiUrl = '${AppConstants.BASE_URL}/pdf/generate';
        List<Map<String, dynamic>> catalogItems = [];

        for (var item in selectedItems) {
          Map<String, dynamic> catalogItem = {};
          catalogItem['fullImagePath'] = item.fullImagePath;
          if (includeDesign) catalogItem['design'] = item.styleCode;
          if (includeShade) catalogItem['shade'] = item.shadeName;
          // if (includeRate) {
          //   catalogItem['mrp'] = item.mrp.toString();
          //   catalogItem['wsp'] = item.wsp.toString();
          // }
          if (includeRate) catalogItem['rate'] = item.mrp;
          if (includeSize) catalogItem['sizeDetails'] = item.sizeDetails;
          if (includeProduct) catalogItem['product'] = item.itemName;
          if (includeRemark) catalogItem['remark'] = item.remark;

          catalogItems.add(catalogItem);
        }

        final requestBody = {
          "company": "VRS Software",
          "createdBy": "admin",
          "mobile": "",
          "catalogItems": catalogItems,
        };

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final pdfFile = File('${downloadsDir?.path}/catalog_$timestamp.pdf');
          await pdfFile.writeAsBytes(response.bodyBytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF downloaded to ${pdfFile.path}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to generate PDF: ${response.statusCode}'),
            ),
          );
        }
      } else if (option == 'image') {
        // Use the API approach from _shareSelectedItems
        final List<Map<String, String>> catalogItems =
            selectedItems.map((item) {
              return {
                'fullImagePath': _getImageUrl(item),
                'design': includeDesign ? item.styleCode : '',
                'shade': includeShade ? item.shadeName : '',
                'rate': includeRate ? item.mrp.toString() : '',
                'size': includeSize ? item.sizeDetails : '',
                'product': includeProduct ? item.itemName : '',
                'remark': includeRemark ? item.remark : '',
              };
            }).toList();

        // Call the image generation API
        final response = await http.post(
          Uri.parse('${AppConstants.BASE_URL}/image/generate-and-share'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'catalogItems': catalogItems,
            'includeDesign': includeDesign,
            'includeShade': includeShade,
            'includeRate': includeRate,
            'includeSize': includeSize,
            'includeProduct': includeProduct,
            'includeRemark': includeRemark,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body) as List;
          int count = 1;
          int successCount = 0;

          for (var imageData in responseData) {
            try {
              final imageBytes = base64Decode(imageData['image']);
              final item = selectedItems[count - 1];
              final finalFile = File(
                '${downloadsDir?.path}/catalog_${item.styleCode}_${count}_$timestamp.jpg',
              );
              await finalFile.writeAsBytes(imageBytes);
              successCount++;
              count++;
            } catch (e) {
              print('Error saving image: $e');
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$successCount images downloaded to Downloads folder',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to generate images: ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: ${e.toString()}')),
      );
    }
  }

  void _showDownloadOptions() {
    // No need to provide initial options - they'll default to false
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DownloadOptionsSheet(
          onDownload: (type, selectedOptions) {
            _handleDownloadOption(
              type,
              includeDesign: selectedOptions['design'] ?? false,
              includeShade: selectedOptions['shade'] ?? false,
              includeRate: selectedOptions['rate'] ?? false,
              includeSize: selectedOptions['size'] ?? false,
              includeProduct: selectedOptions['product'] ?? false,
              includeRemark: selectedOptions['remark'] ?? false,
            );
          },
        );
      },
    );
  }

  Widget _buildToggleRow(String title, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), Switch(value: value, onChanged: onChanged)],
    );
  }
}
