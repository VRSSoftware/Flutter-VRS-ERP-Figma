import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/catalog/toggle_option_screen.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';

class ShareOptionsPage extends StatefulWidget {
  final Function({
    bool includeDesign,
    bool includeShade,
    bool includeRate,
    bool includeWsp,
    bool includeSize,
    bool includeSizeMrp,
    bool includeSizeWsp,
    bool includeProduct,
    bool includeRemark,
  }) onImageShare;
  final Function({
    bool includeDesign,
    bool includeShade,
    bool includeRate,
    bool includeSize,
    bool includeProduct,
    bool includeRemark,
  }) onWhatsAppShare;
  final Function({
    bool includeDesign,
    bool includeShade,
    bool includeRate,
    bool includeWsp,
    bool includeSize,
    bool includeSizeMrp,
    bool includeSizeWsp,
    bool includeProduct,
    bool includeRemark,
  }) onPDFShare;
  final Function(
    bool,
    bool,
    bool,
    bool,
    bool,
    bool,
    bool,
    bool,
    bool,
  ) onToggleOptions;
  final bool includeDesign;
  final bool includeShade;
  final bool includeRate;
  final bool includeWsp;
  final bool includeSize;
  final bool includeSizeMrp;
  final bool includeSizeWsp;
  final bool includeProduct;
  final bool includeRemark;

  const ShareOptionsPage({
    Key? key,
    required this.onImageShare,
    required this.onWhatsAppShare,
    required this.onPDFShare,
    required this.onToggleOptions,
    required this.includeDesign,
    required this.includeShade,
    required this.includeRate,
    required this.includeWsp,
    required this.includeSize,
    required this.includeSizeMrp,
    required this.includeSizeWsp,
    required this.includeProduct,
    required this.includeRemark,
  }) : super(key: key);

  @override
  _ShareOptionsPageState createState() => _ShareOptionsPageState();
}

class _ShareOptionsPageState extends State<ShareOptionsPage> {
  late bool includeDesign;
  late bool includeShade;
  late bool includeRate;
  late bool includeWsp;
  late bool includeSize;
  late bool includeSizeMrp;
  late bool includeSizeWsp;
  late bool includeProduct;
  late bool includeRemark;

  @override
  void initState() {
    super.initState();
    includeDesign = widget.includeDesign;
    includeShade = widget.includeShade;
    includeRate = widget.includeRate;
    includeWsp = widget.includeWsp;
    includeSize = widget.includeSize;
    includeSizeMrp = widget.includeSizeMrp;
    includeSizeWsp = widget.includeSizeWsp;
    includeProduct = widget.includeProduct;
    includeRemark = widget.includeRemark;
  }

  Future<void> _showToggleOptions(BuildContext context) async {
    final options = await showModalBottomSheet<Map<String, bool>>(
      context: context,
      builder: (context) => ToggleOptionsScreen(
        includeDesign: includeDesign,
        includeShade: includeShade,
        includeRate: includeRate,
        includeWsp: includeWsp,
        includeSize: includeSize,
        includeSizeMrp: includeSizeMrp,
        includeSizeWsp: includeSizeWsp,
        includeProduct: includeProduct,
        includeRemark: includeRemark,
      ),
    );

    if (options != null) {
      setState(() {
        includeDesign = options['design'] ?? includeDesign;
        includeShade = options['shade'] ?? includeShade;
        includeRate = options['rate'] ?? includeRate;
        includeWsp = options['wsp'] ?? includeWsp;
        includeSize = options['size'] ?? includeSize;
        includeSizeMrp = options['rate1'] ?? includeSizeMrp;
        includeSizeWsp = options['wsp1'] ?? includeSizeWsp;
        includeProduct = options['product'] ?? includeProduct;
        includeRemark = options['remark'] ?? includeRemark;
      });

      // Call onToggleOptions to update parent state and save to shared_preferences
      widget.onToggleOptions(
        includeDesign,
        includeShade,
        includeRate,
        includeWsp,
        includeSize,
        includeSizeMrp,
        includeSizeWsp,
        includeProduct,
        includeRemark,
      );
    }
  }

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
            onTap: () {
              widget.onImageShare(
                includeDesign: includeDesign,
                includeShade: includeShade,
                includeRate: includeRate,
                includeWsp: includeWsp,
                includeSize: includeSize,
                includeSizeMrp: includeSizeMrp,
                includeSizeWsp: includeSizeWsp,
                includeProduct: includeProduct,
                includeRemark: includeRemark,
              );
            },
            context: context,
          ),
          _buildShareOption(
            icon: Icons.ios_share,
            title: 'WhatsApp',
            onTap: () {
              widget.onWhatsAppShare(
                includeDesign: includeDesign,
                includeShade: includeShade,
                includeRate: includeRate,
                includeSize: includeSize,
                includeProduct: includeProduct,
                includeRemark: includeRemark,
              );
            },
            context: context,
          ),
          _buildShareOption(
            icon: Icons.picture_as_pdf,
            title: 'PDF',
            onTap: () {
              widget.onPDFShare(
                includeDesign: includeDesign,
                includeShade: includeShade,
                includeRate: includeRate,
                includeWsp: includeWsp,
                includeSize: includeSize,
                includeSizeMrp: includeSizeMrp,
                includeSizeWsp: includeSizeWsp,
                includeProduct: includeProduct,
                includeRemark: includeRemark,
              );
            },
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
}