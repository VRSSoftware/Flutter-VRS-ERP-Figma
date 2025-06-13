import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/OrderBooking/barcode/barcode_scanner.dart';

import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/services/app_services.dart';
import 'package:vrs_erp_figma/OrderBooking/barcode/bookOnBarcode.dart';

class BarcodeWiseWidget extends StatefulWidget {
  final ValueChanged<String> onFilterPressed;
  // final Set<String> activeFilters;

  const BarcodeWiseWidget({
    super.key,
    required this.onFilterPressed,
    // required this.activeFilters,
  });

  @override
  State<BarcodeWiseWidget> createState() => _BarcodeWiseWidgetState();
}

class _BarcodeWiseWidgetState extends State<BarcodeWiseWidget> {
  final TextEditingController _barcodeController = TextEditingController();
  List<Map<String, dynamic>> _barcodeResults = [];
  List<String> addedItems = [];
  Map<String, bool> _filters = {
    'WSP': true,
    'Sizes': true,
    'Shades': true,
    'StyleCode': true,
  };

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _showFilterPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Fields to Show'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                _filters.keys.map((key) {
                  return CheckboxListTile(
                    title: Text(key),
                    value: _filters[key],
                    onChanged: (bool? value) {
                      setState(() {
                        _filters[key] = value ?? true;
                      });
                      Navigator.pop(context);
                      _showFilterPopup(
                        context,
                      ); // Reopen dialog to show updated state
                    },
                  );
                }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _scanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => BarcodeScannerScreen()),
    );

    if (barcode != null && barcode.isNotEmpty) {
      setState(() {
        _barcodeController.text = barcode;
      });
    }
  }

  Future<void> _searchBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) return;

    FocusScope.of(context).unfocus(); // 👈 This removes the cursor

    try {
      final result = await ApiService.getBarcodeDetails(barcode);
      debugPrint("Barcode Result: $result");

      if (result is List && result.isNotEmpty) {
        setState(() {
          _barcodeResults = List<Map<String, dynamic>>.from(result);
        });
        widget.onFilterPressed(barcode);
      } else {
        setState(() {
          _barcodeResults = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data found for this barcode')),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch barcode details')),
      );
    }
  }

  void _searchBarcode2() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: "Enter Barcode",
                  labelStyle: const TextStyle(fontSize: 14),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 14.0,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF6F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _scanBarcode,
              child: Image.asset(
                'assets/images/barcode.png',
                width: 40,
                height: 40,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            minimumSize: const Size(80, 40),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          // onPressed: _searchBarcode2,
          onPressed: () {
            print(_barcodeController.text.trim());
            showDialog(
              context: context,
              builder:
                  (context) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: CatalogBookingTableBarcode(
                        barcode: _barcodeController.text.trim(),
                        onSuccess: () {
                          Navigator.pop(context); // Close dialog on success
                          // Optionally refresh parent data or show snackbar
                        },
                      ),
                    ),
                  ),
            );
          },
          child: const Text("Search", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
