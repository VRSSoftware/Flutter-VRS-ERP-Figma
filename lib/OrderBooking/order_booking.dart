import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:vrs_erp_figma/OrderBooking/orderbooking_drawer.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/category.dart';
import 'package:vrs_erp_figma/models/item.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:vrs_erp_figma/services/app_services.dart';
import 'package:vrs_erp_figma/widget/barcodewidget.dart';
import 'package:vrs_erp_figma/widget/bottom_navbar.dart';
import 'package:vrs_erp_figma/widget/filterdailogwidget.dart';

class OrderBookingScreen extends StatefulWidget {
  @override
  _OrderBookingScreenState createState() => _OrderBookingScreenState();
}

class _OrderBookingScreenState extends State<OrderBookingScreen> {
  final List<String> garmentImages = [
    'assets/garments/image_01.png',
    'assets/garments/image_02.png',
    'assets/garments/image_03.png',
    'assets/garments/image_04.png',
    'assets/garments/image_05.png',
  ];

  int _currentIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  String? _selectedCategoryKey = '-1';
  String? _selectedCategoryName = 'All';
  String? coBr = '01';
  String? fcYrId = '24';
  List<Category> _categories = [];
  List<Item> _items = [];
  List<Item> _allItems = [];
  bool showBarcodeWidget = false;
  bool _isLoadingCategories = true;
  bool _isLoadingItems = false;
  bool hasFiltered = false;

  Set<String> _activeFilters = {'mrp', 'wsp', 'shades', 'stylecode'};

void _updateFilters(Set<String> newFilters) {
  setState(() {
    _activeFilters = newFilters;
  });
}

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    fetchAllItems();
  }

  Future<void> _fetchCategories() async {
    try {
      final items = await ApiService.fetchAllItems();
      setState(() {
        _items = items;
        _allItems = items;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> fetchAllItems() async {
    try {
      final categories = await ApiService.fetchCategories();
      setState(() {
        _categories = [
          Category(itemSubGrpKey: '-1', itemSubGrpName: "ALL"),
          ...categories,
        ];
        _isLoadingCategories = false;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
appBar: AppBar(
  title: const Text(
    'Order Booking',
    style: TextStyle(color: Colors.white),
  ),
  backgroundColor: AppColors.primaryColor,
  elevation: 1,
  leading: Builder(
    builder: (context) => IconButton(
      icon: const Icon(Icons.menu, color: Colors.white),
      onPressed: () => Scaffold.of(context).openDrawer(),
    ),
  ),
  automaticallyImplyLeading: false,
  actions: [
    IconButton(
  icon: const Icon(Icons.filter_list, color: Colors.white),
  onPressed: () async {
    final newFilters = await showDialog<Set<String>>(
      context: context,
      builder: (context) => FilterDialog(initialFilters: _activeFilters),
    );
    
    if (newFilters != null) {
      _updateFilters(newFilters);
    }
  },
),
    // Three-dot menu icon
    Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        onPressed: () async {
          final RenderBox button =
              context.findRenderObject() as RenderBox;
          final Offset position = button.localToGlobal(Offset.zero);
          showOrderMenu(context, position); // Show the additional menu when the three-dot icon is pressed
        },
      ),
    ),
  ],
),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            int columnCount = isMobile ? 1 : 2;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: isMobile
                            ? double.infinity
                            : (constraints.maxWidth / columnCount) - 24,
                        child: Row(
                          children: [
                            Checkbox(
                              value: showBarcodeWidget,
                              onChanged: (value) {
                                setState(() {
                                  showBarcodeWidget = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              "Order Booking Barcode Wise",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),

                      if (showBarcodeWidget)
                        SizedBox(
                          width: isMobile
                              ? double.infinity
                              : (constraints.maxWidth / columnCount) - 24,
                          child: BarcodeWiseWidget(
                            onFilterPressed: (barcode) {
                              print("Barcode: $barcode");
                              setState(() {
                                hasFiltered = true;
                                
                              });
                              
                            },
                             activeFilters: _activeFilters,
                          ),
                        ),

                      if (!showBarcodeWidget) ...[
                        SizedBox(height: 15),
                        Text(
                          "Categories",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 10),
                        _isLoadingCategories
                            ? Center(child: CircularProgressIndicator())
                            : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.start,
                                children: _categories.map((category) {
                                  return Container(
                                    width: (MediaQuery.of(context).size.width - 60) / 3,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedCategoryKey = category.itemSubGrpKey;
                                          _selectedCategoryName = category.itemSubGrpName;

                                          if (_selectedCategoryKey == '-1') {
                                            _items = _allItems;
                                          } else {
                                            _items = _allItems
                                                .where((item) => item.itemSubGrpKey == _selectedCategoryKey)
                                                .toList();
                                          }
                                        });
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(
                                          _selectedCategoryKey == category.itemSubGrpKey
                                              ? AppColors.primaryColor
                                              : Colors.white,
                                        ),
                                        side: MaterialStateProperty.all(
                                          BorderSide(color: AppColors.primaryColor, width: 2),
                                        ),
                                      ),
                                      child: Text(
                                        category.itemSubGrpName,
                                        style: TextStyle(
                                          color: _selectedCategoryKey == category.itemSubGrpKey
                                              ? Colors.white
                                              : AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                        SizedBox(height: 20),
                        if (_selectedCategoryKey != null) _buildCategoryItems(),
                      ],

                      Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
     bottomNavigationBar: BottomNavigationWidget(
        currentIndex: 2, // 👈 Highlight Order icon
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/catalog');
          if (index == 2) return; // Already on Order
        },
      ),
    );
  }

  Widget _buildCategoryItems() {
    double buttonWidth = (MediaQuery.of(context).size.width - 60) / 3;
    double buttonHeight = 50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Items in $_selectedCategoryName",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 10),
        _isLoadingItems
            ? Center(child: CircularProgressIndicator())
            : Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.start,
                children: _items.map((item) {
                  return SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        print(item.itemKey);
                        print(item.itemSubGrpKey);
                        Navigator.pushNamed(
                          context,
                          '/catalogpage',
                          arguments: {
                            'itemKey': item.itemKey,
                            'itemSubGrpKey': item.itemSubGrpKey,
                            'coBr': coBr,
                            'fcYrId': fcYrId,
                          },
                        );
                      },
                      child: Text(
                        item.itemName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
}
