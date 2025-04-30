import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewCartPage extends StatefulWidget {
  const ViewCartPage({Key? key}) : super(key: key);

  @override
  State<ViewCartPage> createState() => _ViewCartPageState();
}

class _ViewCartPageState extends State<ViewCartPage> {
  List<String> styleCodes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Cart")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : styleCodes.isEmpty
              ? const Center(child: Text("Your cart is empty"))
              : ListView.builder(
                  itemCount: styleCodes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.shopping_cart),
                      title: Text(styleCodes[index]),
                    );
                  },
                ),
    );
  }
}
