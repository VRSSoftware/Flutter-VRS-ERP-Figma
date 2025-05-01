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
  bool selectAll = false;

  void _toggleAllOptions(bool value) {
    setState(() {
      selectAll = value;
      includeDesign = value;
      includeShade = value;
      includeRate = value;
      includeSize = value;
      includeProduct = value;
      includeRemark = value;
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
            // Title row with text, toggle, and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Share Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Switch(
                      value: selectAll,
                      onChanged: _toggleAllOptions,
                      activeColor: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
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
                      onChanged: (value) {
                        setState(() {
                          includeDesign = value;
                          if (!value) selectAll = false;
                        });
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Shade'),
                      value: includeShade,
                      onChanged: (value) {
                        setState(() {
                          includeShade = value;
                          if (!value) selectAll = false;
                        });
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Rate'),
                      value: includeRate,
                      onChanged: (value) {
                        setState(() {
                          includeRate = value;
                          if (!value) selectAll = false;
                        });
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Size'),
                      value: includeSize,
                      onChanged: (value) {
                        setState(() {
                          includeSize = value;
                          if (!value) selectAll = false;
                        });
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Product'),
                      value: includeProduct,
                      onChanged: (value) {
                        setState(() {
                          includeProduct = value;
                          if (!value) selectAll = false;
                        });
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('Include Remark'),
                      value: includeRemark,
                      onChanged: (value) {
                        setState(() {
                          includeRemark = value;
                          if (!value) selectAll = false;
                        });
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
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
                  side: BorderSide(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}