import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart'; // Import the dropdown_search package

class CatalogPage extends StatefulWidget {
  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  
  String? selectedCategory;
  String? selectedItem;
  String? selectedStyle;
  String? selectedShade;
  String? selectedSize; // For the searchable dropdown of size
  double fromMRP = 0.0;
  double toMRP = 0.0;
  String stockStatus = 'All'; // For radio buttons: 'All' or 'Ready'

  // Sample categories, items, styles, and sizes
  final List<String> categories = ['Apparel', 'Footwear', 'Accessories'];
  final List<String> items = ['T-shirt', 'Jeans', 'Jacket'];
  final List<String> styles = ['Casual', 'Formal', 'Sporty'];
  final List<String> shades = ['Red', 'Blue', 'Green', 'Black'];
  final List<String> sizes = ['S', 'M', 'L', 'XL', 'Free'];

  int _currentIndex = 0; // To track selected index for bottom navigation

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Dropdown
              DropdownSearch<String>(
                selectedItem: selectedCategory,
                items: categories,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                dropdownBuilder: (context, selectedItem) {
                  return Text(
                    selectedItem ?? 'Select Category',
                    style: TextStyle(color: selectedItem == null ? Colors.grey : Colors.black),
                  );
                },
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Search Category",
                      filled: true,
                      fillColor: AppColors.lightBlue,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),

              // Item Dropdown
              DropdownSearch<String>(
                selectedItem: selectedItem,
                items: items,
                onChanged: (value) {
                  setState(() {
                    selectedItem = value;
                  });
                },
                dropdownBuilder: (context, selectedItem) {
                  return Text(
                    selectedItem ?? 'Select Item',
                    style: TextStyle(color: selectedItem == null ? Colors.grey : Colors.black),
                  );
                },
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Search Item",
                      filled: true,
                      fillColor: AppColors.baseColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),

              // Style Dropdown
              DropdownSearch<String>(
                selectedItem: selectedStyle,
                items: styles,
                onChanged: (value) {
                  setState(() {
                    selectedStyle = value;
                  });
                },
                dropdownBuilder: (context, selectedItem) {
                  return Text(
                    selectedItem ?? 'Select Style',
                    style: TextStyle(color: selectedItem == null ? Colors.grey : Colors.black),
                  );
                },
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Search Style",
                      filled: true,
                      fillColor: AppColors.lightBlue,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),

              // Shade Dropdown
              DropdownSearch<String>(
                selectedItem: selectedShade,
                items: shades,
                onChanged: (value) {
                  setState(() {
                    selectedShade = value;
                  });
                },
                dropdownBuilder: (context, selectedItem) {
                  return Text(
                    selectedItem ?? 'Select Shade',
                    style: TextStyle(color: selectedItem == null ? Colors.grey : Colors.black),
                  );
                },
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Search Shade",
                      filled: true,
                      fillColor: AppColors.baseColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),

              // Size Dropdown
              DropdownSearch<String>(
                selectedItem: selectedSize,
                items: sizes,
                onChanged: (value) {
                  setState(() {
                    selectedSize = value;
                  });
                },
                dropdownBuilder: (context, selectedItem) {
                  return Text(
                    selectedItem ?? 'Select Size',
                    style: TextStyle(color: selectedItem == null ? Colors.grey : Colors.black),
                  );
                },
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Search Size",
                      filled: true,
                      fillColor: AppColors.baseColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),

              // MRP Range
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "From MRP",
                        filled: true,
                        fillColor: AppColors.lightBlue,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          fromMRP = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "To MRP",
                        filled: true,
                        fillColor: AppColors.lightBlue,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          toMRP = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Stock Status (Radio Buttons)
              Row(
                children: [
                  Radio<String>(
                    value: 'All',
                    groupValue: stockStatus,
                    onChanged: (value) {
                      setState(() {
                        stockStatus = value!;
                      });
                    },
                  ),
                  Text('All'),
                  Radio<String>(
                    value: 'Ready',
                    groupValue: stockStatus,
                    onChanged: (value) {
                      setState(() {
                        stockStatus = value!;
                      });
                    },
                  ),
                  Text('Ready'),
                ],
              ),
              SizedBox(height: 12),

              // Filter and Clear buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Implement filter logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.baseColor, // Background color as base color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: AppColors.primaryColor), // Border color as primary color
                        ),
                      ),
                      icon: Icon(Icons.filter_list, color: AppColors.primaryColor), // Filter icon with primary color
                      label: Text(
                        "Filter",
                        style: TextStyle(color: AppColors.primaryColor), // Text color as primary color
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0), // Add some spacing between the two buttons
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedCategory = null;
                          selectedItem = null;
                          selectedStyle = null;
                          selectedShade = null;
                          selectedSize = null;
                          fromMRP = 0.0;
                          toMRP = 0.0;
                          stockStatus = 'All';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.baseColor, // Background color as base color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: AppColors.primaryColor), // Border color as primary color
                        ),
                      ),
                      icon: Icon(Icons.clear, color: AppColors.primaryColor), // Clear icon with primary color
                      label: Text(
                        "Clear",
                        style: TextStyle(color: AppColors.primaryColor), // Text color as primary color
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
bottomNavigationBar: BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: _onItemTapped,
  backgroundColor: AppColors.baseColor, // Set background color to baseColor
  selectedItemColor: const Color.fromARGB(255, 221, 115, 82), // Set selected icon and text color to primaryColor
  unselectedItemColor: AppColors.deepPurple, // Set unselected icon and text color to white or another color
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.book_online),
      label: 'Order Booking',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.view_list),
      label: 'Catalog',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart),
      label: 'Cart',
    ),
  ],
)

    );
  }
}
