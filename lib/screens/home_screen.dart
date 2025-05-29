import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:vrs_erp_figma/widget/bottom_navbar.dart';


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildMainButtons(context, constraints.maxWidth),
                      const Spacer(),
                       _buildLogoutButton(context),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
          bottomNavigationBar: BottomNavigationWidget(
        currentIndex: 0, // 👈 Highlight Catalog icon
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) Navigator.pushNamed(context, '/catalog');
          if (index == 2) Navigator.pushNamed(context, '/orderbooking');
          if (index == 3) Navigator.pushNamed(context, '/orderRegister');
            if (index == 4) Navigator.pushNamed(context, '/stockReport');
          // Add others similarly...
        },
      ),
    );
  }

  Widget _buildMainButtons(BuildContext context, double screenWidth) {
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final buttonWidth = (screenWidth - 32 - (crossAxisCount - 1) * 14) / crossAxisCount;

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      alignment: WrapAlignment.center,
      children: [
          _buildFeatureButton(
          'assets/images/orderbooking.png',
          'Order Booking',
          () => Navigator.pushNamed(context, '/orderbooking'),
          buttonWidth,
        ),
          _buildFeatureButton(
          'assets/images/catalog.png',
          'Catalog',
          () => Navigator.pushNamed(context, '/catalog'),
          buttonWidth,
        ),
        _buildFeatureButton(
          'assets/images/register.png',
          'Order Register',
          () => Navigator.pushNamed(context, '/registerOrders'),
          buttonWidth,
        ),
         _buildFeatureButton(
          'assets/images/report.png',
          'Stock Report',
          () => Navigator.pushNamed(context, '/stockReport'),
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
          color: const Color.fromARGB(255, 248, 249, 250),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
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

  Widget _buildLogoutButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      // child: OutlinedButton.icon(
      //   onPressed: () {
      //     Navigator.pushReplacementNamed(context, '/login');
      //   },
      //   icon: Icon(Icons.logout, color: AppColors.primaryColor, size: 18),
      //   label: Text(
      //     "Logout",
      //     style: TextStyle(
      //       fontSize: 14,
      //       fontWeight: FontWeight.w600,
      //       color: AppColors.primaryColor,
      //     ),
      //    ),
      //   style: OutlinedButton.styleFrom(
      //     backgroundColor: const Color.fromARGB(255, 230, 197, 236),
      //     side: BorderSide(color: AppColors.primaryColor, width: 1.5),
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      //   ),
      // ),
    );
  }
}
