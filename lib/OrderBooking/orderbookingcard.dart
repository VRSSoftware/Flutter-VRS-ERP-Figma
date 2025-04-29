
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/widget/booknowwidget.dart';

class BarcodeItemCard extends StatelessWidget {
  final Map<String, dynamic> catalogItem;
  final Set<String> activeFilters;

  const BarcodeItemCard({
    super.key,
    required this.catalogItem,
    required this.activeFilters,
  });

  String _getImageUrl(String? fullImagePath) {
    if (fullImagePath == null || fullImagePath.isEmpty) return '';
    if (fullImagePath.startsWith('http')) return fullImagePath;
    
    final imageName = fullImagePath.split('/').last.split('?').first;
    return '${AppConstants.BASE_URL}/images/$imageName';
  }

  @override
  Widget build(BuildContext context) {
    final brandName = catalogItem['brandName']?.toString() ?? 'No Brand';
    final shadeName = catalogItem['shadeName']?.toString() ?? 'No Shade';
    final fullImagePath = catalogItem['fullImagePath']?.toString() ?? '';
    final imageUrl = _getImageUrl(fullImagePath);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: 150,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => 
                        _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),

          // Product Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(brandName, style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
                const SizedBox(height: 4),
                Text(shadeName, style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                )),
                const SizedBox(height: 8),
                _buildDynamicDetails(),
              ],
            ),
          ),

          // Book Now Button
          Padding(
            padding: const EdgeInsets.all(12).copyWith(top: 0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _showBookingDialog(context),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return SizedBox(
      height: 150,
      child: ColoredBox(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported, size: 40),
      ),
    );
  }

  Widget _buildDynamicDetails() {
    return Column(
      children: [
        if (activeFilters.contains('stylecode'))
          _buildDetailRow('Style Code', catalogItem['styleCode']),
        if (activeFilters.contains('shades'))
          _buildDetailRow('Shade', catalogItem['shadeName']),
        if (activeFilters.contains('mrp'))
          _buildDetailRow('MRP', '₹${catalogItem['mrp']?.toStringAsFixed(2)}'),
        if (activeFilters.contains('wsp'))
          _buildDetailRow('WSP', '₹${catalogItem['wsp']?.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value ?? 'N/A', style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: CatalogBookingTable(
          itemSubGrpKey: catalogItem['itemSubGrpKey']?.toString() ?? '',
          itemKey: catalogItem['itemKey']?.toString() ?? '',
          styleKey: catalogItem['styleKey']?.toString() ?? '',
        ),
      ),
    );
  }
}
