import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/catalog/filter.dart';
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
  List<String> selectedShades = [];
  List<Catalog> catalogItems = [];
  List<Style> styles = [];
  List<Shade> shades = [];
  List<Sizes> sizes = [];
  String? itemKey;
  String? itemSubGrpKey;
  String? coBr;
  String? fcYrId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

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
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

  return Scaffold(
    backgroundColor: Colors.white,
    drawer: DrawerScreen(),
    appBar: AppBar(
      title: Text('Catalog', style: TextStyle(color: Colors.white)),
      backgroundColor: AppColors.primaryColor,
      elevation: 1,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
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
              vertical: 8.0
            ),
            child: catalogItems.isEmpty
                ? Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (viewOption == 0) {
                        return _buildGridView(constraints, isLargeScreen, isPortrait);
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
                    color: selectedStyles.isEmpty
                        ? AppColors.primaryColor
                        : Colors.grey,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: selectedStyles.isEmpty
                      ? AppColors.primaryColor
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 20 : 16,
                    vertical: isLargeScreen ? 16 : 12),
                ),
                child: Text('ALL', 
                  style: TextStyle(fontSize: isLargeScreen ? 14 : 12)),
              ),
            ),
            ...styles.map((style) {
              bool isSelected = selectedStyles.contains(style.styleCode);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    if (isSelected) {
                      selectedStyles.remove(style.styleCode);
                    } else {
                      selectedStyles.add(style.styleCode);
                    }
                  }),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.grey,
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 20 : 16,
                      vertical: isLargeScreen ? 16 : 12),
                  ),
                  child: Text(style.styleCode, 
                    style: TextStyle(fontSize: isLargeScreen ? 14 : 12)),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

Widget _buildGridView(BoxConstraints constraints, bool isLargeScreen, bool isPortrait) {
  final filteredItems = _getFilteredItems();
  final crossAxisCount = isPortrait
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
    itemBuilder: (context, index) => _buildItemCard(filteredItems[index], isLargeScreen),
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
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
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
                            fontSize: isLargeScreen ? 18 : 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        _buildDetailText('Style: ${item.styleCode}', isLargeScreen),
                        _buildDetailText('MRP: ${item.mrp}', isLargeScreen),
                        _buildDetailText('WSP: ${item.wsp}', isLargeScreen),
                        _buildDetailText('Shade: ${item.shadeName}', isLargeScreen),
                      ],
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
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: isLargeScreen ? 16 : 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
          child: Column(
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
                        fontSize: isLargeScreen ? 24 : 20),
                    ),
                    SizedBox(height: 8),
                    _buildDetailText('Style: ${item.styleCode}', isLargeScreen),
                    _buildDetailText('MRP: ${item.mrp}', isLargeScreen),
                    _buildDetailText('WSP: ${item.wsp}', isLargeScreen),
                    _buildDetailText('Shade: ${item.shadeName}', isLargeScreen),
                  ],
                ),
              ),
            ],
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
          color: Colors.grey[700]),
      ),
    );
  }

Widget _buildItemCard(Catalog item, bool isLargeScreen) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: Image.network(
            _getImageUrl(item),
            height: 140, // <<< fixed height like your working code
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
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildBottomButtons(bool isLargeScreen) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 24 : 12,
          vertical: 12),
        color: Colors.white,
        child: isLargeScreen
            ? Row(
                children: _buildButtonChildren(isLargeScreen),
              )
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align buttons in a row with space between
      children: [
        Expanded(
          child: _buildFilterButton('New Arrival', isLargeScreen),
        ),
        SizedBox(width: 8), // Add space between buttons
        Expanded(
          child: _buildFilterButton('Featured', isLargeScreen),
        ),
        SizedBox(width: 8), // Add space between buttons
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showFilterDialog,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primaryColor),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 24 : 16,
                vertical: 12), // Reduced vertical padding
            ),
            icon: Icon(Icons.filter_list, size: isLargeScreen ? 24 : 20),
            label: Text('Filter', style: TextStyle(fontSize: isLargeScreen ? 16 : 14)),
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
        color: filterOption == label
            ? AppColors.primaryColor
            : Colors.grey,
      ),
      backgroundColor: Colors.white,
      foregroundColor: filterOption == label
          ? AppColors.primaryColor
          : Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 16 : 12,
        horizontal: isLargeScreen ? 24 : 16),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
    ),
  );
}


  List<Catalog> _getFilteredItems() {
    var filteredItems = catalogItems;

    if (selectedStyles.isNotEmpty) {
      filteredItems = filteredItems
          .where((item) => selectedStyles.contains(item.styleCode))
          .toList();
    }

    if (selectedShades.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        final shades = item.shadeName?.split(',') ?? [];
        return shades.any((shade) => selectedShades.contains(shade));
      }).toList();
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

 void _showFilterDialog() {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => FilterPage(),
      settings: RouteSettings(  // Add this block
        arguments: {
          'itemKey': itemKey,
          'itemSubGrpKey': itemSubGrpKey,
          'coBr': coBr,
          'fcYrId': fcYrId,
          'styles': styles,
           'shades': shades,  // Add shades list
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
  }

}