import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/category.dart';
import 'package:vrs_erp_figma/models/item.dart';
import 'package:vrs_erp_figma/services/app_services.dart';

class StockReportPage extends StatefulWidget {
  const StockReportPage({super.key});

  @override
  State<StockReportPage> createState() => _StockReportPageState();
}

class _StockReportPageState extends State<StockReportPage> {
  String? selectedCategoryKey; // Store itemSubGrpKey for API calls
  String? selectedCategoryName; // Store itemSubGrpName for display
  String? selectedItem;

  List<Category> categories = []; // List to store category data
  List<Item> items = []; // List to store item data
  bool isLoadingCategories = true; // Loading state for categories
  bool isLoadingItems = true; // Loading state for items

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch all categories when the page loads
    _fetchAllItems(); // Fetch all items initially
  }

  // Fetch categories from API using ApiService
  Future<void> _fetchCategories() async {
    setState(() {
      isLoadingCategories = true;
    });
    try {
      final fetchedCategories = await ApiService.fetchCategories();
      setState(() {
        categories = fetchedCategories; // Store the category list
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    }
  }

  // Fetch all items initially
  Future<void> _fetchAllItems() async {
    setState(() {
      isLoadingItems = true;
    });
    try {
      final fetchedItems = await ApiService.fetchAllItems();
      setState(() {
        items = fetchedItems;
        isLoadingItems = false;
      });
    } catch (e) {
      setState(() {
        isLoadingItems = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading items: $e')),
      );
    }
  }

  // Fetch items by category
  Future<void> _fetchItemsByCategory(String categoryKey) async {
    setState(() {
      isLoadingItems = true;
    });
    try {
      final fetchedItems = await ApiService.fetchItemsByCategory(categoryKey);
      setState(() {
        items = fetchedItems;
        isLoadingItems = false;
      });
    } catch (e) {
      setState(() {
        isLoadingItems = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading items: $e')),
      );
    }
  }

  void clearFilters() {
    setState(() {
      selectedCategoryKey = null;
      selectedCategoryName = null;
      selectedItem = null;
      _fetchAllItems(); // Reset to all items when clearing filters
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Show loading indicator for categories
            if (isLoadingCategories)
              const Center(child: CircularProgressIndicator())
            else
              // Category Dropdown
              DropdownSearch<String>(
                items: categories.map((category) => category.itemSubGrpName).toList(),
                selectedItem: selectedCategoryName,
                onChanged: (value) {
                  setState(() {
                    selectedCategoryName = value;
                    selectedItem = null; // Reset item selection when category changes
                    if (value != null) {
                      Category? selectedCategory;
                      try {
                        for (var cat in categories) {
                          if (cat.itemSubGrpName == value) {
                            selectedCategory = cat;
                            break;
                          }
                        }
                        if (selectedCategory != null) {
                          selectedCategoryKey = selectedCategory.itemSubGrpKey;
                          _fetchItemsByCategory(selectedCategoryKey!);
                        } else {
                          selectedCategoryKey = null;
                          _fetchAllItems(); // Fallback to all items if no category match
                        }
                      } catch (e) {
                        selectedCategoryKey = null;
                        _fetchAllItems();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error selecting category: $e')),
                        );
                      }
                    } else {
                      selectedCategoryKey = null;
                      _fetchAllItems(); // If no category selected, fetch all items
                    }
                  });
                },
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Select Category",
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: const PopupProps.menu(showSearchBox: true),
              ),
            const SizedBox(height: 16),
            // Show loading indicator for items
            if (isLoadingItems)
              const Center(child: CircularProgressIndicator())
            else
              // Item Dropdown
              DropdownSearch<String>(
                items: items.map((item) => item.itemName).toList(),
                selectedItem: selectedItem,
                onChanged: (value) {
                  setState(() {
                    selectedItem = value;
                  });
                },
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Select Item",
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: const PopupProps.menu(showSearchBox: true),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: View logic
                      },
                      icon: const Icon(Icons.visibility, size: 12),
                      label: const Text(
                        "View",
                        style: TextStyle(fontSize: 10),
                        softWrap: false,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        side: const BorderSide(color: Colors.blue),
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Download logic
                      },
                      icon: const Icon(Icons.download, size: 12),
                      label: const Text(
                        "Download",
                        style: TextStyle(fontSize: 10),
                        softWrap: false,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        side: const BorderSide(color: Colors.deepPurple),
                        foregroundColor: Colors.deepPurple,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: WhatsApp logic
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.whatsapp,
                        size: 12,
                        color: Colors.green,
                      ),
                      label: const Text(
                        "WhatsApp",
                        style: TextStyle(fontSize: 10, color: Colors.green),
                        softWrap: false,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        side: const BorderSide(color: Colors.green),
                        foregroundColor: Colors.green,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: clearFilters,
                      icon: const Icon(
                        Icons.clear,
                        size: 12,
                        color: Colors.red,
                      ),
                      label: const Text(
                        "Clear",
                        style: TextStyle(fontSize: 10, color: Colors.red),
                        softWrap: false,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}