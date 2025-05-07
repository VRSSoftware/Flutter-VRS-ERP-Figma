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
  String fromMRP = "";
  String toMRP = "";
  String WSPfrom = "";
  String WSPto = "";
  bool isLoading = true;
  List<String> addedItems = [];
    String? itemNamee;

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

        if (coBr != null && fcYrId != null) {
          _fetchAddedItems(coBr!, fcYrId!);
        }

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
      final barcode = '';
      final addedItemsList = await ApiService.fetchAddedItems(
        coBrId: coBrId,
        userId: userId,
        fcYrId: fcYrId!,
        barcode: barcode,
      );
      setState(() {
        addedItems = addedItemsList;
      });
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

      // Fetch the catalog data
      final result = await ApiService.fetchCatalogItem(
        itemSubGrpKey: itemSubGrpKey!,
        itemKey: itemKey!,
        cobr: coBr!,
        styleKey:
            selectedStyles.length == 1 ? selectedStyles[0].styleKey : null,
        shadeKey:
            selectedShades.isEmpty
                ? null
                : selectedShades.map((s) => s.shadeKey).join(','),
        sizeKey:
            selectedSize.isEmpty
                ? null
                : selectedSize.map((s) => s.itemSizeKey).join(','),
        fromMRP: fromMRP == "" ? null : fromMRP,
        toMRP: toMRP == "" ? null : toMRP,
      );

      int status = result["statusCode"];
      if (status == 200) {
        setState(() {
          isLoading = false;
        });
      }

      final items = result["catalogs"];

      // Filter by WSP first
      double? wspFrom = double.tryParse(WSPfrom);
      double? wspTo = double.tryParse(WSPto);

      List<Catalog> wspFilteredCatalogs = items;

      if (wspFrom != null && wspTo != null) {
        wspFilteredCatalogs =
            wspFilteredCatalogs
                .where(
                  (catalog) => catalog.wsp >= wspFrom && catalog.wsp <= wspTo,
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

      // Now, filter by style if styles are selected
      if (selectedStyles.isNotEmpty) {
        final selectedStyleKeys =
            selectedStyles.map((style) => style.styleKey).toSet();

        wspFilteredCatalogs =
            wspFilteredCatalogs
                .where(
                  (catalog) => selectedStyleKeys.contains(catalog.styleKey),
                )
                .toList();
      }

      // Set the final filtered catalog items
      setState(() {
        catalogItems = wspFilteredCatalogs;
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
          IconButton(
            icon: const Icon(
              CupertinoIcons.cart_badge_plus,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/viewOrder');
            },
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
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 16.0 : 8.0,
                vertical: 8.0,
              ),
              child: isLoading
                  ? Center(child: CircularProgressIndicator()) 
                  : catalogItems.isEmpty 
                  ? Center(child: Text("No Item Available")) 
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
    final crossAxisCount =
        isPortrait
            ? (isLargeScreen ? 3 : 2)
            : (constraints.maxWidth ~/ 300).clamp(3, 4);

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: catalogItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isLargeScreen ? 14.0 : 8.0,
        mainAxisSpacing: isLargeScreen ? 1.0 : 8.0,
        childAspectRatio: _getChildAspectRatio(constraints, isLargeScreen),
      ),
      itemBuilder: (context, index) {
        final item = catalogItems[index];
        return GestureDetector(
          onTap: () => _openImageZoom(context, item),
          child: _buildItemCard(item, isLargeScreen, addedItems),
        );
      },
    );
  }


  double _getChildAspectRatio(BoxConstraints constraints, bool isLargeScreen) {
    if (constraints.maxWidth > 1000) return isLargeScreen ? 0.65 : 0.6;
    if (constraints.maxWidth > 600) return isLargeScreen ? 0.6 : 0.55;
    return 0.6; // More height for small screens to fit full image
  }
  

  Widget _buildListView(BoxConstraints constraints, bool isLargeScreen) {
    return ListView.builder(
      itemCount: catalogItems.length,
      itemBuilder: (context, index) {
        final item = catalogItems[index];
        return GestureDetector(
          onTap: () => _openImageZoom(context, item),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(isLargeScreen ? 12.0 : 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1, // Maintain square ratio
                          child: Image.network(
                            _getImageUrl(item),
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Center(child: Icon(Icons.error)),
                              );
                            },
                          ),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.styleCode ,                               
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                  fontSize: isLargeScreen ? 24 : 20,
                                ),
                              ),
                            
                              _buildDetailTextRow(
                                'MRP',
                                '${item.mrp.toStringAsFixed(2)}',
                                'WSP',
                                '${item.wsp.toStringAsFixed(2)}',
                                isLargeScreen,
                              ),
                                _buildDetailText(
                                'Sizes',
                                item.sizeDetails,
                                isLargeScreen,
                              ),
                              _buildDetailText(
                                'Shade',
                                item.shadeName,
                                isLargeScreen,
                              ),
                            
                            ],
                          ),

                          SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 6.0,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    addedItems.contains(item.styleCode)
                                        ? Colors.green
                                        : AppColors.primaryColor,
                                  ),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                onPressed:
                                    addedItems.contains(item.styleCode)
                                        ? null
                                        : () =>
                                            _showBookingDialog(context, item),
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
    return ListView.builder(
      itemCount: catalogItems.length,
      itemBuilder: (context, index) {
        final item = catalogItems[index];
        return GestureDetector(
          onTap: () => _openImageZoom(context, item),
          child: Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: isLargeScreen ? 16 : 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: Column(
              children: [
                AspectRatio(
                           aspectRatio: 5 / 5.5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1, // Maintain square ratio
                      child: Image.network(
                        _getImageUrl(item),
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Center(child: Icon(Icons.error)),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.styleCode,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                               color: AppColors.primaryColor,
                              fontSize: isLargeScreen ? 24 : 20,
                            ),
                          ),
                          // _buildDetailTextRow(
                          //   'MRP',
                          //   '${item.mrp.toStringAsFixed(2)}',
                          //   'WSP',
                          //   '${item.wsp.toStringAsFixed(2)}',
                          //   isLargeScreen,
                          // ),
                          //   _buildDetailText(
                          //   'Sizes',
                          //   item.sizeDetails,
                          //   isLargeScreen,
                          // ),
                          // _buildDetailText(
                          //   'Shade',
                          //   item.shadeName,
                          //   isLargeScreen,
                          // ),
                        
                        ],
                      ),

                      SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 6.0,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                addedItems.contains(item.styleCode)
                                    ? Colors.green
                                    : AppColors.primaryColor,
                              ),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


 Widget _buildDetailTextRow(
    String label1,
    String value1,
    String label2,
    String value2,
    bool isLargeScreen,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label1: ',
                style: TextStyle(
                  fontSize: isLargeScreen ? 16 : 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: '$value1   ',
                style: TextStyle(
                  fontSize: isLargeScreen ? 16 : 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.normal,
                ),
              ),
              TextSpan(
                text: '$label2: ',
                style: TextStyle(
                  fontSize: isLargeScreen ? 16 : 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: value2,
                style: TextStyle(
                  fontSize: isLargeScreen ? 16 : 14,
                  color:Colors.grey.shade700,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailText(
    String label,
    String value,
    bool isLargeScreen, {
    bool isValuePrimaryColor = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label: ',
                style: TextStyle(
                  fontSize: isLargeScreen ? 16 : 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: isLargeScreen ? 16 : 14,
                  color:
                      isValuePrimaryColor
                          ? AppColors.primaryColor
                          : Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
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
    return GestureDetector(
      onDoubleTap: () => _openImageZoom(context, item),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
       ClipRRect(
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(12),
    topRight: Radius.circular(12),
  ),
  child: Container(
    height: 200,  // Set the desired height for the image
    child: AspectRatio(
      aspectRatio: 1, // Maintain square ratio
      child: Image.network(
        _getImageUrl(item),
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: const Center(child: Icon(Icons.error)),
          );
        },
      ),
    ),
  ),
),


            // Content section
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 10 : 8,
                  vertical: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   item.styleCode,
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.bold,
                    //     color: AppColors.primaryColor,
                    //     fontSize: isLargeScreen ? 20 : 18,
                    //   ),
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    // SizedBox(height: 10),
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Text.rich(
                    //     TextSpan(
                    //       children: [
                    //         TextSpan(
                    //           text: 'MRP: ',
                    //           style: TextStyle(
                    //             fontSize: isLargeScreen ? 13 : 12,
                    //             color:
                    //                 Colors.grey.shade700, // Label color (gray)
                    //             fontWeight:
                    //                 FontWeight.bold, // Bold for the label
                    //           ),
                    //         ),
                    //         TextSpan(
                    //           text: '${item.mrp.toStringAsFixed(2)}  ',
                    //           style: TextStyle(
                    //             fontSize: isLargeScreen ? 13 : 12,
                    //             color: Colors.grey.shade700, // Value color
                    //             fontWeight:
                    //                 FontWeight
                    //                     .normal, // Normal weight for values
                    //           ),
                    //         ),
                    //         TextSpan(
                    //           text: 'WSP: ',
                    //           style: TextStyle(
                    //             fontSize: isLargeScreen ? 13 : 12,
                    //             color:
                    //                 Colors.grey.shade700, // Label color (gray)
                    //             fontWeight:
                    //                 FontWeight.bold, // Bold for the label
                    //           ),
                    //         ),
                    //         TextSpan(
                    //           text: '${item.wsp.toStringAsFixed(2)}',
                    //           style: TextStyle(
                    //             fontSize: isLargeScreen ? 13 : 12,
                    //             color: Colors.grey.shade700, // Value color
                    //             fontWeight:
                    //                 FontWeight
                    //                     .normal, // Normal weight for values
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    // SizedBox(height: 4),
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Text.rich(
                    //     TextSpan(
                    //       children: [
                    //         TextSpan(
                    //           text: 'Sizes: ',
                    //           style: TextStyle(
                    //             fontSize: isLargeScreen ? 14 : 13,
                    //             color:
                    //                 Colors.grey.shade700, // Label color (gray)
                    //             fontWeight:
                    //                 FontWeight.bold, // Bold for the label
                    //           ),
                    //         ),
                    //         TextSpan(
                    //           text: item.sizeDetails,
                    //           style: TextStyle(
                    //             fontSize: isLargeScreen ? 14 : 13,
                    //             color: Colors.black, // Value color (normal)
                    //             fontWeight:
                    //                 FontWeight
                    //                     .normal, // Normal weight for values
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 4),
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Text.rich(
                    //     TextSpan(
                    //       children: [
                    //         TextSpan(
                    //           text: 'Shade: ',
                    //           style: TextStyle(
                    //             fontSize: isLargeScreen ? 14 : 13,
                    //             color:
                    //                 Colors.grey.shade700, // Label color (gray)
                    //             fontWeight:
                    //                 FontWeight.bold, // Bold for the label
                    //           ),
                    //         ),
                    //         TextSpan(
                    //           text: item.shadeName,
                    //           style: TextStyle(
                    //             fontSize: isLargeScreen ? 14 : 13,
                    //             color: Colors.black, // Value color (normal)
                    //             fontWeight:
                    //                 FontWeight
                    //                     .normal, // Normal weight for values
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            // Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 6.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      addedItems.contains(item.styleCode)
                          ? Colors.green
                          : AppColors.primaryColor,
                    ),
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
                    addedItems.contains(item.styleCode) ? 'Added' : 'BOOK NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLargeScreen ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
        child: isLargeScreen
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

    if (result != null) {
      Map<String, dynamic> selectedFilters = result;
      setState(() {
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


  void _showBookingDialog(BuildContext context, Catalog item) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.all(16),
      child: CatalogBookingTable(
        itemSubGrpKey: item.itemSubGrpKey.toString() ?? '',
        itemKey: item.itemKey.toString() ?? '',
        styleKey: item.styleKey.toString() ?? '',
        onSuccess: () => setState(() { // Add this callback
          addedItems.add(item.styleCode);
        }),
      ),
    ),
  );
}
}