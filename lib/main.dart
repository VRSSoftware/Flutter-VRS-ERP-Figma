import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vrs_erp_figma/OrderBooking/order_booking.dart';
import 'package:vrs_erp_figma/OrderBooking/orderbooking_booknow.dart';
import 'package:vrs_erp_figma/catalog/catalog.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/dashboard/order_summary.dart';
import 'package:vrs_erp_figma/models/CartModel.dart';
import 'package:vrs_erp_figma/privacypolicy/deleteAccount.dart';
import 'package:vrs_erp_figma/privacypolicy/privacypolicy.dart';
import 'package:vrs_erp_figma/register/register.dart';
import 'package:vrs_erp_figma/screens/catalog_screen.dart';

import 'package:vrs_erp_figma/screens/home_screen.dart';
import 'package:vrs_erp_figma/screens/login_screen.dart';
import 'package:vrs_erp_figma/screens/splash_screen.dart';
import 'package:vrs_erp_figma/stockReport/stockreportpage.dart';
import 'package:vrs_erp_figma/viewOrder/view_order.dart';
import 'package:vrs_erp_figma/viewOrder/view_order_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
      ],
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VRS ERP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        // primarySwatch: AppColors.primaryColor
        primarySwatch: Colors.blue,
        progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.blue),
        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStateProperty.all(Colors.white),
          overlayColor: WidgetStateProperty.all(Colors.blue),
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.blue; // your desired background color when checked
            }
            return Colors.grey.shade300; // color when unchecked
          }),
          // fillColor: MaterialStateProperty.all(Colors.blue),
        ),
      ),
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/catalog': (context) => CatalogScreen(),
        '/catalogpage': (context) => CatalogPage(),
        '/orderbooking': (context) => OrderBookingScreen(),
        '/orderpage': (context) => OrderPage(),
        '/viewOrder': (context) => ViewOrderScreen(),
        '/viewOrders': (context) => ViewOrderScreens(),
        '/registerOrders': (context) => RegisterPage(),
        '/stockReport': (context) => StockReportPage(),
        '/dashboard' : (context) => OrderSummaryPage(),
         '/deleteAccount' : (context) => DeleteAccountPage(),
          '/setting' : (context) => PrivacyPolicyPage(),

      },

      home: HomeScreen(),
      // home: SplashScreen(),
    );
  }
}
