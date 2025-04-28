import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/catalog/toggle_option_screen.dart';

class ShareOptionsPage extends StatelessWidget {
  final Function() onImageShare;
  final Function() onPDFShare;
  final Function() onWeblinkShare;
  final Function() onVideoShare;
  final Function() onQRCodeShare;
  final Function(bool, bool, bool, bool,bool,bool) onToggleOptions;

  const ShareOptionsPage({
    Key? key,
    required this.onImageShare,
    required this.onPDFShare,
    required this.onWeblinkShare,
    required this.onVideoShare,
    required this.onQRCodeShare,
    required this.onToggleOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Share Design as',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
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
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showToggleOptions(context),
      ),
      onTap: onTap,
    );
  }

  Future<void> _showToggleOptions(BuildContext context) async {
    final options = await Navigator.push<Map<String, bool>>(
      context,
      MaterialPageRoute(
        builder: (context) => ToggleOptionsScreen(),
      ),
    );
    
    if (options != null) {
      onToggleOptions(
        options['design'] ?? true,
        options['shade'] ?? true,
        options['rate'] ?? true,
        options['size'] ?? true,
        options['product']??true,
        options['remark']??true,
      );
    }
  }
}