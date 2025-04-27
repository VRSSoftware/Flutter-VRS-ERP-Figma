import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/catalog/filter.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/catalog.dart';
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
        _fetchCatalogItems();
        if (itemKey != null) {
          _fetchStylesByItemKey(itemKey!);
        }
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

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
                  ? Icons.view_list
                  : viewOption == 1
                      ? Icons.grid_on
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
          _buildStyleSelection(isLargeScreen),
        
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
              child: catalogItems.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : viewOption == 0
                      ? _buildGridView(isLargeScreen)
                      : viewOption == 1
                          ? _buildListView(isLargeScreen)
                          : _buildExpandedView(isLargeScreen),
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
            SizedBox(width: isLargeScreen ? 24 : 16),
            // ALL Button
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    selectedStyles.clear();
                  });
                },
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
                  onPressed: () {
                    setState(() {
                      if (isSelected) {
                        selectedStyles.remove(style.styleCode);
                      } else {
                        selectedStyles.add(style.styleCode);
                      }
                    });
                  },
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

  Widget _buildGridView(bool isLargeScreen) {
    final filteredItems = _getFilteredItems();
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLargeScreen ? 3 : 2,
        crossAxisSpacing: isLargeScreen ? 24.0 : 16.0,
        mainAxisSpacing: isLargeScreen ? 24.0 : 16.0,
        childAspectRatio: isLargeScreen ? 0.65 : 0.7,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(item, isLargeScreen);
      },
    );
  }

  Widget _buildListView(bool isLargeScreen) {
    final filteredItems = _getFilteredItems();
    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(item, isLargeScreen);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _getImageUrl(item),
                  fit: BoxFit.cover,
                  height: isLargeScreen ? 550 : 500,
                  width: double.infinity,
                ),
              ),
              SizedBox(height: isLargeScreen ? 12 : 8),
              Text(
                item.itemName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isLargeScreen ? 20 : 16),
              ),
              SizedBox(height: 4),
              Text('Style: ${item.styleCode}', 
                style: TextStyle(fontSize: isLargeScreen ? 16 : 14)),
              Text('MRP: ${item.mrp}', 
                style: TextStyle(fontSize: isLargeScreen ? 16 : 14)),
              Text('WSP: ${item.wsp}', 
                style: TextStyle(fontSize: isLargeScreen ? 16 : 14)),
              Text('Shade: ${item.shadeName}', 
                style: TextStyle(fontSize: isLargeScreen ? 16 : 14)),
            ],
          ),
        );
      },
    );
  }

  List<Catalog> _getFilteredItems() {
    var filteredItems = catalogItems;

    // Apply style filter
    if (selectedStyles.isNotEmpty) {
      filteredItems = filteredItems
          .where((item) => selectedStyles.contains(item.styleCode))
          .toList();
    }

    // Apply shade filter
    if (selectedShades.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        final shades = item.shadeName?.split(',') ?? [];
        return shades.any((shade) => selectedShades.contains(shade));
      }).toList();
    }

    return filteredItems;
  }

  Widget _buildItemCard(Catalog item, bool isLargeScreen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _getImageUrl(item),
              fit: BoxFit.cover,
              height: isLargeScreen ? 180 : 150,
              width: double.infinity,
            ),
          ),
          SizedBox(height: isLargeScreen ? 12 : 8),
          Padding(
            padding: EdgeInsets.all(isLargeScreen ? 8.0 : 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 18 : 16),
                ),
                SizedBox(height: 4),
                Text('Style: ${item.styleCode}', 
                  style: TextStyle(fontSize: isLargeScreen ? 14 : 12)),
                Text('MRP: ${item.mrp}', 
                  style: TextStyle(fontSize: isLargeScreen ? 14 : 12)),
                Text('WSP: ${item.wsp}', 
                  style: TextStyle(fontSize: isLargeScreen ? 14 : 12)),
              ],
            ),
          ),
        ],
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

  Widget _buildBottomButtons(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24 : 16,
        vertical: isLargeScreen ? 12 : 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  filterOption = 'New Arrival';
                });
              },
              style: _buttonStyle('New Arrival', isLargeScreen),
              child: Text('New Arrival', 
                style: TextStyle(fontSize: isLargeScreen ? 16 : 14)),
            ),
          ),
          SizedBox(width: isLargeScreen ? 16 : 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  filterOption = 'Featured';
                });
              },
              style: _buttonStyle('Featured', isLargeScreen),
              child: Text('Featured', 
                style: TextStyle(fontSize: isLargeScreen ? 16 : 14)),
            ),
          ),
          SizedBox(width: isLargeScreen ? 16 : 8),
          OutlinedButton.icon(
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
                vertical: isLargeScreen ? 16 : 12),
            ),
            icon: Icon(Icons.filter_list, 
              size: isLargeScreen ? 24 : 20),
            label: Text('Filter', 
              style: TextStyle(fontSize: isLargeScreen ? 16 : 14)),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(String option, bool isLargeScreen) {
    return OutlinedButton.styleFrom(
      side: BorderSide(
        color: filterOption == option
            ? AppColors.primaryColor
            : Colors.grey,
      ),
      backgroundColor: Colors.white,
      foregroundColor: filterOption == option
          ? AppColors.primaryColor
          : Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 16 : 12,
        horizontal: isLargeScreen ? 24 : 16),
    );
  }

  void _showFilterDialog() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FilterPage(),
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