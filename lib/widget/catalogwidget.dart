import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/catalog.dart';
import 'package:vrs_erp_figma/widget/booknowwidget.dart';


class CatalogItemCard extends StatelessWidget {
  final Catalog catalog;
  final bool isSelected;
  final bool isLiked;
  final VoidCallback onSelect;
  final VoidCallback onLike;
  final VoidCallback onAddToCart;
  final double? width;
  final double imageHeight;
  final bool bookNowButton ;

  const CatalogItemCard({
    Key? key,
    required this.catalog,
    required this.isSelected,
    required this.isLiked,
    required this.onSelect,
    required this.onLike,
    required this.onAddToCart, // Make sure to pass the onAddToCart callback
    this.width,
    this.imageHeight = 200, // Default image height
    this.bookNowButton = true,
  }) : super(key: key);

  String _getImageUrl() {
    if (catalog.fullImagePath.startsWith('http')) {
      return catalog.fullImagePath;
    }
    final imageName = catalog.fullImagePath.split('/').last.split('?').first;
    return '${AppConstants.BASE_URL}/images/$imageName';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen =
            constraints.maxWidth < 600; // Threshold for small screens

        return SizedBox(
          width: width ?? double.infinity,
          child: Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color:
                    isSelected
                        ? const Color.fromARGB(255, 228, 36, 36)
                        : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            elevation: 2,
            child: InkWell(
              onTap: onSelect, // Card tap triggers selection
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                // Use a Stack to overlay the cart icon
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildImageSection(constraints), // Image Section
                      if (!isSmallScreen)
                        _buildDetailsSection(isDarkMode, context),
                      if (isSmallScreen)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildDetailsSection(isDarkMode, context),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(BoxConstraints constraints) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.network(
            _getImageUrl(),
            fit: BoxFit.fitWidth, // Full width, height adjusts automatically
            width: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) => _buildImageError(),
          ),
        ),
        if (isSelected)
          Positioned(top: 8, left: 8, child: _buildSelectedIndicator()),
      ],
    );
  }

  Widget _buildImageError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported, size: 40),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isLiked
                ? Colors.red
                : Colors.transparent, // Red background when liked
      ),
      child: IconButton(
        icon: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.white : Colors.grey, // White icon when liked
          size: 24,
        ),
        onPressed: onLike, // Toggle like on press
      ),
    );
  }

  Widget _buildSelectedIndicator() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 16),
    );
  }

  Widget _buildDetailsSection(bool isDarkMode, BuildContext context) {
    final greyColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              catalog.styleCode,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            _buildLikeButton(), // Add like button here
          ],
        ),
        //const SizedBox(height: 2),
        if (catalog.brandName.isNotEmpty)
          Text(
            '${catalog.brandName}',
            style: TextStyle(fontSize: 16, color: greyColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 6),
        if (catalog.sizeName.isNotEmpty)
          Text(
            'Size: ${catalog.sizeName}',
            style: TextStyle(fontSize: 12, color: greyColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 4),
        if (catalog.shadeName.isNotEmpty)
          Text(
            'Shade: ${catalog.shadeName}',
            style: TextStyle(fontSize: 12, color: greyColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

        // const SizedBox(height: 4),
        const SizedBox(height: 4),
        Text(
          'MRP: ₹${catalog.mrp.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('Stock: ', style: TextStyle(fontSize: 12, color: greyColor)),
            Text(
              catalog.clqty.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: catalog.clqty > 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        bookNowButton ? _buildBookNowButton(context) : Container(),
      ],
    );
  }

  Widget _buildBookNowButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          _showBookingDialog(context);
        },
        child: const Text(
          'Book Now',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: CatalogBookingTable(
            itemSubGrpKey: catalog.itemSubGrpKey,
            itemKey: catalog.itemKey,
            styleKey: catalog.styleKey,
          ),
        );
      },
    );
  }
}
