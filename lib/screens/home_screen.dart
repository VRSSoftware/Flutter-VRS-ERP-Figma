import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/category.dart';
import 'package:vrs_erp_figma/models/item.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:vrs_erp_figma/services/app_services.dart';
import 'package:vrs_erp_figma/widget/bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> garmentImages = [
    'assets/garments/image_01.png',
    'assets/garments/image_02.png',
    'assets/garments/image_03.png',
    'assets/garments/image_04.png',
    'assets/garments/image_05.png',
  ];

  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  String? _selectedCategoryKey = '-1';
  String? _selectedCategoryName = 'All';
  String? coBr = '01';
  String? fcYrId = '24';
  List<Category> _categories = [];
  List<Item> _items = [];
  List<Item> _allItems = [];

  bool _isLoadingCategories = true;
  bool _isLoadingItems = false;

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
        // _isLoadingCategories = false;
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
        title: Text('Home', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.primaryColor,
        elevation: 1,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu, color: AppColors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Image.asset('assets/images/logo.png', height: 40),
                          SizedBox(width: 12),
                          Text(
                            "VRS Softwares",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Stack(
                        children: [
                          CarouselSlider.builder(
                            carouselController: _carouselController,
                            itemCount: garmentImages.length,
                            itemBuilder: (context, index, realIndex) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  garmentImages[index],
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              );
                            },
                            options: CarouselOptions(
                              height: 180,
                              autoPlay: true,
                              enlargeCenterPage: true,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: 80,
                            child: GestureDetector(
                              onTap: () => _carouselController.previousPage(),
                              child: Icon(
                                Icons.arrow_left,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 80,
                            child: GestureDetector(
                              onTap: () => _carouselController.nextPage(),
                              child: Icon(
                                Icons.arrow_right,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            garmentImages.map((image) {
                              int index = garmentImages.indexOf(image);
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                  color:
                                      _currentIndex == index
                                          ? AppColors.primaryColor
                                          : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                      ),
                      SizedBox(height: 20),
                      _buildMainButtons(context, constraints.maxWidth),
                      SizedBox(height: 20),
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
                            children:
                                _categories.map((category) {
                                  return OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedCategoryKey =
                                            category.itemSubGrpKey;
                                        _selectedCategoryName =
                                            category.itemSubGrpName;

                                        // Filter items based on the selected category
                                        if (_selectedCategoryKey == '-1') {
                                          // Show all items if "All" is selected
                                          _items = _allItems;
                                        } else {
                                          _items =
                                              _allItems
                                                  .where(
                                                    (item) =>
                                                        item.itemSubGrpKey ==
                                                        _selectedCategoryKey,
                                                  )
                                                  .toList();
                                        }
                                      });
                                    },

                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                            _selectedCategoryKey ==
                                                    category.itemSubGrpKey
                                                ? AppColors.primaryColor
                                                : Colors.white,
                                          ),
                                      side: MaterialStateProperty.all(
                                        BorderSide(
                                          color: AppColors.primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      category.itemSubGrpName,
                                      style: TextStyle(
                                        color:
                                            _selectedCategoryKey ==
                                                    category.itemSubGrpKey
                                                ? Colors.white
                                                : AppColors.primaryColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                      SizedBox(height: 20),
                      if (_selectedCategoryKey != null) _buildCategoryItems(),
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
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/catalog');
          if (index == 2) Navigator.pushNamed(context, '/orderbooking');
        },
      ),
    );
  }

  Widget _buildCategoryItems() {
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
              children:
                  _items.map((item) {
                    return GestureDetector(
                      onTap: () {
                        print(item.itemKey);
                        print(item.itemSubGrpKey);
                        Navigator.pushNamed(
                          context,
                          '/catalog',
                          arguments: {
                            'itemKey': item.itemKey,
                            'itemSubGrpKey': item.itemSubGrpKey,
                            'coBr': coBr,
                            'fcYrId': fcYrId,
                          },
                        );
                      },
                      child: Chip(
                        label: Text(item.itemName),
                        backgroundColor: Colors.white,
                        shape: StadiumBorder(
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        elevation: 2,
                      ),
                    );
                  }).toList(),
            ),
      ],
    );
  }

  Widget _buildMainButtons(BuildContext context, double screenWidth) {
    final buttonWidth = screenWidth - 14;
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      alignment: WrapAlignment.center,
      children: [
        _buildFeatureButton(
          'assets/images/catalog.png',
          'Catalog',
          () => Navigator.pushNamed(context, '/catalog'),
          buttonWidth,
        ),
      ],
    );
  }

  Widget _buildFeatureButton(
    String imagePath,
    String label,
    VoidCallback onTap,
    double width,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor, width: 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 50, height: 50),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
