import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/widget/booknowwidget.dart';

class BarcodeItemCard extends StatelessWidget {
  final Map<String, dynamic> catalogItem;
  final Set<String> activeFilters;
    final VoidCallback onSuccess; 

  const BarcodeItemCard({
    super.key,
    required this.catalogItem,
    required this.activeFilters,
     required this.onSuccess,
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

return Container(
  decoration: const BoxDecoration(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(12),
      bottomLeft: Radius.circular(12),
    ),
    border: Border(
      left: BorderSide(width: 6.0, color: Colors.yellow),
    ),
  ),
  child: ClipRRect(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(12),
      bottomLeft: Radius.circular(12),
    ),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      margin: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child: SizedBox(
              width: 120,
              height: 150,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),

          // Details and Button Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brandName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shadeName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDynamicDetails(),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
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
            ),
          ),
        ],
      ),
    ),
  ),
);

  }

  Widget _buildImagePlaceholder() {
    return ColoredBox(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 40),
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
            onSuccess: ()  { // Add this callback
           onSuccess(); // Use the passed callback
            Navigator.pop(context); // Close the dialog
        }),
        ),
      );
    
  }
}