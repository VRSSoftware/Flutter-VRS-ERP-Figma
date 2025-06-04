import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';

class BottomNavigationWidget extends StatelessWidget {
  final Function(int) onTap;
  final int currentIndex;

  const BottomNavigationWidget({
    required this.onTap,
    required this.currentIndex,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build dynamic items list based on user type
    List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(CupertinoIcons.square_list_fill), label: 'Catalog'),
      const BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart_fill_badge_plus), label: 'Order'),
      const BottomNavigationBarItem(icon: Icon(CupertinoIcons.tray_full_fill), label: 'Dashboard'),
    ];

    if (UserSession.userType != 'C') {
      navItems.addAll([
        const BottomNavigationBarItem(icon: Icon(CupertinoIcons.today), label: 'Report'),
        // const BottomNavigationBarItem(icon: Icon(CupertinoIcons.tray_full_fill), label: 'Dashboard'),
      ]);
    }

    navItems.add(
      const BottomNavigationBarItem(icon: Icon(CupertinoIcons.person_3_fill), label: 'Team'),
    );

    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: Colors.grey,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      iconSize: 24,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      items: navItems,
      onTap: onTap,
    );
  }
}
