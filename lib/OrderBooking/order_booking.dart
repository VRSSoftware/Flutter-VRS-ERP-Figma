// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:provider/provider.dart';

// import 'package:vrs_erp_figma/OrderBooking/orderbooking_drawer.dart';
// import 'package:vrs_erp_figma/constants/app_constants.dart';
// import 'package:vrs_erp_figma/models/CartModel.dart';
// import 'package:vrs_erp_figma/models/category.dart';
// import 'package:vrs_erp_figma/models/item.dart';
// import 'package:vrs_erp_figma/screens/drawer_screen.dart';
// import 'package:vrs_erp_figma/services/app_services.dart';
// import 'package:vrs_erp_figma/OrderBooking/barcode/barcodewidget.dart';
// import 'package:vrs_erp_figma/widget/bottom_navbar.dart';
// import 'package:vrs_erp_figma/widget/filterdailogwidget.dart';

// class OrderBookingScreen extends StatefulWidget {
//   @override
//   _OrderBookingScreenState createState() => _OrderBookingScreenState();
// }

// class _OrderBookingScreenState extends State<OrderBookingScreen> {
//   int _currentIndex = 0;
//   final CarouselSliderController _carouselController =
//       CarouselSliderController();

//   String? _selectedCategoryKey = '-1';
//   String? _selectedCategoryName = 'All';
//   String? coBr = UserSession.coBrId??'';
//   String? fcYrId = UserSession.userFcYr??'';
//   List<Category> _categories = [];
//   List<Item> _items = [];
//   List<Item> _allItems = [];
//   bool showBarcodeWidget = false;
//   bool _isLoadingCategories = true;
//   bool _isLoadingItems = false;
//   bool hasFiltered = false;
//   // int _cartItemCount = 0;

//   Set<String> _activeFilters = {'mrp', 'wsp', 'shades', 'stylecode'};

//   void _updateFilters(Set<String> newFilters) {
//     setState(() {
//       _activeFilters = newFilters;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchCategories();
//     fetchAllItems();

//     if (coBr != null && fcYrId != null) {
//       _fetchCartCount();
//     }
//   }

//  // Replace the existing _fetchCartCount method
// Future<void> _fetchCartCount() async {
//   try {
//     final data = await ApiService.getSalesOrderData(
//       coBrId: UserSession.coBrId??'',
//       userId: UserSession.userName??'',
//       fcYrId: UserSession.userFcYr??'',
//       barcode: showBarcodeWidget ? 'true' : 'false',
//     );
    
//     final cartModel = Provider.of<CartModel>(context, listen: false);
//     cartModel.updateCount(data['cartItemCount'] ?? 0);
//   } catch (e) {
//     print('Error fetching cart count: $e');
//   }
// }

//   Future<void> _fetchCategories() async {
//     try {
//       final items = await ApiService.fetchAllItems();
//       setState(() {
//         _items = items;
//         _allItems = items;
//       });
//     } catch (e) {
//       print('Error fetching categories: $e');
//     }
//   }

//   Future<void> fetchAllItems() async {
//     try {
//       final categories = await ApiService.fetchCategories();
//       setState(() {
//         _categories = [
//         //  Category(itemSubGrpKey: '-1', itemSubGrpName: "ALL"),
//           ...categories,
//         ];
//         _isLoadingCategories = false;
//       });
//     } catch (e) {
//       print('Error fetching categories: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cartModel = Provider.of<CartModel>(context);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: DrawerScreen(),
//       appBar: AppBar(
//         title: Text(
//           showBarcodeWidget ? 'Barcode' : 'Order Booking',
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: AppColors.primaryColor,
//         elevation: 1,
//         leading:
//             showBarcodeWidget
//                 ? IconButton(
//                   icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//                   onPressed: () {
//                     setState(() {
//                       showBarcodeWidget = false;
//                     });
//                   },
//                 )
//                 : Builder(
//                   builder:
//                       (context) => IconButton(
//                         icon: const Icon(Icons.menu, color: Colors.white),
//                         onPressed: () => Scaffold.of(context).openDrawer(),
//                       ),
//                 ),
//         automaticallyImplyLeading: false,
//         actions: [
//           // Show filter icon only in barcode mode
//           if (showBarcodeWidget)
//             IconButton(
//               icon: const Icon(Icons.filter_list, color: Colors.white),
//               onPressed: () {
//                 final overlay = Overlay.of(context);
//                 final renderBox = context.findRenderObject() as RenderBox;
//                 final position = renderBox.localToGlobal(Offset.zero);

//                 late OverlayEntry entry;

//                 entry = OverlayEntry(
//                   builder:
//                       (context) => Positioned(
//                         top: position.dy + kToolbarHeight,
//                         right: 16,
//                         child: Material(
//                           color: Colors.transparent,
//                           child: FilterMenuWidget(
//                             initialFilters: _activeFilters,
//                             onApply: (newFilters) {
//                               _updateFilters(newFilters);
//                               entry.remove();
//                             },
//                             onCancel: () => entry.remove(),
//                           ),
//                         ),
//                       ),
//                 );

//                 overlay.insert(entry);
//               },
//             ),

//           // Cart Icon for both modes
//           IconButton(
//             icon: Stack(
//               children: [
//                 const Icon(CupertinoIcons.cart_badge_plus, color: Colors.white),
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: Container(
//                     padding: const EdgeInsets.all(2),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     constraints: const BoxConstraints(
//                       minWidth: 14,
//                       minHeight: 14,
//                     ),
//                     child: Text(
//                      '${cartModel.count}',
//                       style: const TextStyle(color: Colors.white, fontSize: 8),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             onPressed: () {
//               Navigator.pushNamed(
//                 context,
//                 '/viewOrder',
//                 arguments: {'barcode': showBarcodeWidget}, // Pass barcode state
//               ).then((_) => _fetchCartCount());

//             },
//           ),
//           // Always show the three-dot menu
//           Builder(
//             builder:
//                 (context) => IconButton(
//                   icon: const Icon(Icons.more_vert, color: Colors.white),
//                   onPressed: () {
//                     final RenderBox button =
//                         context.findRenderObject() as RenderBox;
//                     final Offset position = button.localToGlobal(Offset.zero);
//                     showOrderMenu(context, position);
//                   },
//                 ),
//           ),
//         ],
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             bool isMobile = constraints.maxWidth < 600;
//             int columnCount = isMobile ? 1 : 2;
//             return SingleChildScrollView(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                 child: IntrinsicHeight(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         width:
//                             isMobile
//                                 ? double.infinity
//                                 : (constraints.maxWidth / columnCount) - 24,
//                         child: Row(
//                           children: [
//                             Checkbox(
//                               value: showBarcodeWidget,
//                               onChanged: (value) {
//                                 setState(() {
//                                   showBarcodeWidget = value ?? false;
//                                   _fetchCartCount();
//                                 });
//                               },
//                             ),
//                             const Text(
//                               "Order Booking Barcode Wise",
//                               style: TextStyle(fontWeight: FontWeight.w600),
//                             ),
//                           ],
//                         ),
//                       ),

//                       if (showBarcodeWidget)
//                         SizedBox(
//                           width:
//                               isMobile
//                                   ? double.infinity
//                                   : (constraints.maxWidth / columnCount) - 24,
//                           child: BarcodeWiseWidget(
//                             onFilterPressed: (barcode) {
//                               print("Barcode: $barcode");
//                               setState(() {
//                                 hasFiltered = true;
//                               });
//                             },
//                             // activeFilters: _activeFilters,
//                           ),
//                         ),

//                       if (!showBarcodeWidget) ...[
//                         SizedBox(height: 15),
//                         Text(
//                           "Categories",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         _isLoadingCategories
//                             ? Center(child: CircularProgressIndicator())
//                             : Wrap(
//                               spacing: 10,
//                               runSpacing: 10,
//                               alignment: WrapAlignment.start,
//                               children:
//                                   _categories.map((category) {
//                                     return Container(
//                                       width:
//                                           (MediaQuery.of(context).size.width -
//                                               60) /
//                                           2,
//                                       child: OutlinedButton(
//                                         onPressed: () {
//                                           setState(() {
//                                             // _selectedCategoryKey =
//                                             //     category.itemSubGrpKey;
//                                             // _selectedCategoryName =
//                                             //     category.itemSubGrpName;

//                                             // if (_selectedCategoryKey == '-1') {
//                                             //   _items = _allItems;
//                                             // } else {
//                                             //   _items =
//                                             //       _allItems
//                                             //           .where(
//                                             //             (item) =>
//                                             //                 item.itemSubGrpKey ==
//                                             //                 _selectedCategoryKey,
//                                             //           )
//                                             //           .toList();
//                                             // }
//                                           });
//                                           Navigator.pushNamed(
//                                             context,
//                                             '/orderpage',
//                                             arguments: {
//                                               'itemKey': null,
//                                               'itemSubGrpKey':
//                                                   category.itemSubGrpKey,
//                                               'itemName':
//                                                   category.itemSubGrpName,
//                                               'coBr': coBr,
//                                               'fcYrId': fcYrId,
//                                             },
//                                           );
//                                         },
//                                         style: ButtonStyle(
//                                           backgroundColor:
//                                               MaterialStateProperty.all(
//                                                 _selectedCategoryKey ==
//                                                         category.itemSubGrpKey
//                                                     ? AppColors.primaryColor
//                                                     : Colors.white,
//                                               ),
//                                           side: MaterialStateProperty.all(
//                                             BorderSide(
//                                               color: AppColors.primaryColor,
//                                               width: 2,
//                                             ),
//                                           ),
//                                           shape: MaterialStateProperty.all(
//                                             RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                           ),
//                                         ),
//                                         child: Text(
//                                           category.itemSubGrpName,
//                                           style: TextStyle(
//                                             color:
//                                                 _selectedCategoryKey ==
//                                                         category.itemSubGrpKey
//                                                     ? Colors.white
//                                                     : AppColors.primaryColor,
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                             ),

//                         SizedBox(height: 20),
//                         if (_selectedCategoryKey != null) _buildCategoryItems(),
//                       ],

//                       Spacer(),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationWidget(
//         currentIndex: 2, // 👈 Highlight Order icon
//         onTap: (index) {
//           if (index == 0) Navigator.pushNamed(context, '/home');
//           if (index == 1) Navigator.pushNamed(context, '/catalog');
//           if (index == 2) return; // Already on Order
//           if (index == 3) Navigator.pushNamed(context, '/stockReport');
//           if (index == 4) Navigator.pushNamed(context, '/dashboard');
//         },
//       ),
//     );
//   }

//   Widget _buildCategoryItems() {
//     double buttonWidth = (MediaQuery.of(context).size.width - 60) / 2;
//     double buttonHeight = 50;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Items in $_selectedCategoryName",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         SizedBox(height: 10),
//         _isLoadingItems
//             ? Center(child: CircularProgressIndicator())
//             : Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               alignment: WrapAlignment.start,
//               children:
//                   _items.map((item) {
//                     return SizedBox(
//                       width: buttonWidth,
//                       height: buttonHeight,
//                       child: OutlinedButton(
//                         style: OutlinedButton.styleFrom(
//                           side: BorderSide(color: Colors.grey.shade300),
//                           backgroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12), // curve 12
//                           ),
//                         ),
//                         onPressed: () {
//                           print(item.itemKey);
//                           print(item.itemSubGrpKey);
//                           Navigator.pushNamed(
//                             context,
//                             '/orderpage',
//                             arguments: {
//                               'itemKey': item.itemKey,
//                               'itemName': item.itemName,
//                               'itemSubGrpKey': item.itemSubGrpKey,
//                               'coBr': coBr,
//                               'fcYrId': fcYrId,
//                             },
//                           ).then((_) => _fetchCartCount());
//                         },
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: Text(
//                             item.itemName,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.black87,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//             ),
//       ],
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:vrs_erp_figma/OrderBooking/orderbooking_drawer.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/dashboard/orderStatus.dart';
import 'package:vrs_erp_figma/models/CartModel.dart';
import 'package:vrs_erp_figma/models/category.dart';
import 'package:vrs_erp_figma/models/item.dart';
import 'package:vrs_erp_figma/register/register.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:vrs_erp_figma/services/app_services.dart';
import 'package:vrs_erp_figma/OrderBooking/barcode/barcodewidget.dart';
import 'package:vrs_erp_figma/widget/bottom_navbar.dart';
import 'package:vrs_erp_figma/widget/filterdailogwidget.dart';

class OrderBookingScreen extends StatefulWidget {
  @override
  _OrderBookingScreenState createState() => _OrderBookingScreenState();
}

class _OrderBookingScreenState extends State<OrderBookingScreen> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  String? _selectedCategoryKey = '-1';
  String? _selectedCategoryName = 'All';
  String? coBr = UserSession.coBrId ?? '';
  String? fcYrId = UserSession.userFcYr ?? '';
  List<Category> _categories = [];
  List<Item> _items = [];
  List<Item> _allItems = [];
  bool showBarcodeWidget = false;
  bool _isLoadingCategories = true;
  bool _isLoadingItems = false;
  bool hasFiltered = false;
  // int _cartItemCount = 0;

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

    if (coBr != null && fcYrId != null) {
      _fetchCartCount();
    }
  }

  // Replace the existing _fetchCartCount method
  Future<void> _fetchCartCount() async {
    try {
      final data = await ApiService.getSalesOrderData(
        coBrId: UserSession.coBrId ?? '',
        userId: UserSession.userName ?? '',
        fcYrId: UserSession.userFcYr ?? '',
        barcode: showBarcodeWidget ? 'true' : 'false',
      );

      final cartModel = Provider.of<CartModel>(context, listen: false);
      cartModel.updateCount(data['cartItemCount'] ?? 0);
    } catch (e) {
      print('Error fetching cart count: $e');
    }
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
          //  Category(itemSubGrpKey: '-1', itemSubGrpName: "ALL"),
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
    final cartModel = Provider.of<CartModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
      appBar: AppBar(
        title: Text(
          showBarcodeWidget ? 'Barcode' : 'Order Booking',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 1,
        leading: showBarcodeWidget
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  setState(() {
                    showBarcodeWidget = false;
                  });
                },
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        automaticallyImplyLeading: false,
        // actions: [
        //   // Show filter icon only in barcode mode
        //   if (showBarcodeWidget)
        //     // IconButton(
        //     //   icon: const Icon(Icons.filter_list, color: Colors.white),
        //     //   onPressed: () {
        //     //     final overlay = Overlay.of(context);
        //     //     final renderBox = context.findRenderObject() as RenderBox;
        //     //     final position = renderBox.localToGlobal(Offset.zero);

        //     //     late OverlayEntry entry;

        //     //     entry = OverlayEntry(
        //     //       builder: (context) => Positioned(
        //     //         top: position.dy + kToolbarHeight,
        //     //         right: 16,
        //     //         child: Material(
        //     //           color: Colors.transparent,
        //     //           child: FilterMenuWidget(
        //     //             initialFilters: _activeFilters,
        //     //             onApply: (newFilters) {
        //     //               _updateFilters(newFilters);
        //     //               entry.remove();
        //     //             },
        //     //             onCancel: () => entry.remove(),
        //     //           ),
        //     //         ),
        //     //       ),
        //     //     );

        //     //     overlay.insert(entry);
        //     //   },
        //     // ),

        //   // Cart Icon for both modes
        //   IconButton(
        //     icon: Stack(
        //       children: [
        //         const Icon(CupertinoIcons.cart_badge_plus, color: Colors.white),
        //         Positioned(
        //           right: 0,
        //           top: 0,
        //           child: Container(
        //             padding: const EdgeInsets.all(2),
        //             decoration: BoxDecoration(
        //               color: Colors.red,
        //               borderRadius: BorderRadius.circular(0),
        //             ),
        //             constraints: const BoxConstraints(
        //               minWidth: 14,
        //               minHeight: 14,
        //             ),
        //             child: Text(
        //               '${cartModel.count}',
        //               style: const TextStyle(color: Colors.white, fontSize: 8),
        //               textAlign: TextAlign.center,
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //     onPressed: () {
        //       if(showBarcodeWidget){
        //         Navigator.pushNamed(
        //           context,
        //           '/viewOrder2',
        //           arguments: {'barcode': showBarcodeWidget}, // Pass barcode state
        //         ).then((_) => _fetchCartCount());
        //       }else{
        //       Navigator.pushNamed(
        //         context,
        //         '/viewOrder',
        //         arguments: {'barcode': showBarcodeWidget}, // Pass barcode state
        //       ).then((_) => _fetchCartCount());
        //       }
        //     },
        //   ),

        //       IconButton(
        //     icon: const Icon(Icons.receipt_long, color: Colors.white, size: 24),
        //     tooltip: 'My Orders',
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) =>  RegisterPage()),
        //       );
        //     },
        //   ),
        //   // Always show the three-dot menu
        //   // Builder(
        //   //   builder: (context) => IconButton(
        //   //     icon: const Icon(Icons.more_vert, color: Colors.white),
        //   //     onPressed: () {
        //   //       final RenderBox button = context.findRenderObject() as RenderBox;
        //   //       final Offset position = button.localToGlobal(Offset.zero);
        //   //       showOrderMenu(context, position);
        //   //     },
        //   //   ),
        //   // ),
        // ],
      actions: [
  // Cart Icon for both modes (Order Booking and Barcode)
  IconButton(
    icon: Stack(
      children: [
        const Icon(CupertinoIcons.cart_badge_plus, color: Colors.white),
        if (cartModel.count >= 0)
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
                '${cartModel.count}',
                style: const TextStyle(color: Colors.white, fontSize: 8),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    ),
    onPressed: () {
      if (showBarcodeWidget) {
        Navigator.pushNamed(
          context,
          '/viewOrder2',
          arguments: {'barcode': showBarcodeWidget},
        ).then((_) => _fetchCartCount());
      } else {
        Navigator.pushNamed(
          context,
          '/viewOrder',
          arguments: {'barcode': showBarcodeWidget},
        ).then((_) => _fetchCartCount());
      }
    },
  ),

  // Orders icon
  IconButton(
    icon: const Icon(Icons.receipt_long, color: Colors.white, size: 24),
    tooltip: 'My Orders',
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegisterPage()),
      );
    },
  ),
],

      
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Reduced padding
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Button width: total width minus 16 (padding) minus 8 (gap), divided by 2, increased by 20%
            double buttonWidth = ((constraints.maxWidth - 16 - 8) / 2) * 1;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Checkbox(
                              value: showBarcodeWidget,
                              onChanged: (value) {
                                setState(() {
                                  showBarcodeWidget = value ?? false;
                                  _fetchCartCount();
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
                          width: double.infinity,
                          child: BarcodeWiseWidget(
                            onFilterPressed: (barcode) {
                              print("Barcode: $barcode");
                              setState(() {
                                hasFiltered = true;
                              });
                            },
                            // activeFilters: _activeFilters,
                          ),
                        ),
                      if (!showBarcodeWidget) ...[
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: const Text(
                            "Categories",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _isLoadingCategories
                            ? Center(
                              child: LoadingAnimationWidget.waveDots(
                                color: AppColors.primaryColor,
                                size: 30,
                              ),
                            )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Wrap(
                                  spacing: 8, // Reduced gap between buttons
                                  runSpacing: 10,
                                  alignment: WrapAlignment.start,
                                  children: _categories.map((category) {
                                    return SizedBox(
                                      width: buttonWidth, // Increased width
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            // _selectedCategoryKey = category.itemSubGrpKey;
                                            // _selectedCategoryName = category.itemSubGrpName;
                                            // if (_selectedCategoryKey == '-1') {
                                            //   _items = _allItems;
                                            // } else {
                                            //   _items = _allItems
                                            //       .where(
                                            //         (item) => item.itemSubGrpKey == _selectedCategoryKey,
                                            //       )
                                            //       .toList();
                                            // }
                                          });
                                          Navigator.pushNamed(
                                            context,
                                            '/orderpage',
                                            arguments: {
                                              'itemKey': null,
                                              'itemSubGrpKey': category.itemSubGrpKey,
                                              'itemName': category.itemSubGrpName.trim(),
                                              'coBr': coBr,
                                              'fcYrId': fcYrId,
                                            },
                                          );
                                        },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(
                                            _selectedCategoryKey == category.itemSubGrpKey
                                                ? AppColors.primaryColor
                                                : Colors.white,
                                          ),
                                          side: MaterialStateProperty.all(
                                            BorderSide(
                                              color: AppColors.primaryColor,
                                              width: 1,
                                            ),
                                          ),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(0),
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          category.itemSubGrpName,
                                          textAlign: TextAlign.center, // Center text
                                          style: TextStyle(
                                            color: _selectedCategoryKey == category.itemSubGrpKey
                                                ? Colors.white
                                                : AppColors.primaryColor,
                                            fontSize: 14, // Consistent font size
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                        const SizedBox(height: 20),
                        if (_selectedCategoryKey != null) _buildCategoryItems(buttonWidth),
                      ],
                    const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: 2, // Highlight Order icon
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/catalog');
          if (index == 2) return; // Already on Order
          if (index == 3) Navigator.pushNamed(context, '/stockReport');
          if (index == 4) Navigator.pushNamed(context, '/dashboard');
        },
      ),
    );
  }

  Widget _buildCategoryItems(double buttonWidth) {
    double buttonHeight = 43;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Items in $_selectedCategoryName",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        _isLoadingItems
            ? Center(
                              child: LoadingAnimationWidget.waveDots(
                                color: AppColors.primaryColor,
                                size: 30,
                              ),
                            )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Wrap(
                  spacing: 8, // Reduced gap between buttons
                  runSpacing: 10,
                  alignment: WrapAlignment.start,
                  children: _items.map((item) {
                    return SizedBox(
                      width: buttonWidth, // Increased width
                      height: buttonHeight,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0), 
                          ),
                        ),
                        onPressed: () {
                          print(item.itemKey);
                          print(item.itemSubGrpKey);
                          Navigator.pushNamed(
                            context,
                            '/orderpage',
                            arguments: {
                              'itemKey': item.itemKey,
                              'itemName': item.itemName.trim(),
                              'itemSubGrpKey': item.itemSubGrpKey,
                              'coBr': coBr,
                              'fcYrId': fcYrId,
                            },
                          ).then((_) => _fetchCartCount());
                        },
                        child: Text( 
                          item.itemName,
                          textAlign: TextAlign.center, 
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }
}