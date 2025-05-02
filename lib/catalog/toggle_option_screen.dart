import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';

class ToggleOptionsScreen extends StatefulWidget {
  const ToggleOptionsScreen({Key? key}) : super(key: key);

  @override
  _ToggleOptionsScreenState createState() => _ToggleOptionsScreenState();
}

class _ToggleOptionsScreenState extends State<ToggleOptionsScreen> {
bool includeDesign = true;
bool includeShade = true;
bool includeRate = true;
bool includeSize = true;
bool includeProduct = true;
bool includeRemark = true;


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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: Column(
                    mainAxisSize: MainAxisSize.min,

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
        const SizedBox(width: 70), // Add horizontal space here
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

     

   Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: _buildCompactSwitchTile('Include Design', includeDesign, 
                        (v) => setState(() => includeDesign = v)),
                  ),
                  Flexible(
                    child: _buildCompactSwitchTile('Include Shade', includeShade, 
                        (v) => setState(() => includeShade = v)),
                  ),
                  Flexible(
                    child: _buildCompactSwitchTile('Include Rate', includeRate, 
                        (v) => setState(() => includeRate = v)),
                  ),
                  Flexible(
                    child: _buildCompactSwitchTile('Include Size', includeSize, 
                        (v) => setState(() => includeSize = v)),
                  ),
                  Flexible(
                    child: _buildCompactSwitchTile('Include Product', includeProduct, 
                        (v) => setState(() => includeProduct = v)),
                  ),
                  Flexible(
                    child: _buildCompactSwitchTile('Include Remark', includeRemark, 
                        (v) => setState(() => includeRemark = v)),
                  ),
                ],
              ),
            ),

            // Done button
Container(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
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
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      backgroundColor:AppColors.primaryColor ,
      side: BorderSide(color: AppColors.primaryColor),
      shape: RoundedRectangleBorder( // 👈 Add this for rounded corners
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildCompactSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      activeColor: AppColors.primaryColor,
    );
  }
