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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: Colors.grey,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      iconSize: 24,
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
