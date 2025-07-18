// import 'package:flutter/material.dart';
// import 'package:vrs_erp_figma/constants/app_constants.dart';
// import 'package:vrs_erp_figma/screens/drawer_screen.dart';
// import 'package:vrs_erp_figma/widget/bottom_navbar.dart';


// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: DrawerScreen(),
//       appBar: AppBar(
//         title: Text('Home', style: TextStyle(color: AppColors.white)),
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
//                        _buildLogoutButton(context),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//           bottomNavigationBar: BottomNavigationWidget(
//         currentIndex: 0, // 👈 Highlight Catalog icon
//         onTap: (index) {
//           if (index == 0) return;
//           if (index == 1) Navigator.pushNamed(context, '/catalog');
//           if (index == 2) Navigator.pushNamed(context, '/orderbooking');
//            if (index == 3) Navigator.pushNamed(context, '/stockReport');
//              if (index == 4) Navigator.pushNamed(context, '/dashboard');
//           if (index == 5) Navigator.pushNamed(context, '/orderRegister');
         
        
//           // Add others similarly...
//         },
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
//         _buildFeatureButton(
//           'assets/images/register.png',
//           'Order Register',
//           () => Navigator.pushNamed(context, '/registerOrders'),
//           buttonWidth,
//         ),
//          _buildFeatureButton(
//           'assets/images/report.png',
//           'Stock Report',
//           () => Navigator.pushNamed(context, '/stockReport'),
//           buttonWidth,
//         ),
//         _buildFeatureButton(
//           'assets/images/dashboard.png',
//           'Dashboard',
//           () => Navigator.pushNamed(context, '/dashboard'),
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
          
//        color: Colors.white,
//           borderRadius: BorderRadius.circular(0),
//           border: Border.all(color: AppColors.primaryColor, width: 2),
        
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
//       // child: OutlinedButton.icon(
//       //   onPressed: () {
//       //     Navigator.pushReplacementNamed(context, '/login');
//       //   },
//       //   icon: Icon(Icons.logout, color: AppColors.primaryColor, size: 18),
//       //   label: Text(
//       //     "Logout",
//       //     style: TextStyle(
//       //       fontSize: 14,
//       //       fontWeight: FontWeight.w600,
//       //       color: AppColors.primaryColor,
//       //     ),
//       //    ),
//       //   style: OutlinedButton.styleFrom(
//       //     backgroundColor: const Color.fromARGB(255, 230, 197, 236),
//       //     side: BorderSide(color: AppColors.primaryColor, width: 1.5),
//       //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       //   ),
//       // ),
//     );
//   }
// }

//===============================================design 2============================================================
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:vrs_erp_figma/constants/app_constants.dart';
// import 'package:vrs_erp_figma/screens/drawer_screen.dart';
// import 'package:vrs_erp_figma/widget/bottom_navbar.dart';

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: DrawerScreen(),
//       appBar: AppBar(
//         title: Text('Home', style: GoogleFonts.roboto(color: AppColors.white)),
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
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationWidget(
//         currentIndex: 0,
//         onTap: (index) {
//           if (index == 0) return;
//           if (index == 1) Navigator.pushNamed(context, '/catalog');
//           if (index == 2) Navigator.pushNamed(context, '/orderbooking');
//           if (index == 3) Navigator.pushNamed(context, '/stockReport');
//           if (index == 4) Navigator.pushNamed(context, '/dashboard');
//           if (index == 5) Navigator.pushNamed(context, '/orderRegister');
//         },
//       ),
//     );
//   }

//   Widget _buildMainButtons(BuildContext context, double screenWidth) {
//     final buttonWidth = screenWidth;

//     return Column(
//       children: [
//         _buildFeatureButton(
//           'assets/images/catalog.png',
//           'Catalog',
//           () => Navigator.pushNamed(context, '/catalog'),
//           buttonWidth,
//           true,
//           Colors.blue, // Changed to blue
//         ),
//         const SizedBox(height: 14),
//         _buildFeatureButton(
//           'assets/images/orderbooking.png',
//           'Order Booking',
//           () => Navigator.pushNamed(context, '/orderbooking'),
//           buttonWidth,
//           false,
//           Colors.indigo, // Changed to indigo
//         ),
//         const SizedBox(height: 14),
//         _buildFeatureButton(
//           'assets/images/register.png',
//           'Order Register',
//           () => Navigator.pushNamed(context, '/registerOrders'),
//           buttonWidth,
//           true,
//           Colors.cyan, // Changed to cyan
//         ),
//         const SizedBox(height: 14),
//         if (UserSession.userType != 'C') ...[
//           _buildFeatureButton(
//             'assets/images/report.png',
//             'Stock Report',
//             () => Navigator.pushNamed(context, '/stockReport'),
//             buttonWidth,
//             false,
//             Colors.lightBlue, // Changed to light blue
//           ),
//           const SizedBox(height: 14),
//         ],
//         _buildFeatureButton(
//           'assets/images/dashboard.png',
//           'Dashboard',
//           () => Navigator.pushNamed(context, '/dashboard'),
//           buttonWidth,
//           true,
//           Colors.blueGrey, // Changed to blue-grey
//         ),
//         const SizedBox(height: 14),
//         _buildFeatureButton(
//           'assets/images/team.png',
//           'Team',
//           () => Navigator.pushNamed(context, '/home'),
//           buttonWidth,
//           false,
//           Colors.blueAccent, // Changed to blue accent
//         ),
//       ],
//     );
//   }

//   Widget _buildFeatureButton(
//     String imagePath,
//     String label,
//     VoidCallback onTap,
//     double width,
//     bool imageOnLeft,
//     Color bgColor,
//   ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: width,
//         height: 95,
//         decoration: BoxDecoration(
//           color: bgColor.withOpacity(0.1), // Background for the entire container
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: imageOnLeft
//               ? [
//                   // Image on left
//                   Container(
//                     width: 100, // Square container for image
//                     height: 100,
//                     color: bgColor, // Full background color for image
//                     child: Center(
//                       child: Image.asset(
//                         imagePath,
//                         width: 80,
//                         height: 80,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),
//                   // White vertical divider
//                   Container(
//                     width: 4,
//                     height: double.infinity,
//                     color: Colors.white,
//                   ),
//                   // Text on right
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                       child: Text(
//                         label,
//                         textAlign: TextAlign.center,
//                         style: GoogleFonts.roboto(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: bgColor, // Text color set to bgColor
//                         ),
//                       ),
//                     ),
//                   ),
//                 ]
//               : [
//                   // Text on left
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                       child: Text(
//                         label,
//                         textAlign: TextAlign.center,
//                         style: GoogleFonts.roboto(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: bgColor, // Text color set to bgColor
//                         ),
//                       ),
//                     ),
//                   ),
//                   // White vertical divider
//                   Container(
//                     width: 4,
//                     height: double.infinity,
//                     color: Colors.white,
//                   ),
//                   // Image on right
//                   Container(
//                     width: 100, // Square container for image
//                     height: 100,
//                     color: bgColor, // Full background color for image
//                     child: Center(
//                       child: Image.asset(
//                         imagePath,
//                         width: 80,
//                         height: 80,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),
//                 ],
//         ),
//       ),
//     );
//   }
// }
//============================================================design 3================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:vrs_erp_figma/widget/bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedFeature; // Track the selected feature button

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
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: AppColors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _buildMainButtons(context, constraints.maxWidth),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            setState(() => selectedFeature = 'Catalog');
            Navigator.pushNamed(context, '/catalog');
          } else if (index == 2) {
            setState(() => selectedFeature = 'Order Booking');
            Navigator.pushNamed(context, '/orderbooking');
          } else if (index == 3) {
            setState(() => selectedFeature = 'Stock Report');
            Navigator.pushNamed(context, '/stockReport');
          } else if (index == 4) {
            setState(() => selectedFeature = 'Dashboard');
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 5) {
            setState(() => selectedFeature = 'Order Register');
            Navigator.pushNamed(context, '/orderRegister');
          }
        },
      ),
    );
  }

  Widget _buildMainButtons(BuildContext context, double screenWidth) {
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final spacing = 14.0;
    final totalSpacing = (crossAxisCount - 1) * spacing;
    final buttonWidth = (screenWidth - 32 - totalSpacing) / crossAxisCount;

    return Center(
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        alignment: WrapAlignment.center,
        children: [
          _buildFeatureButton(
            context,
            'assets/images/orderbooking.png',
            'Order Booking',
            () {
              setState(() => selectedFeature = 'Order Booking');
              Navigator.pushNamed(context, '/orderbooking');
            },
            buttonWidth,
          ),
          _buildFeatureButton(
            context,
            'assets/images/catalog.png',
            'Catalog',
            () {
              setState(() => selectedFeature = 'Catalog');
              Navigator.pushNamed(context, '/catalog');
            },
            buttonWidth,
          ),
          _buildFeatureButton(
            context,
            'assets/images/register.png',
            'Order Register',
            () {
              setState(() => selectedFeature = 'Order Register');
              Navigator.pushNamed(context, '/registerOrders');
            },
            buttonWidth,
          ),
          
          _buildFeatureButton(
            context,
            'assets/images/register.png',
            'Packing Register',
            () {
              setState(() => selectedFeature = 'Packing Register');
              Navigator.pushNamed(context, '/packingOrders');
            },
            buttonWidth,
          ),
          _buildFeatureButton(
            context,
            'assets/images/report.png',
            'Stock Report',
            () {
              setState(() => selectedFeature = 'Stock Report');
              Navigator.pushNamed(context, '/stockReport');
            },
            buttonWidth,
          ),
          _buildFeatureButton(
            context,
            'assets/images/dashboard.png',
            'Dashboard',
            () {
              setState(() => selectedFeature = 'Dashboard');
              Navigator.pushNamed(context, '/dashboard');
            },
            buttonWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context,
    String imagePath,
    String label,
    VoidCallback onTap,
    double width,
  ) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: StatefulBuilder(
        builder: (context, setState) {
          bool isHovered = false;
          final isSelected = selectedFeature == label;

          return MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: width,
                height: isLargeScreen ? 120 : 100,
                decoration: BoxDecoration(
                  color: isSelected || isHovered
                      ? const Color.fromARGB(255, 206, 222, 240)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(color: AppColors.primaryColor, width: 1),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 16 : 8,
                          ),
                          child: Image.asset(
                            imagePath,
                            width: isLargeScreen ? 50 : 40,
                            height: isLargeScreen ? 50 : 40,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.broken_image,
                                size: isLargeScreen ? 50 : 40,
                                color: isSelected || isHovered
                                    ? AppColors.primaryColor
                                    : Colors.grey[800],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: isLargeScreen ? 30 : 25,
                      color: isSelected || isHovered
                          ? AppColors.primaryColor
                          : const Color(0xFFE91E63),
                      padding: EdgeInsets.symmetric(
                        vertical: isLargeScreen ? 6 : 4,
                      ),
                      child: Center(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: isLargeScreen ? 12 : 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
