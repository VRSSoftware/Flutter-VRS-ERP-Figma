import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<String> styles = ['Style 01', 'Style 02', 'Style 03', 'Style 04'];
  List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];
  List<String> shades = ['Red', 'Blue', 'Green', 'Black', 'White'];

  List<String> selectedStyles = [];
  List<String> selectedSizes = [];
  List<String> selectedShades = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
      appBar: AppBar(
        title: Text('Filter', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Select Style', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: styles.map((style) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 24,
                  child: CheckboxListTile(
                    title: Text(style),
                    value: selectedStyles.contains(style),
                    activeColor: AppColors.primaryColor,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedStyles.add(style);
                        } else {
                          selectedStyles.remove(style);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24),
            Text('Select Size', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: sizes.map((size) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 24,
                  child: CheckboxListTile(
                    title: Text(size),
                    value: selectedSizes.contains(size),
                    activeColor: AppColors.primaryColor,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedSizes.add(size);
                        } else {
                          selectedSizes.remove(size);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24),
            Text('Select Shade', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: shades.map((shade) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 24,
                  child: CheckboxListTile(
                    title: Text(shade),
                    value: selectedShades.contains(shade),
                    activeColor: AppColors.primaryColor,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedShades.add(shade);
                        } else {
                          selectedShades.remove(shade);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
bottomNavigationBar: Container(
  color: Colors.white, // <-- Changed to white
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Expanded(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Colors.grey, // Border color for the Clear button
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _clearFilters,
          child: Text('Clear'),
        ),
      ),
      SizedBox(width: 16),
      Expanded(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: AppColors.primaryColor, // Border color for the Apply button
            ),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _applyFilters,
          child: Text('Apply'),
        ),
      ),
    ],
  ),
),

    );
  }

  void _clearFilters() {
    setState(() {
      selectedStyles.clear();
      selectedSizes.clear();
      selectedShades.clear();
    });
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'styles': selectedStyles,
      'sizes': selectedSizes,
      'shades': selectedShades,
    });
  }
}
