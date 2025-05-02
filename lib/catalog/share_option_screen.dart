import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/catalog/toggle_option_screen.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';

class ShareOptionsPage extends StatelessWidget {
  final Function() onImageShare;
  final Function() onWhatsAppShare;
  final Function() onPDFShare;
  final Function() onWeblinkShare;
  final Function() onVideoShare;
  final Function() onQRCodeShare;
  final Function(bool, bool, bool, bool, bool, bool) onToggleOptions;

  const ShareOptionsPage({
    Key? key,
    required this.onImageShare,
    required this.onWhatsAppShare,
    required this.onPDFShare,
    required this.onWeblinkShare,
    required this.onVideoShare,
    required this.onQRCodeShare,
    required this.onToggleOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Share Design as',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showToggleOptions(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildShareOption(
            icon: Icons.image,
            title: 'Image',
            onTap: onImageShare,
            context: context,
          ),
          _buildShareOption(
            icon: Icons.ios_share,
            title: 'WhatsApp',
            onTap: onWhatsAppShare,
            context: context,
          ),
          _buildShareOption(
            icon: Icons.picture_as_pdf,
            title: 'PDF',
            onTap: onPDFShare,
            context: context,
          ),
          _buildShareOption(
            icon: Icons.link,
            title: 'Weblink',
            onTap: onWeblinkShare,
            context: context,
          ),
          _buildShareOption(
            icon: Icons.video_library,
            title: 'Video',
            onTap: onVideoShare,
            context: context,
          ),
          _buildShareOption(
            icon: Icons.qr_code,
            title: 'With QR Code',
            onTap: onQRCodeShare,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String title,
    required Function() onTap,
    required BuildContext context,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      onTap: onTap,
    );
  }

  Future<void> _showToggleOptions(BuildContext context) async {
    final options = await showModalBottomSheet<Map<String, bool>>(
      context: context,
      builder: (context) => const ToggleOptionsScreen(),
    );

    if (options != null) {
      onToggleOptions(
        options['design'] ?? false,
        options['shade'] ?? false,
        options['rate'] ?? false,
        options['size'] ?? false,
        options['product'] ?? false,
        options['remark'] ?? false,
      );
    }
  }
}
