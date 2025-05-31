import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/models/keyName.dart';
import 'package:vrs_erp_figma/services/app_services.dart';

class OrderStatus extends StatefulWidget {
  const OrderStatus({Key? key}) : super(key: key);

  @override
  _OrderStatusState createState() => _OrderStatusState();
}

class _OrderStatusState extends State<OrderStatus> {
  String? _selectedProduct;
  String? _selectedCategory;
  
  // Sample data for products dropdown
  final List<String> _products = [
    'Product A',
    'Product B',
    'Product C',
    'Product D',
    'Product E',
  ];
  
  // Dynamic list for categories, initially empty
  List<String> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories on widget initialization
  }

  // Function to fetch categories using the provided fetchLedgers method
  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the fetchLedgers method from ApiService
      final response = await ApiService.fetchLedgers(
        ledCat: 'W', // From the provided body
        coBrId: '01', // From the provided body
      );

      if (response['statusCode'] == 200) {
        final List<KeyName> result = response['result'];
        setState(() {
          // Map the Led_Name values to the _categories list
          _categories = result.map((item) => item.name).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Failed to fetch categories: ${response['statusCode']}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Exception while fetching categories: $e');
    }
  }

  // Function to fetch stock report
  void _fetchStockReport() {
    // TODO: Implement stock report fetching logic
    print('Fetching stock report for: Product: $_selectedProduct, Category: $_selectedCategory');
  }

  // Function to clear filters
  void clearFilters() {
    setState(() {
      _selectedProduct = null;
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<String>(
                value: _selectedProduct,
                hint: const Text('Select Product'),
                isExpanded: true,
                items: _products.map((String product) {
                  return DropdownMenuItem<String>(
                    value: product,
                    child: Text(product),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProduct = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Product',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                isDense: true,
              ),
            ),

            // Category Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      hint: const Text('Select Category'),
                      isExpanded: true,
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      isDense: true,
                    ),
            ),

            // Buttons Row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  _buildButton("View", Icons.visibility, Colors.blue, _fetchStockReport),
                  const SizedBox(width: 8),
                  _buildButton("Download", Icons.download, Colors.deepPurple, () {
                    // TODO: Implement download logic
                  }),
                  const SizedBox(width: 8),
                  _buildButton("WhatsApp", FontAwesomeIcons.whatsapp, Colors.green, () {
                    // TODO: Implement WhatsApp logic
                  }, isFaIcon: true),
                  const SizedBox(width: 8),
                  _buildButton("Clear", Icons.clear, Colors.red, clearFilters),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, Color color, VoidCallback onPressed, {bool isFaIcon = false}) {
    return Expanded(
      child: SizedBox(
        height: 40,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: isFaIcon
              ? FaIcon(icon, size: 12, color: color)
              : Icon(icon, size: 12, color: color),
          label: Text(
            label,
            style: TextStyle(fontSize: 10, color: color),
            softWrap: false,
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            side: BorderSide(color: color),
            foregroundColor: color,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}