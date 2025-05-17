import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vrs_erp_figma/OrderBooking/booking2/booking2.dart';
import 'package:vrs_erp_figma/OrderBooking/booking2/booking3.dart';
import 'package:vrs_erp_figma/OrderBooking/booking2/multipleorderbooking.dart';
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
  String sortBy = "";
  bool isLoading = true;
  List<String> addedItems = [];
  String? itemNamee;
  List<Catalog> selectedItems = [];
  bool showSizes = true;
  bool showProduct = true;
  int _cartItemCount = 0;

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

      if (coBr != null && fcYrId != null) {
        _fetchCartCount();
      }
    });
  }

Future<void> _fetchCartCount() async {
  try {
    final data = await ApiService.getSalesOrderData(
      coBrId: '01',
      userId: 'Admin', // Replace with actual user ID if needed
      fcYrId: 24,       // Note: fcYrId should be an int, not string
      barcode: '',
    );
    setState(() {
      _cartItemCount = data['cartItemCount'] ?? 0;
    });
  } catch (e) {
    print('Error fetching cart count: $e');
  }
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

  Future<void> _fetchCatalogItems() async {
    try {
      setState(() {
        catalogItems = [];
        isLoading = true;
      });

      final result = await ApiService.fetchCatalogItem(
        itemSubGrpKey: itemSubGrpKey!,
        itemKey: itemKey!,
        cobr: coBr!,
        sortBy: sortBy,
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

      setState(() {
        catalogItems = wspFilteredCatalogs;
      });
    } catch (e) {
      debugPrint('Failed to load catalog items: $e');
    }
  }

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

  void _toggleItemSelection(Catalog item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
    });
    debugPrint(selectedItems.length.toString());
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
  icon: Stack(
    children: [
      const Icon(
        CupertinoIcons.cart_badge_plus,
        color: Colors.white,
      ),
      Positioned(
        right: 0,
        top: 0,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(6),
          ),
          constraints: const BoxConstraints(
            minWidth: 14,
            minHeight: 14,
          ),
          child: Text(
            '$_cartItemCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ],
  ),
  onPressed: () {
    Navigator.pushNamed(context, '/viewOrder');
     _fetchCartCount();
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
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width > 600 ? 24.0 : 16.0,
                        ),
                        child: StatefulBuilder(
                          builder: (context, setStateDialog) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width > 600
                                          ? 600
                                          : 440,
                                  minWidth: 320,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Options",
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width >
                                                    600
                                                ? 22
                                                : 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final isWide = constraints.maxWidth > 400;
                                        return isWide
                                            ? Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        _buildToggleRow(
                                                          "Show Product",
                                                          showProduct,
                                                          (val) {
                                                            showProduct = val;
                                                            setStateDialog(() {});
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        _buildToggleRow(
                                                          "Show Size",
                                                          showSizes,
                                                          (val) {
                                                            showSizes = val;
                                                            setStateDialog(() {});
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                children: [
                                                  _buildToggleRow(
                                                    "Show Size",
                                                    showSizes,
                                                    (val) {
                                                      showSizes = val;
                                                      setStateDialog(() {});
                                                    },
                                                  ),
                                                  _buildToggleRow(
                                                    "Show Product",
                                                    showProduct,
                                                    (val) {
                                                      showProduct = val;
                                                      setStateDialog(() {});
                                                    },
                                                  ),
                                                ],
                                              );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                          ),
                                          child: Text(
                                            "Close",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      600
                                                  ? 18
                                                  : 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
        isPortrait ? (isLargeScreen ? 3 : 2) : (constraints.maxWidth ~/ 300).clamp(3, 4);

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
          onDoubleTap: () => _openImageZoom(context, item),
          onTap: () => _toggleItemSelection(item),
          child: _buildItemCard(item, isLargeScreen, addedItems),
        );
      },
    );
  }

  double _getChildAspectRatio(BoxConstraints constraints, bool isLargeScreen) {
    if (constraints.maxWidth > 1000) return isLargeScreen ? 0.35 : 0.4;
    if (constraints.maxWidth > 600) return isLargeScreen ? 0.4 : 0.45;
    return 0.42;
  }

  Widget _buildListView(BoxConstraints constraints, bool isLargeScreen) {
    return ListView.builder(
      itemCount: catalogItems.length,
      itemBuilder: (context, index) {
        final item = catalogItems[index];
        final isSelected = selectedItems.contains(item);
        return GestureDetector(
          onDoubleTap: () => _openImageZoom(context, item),
          onTap: () => _toggleItemSelection(item),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Card(
              elevation: isSelected ? 8 : 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
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
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(0),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final maxImageHeight = constraints.maxWidth * 1.2;
                                return ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: maxImageHeight,
                                  ),
                                  child: SizedBox(
                                    height: maxImageHeight,
                                    width: double.infinity,
                                    child: Center(
                                      child: Image.network(
                                        _getImageUrl(item),
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade300,
                                            child: const Center(child: Icon(Icons.error)),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
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
                                        _buildLabelText('Design'),
                                        const Text(':'),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            item.styleCodeWithcount,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: isLargeScreen ? 20 : 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    _buildSpacerRow(),
                                    TableRow(
                                      children: [
                                        _buildLabelText('MRP'),
                                        const Text(':'),
                                        Text(
                                          item.mrp.toStringAsFixed(2),
                                          style: _valueTextStyle(isLargeScreen),
                                        ),
                                      ],
                                    ),
                                    _buildSpacerRow(),
                                    if (showSizes && item.sizeName.isNotEmpty)
                                      TableRow(
                                        children: [
                                          _buildLabelText('Size'),
                                          const Text(':'),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              item.sizeWithMrp,
                                              style: _valueTextStyle(isLargeScreen),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (showSizes && item.sizeName.isNotEmpty)
                                      _buildSpacerRow(),
                                    if (showProduct)
                                      TableRow(
                                        children: [
                                          _buildLabelText('Product'),
                                          const Text(':'),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              item.itemName,
                                              style: _valueTextStyle(isLargeScreen),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
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
                                          borderRadius: BorderRadius.circular(0),
                                        ),
                                      ),
                                    ),
                                    onPressed: addedItems.contains(item.styleCode)
                                        ? null
                                        : () => _showBookingDialog(context, item),
                                    child: Text(
                                      addedItems.contains(item.styleCode)
                                          ? 'Added'
                                          : 'BOOK NOW',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isLargeScreen ? 14 : 12,
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
                          size: isLargeScreen ? 24 : 20,
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
    return ListView.builder(
      itemCount: catalogItems.length,
      itemBuilder: (context, index) {
        final item = catalogItems[index];
        final isSelected = selectedItems.contains(item);
        return GestureDetector(
          onDoubleTap: () => _openImageZoom(context, item),
          onTap: () => _toggleItemSelection(item),
          child: Card(
            elevation: isSelected ? 8 : 4,
            margin: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: isLargeScreen ? 16 : 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            color: isSelected ? Colors.blue.shade50 : Colors.white,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxImageHeight = constraints.maxWidth * 1.2;
                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: maxImageHeight,
                              minHeight: constraints.maxWidth,
                            ),
                            child: Image.network(
                              _getImageUrl(item),
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(child: Icon(Icons.error)),
                                );
                              },
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
                              _buildLabelText('Design'),
                              const Text(':'),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  item.styleCodeWithcount,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isLargeScreen ? 20 : 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _buildSpacerRow(),
                          TableRow(
                            children: [
                              _buildLabelText('MRP'),
                              const Text(':'),
                              Text(
                                item.mrp.toStringAsFixed(2),
                                style: _valueTextStyle(isLargeScreen),
                              ),
                            ],
                          ),
                          _buildSpacerRow(),
                          if (showSizes && item.sizeName.isNotEmpty)
                            TableRow(
                              children: [
                                _buildLabelText('Size'),
                                const Text(':'),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    item.sizeWithMrp,
                                    style: _valueTextStyle(isLargeScreen),
                                  ),
                                ),
                              ],
                            ),
                          if (showSizes && item.sizeName.isNotEmpty)
                            _buildSpacerRow(),
                          if (showProduct)
                            TableRow(
                              children: [
                                _buildLabelText('Product'),
                                const Text(':'),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    item.itemName,
                                    style: _valueTextStyle(isLargeScreen),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
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
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                          ),
                          onPressed: addedItems.contains(item.styleCode)
                              ? null
                              : () => _showBookingDialog(context, item),
                          child: Text(
                            addedItems.contains(item.styleCode)
                                ? 'Added'
                                : 'BOOK NOW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isLargeScreen ? 14 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                        size: isLargeScreen ? 24 : 20,
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

  Widget _buildItemCard(
    Catalog item,
    bool isLargeScreen,
    List<String> addedItems,
  ) {
    final isSelected = selectedItems.contains(item);
    return GestureDetector(
      onDoubleTap: () => _openImageZoom(context, item),
      onTap: () => _toggleItemSelection(item),
      child: Card(
        elevation: isSelected ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxImageHeight = constraints.maxWidth * 1.2;
                      return ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxImageHeight),
                        child: SizedBox(
                          height: maxImageHeight,
                          width: double.infinity,
                          child: Center(
                            child: Image.network(
                              _getImageUrl(item),
                              fit: BoxFit.contain,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(child: Icon(Icons.error)),
                                );
                              },
                            ),
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
                          _buildLabelText('Design'),
                          const Text(':'),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              item.styleCodeWithcount,
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: isLargeScreen ? 20 : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildSpacerRow(),
                      TableRow(
                        children: [
                          _buildLabelText('MRP'),
                          const Text(':'),
                          Text(
                            item.mrp.toStringAsFixed(2),
                            style: _valueTextStyle(isLargeScreen),
                          ),
                        ],
                      ),
                      _buildSpacerRow(),
                      if (showSizes && item.sizeName.isNotEmpty)
                        TableRow(
                          children: [
                            _buildLabelText('Size'),
                            const Text(':'),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                item.sizeWithMrp,
                                style: _valueTextStyle(isLargeScreen),
                              ),
                            ),
                          ],
                        ),
                      if (showSizes && item.sizeName.isNotEmpty)
                        _buildSpacerRow(),
                      if (showProduct)
                        TableRow(
                          children: [
                            _buildLabelText('Product'),
                            const Text(':'),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                item.itemName,
                                style: _valueTextStyle(isLargeScreen),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
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
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                      onPressed: addedItems.contains(item.styleCode)
                          ? null
                          : () => _showBookingDialog(context, item),
                      child: Text(
                        addedItems.contains(item.styleCode)
                            ? 'Added'
                            : 'BOOK NOW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isLargeScreen ? 14 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                    size: isLargeScreen ? 24 : 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelText(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
          fontSize: 14,
        ),
      ),
    );
  }

  TextStyle _valueTextStyle(bool isLargeScreen) {
    return TextStyle(
      color: Colors.grey[800],
      fontSize: isLargeScreen ? 14 : 13,
    );
  }

  TableRow _buildSpacerRow() {
    return const TableRow(
      children: [SizedBox(height: 8), SizedBox(height: 8), SizedBox(height: 8)],
    );
  }

  Widget _buildDetailTextRow(
    String label1,
    String value1,
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
                text: value1,
                style: TextStyle(
                  fontSize: isLargeScreen ? 16 : 14,
                  color: Colors.grey.shade700,
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
                      isValuePrimaryColor ? AppColors.primaryColor : Colors.black,
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
      if (isLargeScreen)
        Expanded(child: _buildFilterButton(isLargeScreen))
      else
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFilterButton(isLargeScreen),
            if (selectedItems.isNotEmpty)
        Container(
  decoration: BoxDecoration(
    color: AppColors.primaryColor,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onPressed: selectedItems.isNotEmpty
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiCatalogBookingPage(
                      catalogs: selectedItems,
                    ),
                  ),
                )
            : null,
        child: Text("Book Now"),
      ),
      // First divider
      SizedBox(
        height: 24,
        child: VerticalDivider(
          color: Colors.white,
          thickness: 1,
          width: 1,
        ),
      ),
      IconButton(
        icon: Icon(Icons.shopping_cart, color: Colors.white),
        onPressed: selectedItems.isNotEmpty
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateOrderScreen(
                      catalogs: selectedItems,
                    ),
                  ),
                )
            : null,
      ),
      // Second divider
      SizedBox(
        height: 24,
        child: VerticalDivider(
          color: Colors.white,
          thickness: 1,
          width: 1,
        ),
      ),
      IconButton(
        icon: Icon(Icons.assignment, color: Colors.white),
        onPressed: selectedItems.isNotEmpty
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateOrderScreen3(
                      catalogs: selectedItems,
                    ),
                  ),
                )
            : null,
      ),
    ],
  ),
)
          ],
        ),
    ];
  }

  Widget _buildFilterButton(bool isLargeScreen) {
    return OutlinedButton.icon(
      onPressed: _showFilterDialog,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.primaryColor),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    );
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
            'sortBy': sortBy,
          },
        ),
        transitionDuration: Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: animation,
            alignment: Alignment.bottomRight,
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
        sortBy = selectedFilters['sortBy'];
      });
      print("aaaaaaaa  ${selectedFilters['styles']}");
      print("aaaaaaaa  ${selectedFilters['WSPfrom']}");
      print("aaaaaaaa  ${selectedFilters['WSPto']}");
      if (!(selectedStyles.isEmpty &&
          selectedSize.isEmpty &&
          selectedShades.isEmpty &&
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
        onSuccess: () {
          // Update local state
          setState(() {
            addedItems.add(item.styleCode);
          });
               _fetchCartCount().then((_) {
            // Notify OrderBookingScreen through navigation
            Navigator.pop(context); // Close dialog
          });
        },
      ),
    ),
  );
}


  Widget _buildToggleRow(String title, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), Switch(value: value, onChanged: onChanged)],
    );
  }
}