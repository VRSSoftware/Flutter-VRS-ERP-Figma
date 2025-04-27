// bottom_navigation_widget.dart
import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';

class BottomNavigationWidget extends StatelessWidget {
  final Function(int) onTap;

  BottomNavigationWidget({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: Colors.grey,
      elevation: 8,
      type: BottomNavigationBarType.fixed, // To always show the label and icon
      iconSize: 24, // Adjust icon size for consistency
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.view_module), label: 'Catalog'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Order'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Report'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Team'),
      ],
      onTap: onTap,
    );
  }
}
