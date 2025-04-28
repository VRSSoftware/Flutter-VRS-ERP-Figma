// import 'package:flutter/material.dart';
// import 'package:vrs_erp_figma/constants/app_constants.dart';
// import 'package:vrs_erp_figma/models/shade.dart';
// import 'package:vrs_erp_figma/models/size.dart';
// import 'package:vrs_erp_figma/models/style.dart';
// import 'package:vrs_erp_figma/screens/drawer_screen.dart';

// class FilterPage extends StatefulWidget {
//   @override
//   _FilterPageState createState() => _FilterPageState();
// }

// class _FilterPageState extends State<FilterPage> {
//   List<Style> styles = [];
//   List<Shade> shades = [];
//   List<Sizes> sizes = [];

//   List<String> selectedStyleCodes = [];
//   List<String> selectedShadeCodes = [];
//   List<String> selectedSizeNames = [];

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Access arguments after context is fully initialized
//     final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
//     if (args != null) {
//       styles = args['styles'] is List<Style> ? args['styles'] : [];
//       shades = args['shades'] is List<Shade> ? args['shades'] : [];
//       sizes = args['sizes'] is List<Sizes> ? args['sizes'] : [];
//     }
//   }

//   Future<void> _showMultiSelectDialog(
//     BuildContext context,
//     String title,
//     List<String> items,
//     List<String> selectedItems,
//     Function(List<String>) onChanged,
//   ) {
//     return showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(title),
//           content: SingleChildScrollView(
//             child: Column(
//               children: items.map((item) {
//                 bool isSelected = selectedItems.contains(item);
//                 return ListTile(
//                   title: Text(item),
//                   trailing: isSelected
//                       ? Icon(Icons.check_circle, color: Colors.green)
//                       : Icon(Icons.check_circle_outline),
//                   onTap: () {
//                     setState(() {
//                       if (isSelected) {
//                         selectedItems.remove(item);
//                       } else {
//                         selectedItems.add(item);
//                       }
//                     });
//                     onChanged(selectedItems); // Update the selection list
//                   },
//                 );
//               }).toList(),
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Done'),
//             ),
//           ],
//         );
//       },
//     ) as Future<void>;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: DrawerScreen(),
//       appBar: AppBar(
//         title: Text('Filter', style: TextStyle(color: Colors.white)),
//         backgroundColor: AppColors.primaryColor,
//         elevation: 1,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: Icon(Icons.menu, color: Colors.white),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Style Dropdown with Multi-Select Dialog
//             GestureDetector(
//               onTap: () {
//                 _showMultiSelectDialog(
//                   context,
//                   'Select Styles',
//                   styles.map((style) => style.styleCode).toList(),
//                   selectedStyleCodes,
//                   (updatedSelection) {
//                     setState(() {
//                       selectedStyleCodes = updatedSelection;
//                     });
//                   },
//                 );
//               },
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('Styles: ${selectedStyleCodes.join(', ')}', style: TextStyle(fontSize: 16)),
//                     Icon(Icons.arrow_drop_down),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),

//             // Shade Dropdown with Multi-Select Dialog
//             GestureDetector(
//               onTap: () {
//                 _showMultiSelectDialog(
//                   context,
//                   'Select Shades',
//                   shades.map((shade) => shade.shadeName).toList(),
//                   selectedShadeCodes,
//                   (updatedSelection) {
//                     setState(() {
//                       selectedShadeCodes = updatedSelection;
//                     });
//                   },
//                 );
//               },
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('Shades: ${selectedShadeCodes.join(', ')}', style: TextStyle(fontSize: 16)),
//                     Icon(Icons.arrow_drop_down),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),

//             // Size Dropdown with Multi-Select Dialog
//             GestureDetector(
//               onTap: () {
//                 _showMultiSelectDialog(
//                   context,
//                   'Select Sizes',
//                   sizes.map((size) => size.sizeName).toList(),
//                   selectedSizeNames,
//                   (updatedSelection) {
//                     setState(() {
//                       selectedSizeNames = updatedSelection;
//                     });
//                   },
//                 );
//               },
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('Sizes: ${selectedSizeNames.join(', ')}', style: TextStyle(fontSize: 16)),
//                     Icon(Icons.arrow_drop_down),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/shade.dart';
import 'package:vrs_erp_figma/models/size.dart';
import 'package:vrs_erp_figma/models/style.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<Style> styles = [];
  List<Shade> shades = [];
  List<Sizes> sizes = [];

  List<String> selectedStyleCodes = [];
  List<String> selectedShadeCodes = [];
  List<String> selectedSizeNames = [];

  bool isCheckboxMode = false; // To toggle between dropdown and checkbox mode

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access arguments after context is fully initialized
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      styles = args['styles'] is List<Style> ? args['styles'] : [];
      shades = args['shades'] is List<Shade> ? args['shades'] : [];
      sizes = args['sizes'] is List<Sizes> ? args['sizes'] : [];
    }
  }

  Future<void> _showMultiSelectDialog(
    BuildContext context,
    String title,
    List<String> items,
    List<String> selectedItems,
    Function(List<String>) onChanged,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              children: items.map((item) {
                bool isSelected = selectedItems.contains(item);
                return ListTile(
                  title: Text(item),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(Icons.check_circle_outline),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedItems.remove(item);
                      } else {
                        selectedItems.add(item);
                      }
                    });
                    onChanged(selectedItems); // Update the selection list
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Done'),
            ),
          ],
        );
      },
    ) as Future<void>;
  }

  // Method to build checkbox section in a 3-column grid
  Widget _buildCheckboxSection(
    String title,
    List<String> items,
    List<String> selectedItems,
    Function(List<String>) onChanged,
  ) {
    List<Widget> rows = [];
    // Split the items into rows of 3
    for (int i = 0; i < items.length; i += 3) {
      // Get up to 3 items for the current row
      List<String> rowItems = items.sublist(i, i + 3 > items.length ? items.length : i + 3);
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: rowItems.map((item) {
            bool isSelected = selectedItems.contains(item);
            return Expanded(
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedItems.add(item);
                        } else {
                          selectedItems.remove(item);
                        }
                      });
                      onChanged(selectedItems);
                    },
                  ),
                  Expanded(child: Text(item, overflow: TextOverflow.ellipsis)),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title:', style: TextStyle(fontSize: 16)),
        // Use SingleChildScrollView here to allow scrolling for checkboxes
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: rows,
          ),
        ),
      ],
    );
  }

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
        actions: [
          // Toggle switch to switch between dropdown and checkbox mode
          Switch(
            value: isCheckboxMode,
            onChanged: (value) {
              setState(() {
                isCheckboxMode = value;
              });
            },
            activeColor: Colors.white,
          ),
          //Text(isCheckboxMode ? "Checkbox" : "Dropdown")
        ],
      ),
      body: SingleChildScrollView( // Wrap the entire body with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Conditional rendering based on `isCheckboxMode`
              if (isCheckboxMode) ...[
                // Style Checkbox List
                _buildCheckboxSection(
                  'Styles',
                  styles.map((style) => style.styleCode).toList(),
                  selectedStyleCodes,
                  (updatedSelection) {
                    setState(() {
                      selectedStyleCodes = updatedSelection;
                    });
                  },
                ),
                SizedBox(height: 20),

                // Shade Checkbox List
                _buildCheckboxSection(
                  'Shades',
                  shades.map((shade) => shade.shadeName).toList(),
                  selectedShadeCodes,
                  (updatedSelection) {
                    setState(() {
                      selectedShadeCodes = updatedSelection;
                    });
                  },
                ),
                SizedBox(height: 20),

                // Size Checkbox List
                _buildCheckboxSection(
                  'Sizes',
                  sizes.map((size) => size.sizeName).toList(),
                  selectedSizeNames,
                  (updatedSelection) {
                    setState(() {
                      selectedSizeNames = updatedSelection;
                    });
                  },
                ),
              ] else ...[
                // Style Dropdown with Multi-Select Dialog
                _buildDropdownSection(
                  context,
                  'Select Styles',
                  styles.map((style) => style.styleCode).toList(),
                  selectedStyleCodes,
                  (updatedSelection) {
                    setState(() {
                      selectedStyleCodes = updatedSelection;
                    });
                  },
                ),
                SizedBox(height: 20),

                // Shade Dropdown with Multi-Select Dialog
                _buildDropdownSection(
                  context,
                  'Select Shades',
                  shades.map((shade) => shade.shadeName).toList(),
                  selectedShadeCodes,
                  (updatedSelection) {
                    setState(() {
                      selectedShadeCodes = updatedSelection;
                    });
                  },
                ),
                SizedBox(height: 20),

                // Size Dropdown with Multi-Select Dialog
                _buildDropdownSection(
                  context,
                  'Select Sizes',
                  sizes.map((size) => size.sizeName).toList(),
                  selectedSizeNames,
                  (updatedSelection) {
                    setState(() {
                      selectedSizeNames = updatedSelection;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Method to build dropdown section
  Widget _buildDropdownSection(
    BuildContext context,
    String title,
    List<String> items,
    List<String> selectedItems,
    Function(List<String>) onChanged,
  ) {
    return GestureDetector(
      onTap: () {
        _showMultiSelectDialog(
          context,
          title,
          items,
          selectedItems,
          onChanged,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$title: ${selectedItems.join(', ')}', style: TextStyle(fontSize: 16)),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
