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

  List<String> filteredStyles = [];
  List<String> filteredShades = [];
  List<String> filteredSizes = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      styles = args['styles'] is List<Style> ? args['styles'] : [];
      shades = args['shades'] is List<Shade> ? args['shades'] : [];
      sizes = args['sizes'] is List<Sizes> ? args['sizes'] : [];
      filteredStyles = styles.map((style) => style.styleCode).toList();
      filteredShades = shades.map((shade) => shade.shadeName).toList();
      filteredSizes = sizes.map((size) => size.sizeName).toList();
    }
  }

  // Method to build searchable dropdown with multiselect functionality
  Widget _buildDropdownSection(
    BuildContext context,
    String title,
    List<String> items,
    List<String> selectedItems,
    Function(List<String>) onChanged,
  ) {
    TextEditingController searchController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedItems.clear();
                  selectedItems.addAll(items);
                });
                onChanged(selectedItems);
              },
              child: Text('Select All', style: TextStyle(color: Colors.blue)),
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
        SizedBox(height: 8),
        // Searchable Dropdown Section
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(hintText: 'Search $title'),
                        onChanged: (query) {
                          setState(() {
                            if (title == 'Select Styles') {
                              filteredStyles = items
                                  .where((item) => item.toLowerCase().contains(query.toLowerCase()))
                                  .toList();
                            } else if (title == 'Select Shades') {
                              filteredShades = items
                                  .where((item) => item.toLowerCase().contains(query.toLowerCase()))
                                  .toList();
                            } else if (title == 'Select Sizes') {
                              filteredSizes = items
                                  .where((item) => item.toLowerCase().contains(query.toLowerCase()))
                                  .toList();
                            }
                          });
                        },
                      ),
                      Expanded(
                        child: ListView(
                          children: (title == 'Select Styles'
                                  ? filteredStyles
                                  : title == 'Select Shades'
                                      ? filteredShades
                                      : filteredSizes)
                              .map((item) {
                            bool isSelected = selectedItems.contains(item);
                            return ListTile(
                              title: Text(item),
                              trailing: Icon(
                                isSelected ? Icons.check_circle : Icons.check_circle_outline,
                                color: isSelected ? Colors.green : null,
                              ),
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedItems.remove(item);
                                  } else {
                                    selectedItems.add(item);
                                  }
                                });
                                onChanged(selectedItems);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8.0,
                    children: selectedItems.map((item) {
                      return Chip(
                        label: Text(item),
                        deleteIcon: Icon(Icons.cut, size: 18),
                        deleteIconColor: Colors.red,
                        onDeleted: () {
                          setState(() {
                            selectedItems.remove(item);
                          });
                          onChanged(selectedItems);
                        },
                      );
                    }).toList(),
                  ),
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
          ),
        ),
      ),
    );
  }
}
