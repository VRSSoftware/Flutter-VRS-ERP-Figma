
// import 'package:flutter/material.dart';
// import 'package:vrs_erp_figma/catalog/filter.dart';
// import 'package:vrs_erp_figma/constants/app_constants.dart';
// import 'package:vrs_erp_figma/screens/drawer_screen.dart';

// class CatalogPage extends StatefulWidget {
//   @override
//   _CatalogPageState createState() => _CatalogPageState();
// }

// class _CatalogPageState extends State<CatalogPage> {
//   final List<Map<String, String>> items = [
//     {
//       'category': 'Kids',
//       'style': 'Style 01',
//       'design': 'Design A',
//       'image': 'assets/garments/image_06.png',
//     },
//     {
//       'category': 'Mens',
//       'style': 'Style 02',
//       'design': 'Design B',
//       'image': 'assets/garments/image_07.png',
//     },
//     {
//       'category': 'Women',
//       'style': 'Style 03',
//       'design': 'Design C',
//       'image': 'assets/garments/image_08.png',
//     },
//     {
//       'category': 'Sarees',
//       'style': 'Style 04',
//       'design': 'Design D',
//       'image': 'assets/garments/image_09.png',
//     },
//     {
//       'category': 'Kids',
//       'style': 'Style 05',
//       'design': 'Design E',
//       'image': 'assets/garments/image_10.png',
//     },
//     {
//       'category': 'Mens',
//       'style': 'Style 06',
//       'design': 'Design F',
//       'image': 'assets/garments/image_11.png',
//     },
//     {
//       'category': 'Women',
//       'style': 'Style 07',
//       'design': 'Design G',
//       'image': 'assets/garments/image_12.png',
//     },
//   ];

//   String filterOption = 'New Arrival';
//   int viewOption = 0; // 0 - Grid, 1 - List, 2 - Expanded
//   List<String> selectedStyles = []; // <-- Multi selection

//   final List<String> styleOptions = [
//     'Style 01',
//     'Style 02',
//     'Style 03',
//     'Style 04',
//     'Style 05',
//     'Style 06',
//     'Style 07',
//   ];

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
//           builder:
//               (context) => IconButton(
//                 icon: Icon(Icons.menu, color: Colors.white),
//                 onPressed: () => Scaffold.of(context).openDrawer(),
//               ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(
//               viewOption == 0
//                   ? Icons.view_list
//                   : viewOption == 1
//                   ? Icons.grid_on
//                   : Icons.expand,
//               color: Colors.white,
//             ),
//             onPressed: () {
//               setState(() {
//                 viewOption = (viewOption + 1) % 3;
//               });
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Horizontal Style Options
//           Container(
//             height: 50,
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   SizedBox(width: 16),
//                   OutlinedButton(
//                     onPressed: () {
//                       setState(() {
//                         selectedStyles.clear(); // Clear all styles
//                       });
//                     },
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(
//                         color:
//                             selectedStyles.isEmpty
//                                 ? AppColors.primaryColor
//                                 : Colors.grey,
//                       ),
//                       backgroundColor: Colors.white,
//                       foregroundColor:
//                           selectedStyles.isEmpty
//                               ? AppColors.primaryColor
//                               : Colors.grey,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text('All', style: TextStyle(fontSize: 12)),
//                   ),
//                   SizedBox(width: 8),
//                   ...styleOptions.map((style) {
//                     bool isSelected = selectedStyles.contains(style);
//                     return Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: OutlinedButton(
//                         onPressed: () {
//                           setState(() {
//                             if (isSelected) {
//                               selectedStyles.remove(style);
//                             } else {
//                               selectedStyles.add(style);
//                             }
//                           });
//                         },
//                         style: OutlinedButton.styleFrom(
//                           side: BorderSide(
//                             color:
//                                 isSelected
//                                     ? AppColors.primaryColor
//                                     : Colors.grey,
//                           ),
//                           backgroundColor: Colors.white,
//                           foregroundColor:
//                               isSelected ? AppColors.primaryColor : Colors.grey,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: Text(style, style: TextStyle(fontSize: 12)),
//                       ),
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//           ),
//           // Main Catalog View (Grid/List/Expanded)
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child:
//                   viewOption == 0
//                       ? _buildGridView()
//                       : viewOption == 1
//                       ? _buildListView()
//                       : _buildExpandedView(),
//             ),
//           ),
//           // Buttons at Bottom
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {
//                       setState(() {
//                         filterOption = 'New Arrival';
//                       });
//                     },
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(
//                         color:
//                             filterOption == 'New Arrival'
//                                 ? AppColors.primaryColor
//                                 : Colors.grey,
//                       ),
//                       backgroundColor: Colors.white,
//                       foregroundColor:
//                           filterOption == 'New Arrival'
//                               ? AppColors.primaryColor
//                               : Colors.grey,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text('New Arrival'),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {
//                       setState(() {
//                         filterOption = 'Featured';
//                       });
//                     },
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(
//                         color:
//                             filterOption == 'Featured'
//                                 ? AppColors.primaryColor
//                                 : Colors.grey,
//                       ),
//                       backgroundColor: Colors.white,
//                       foregroundColor:
//                           filterOption == 'Featured'
//                               ? AppColors.primaryColor
//                               : Colors.grey,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text('Featured'),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 OutlinedButton.icon(
//                   onPressed: () {
//                     _showFilterDialog();
//                   },
//                   style: OutlinedButton.styleFrom(
//                     side: BorderSide(color: AppColors.primaryColor),
//                     backgroundColor: Colors.white,
//                     foregroundColor: AppColors.primaryColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                   ),
//                   icon: Icon(Icons.filter_list),
//                   label: Text('Filter'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Build GridView
//   Widget _buildGridView() {
//     final filteredItems =
//         selectedStyles.isEmpty
//             ? items
//             : items
//                 .where((item) => selectedStyles.contains(item['style']))
//                 .toList();
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 16.0,
//         mainAxisSpacing: 16.0,
//         childAspectRatio: 0.7,
//       ),
//       itemCount: filteredItems.length,
//       itemBuilder: (context, index) {
//         final item = filteredItems[index];
//         return _buildItemCard(item);
//       },
//     );
//   }

//   // Build ListView
//   Widget _buildListView() {
//     final filteredItems =
//         selectedStyles.isEmpty
//             ? items
//             : items
//                 .where((item) => selectedStyles.contains(item['style']))
//                 .toList();
//     return ListView.builder(
//       itemCount: filteredItems.length,
//       itemBuilder: (context, index) {
//         final item = filteredItems[index];
//         return _buildItemCard(item);
//       },
//     );
//   }

//   // Build Expanded View
//   Widget _buildExpandedView() {
//     final filteredItems =
//         selectedStyles.isEmpty
//             ? items
//             : items
//                 .where((item) => selectedStyles.contains(item['style']))
//                 .toList();
//     return ListView.builder(
//       itemCount: filteredItems.length,
//       itemBuilder: (context, index) {
//         final item = filteredItems[index];
//         return Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           color: Colors.white,
//           child: Column(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.asset(
//                   item['image']!,
//                   fit: BoxFit.cover,
//                   height: 500,
//                   width: double.infinity,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 item['category']!,
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               Text('Style: ${item['style']}', style: TextStyle(fontSize: 14)),
//               Text('Design: ${item['design']}', style: TextStyle(fontSize: 14)),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Build Item Card
//   Widget _buildItemCard(Map<String, String> item) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.white,
//       child: Column(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.asset(
//               item['image']!,
//               fit: BoxFit.cover,
//               height: 150,
//               width: double.infinity,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             item['category']!,
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           Text('Style: ${item['style']}', style: TextStyle(fontSize: 14)),
//           Text('Design: ${item['design']}', style: TextStyle(fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   void _showFilterDialog() {
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) => FilterPage(),
//         transitionDuration: Duration(milliseconds: 500),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           final begin = Offset(0.0, 1.0);
//           final end = Offset.zero;
//           final curve = Curves.easeInOut;

//           var tween = Tween(
//             begin: begin,
//             end: end,
//           ).chain(CurveTween(curve: curve));
//           var offsetAnimation = animation.drive(tween);

//           return SlideTransition(position: offsetAnimation, child: child);
//         },
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:vrs_erp_figma/catalog/filter.dart';
// import 'package:vrs_erp_figma/constants/app_constants.dart';
// import 'package:vrs_erp_figma/screens/drawer_screen.dart';

// class CatalogPage extends StatefulWidget {
//   @override
//   _CatalogPageState createState() => _CatalogPageState();
// }

// class _CatalogPageState extends State<CatalogPage> {
//   final List<Map<String, String>> items = [
//     {
//       'category': 'Kids',
//       'style': 'Style 01',
//       'design': 'Design A',
//       'image': 'assets/garments/image_06.png',
//     },
//     {
//       'category': 'Mens',
//       'style': 'Style 02',
//       'design': 'Design B',
//       'image': 'assets/garments/image_07.png',
//     },
//     {
//       'category': 'Women',
//       'style': 'Style 03',
//       'design': 'Design C',
//       'image': 'assets/garments/image_08.png',
//     },
//     {
//       'category': 'Sarees',
//       'style': 'Style 04',
//       'design': 'Design D',
//       'image': 'assets/garments/image_09.png',
//     },
//     {
//       'category': 'Kids',
//       'style': 'Style 05',
//       'design': 'Design E',
//       'image': 'assets/garments/image_10.png',
//     },
//     {
//       'category': 'Mens',
//       'style': 'Style 06',
//       'design': 'Design F',
//       'image': 'assets/garments/image_11.png',
//     },
//     {
//       'category': 'Women',
//       'style': 'Style 07',
//       'design': 'Design G',
//       'image': 'assets/garments/image_12.png',
//     },
//   ];

//   String filterOption = 'New Arrival';
//   int viewOption = 0; // 0 - Grid, 1 - List, 2 - Expanded
//   List<String> selectedStyles = [];

//   final List<String> styleOptions = [
//     'Style 01',
//     'Style 02',
//     'Style 03',
//     'Style 04',
//     'Style 05',
//     'Style 06',
//     'Style 07',
//   ];

//   // Variables for received arguments
//   String? itemKey;
//   String? itemSubGrpKey;
//   String? coBr;
//   String? fcYrId;

//   @override
//   void initState() {
//     super.initState();
//     // Fetch the arguments after the first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//       if (args != null) {
//         setState(() {
//           itemKey = args['itemKey']?.toString();
//           itemSubGrpKey = args['itemSubGrpKey']?.toString();
//           coBr = args['coBr']?.toString();
//           fcYrId = args['fcYrId']?.toString();
//         });
//         // Debugging: print received values
//         print('Received itemKey: $itemKey');
//         print('Received itemSubGrpKey: $itemSubGrpKey');
//         print('Received coBr: $coBr');
//         print('Received fcYrId: $fcYrId');
//       }
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
//         actions: [
//           IconButton(
//             icon: Icon(
//               viewOption == 0
//                   ? Icons.view_list
//                   : viewOption == 1
//                       ? Icons.grid_on
//                       : Icons.expand,
//               color: Colors.white,
//             ),
//             onPressed: () {
//               setState(() {
//                 viewOption = (viewOption + 1) % 3;
//               });
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Horizontal Style Options
//           _buildStyleOptions(),
//           // Main Catalog View (Grid/List/Expanded)
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: viewOption == 0
//                   ? _buildGridView()
//                   : viewOption == 1
//                       ? _buildListView()
//                       : _buildExpandedView(),
//             ),
//           ),
//           // Bottom Filter Buttons
//           _buildBottomButtons(),
//         ],
//       ),
//     );
//   }

//   Widget _buildStyleOptions() {
//     return Container(
//       height: 50,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             SizedBox(width: 16),
//             OutlinedButton(
//               onPressed: () {
//                 setState(() {
//                   selectedStyles.clear();
//                 });
//               },
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(
//                   color: selectedStyles.isEmpty
//                       ? AppColors.primaryColor
//                       : Colors.grey,
//                 ),
//                 backgroundColor: Colors.white,
//                 foregroundColor: selectedStyles.isEmpty
//                     ? AppColors.primaryColor
//                     : Colors.grey,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text('All', style: TextStyle(fontSize: 12)),
//             ),
//             SizedBox(width: 8),
//             ...styleOptions.map((style) {
//               bool isSelected = selectedStyles.contains(style);
//               return Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: OutlinedButton(
//                   onPressed: () {
//                     setState(() {
//                       if (isSelected) {
//                         selectedStyles.remove(style);
//                       } else {
//                         selectedStyles.add(style);
//                       }
//                     });
//                   },
//                   style: OutlinedButton.styleFrom(
//                     side: BorderSide(
//                       color: isSelected
//                           ? AppColors.primaryColor
//                           : Colors.grey,
//                     ),
//                     backgroundColor: Colors.white,
//                     foregroundColor: isSelected
//                         ? AppColors.primaryColor
//                         : Colors.grey,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(style, style: TextStyle(fontSize: 12)),
//                 ),
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGridView() {
//     final filteredItems = selectedStyles.isEmpty
//         ? items
//         : items.where((item) => selectedStyles.contains(item['style'])).toList();
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 16.0,
//         mainAxisSpacing: 16.0,
//         childAspectRatio: 0.7,
//       ),
//       itemCount: filteredItems.length,
//       itemBuilder: (context, index) {
//         final item = filteredItems[index];
//         return _buildItemCard(item);
//       },
//     );
//   }

//   Widget _buildListView() {
//     final filteredItems = selectedStyles.isEmpty
//         ? items
//         : items.where((item) => selectedStyles.contains(item['style'])).toList();
//     return ListView.builder(
//       itemCount: filteredItems.length,
//       itemBuilder: (context, index) {
//         final item = filteredItems[index];
//         return _buildItemCard(item);
//       },
//     );
//   }

//   Widget _buildExpandedView() {
//     final filteredItems = selectedStyles.isEmpty
//         ? items
//         : items.where((item) => selectedStyles.contains(item['style'])).toList();
//     return ListView.builder(
//       itemCount: filteredItems.length,
//       itemBuilder: (context, index) {
//         final item = filteredItems[index];
//         return Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           color: Colors.white,
//           child: Column(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.asset(
//                   item['image']!,
//                   fit: BoxFit.cover,
//                   height: 500,
//                   width: double.infinity,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 item['category']!,
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               Text('Style: ${item['style']}', style: TextStyle(fontSize: 14)),
//               Text('Design: ${item['design']}', style: TextStyle(fontSize: 14)),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildItemCard(Map<String, String> item) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.white,
//       child: Column(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.asset(
//               item['image']!,
//               fit: BoxFit.cover,
//               height: 150,
//               width: double.infinity,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             item['category']!,
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           Text('Style: ${item['style']}', style: TextStyle(fontSize: 14)),
//           Text('Design: ${item['design']}', style: TextStyle(fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomButtons() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       color: Colors.white,
//       child: Row(
//         children: [
//           Expanded(
//             child: OutlinedButton(
//               onPressed: () {
//                 setState(() {
//                   filterOption = 'New Arrival';
//                 });
//               },
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(
//                   color: filterOption == 'New Arrival'
//                       ? AppColors.primaryColor
//                       : Colors.grey,
//                 ),
//                 backgroundColor: Colors.white,
//                 foregroundColor: filterOption == 'New Arrival'
//                     ? AppColors.primaryColor
//                     : Colors.grey,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text('New Arrival'),
//             ),
//           ),
//           SizedBox(width: 8),
//           Expanded(
//             child: OutlinedButton(
//               onPressed: () {
//                 setState(() {
//                   filterOption = 'Featured';
//                 });
//               },
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(
//                   color: filterOption == 'Featured'
//                       ? AppColors.primaryColor
//                       : Colors.grey,
//                 ),
//                 backgroundColor: Colors.white,
//                 foregroundColor: filterOption == 'Featured'
//                     ? AppColors.primaryColor
//                     : Colors.grey,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text('Featured'),
//             ),
//           ),
//           SizedBox(width: 8),
//           OutlinedButton.icon(
//             onPressed: _showFilterDialog,
//             style: OutlinedButton.styleFrom(
//               side: BorderSide(color: AppColors.primaryColor),
//               backgroundColor: Colors.white,
//               foregroundColor: AppColors.primaryColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//             ),
//             icon: Icon(Icons.filter_list),
//             label: Text('Filter'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showFilterDialog() {
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) => FilterPage(),
//         transitionDuration: Duration(milliseconds: 500),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           final begin = Offset(0.0, 1.0);
//           final end = Offset.zero;
//           final curve = Curves.easeInOut;

//           var tween = Tween(
//             begin: begin,
//             end: end,
//           ).chain(CurveTween(curve: curve));
//           var offsetAnimation = animation.drive(tween);

//           return SlideTransition(position: offsetAnimation, child: child);
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/catalog/filter.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/catalog.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:vrs_erp_figma/catalog/catalog.dart'; // Ensure you have this model
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vrs_erp_figma/services/app_services.dart';

class CatalogPage extends StatefulWidget {
  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String filterOption = 'New Arrival';
  int viewOption = 0; // 0 - Grid, 1 - List, 2 - Expanded
  List<String> selectedStyles = [];
  List<String> selectedShades = []; // For storing selected shades
  List<Catalog> catalogItems = [];

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
          // Horizontal Shade Selection
          _buildShadeSelection(),
          // Main Catalog View (Grid/List/Expanded)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: catalogItems.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : viewOption == 0
                      ? _buildGridView()
                      : viewOption == 1
                          ? _buildListView()
                          : _buildExpandedView(),
            ),
          ),
          // Bottom Filter Buttons (unchanged)
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildShadeSelection() {
    // Extract all unique shades from the catalog items
    final allShades = catalogItems
        .expand((item) => item.shadeName?.split(',') ?? [])
        .toSet()
        .toList();

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 16),
            ...allShades.map((shade) {
              bool isSelected = selectedShades.contains(shade);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      if (isSelected) {
                        selectedShades.remove(shade);
                      } else {
                        selectedShades.add(shade);
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
                  ),
                  child: Text(shade, style: TextStyle(fontSize: 12)),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    final filteredItems = selectedShades.isEmpty
        ? catalogItems
        : catalogItems.where((item) {
            final shades = item.shadeName?.split(',') ?? [];
            return shades.any((shade) => selectedShades.contains(shade));
          }).toList();
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

  Widget _buildListView() {
    final filteredItems = selectedShades.isEmpty
        ? catalogItems
        : catalogItems.where((item) {
            final shades = item.shadeName?.split(',') ?? [];
            return shades.any((shade) => selectedShades.contains(shade));
          }).toList();
    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildExpandedView() {
    final filteredItems = selectedShades.isEmpty
        ? catalogItems
        : catalogItems.where((item) {
            final shades = item.shadeName?.split(',') ?? [];
            return shades.any((shade) => selectedShades.contains(shade));
          }).toList();
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
                  height: 500,
                  width: double.infinity,
                ),
              ),
              SizedBox(height: 8),
              Text(
                item.itemName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text('Style: ${item.styleCode}', style: TextStyle(fontSize: 14)),
              Text('MRP: ${item.mrp}', style: TextStyle(fontSize: 14)),
              Text('WSP: ${item.wsp}', style: TextStyle(fontSize: 14)),
              Text('Shade: ${item.shadeName}', style: TextStyle(fontSize: 14)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(Catalog item) {
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
              height: 150,
              width: double.infinity,
            ),
          ),
          SizedBox(height: 8),
          Text(
            item.itemName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text('Style: ${item.styleCode}', style: TextStyle(fontSize: 14)),
          Text('MRP: ${item.mrp}', style: TextStyle(fontSize: 14)),
          Text('WSP: ${item.wsp}', style: TextStyle(fontSize: 14)),
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

  Widget _buildBottomButtons() {
    return Container(
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
                  color: filterOption == 'New Arrival'
                      ? AppColors.primaryColor
                      : Colors.grey,
                ),
                backgroundColor: Colors.white,
                foregroundColor: filterOption == 'New Arrival'
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
                  color: filterOption == 'Featured'
                      ? AppColors.primaryColor
                      : Colors.grey,
                ),
                backgroundColor: Colors.white,
                foregroundColor: filterOption == 'Featured'
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
            onPressed: _showFilterDialog,
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
