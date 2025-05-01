import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';

class DownloadOptionsSheet extends StatefulWidget {
  final Function(String, Map<String, bool>) onDownload;
  final Map<String, bool>? initialOptions;

  const DownloadOptionsSheet({
    Key? key,
    required this.onDownload,
    this.initialOptions,
  }) : super(key: key);

  @override
  _DownloadOptionsSheetState createState() => _DownloadOptionsSheetState();
}

class _DownloadOptionsSheetState extends State<DownloadOptionsSheet> {
  late Map<String, bool> options;

  @override
  void initState() {
    super.initState();
    // Set all options to false by default
    options = widget.initialOptions ?? {
      'design': false,
      'shade': false,
      'rate': false,
      'size': false,
      'product': false,
      'remark': false,
    };
  }

void _showOptionsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Fields to Include',
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
                  _buildToggleOption('Design', options['design']!, (value) {
                    setState(() => options['design'] = value);
                  }),
                  _buildToggleOption('Shade', options['shade']!, (value) {
                    setState(() => options['shade'] = value);
                  }),
                  _buildToggleOption('Rate', options['rate']!, (value) {
                    setState(() => options['rate'] = value);
                  }),
                  _buildToggleOption('Size', options['size']!, (value) {
                    setState(() => options['size'] = value);
                  }),
                  _buildToggleOption('Product', options['product']!, (value) {
                    setState(() => options['product'] = value);
                  }),
                  _buildToggleOption('Remark', options['remark']!, (value) {
                    setState(() => options['remark'] = value);
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                      style: ElevatedButton.styleFrom(
                       // backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}



@override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.7,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Download Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showOptionsBottomSheet(context),
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
          _buildDownloadOption(
            icon: Icons.image,
            title: 'Download as Image',
            onTap: () {
              Navigator.pop(context);
              widget.onDownload('image', options);
            },
          ),
          const SizedBox(height: 8),
          _buildDownloadOption(
            icon: Icons.picture_as_pdf,
            title: 'Download as PDF',
            onTap: () {
              Navigator.pop(context);
              widget.onDownload('pdf', options);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}


Widget _buildDownloadOption({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor),
          SizedBox(width: 12),
          Text(title),
        ],
      ),
    ),
  );
}



  Widget _buildToggleOption(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
}