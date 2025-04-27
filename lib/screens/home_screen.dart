// import 'package:flutter/material.dart';
// import 'package:vrs_erp_figma/constants/app_constants.dart';
// import 'package:vrs_erp_figma/screens/drawer_screen.dart';

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: DrawerScreen(),
//       appBar: AppBar(
//         title: Text('Dashboard', style: TextStyle(color: AppColors.white)),
//         backgroundColor: AppColors.primaryColor,
//         elevation: 1,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: Icon(Icons.menu, color: AppColors.white),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                 child: IntrinsicHeight(
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 20),
//                       _buildMainButtons(context, constraints.maxWidth),
//                       const Spacer(),
//                       _buildLogoutButton(context),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildMainButtons(BuildContext context, double screenWidth) {
//     final crossAxisCount = screenWidth > 600 ? 3 : 2;
//     final buttonWidth = (screenWidth - 32 - (crossAxisCount - 1) * 14) / crossAxisCount;

//     return Wrap(
//       spacing: 14,
//       runSpacing: 14,
//       alignment: WrapAlignment.center,
//       children: [
//           _buildFeatureButton(
//           'assets/images/orderbooking.png',
//           'Order Booking',
//           () => Navigator.pushNamed(context, '/orderbooking'),
//           buttonWidth,
//         ),
//           _buildFeatureButton(
//           'assets/images/catalog.png',
//           'Catalog',
//           () => Navigator.pushNamed(context, '/catalog'),
//           buttonWidth,
//         ),
//       ],
//     );
//   }

//   Widget _buildFeatureButton(
//     String imagePath,
//     String label,
//     VoidCallback onTap,
//     double width,
//   ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: width,
//         decoration: BoxDecoration(
//           color: const Color.fromARGB(255, 248, 249, 250),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: AppColors.primaryColor, width: 2),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 4,
//               offset: Offset(2, 2),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(imagePath, width: 50, height: 50),
//             const SizedBox(height: 6),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.primaryColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLogoutButton(BuildContext context) {
//     return Align(
//       alignment: Alignment.bottomRight,
//       child: OutlinedButton.icon(
//         onPressed: () {
//           Navigator.pushReplacementNamed(context, '/login');
//         },
//         icon: Icon(Icons.logout, color: AppColors.primaryColor, size: 18),
//         label: Text(
//           "Logout",
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: AppColors.primaryColor,
//           ),
//         ),
//         style: OutlinedButton.styleFrom(
//           backgroundColor: AppColors.secondaryColor,
//           side: BorderSide(color: AppColors.primaryColor, width: 1.5),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';

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
      CarouselSliderController(); // Corrected with CarouselSliderController
  String? _selectedCategory; // nullable String
  // State variable to track selected category

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
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
                            itemBuilder: (
                              BuildContext context,
                              int index,
                              int realIndex,
                            ) {
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
                              aspectRatio: 16 / 9,
                              viewportFraction: 0.8,
                              initialPage: 0,
                              enableInfiniteScroll: true,
                              reverse: false,
                              autoPlay: true,
                              autoPlayInterval: Duration(seconds: 3),
                              autoPlayAnimationDuration: Duration(
                                milliseconds: 800,
                              ),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.3,
                              scrollDirection: Axis.horizontal,
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
                              onTap: () {
                                _carouselController.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.linear,
                                );
                              },
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
                              onTap: () {
                                _carouselController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.linear,
                                );
                              },
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
                      Wrap(
                        spacing: 10,
                        children:
                            ["All", "Kids", "Mens", "Women", "Sarees"].map((
                              label,
                            ) {
                              return OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedCategory =
                                        label; // Set the selected category
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    _selectedCategory == label
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
                                  label,
                                  style: TextStyle(
                                    color:
                                        _selectedCategory == label
                                            ? Colors.white
                                            : AppColors.primaryColor,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      SizedBox(height: 20),
                      if (_selectedCategory != null)
                        _buildCategoryItems(_selectedCategory!),

                      Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // <-- add this line
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey, // <-- optional for better look
        elevation: 8, // <-- optional for shadow effect

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_module),
            label: 'Catalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Order',
          ),
        ],
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/catalog');
          if (index == 2) Navigator.pushNamed(context, '/orderbooking');
        },
      ),
    );
  }

  Widget _buildCategoryItems(String category) {
    List<String> items = [];
    if (category == "All") {
      items = ["Item 1", "Item 2", "Item 3", "Item 4"];
    } else if (category == "Kids") {
      items = ["Kids Item 1", "Kids Item 2"];
    } else if (category == "Mens") {
      items = ["Mens Item 1", "Mens Item 2"];
    } else if (category == "Women") {
      items = ["Women Item 1", "Women Item 2"];
    } else if (category == "Sarees") {
      items = ["Saree Item 1", "Saree Item 2"];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Items in $category",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children:
              items.map((item) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/catalog',
                      arguments: category,
                    );
                  },
                  child: Chip(
                    label: Text(item),
                    backgroundColor: Colors.white, // <-- White background
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ), // optional: thin border
                    ),
                    elevation: 2, // optional: slight shadow effect
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
          color: Colors.white, // <-- No background
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
