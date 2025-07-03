import 'package:flutter/material.dart';

class CustomerDetailBarcode2 extends StatelessWidget {
  final List<dynamic> orderData;

  const CustomerDetailBarcode2({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Customer details will be displayed here.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
