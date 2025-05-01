import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';

class ToggleOptionsScreen extends StatefulWidget {
  const ToggleOptionsScreen({Key? key}) : super(key: key);

  @override
  _ToggleOptionsScreenState createState() => _ToggleOptionsScreenState();
}

class _ToggleOptionsScreenState extends State<ToggleOptionsScreen> {
  bool includeDesign = false;
  bool includeShade = false;
  bool includeRate = false;
  bool includeSize = false;
  bool includeProduct = false;
  bool includeRemark = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height *
              0.65, // Adjusted height to fit the screen
        ),
        child: Column(
          children: [
            // Close button at the top right corner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Share Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ), // Reduced height between title and switch list
            // Wrap the SwitchListTile widgets inside an Expanded widget to allow flexible height usage
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Include Design'),
                      value: includeDesign,
                      onChanged:
                          (value) => setState(() => includeDesign = value),
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Shade'),
                      value: includeShade,
                      onChanged:
                          (value) => setState(() => includeShade = value),
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Rate'),
                      value: includeRate,
                      onChanged: (value) => setState(() => includeRate = value),
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Size'),
                      value: includeSize,
                      onChanged: (value) => setState(() => includeSize = value),
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Product'),
                      value: includeProduct,
                      onChanged:
                          (value) => setState(() => includeProduct = value),
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Remark'),
                      value: includeRemark,
                      onChanged:
                          (value) => setState(() => includeRemark = value),
                      activeColor: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            // 'Done' button at the bottom, wrapped inside a Container to avoid overflow
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'design': includeDesign,
                    'shade': includeShade,
                    'rate': includeRate,
                    'size': includeSize,
                    'product': includeProduct,
                    'remark': includeRemark,
                  });
                },
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: AppColors.primaryColor, // Use custom primary color
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white, // Optional: white background
                  side: BorderSide(
                    color: AppColors.primaryColor,
                  ), // Optional border
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
