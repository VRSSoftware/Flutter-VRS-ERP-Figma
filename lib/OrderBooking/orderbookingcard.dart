import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';

class BarcodeItemCard extends StatelessWidget {
  final Map<String, dynamic> catalogItem;
  final Set<String> activeFilters;

  const BarcodeItemCard({
    Key? key, 
    required this.catalogItem,
    required this.activeFilters,
  }) : super(key: key);

  String _getImageUrl(String fullImagePath) {
    if (fullImagePath.startsWith('http')) {
      return fullImagePath;
    }
    final imageName = fullImagePath.split('/').last.split('?').first;
    return '${AppConstants.BASE_URL}/images/$imageName';
  }

  @override
  Widget build(BuildContext context) {
    final String brandName = catalogItem['brandName'] ?? '';
    final String shadeName = catalogItem['shadeName'] ?? '';
    final String fullImagePath = catalogItem['fullImagePath'] ?? '';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: fullImagePath.isNotEmpty
                ? Image.network(
                    _getImageUrl(fullImagePath),
                    fit: BoxFit.cover,
                    height: 150, // <-- 👈 fixed height
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported),
                  )
                : const SizedBox(
                    height: 150,
                    child: Icon(Icons.image_not_supported),
                  ),
          ),

          // Brand Name and Shade Name
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brandName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  shadeName,
                  style: const TextStyle(color: Colors.grey),
                ),
                 if (activeFilters.contains('stylecode'))
                  _buildInfoRow('Style Code', catalogItem['styleCode']),
                if (activeFilters.contains('shades'))
                  _buildInfoRow('Shade', catalogItem['shadeName']),
                if (activeFilters.contains('mrp'))
                  _buildInfoRow('MRP', '₹${catalogItem['mrp']}'),
                if (activeFilters.contains('wsp'))
                  _buildInfoRow('WSP', '₹${catalogItem['wsp']}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', 
            style: TextStyle(fontWeight: FontWeight.bold)),
          Text('$value'),
        ],
      ),
    );
  }
}


