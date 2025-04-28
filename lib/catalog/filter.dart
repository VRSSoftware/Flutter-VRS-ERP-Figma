import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/shade.dart';
import 'package:vrs_erp_figma/models/size.dart';
import 'package:vrs_erp_figma/models/style.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:dropdown_search/dropdown_search.dart';

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

  List<Shade> selectedShades = [];
  List<Sizes> selectedSizes = [];

  TextEditingController fromMRPController = TextEditingController();
  TextEditingController toMRPController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  bool isCheckboxModeShade = true; // Checkbox mode for shades
  bool isCheckboxModeSize = true; // Checkbox mode for sizes
  bool isShadeExpanded = true; // Expansion state for shades
  bool isSizeExpanded = true; // Expansion state for sizes

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      styles = args['styles'] is List<Style> ? args['styles'] : [];
      shades = args['shades'] is List<Shade> ? args['shades'] : [];
      sizes = args['sizes'] is List<Sizes> ? args['sizes'] : [];
    }
  }

  DateTime? fromDate;
  DateTime? toDate;

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    DateTime? initialDate,
  ) async {
    final DateTime picked =
        await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        ) ??
        DateTime.now();

    setState(() {
      if (controller == fromDateController) {
        fromDate = picked;
      } else if (controller == toDateController) {
        toDate = picked;
      }
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  // Synchronize selected values between Checkbox and Select modes
  void syncSelectedValues(
    List<String> newSelectedValues,
    List<String> targetList,
  ) {
    setState(() {
      targetList.clear();
      targetList.addAll(newSelectedValues);
    });
  }

  // Show multi-select dialog for sizes and shades
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
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  children:
                      items.map((item) {
                        bool isSelected = selectedItems.contains(item);
                        return ListTile(
                          title: Text(item),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
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
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onChanged(List.from(selectedItems));
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Build the section for checkboxes (for shades or sizes)
  Widget _buildCheckboxSection(
    String title,
    List<String> items,
    List<String> selectedItems,
    Function(List<String>) onChanged,
  ) {
    List<Widget> rows = [];
    for (int i = 0; i < items.length; i += 3) {
      List<String> rowItems = items.sublist(
        i,
        i + 3 > items.length ? items.length : i + 3,
      );
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              rowItems.map((item) {
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
                      Expanded(
                        child: Text(item, overflow: TextOverflow.ellipsis),
                      ),
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
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(children: rows),
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
          builder:
              (context) => IconButton(
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
              DropdownSearch<String>.multiSelection(
                items: styles.map((style) => style.styleCode).toList(),
                selectedItems: selectedStyleCodes,
                onChanged: (selectedItems) {
                  setState(() {
                    selectedStyleCodes = List.from(selectedItems ?? []);
                  });
                },
                popupProps: PopupPropsMultiSelection.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: 'Search and select styles',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                itemAsString: (String styleCode) => styleCode,
                dropdownBuilder: (context, selectedItems) {
                  if (selectedItems == null || selectedItems.isEmpty) {
                    return Text('Select Styles');
                  } else {
                    return Text(selectedItems.join(', '));
                  }
                },
              ),

              // _buildDropdownSection(
              //   context,
              //   'Select Styles',
              //   styles.map((style) => style.styleCode).toList(),
              //   selectedStyleCodes,
              //   (updatedSelection) {
              //     setState(() {
              //       selectedStyleCodes = updatedSelection;
              //     });
              //   },
              // ),
              SizedBox(height: 10),
              // Shade Expansion Tile with "Select All" near the icons
              ExpansionTile(
                title: Text('Select Shades'),
                initiallyExpanded: isShadeExpanded,
                tilePadding: EdgeInsets.all(0),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            if (value == 'Checkbox') {
                              // Synchronize values when switching modes
                              syncSelectedValues(
                                selectedShadeCodes,
                                selectedShades
                                    .map((shade) => shade.shadeName)
                                    .toList(),
                              );
                              isCheckboxModeShade = true;
                            } else {
                              syncSelectedValues(
                                selectedShades
                                    .map((shade) => shade.shadeName)
                                    .toList(),
                                selectedShadeCodes,
                              );
                              isCheckboxModeShade = false;
                            }
                          });
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: 'Checkbox',
                                child: Text('Checkbox'),
                              ),
                              PopupMenuItem(
                                value: 'Select',
                                child: Text('Select'),
                              ),
                            ],
                        child: Row(
                          children: [
                            Icon(
                              isCheckboxModeShade
                                  ? Icons.check_box
                                  : Icons.arrow_drop_down,
                            ),
                            Text(isCheckboxModeShade ? 'Checkbox' : 'Select'),
                          ],
                        ),
                      ),
                      if (isShadeExpanded)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedShadeCodes =
                                  shades
                                      .map((shade) => shade.shadeName)
                                      .toList();
                            });
                          },
                          child: Text('Select All'),
                        ),
                    ],
                  ),
                  if (isCheckboxModeShade)
                    _buildCheckboxSection(
                      'Shades',
                      shades.map((shade) => shade.shadeName).toList(),
                      selectedShadeCodes,
                      (updatedSelection) {
                        setState(() {
                          selectedShadeCodes = updatedSelection;
                        });
                      },
                    )
                  else
                    DropdownSearch<Shade>.multiSelection(
                      items: shades,
                      selectedItems: selectedShades,
                      onChanged: (selectedItems) {
                        setState(() {
                          selectedShades = List.from(selectedItems ?? []);
                        });
                      },
                      popupProps: PopupPropsMultiSelection.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'Search and select shades',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      itemAsString: (Shade shade) => shade.shadeName,
                      dropdownBuilder: (context, selectedItems) {
                        if (selectedItems == null || selectedItems.isEmpty) {
                          return Text('Select shades');
                        } else {
                          return Text(
                            selectedItems.map((e) => e.shadeName).join(', '),
                          );
                        }
                      },
                    ),
                ],
                onExpansionChanged: (expanded) {
                  setState(() {
                    isShadeExpanded = expanded;
                  });
                },
              ),
              SizedBox(height: 10),

              // Size Expansion Tile with checkboxes or dropdown
              ExpansionTile(
                title: Text('Select Sizes'),
                initiallyExpanded: isSizeExpanded,
                //tilePadding: EdgeInsets.all(0),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            if (value == 'Checkbox') {
                              syncSelectedValues(
                                selectedSizeNames,
                                selectedSizes
                                    .map((size) => size.sizeName)
                                    .toList(),
                              );
                              isCheckboxModeSize = true;
                            } else {
                              syncSelectedValues(
                                selectedSizes
                                    .map((size) => size.sizeName)
                                    .toList(),
                                selectedSizeNames,
                              );
                              isCheckboxModeSize = false;
                            }
                          });
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: 'Checkbox',
                                child: Text('Checkbox'),
                              ),
                              PopupMenuItem(
                                value: 'Select',
                                child: Text('Select'),
                              ),
                            ],
                        child: Row(
                          children: [
                            Icon(
                              isCheckboxModeSize
                                  ? Icons.check_box
                                  : Icons.arrow_drop_down,
                            ),
                            Text(isCheckboxModeSize ? 'Checkbox' : 'Select'),
                          ],
                        ),
                      ),
                      if (isSizeExpanded)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedSizeNames =
                                  sizes.map((size) => size.sizeName).toList();
                            });
                          },
                          child: Text('Select All'),
                        ),
                    ],
                  ),
                  if (isCheckboxModeSize)
                    _buildCheckboxSection(
                      'Sizes',
                      sizes.map((size) => size.sizeName).toList(),
                      selectedSizeNames,
                      (updatedSelection) {
                        setState(() {
                          selectedSizeNames = updatedSelection;
                        });
                      },
                    )
                  else
                    DropdownSearch<String>.multiSelection(
                      items: sizes.map((size) => size.sizeName).toList(),
                      selectedItems: selectedSizeNames,
                      onChanged: (selectedItems) {
                        setState(() {
                          selectedSizeNames = List.from(selectedItems ?? []);
                        });
                      },
                      popupProps: PopupPropsMultiSelection.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'Search and select sizes',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      itemAsString: (String sizeName) => sizeName,
                      dropdownBuilder: (context, selectedItems) {
                        if (selectedItems == null || selectedItems.isEmpty) {
                          return Text('Select Sizes');
                        } else {
                          return Text(selectedItems.join(', '));
                        }
                      },
                    ),
                ],
                onExpansionChanged: (expanded) {
                  setState(() {
                    isSizeExpanded = expanded;
                  });
                },
              ),

              // Adding ExpansionTile for MRP and Dates
              SizedBox(height: 20),
              ExpansionTile(
                title: Text('Price Range'),
                tilePadding: EdgeInsets.all(0),
                initiallyExpanded: true, // Keep expanded by default
                children: [
                  // MRP Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: fromMRPController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'From MRP',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: toMRPController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'To MRP',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
              SizedBox(height: 20),
              ExpansionTile(
                title: Text('Date'),
                tilePadding: EdgeInsets.all(0),
                initiallyExpanded: true, // Keep expanded by default
                children: [
                  // Date Range Row (From Date & To Date)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: fromDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'From Date',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed:
                                  () => _selectDate(
                                    context,
                                    fromDateController,
                                    fromDate,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: toDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'To Date',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed:
                                  () => _selectDate(
                                    context,
                                    toDateController,
                                    toDate,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSection(
    BuildContext context,
    String title,
    List<String> items,
    List<String> selectedItems,
    Function(List<String>) onChanged,
  ) {
    return GestureDetector(
      onTap: () {
        _showMultiSelectDialog(context, title, items, selectedItems, onChanged);
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
              child: Text(
                selectedItems.isEmpty
                    ? 'Select $title'
                    : selectedItems.join(', '),
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
