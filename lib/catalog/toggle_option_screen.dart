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

  bool get allSelected =>
      includeDesign &&
      includeShade &&
      includeRate &&
      includeSize &&
      includeProduct &&
      includeRemark;

  void toggleAll(bool? value) {
    final newValue = value ?? false;
    setState(() {
      includeDesign = newValue;
      includeShade = newValue;
      includeRate = newValue;
      includeSize = newValue;
      includeProduct = newValue;
      includeRemark = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: Column(
          children: [
            // Header with Select All checkbox and close button
    Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(
      children: [
        const Text(
          'Select Share Options',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 90), // Add horizontal space here
        Checkbox(
          value: allSelected,
          onChanged: toggleAll,
          activeColor: AppColors.primaryColor,
        ),
      ],
    ),
    IconButton(
      icon: const Icon(Icons.close),
      onPressed: () => Navigator.pop(context),
    ),
  ],
),

            const SizedBox(height: 8),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Include Design'),
                      value: includeDesign,
                      onChanged: (value) =>
                          setState(() => includeDesign = value),
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Shade'),
                      value: includeShade,
                      onChanged: (value) =>
                          setState(() => includeShade = value),
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Rate'),
                      value: includeRate,
                      onChanged: (value) =>
                          setState(() => includeRate = value),
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Size'),
                      value: includeSize,
                      onChanged: (value) =>
                          setState(() => includeSize = value),
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Product'),
                      value: includeProduct,
                      onChanged: (value) =>
                          setState(() => includeProduct = value),
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Remark'),
                      value: includeRemark,
                      onChanged: (value) =>
                          setState(() => includeRemark = value),
                      activeColor: AppColors.primaryColor,
                    ),
                  ],
                ),
            
              ),
            ),

            // Done button
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
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: AppColors.primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
