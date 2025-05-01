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
return BottomNavigationBar(
  currentIndex: currentIndex,
  backgroundColor: Colors.white,
  selectedItemColor: AppColors.primaryColor,
  unselectedItemColor: Colors.grey,
  elevation: 8,
  type: BottomNavigationBarType.fixed,
  iconSize: 24,
  selectedFontSize: 12, // reduce if needed
  unselectedFontSize: 11, // reduce if needed
  items: const [
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.square_list_fill), label: 'Catalog'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart_fill_badge_plus), label: 'Order'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.today), label: 'Report'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.tray_full_fill), label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.person_3_fill), label: 'Team'),
  ],
  onTap: onTap,
);

  }

}
