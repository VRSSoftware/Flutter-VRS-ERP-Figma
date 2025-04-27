// import 'package:flutter/material.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:vrs_erp_figma/constants/app_constants.dart';
// import 'package:vrs_erp_figma/screens/drawer_screen.dart'; // Import the dropdown_search package

// class CatalogPage extends StatefulWidget {
//   @override
//   _CatalogPageState createState() => _CatalogPageState();
// }

// class _CatalogPageState extends State<CatalogPage> {

//   String? selectedCategory;
//   String? selectedItem;
//   String? selectedStyle;
//   String? selectedShade;
//   String? selectedSize; // For the searchable dropdown of size
//   double fromMRP = 0.0;
//   double toMRP = 0.0;
//   String stockStatus = 'All'; // For radio buttons: 'All' or 'Ready'

//   // Sample categories, items, styles, and sizes
//   final List<String> categories = ['Apparel', 'Footwear', 'Accessories'];
//   final List<String> items = ['T-shirt', 'Jeans', 'Jacket'];
//   final List<String> styles = ['Casual', 'Formal', 'Sporty'];
//   final List<String> shades = ['Red', 'Blue', 'Green', 'Black'];
//   final List<String> sizes = ['S', 'M', 'L', 'XL', 'Free'];

//   int _currentIndex = 0; // To track selected index for bottom navigation

//   void _onItemTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: DrawerScreen(),
//       appBar: AppBar(
//         title: Text('Catalog', style: TextStyle(color: Colors.white)),
//         backgroundColor: AppColors.primaryColor,
//         elevation: 1,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: Icon(Icons.menu, color: Colors.white),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Category Dropdown
//               DropdownSearch<String>(
//                 selectedItem: selectedCategory,
//                 items: categories,
//                 onChanged: (value) {
//                   setState(() {
//                     selectedCategory = value;
//                   });
//                 },
//                 dropdownBuilder: (context, selectedItem) {
//                   return Text(
//                     selectedItem ?? 'Select Category',
//                     style: TextStyle(color: selectedItem == null ? Colors.grey : Colors.black),
//                   );
//                 },
//                 popupProps: PopupProps.menu(
//                   showSearchBox: true,
//                   searchFieldProps: TextFieldProps(
//                     decoration: InputDecoration(
//                       hintText: "Search Category",
//                       filled: true,
//                       fillColor: AppColors.lightBlue,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 12),

//               // Item Dropdown
//               DropdownSearch<String>(
//                 selectedItem: selectedItem,
//                 items: items,
//                 onChanged: (value) {
//                   setState(() {
//                     selectedItem = value;
//                   });
//                 },
//                 dropdownBuilder: (context, selectedItem) {
//                   return Text(
//                     selectedItem ?? 'Select Item',
//                     style: TextStyle(color: selectedItem == null ? Colors.grey : Colors.black),
//                   );
//                 },
//                 popupProps: PopupProps.menu(
//                   showSearchBox: true,
//                   searchFieldProps: TextFieldProps(
//                     decoration: InputDecoration(
//                       hintText: "Search Item",
//                       filled: true,
//                       fillColor: AppColors.secondaryColor,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 12),

//               // Style Dropdown
//               DropdownSearch<String>(
//                 selectedItem: selectedStyle,
//                 items: styles,
//                 onChanged: (value) {
//                   setState(() {
//                     selectedStyle = value;
//                   });
//                 },
//                 dropdownBuilder: (context, selectedItem) {
//                   return Text(
//                     selectedItem ?? 'Select Style',
//                     style: TextStyle(color: selectedItem == null ? Colors.grey : Colors.black),
//                   );
//                 },
//                 popupProps: PopupProps.menu(
//                   showSearchBox: true,
//                   searchFieldProps: TextFieldProps(
//                     decoration: InputDecoration(
//                       hintText: "Search Style",
//                       filled: true,
//                       fillColor: AppColors.lightBlue,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 12),

//               // Shade Dropdown
//               DropdownSearch<String>(
//                 selectedItem: selectedShade,
//                 items: shades,
//                 onChanged: (value) {
//                   setState(() {
//                     selectedShade = value;
//                   });
//                 },
//                 dropdownBuilder: (context, selectedItem) {
//                   return Text(
//                     selectedItem ?? 'Select Shade',
//                     style: TextStyle(color: selectedItem == null ? Colors.grey : Colors.black),
//                   );
//                 },
//                 popupProps: PopupProps.menu(
//                   showSearchBox: true,
//                   searchFieldProps: TextFieldProps(
//                     decoration: InputDecoration(
//                       hintText: "Search Shade",
//                       filled: true,
//                       fillColor: AppColors.secondaryColor,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 12),

//               // Size Dropdown
//               DropdownSearch<String>(
//                 selectedItem: selectedSize,
//                 items: sizes,
//                 onChanged: (value) {
//                   setState(() {
//                     selectedSize = value;
//                   });
//                 },
//                 dropdownBuilder: (context, selectedItem) {
//                   return Text(
//                     selectedItem ?? 'Select Size',
//                     style: TextStyle(color: selectedItem == null ? Colors.grey : Colors.black),
//                   );
//                 },
//                 popupProps: PopupProps.menu(
//                   showSearchBox: true,
//                   searchFieldProps: TextFieldProps(
//                     decoration: InputDecoration(
//                       hintText: "Search Size",
//                       filled: true,
//                       fillColor: AppColors.secondaryColor,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 12),

//               // MRP Range
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       decoration: InputDecoration(
//                         labelText: "From MRP",
//                         filled: true,
//                         fillColor: AppColors.lightBlue,
//                         border: OutlineInputBorder(),
//                       ),
//                       keyboardType: TextInputType.number,
//                       onChanged: (value) {
//                         setState(() {
//                           fromMRP = double.tryParse(value) ?? 0.0;
//                         });
//                       },
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: TextFormField(
//                       decoration: InputDecoration(
//                         labelText: "To MRP",
//                         filled: true,
//                         fillColor: AppColors.lightBlue,
//                         border: OutlineInputBorder(),
//                       ),
//                       keyboardType: TextInputType.number,
//                       onChanged: (value) {
//                         setState(() {
//                           toMRP = double.tryParse(value) ?? 0.0;
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),

//               // Stock Status (Radio Buttons)
//               Row(
//                 children: [
//                   Radio<String>(
//                     value: 'All',
//                     groupValue: stockStatus,
//                     onChanged: (value) {
//                       setState(() {
//                         stockStatus = value!;
//                       });
//                     },
//                   ),
//                   Text('All'),
//                   Radio<String>(
//                     value: 'Ready',
//                     groupValue: stockStatus,
//                     onChanged: (value) {
//                       setState(() {
//                         stockStatus = value!;
//                       });
//                     },
//                   ),
//                   Text('Ready'),
//                 ],
//               ),
//               SizedBox(height: 12),

//               // Filter and Clear buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         // Implement filter logic here
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.secondaryColor, // Background color as base color
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                           side: BorderSide(color: AppColors.primaryColor), // Border color as primary color
//                         ),
//                       ),
//                       icon: Icon(Icons.filter_list, color: AppColors.primaryColor), // Filter icon with primary color
//                       label: Text(
//                         "Filter",
//                         style: TextStyle(color: AppColors.primaryColor), // Text color as primary color
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8.0), // Add some spacing between the two buttons
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         setState(() {
//                           selectedCategory = null;
//                           selectedItem = null;
//                           selectedStyle = null;
//                           selectedShade = null;
//                           selectedSize = null;
//                           fromMRP = 0.0;
//                           toMRP = 0.0;
//                           stockStatus = 'All';
//                         });
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.secondaryColor, // Background color as base color
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                           side: BorderSide(color: AppColors.primaryColor), // Border color as primary color
//                         ),
//                       ),
//                       icon: Icon(Icons.clear, color: AppColors.primaryColor), // Clear icon with primary color
//                       label: Text(
//                         "Clear",
//                         style: TextStyle(color: AppColors.primaryColor), // Text color as primary color
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
// bottomNavigationBar: BottomNavigationBar(
//   currentIndex: _currentIndex,
//   onTap: _onItemTapped,
//   backgroundColor: AppColors.secondaryColor, // Set background color to

//   selectedItemColor: const Color.fromARGB(255, 221, 115, 82), // Set selected icon and text color to primaryColor
//   unselectedItemColor: AppColors.deepPurple, // Set unselected icon and text color to white or another color
//   items: [
//     BottomNavigationBarItem(
//       icon: Icon(Icons.dashboard),
//       label: 'Dashboard',
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.book_online),
//       label: 'Order Booking',
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.view_list),
//       label: 'Catalog',
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.shopping_cart),
//       label: 'Cart',
//     ),
//   ],
// )

//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/catalog/filter.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';

class CatalogPage extends StatefulWidget {
  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final List<Map<String, String>> items = [
    {
      'category': 'Kids',
      'style': 'Style 01',
      'design': 'Design A',
      'image': 'assets/garments/image_06.png',
    },
    {
      'category': 'Mens',
      'style': 'Style 02',
      'design': 'Design B',
      'image': 'assets/garments/image_07.png',
    },
    {
      'category': 'Women',
      'style': 'Style 03',
      'design': 'Design C',
      'image': 'assets/garments/image_08.png',
    },
    {
      'category': 'Sarees',
      'style': 'Style 04',
      'design': 'Design D',
      'image': 'assets/garments/image_09.png',
    },
    {
      'category': 'Kids',
      'style': 'Style 05',
      'design': 'Design E',
      'image': 'assets/garments/image_10.png',
    },
    {
      'category': 'Mens',
      'style': 'Style 06',
      'design': 'Design F',
      'image': 'assets/garments/image_11.png',
    },
    {
      'category': 'Women',
      'style': 'Style 07',
      'design': 'Design G',
      'image': 'assets/garments/image_12.png',
    },
  ];

  String filterOption = 'New Arrival';
  int viewOption = 0; // 0 - Grid, 1 - List, 2 - Expanded
  List<String> selectedStyles = []; // <-- Multi selection

  final List<String> styleOptions = [
    'Style 01',
    'Style 02',
    'Style 03',
    'Style 04',
    'Style 05',
    'Style 06',
    'Style 07',
  ];

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
          builder:
              (context) => IconButton(
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
          // Horizontal Style Options
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedStyles.clear(); // Clear all styles
                      });
                    },
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
                    ),
                    child: Text('All', style: TextStyle(fontSize: 12)),
                  ),
                  SizedBox(width: 8),
                  ...styleOptions.map((style) {
                    bool isSelected = selectedStyles.contains(style);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            if (isSelected) {
                              selectedStyles.remove(style);
                            } else {
                              selectedStyles.add(style);
                            }
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                isSelected
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                          ),
                          backgroundColor: Colors.white,
                          foregroundColor:
                              isSelected ? AppColors.primaryColor : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(style, style: TextStyle(fontSize: 12)),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          // Main Catalog View (Grid/List/Expanded)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  viewOption == 0
                      ? _buildGridView()
                      : viewOption == 1
                      ? _buildListView()
                      : _buildExpandedView(),
            ),
          ),
          // Buttons at Bottom
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color:
                            filterOption == 'New Arrival'
                                ? AppColors.primaryColor
                                : Colors.grey,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor:
                          filterOption == 'New Arrival'
                              ? AppColors.primaryColor
                              : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('New Arrival'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        filterOption = 'Featured';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color:
                            filterOption == 'Featured'
                                ? AppColors.primaryColor
                                : Colors.grey,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor:
                          filterOption == 'Featured'
                              ? AppColors.primaryColor
                              : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Featured'),
                  ),
                ),
                SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    _showFilterDialog();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryColor),
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  icon: Icon(Icons.filter_list),
                  label: Text('Filter'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build GridView
  Widget _buildGridView() {
    final filteredItems =
        selectedStyles.isEmpty
            ? items
            : items
                .where((item) => selectedStyles.contains(item['style']))
                .toList();
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(item);
      },
    );
  }

  // Build ListView
  Widget _buildListView() {
    final filteredItems =
        selectedStyles.isEmpty
            ? items
            : items
                .where((item) => selectedStyles.contains(item['style']))
                .toList();
    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(item);
      },
    );
  }

  // Build Expanded View
  Widget _buildExpandedView() {
    final filteredItems =
        selectedStyles.isEmpty
            ? items
            : items
                .where((item) => selectedStyles.contains(item['style']))
                .toList();
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
                child: Image.asset(
                  item['image']!,
                  fit: BoxFit.cover,
                  height: 500,
                  width: double.infinity,
                ),
              ),
              SizedBox(height: 8),
              Text(
                item['category']!,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text('Style: ${item['style']}', style: TextStyle(fontSize: 14)),
              Text('Design: ${item['design']}', style: TextStyle(fontSize: 14)),
            ],
          ),
        );
      },
    );
  }

  // Build Item Card
  Widget _buildItemCard(Map<String, String> item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              item['image']!,
              fit: BoxFit.cover,
              height: 150,
              width: double.infinity,
            ),
          ),
          SizedBox(height: 8),
          Text(
            item['category']!,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text('Style: ${item['style']}', style: TextStyle(fontSize: 14)),
          Text('Design: ${item['design']}', style: TextStyle(fontSize: 14)),
        ],
      ),
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
