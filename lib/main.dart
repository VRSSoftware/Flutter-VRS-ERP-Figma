import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/catalog/catalog.dart';

import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/screens/home_screen.dart';
import 'package:vrs_erp_figma/screens/login_screen.dart';
import 'package:vrs_erp_figma/screens/splash_screen.dart'; 

void main() {
  runApp(const MyApp());
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
      ),
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/catalog': (context) => CatalogPage(),
        // '/orderbooking':(context)=>OrderBooking(),
        // '/viewOrder':(context)=>ViewOrderScreen(),
        // '/viewOrders':(context)=>ViewOrderScreens()
      },

      home: HomeScreen(),
    );
  }
}
