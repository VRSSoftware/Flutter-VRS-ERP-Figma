import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/screens/login_screen.dart'; // Import your LoginScreen

class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  String? selectedSection;
  String? hoveredSection;

  final Map<String, String> _iconPaths = {
    'Home': 'assets/images/home.png',
    'Order Booking': 'assets/images/orderbooking.png',
    'Catalog': 'assets/images/catalog.png',
    'Order Register':'assets/images/register.png'
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedSection();
  }

  void _updateSelectedSection() {
    final route = ModalRoute.of(context)?.settings.name;
    setState(() {
      selectedSection = _getSectionFromRoute(route);
    });
  }

  String? _getSectionFromRoute(String? route) {
    switch (route) {
      case '/home':
        return 'Home';
      case '/orderbooking':
        return 'Order Booking';
      case '/catalog':
        return 'Catalog';
      case '/registerOrders':
        return 'Order Register';
      default:
        return null;
    }
  }

  void _navigateTo(String section, String route) {
    if (selectedSection == section) {
      Navigator.pop(context);
      return;
    }

    setState(() => selectedSection = section);
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              ..._iconPaths.keys.map((title) => _buildDrawerItem(
                    title,
                    _getRouteFromSection(title),
                  )),
              const Divider(),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  String _getRouteFromSection(String section) {
    switch (section) {
      case 'Home':
        return '/home';
      case 'Order Booking':
        return '/orderbooking';
      case 'Catalog':
        return '/catalog';
      case 'Order Register':
        return '/registerOrders';
      default:
        return '/home';
    }
  }

  Widget _buildDrawerItem(String title, String route) {
    final isSelected = selectedSection == title;
    final isHovered = hoveredSection == title;
    final iconPath = _iconPaths[title]!;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredSection = title),
      onExit: (_) => setState(() => hoveredSection = null),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateTo(title, route),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected || isHovered
                  ? const Color.fromARGB(255, 222, 187, 231)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: Image.asset(
                iconPath,
                width: 24,
                height: 24,
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected || isHovered
                      ? AppColors.primaryColor
                      : Colors.grey[800],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => hoveredSection = 'Logout'),
      onExit: (_) => setState(() => hoveredSection = null),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.pop(context); // Close the drawer
            Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
          },
          child: Container(
            decoration: BoxDecoration(
              color: hoveredSection == 'Logout'
                  ? const Color.fromARGB(255, 222, 187, 231)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: Icon(
                Icons.exit_to_app, // Logout icon
                size: 24,
                color: hoveredSection == 'Logout' ? AppColors.primaryColor : Colors.grey[800],
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: hoveredSection == 'Logout' ? AppColors.primaryColor : Colors.grey[800],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
