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

  List<Shade> selectedShades = [];
  List<Sizes> selectedSizes = [];
  //List<String> selectedStyleCodes = [];
  List<String> selectedStyleKeys = [];

  TextEditingController fromMRPController = TextEditingController();
  TextEditingController toMRPController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  bool isCheckboxModeShade = true;
  bool isShadeExpanded = true;
  bool isCheckboxModeSize = true;
  bool isSizeExpanded = true;

  DateTime? fromDate;
  DateTime? toDate;

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

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    DateTime? initialDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (controller == fromDateController) {
          fromDate = picked;
        } else if (controller == toDateController) {
          toDate = picked;
        }
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void syncSelectedShades(List<Shade> newSelectedShades) {
    setState(() {
      selectedShades = List.from(newSelectedShades);
    });
  }

  void syncSelectedSizes(List<Sizes> newSelectedSizes) {
    setState(() {
      selectedSizes = List.from(newSelectedSizes);
    });
  }

  Widget _buildCheckboxSection<T>(
    List<T> items,
    List<T> selectedItems,
    bool Function(T, T) compareFn,
    String Function(T) labelFn,
    Function(List<T>) onChanged,
  ) {
    List<Widget> rows = [];
    for (int i = 0; i < items.length; i += 3) {
      List<T> rowItems = items.sublist(
        i,
        i + 3 > items.length ? items.length : i + 3,
      );
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              rowItems.map((item) {
                bool isSelected = selectedItems.any((s) => compareFn(s, item));
                return Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (!selectedItems.any(
                                (s) => compareFn(s, item),
                              )) {
                                selectedItems.add(item);
                              }
                            } else {
                              selectedItems.removeWhere(
                                (s) => compareFn(s, item),
                              );
                            }
                          });
                          onChanged(selectedItems);
                        },
                      ),
                      Expanded(
                        child: Text(
                          labelFn(item),
                          overflow: TextOverflow.ellipsis,
                        ),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(
              children: [
                // ✅ Shades Filter
                ExpansionTile(
                  title: Text('Select Styles'),
                  initiallyExpanded: true,
                  tilePadding: EdgeInsets.all(0),
                  children: [
                    // DropdownSearch<String>.multiSelection(
                    //   items: styles.map((style) => style.styleCode).toList(),
                    //   selectedItems: selectedStyleCodes,
                    //   onChanged: (selectedItems) {
                    //     setState(() {
                    //       selectedStyleCodes = List.from(selectedItems ?? []);
                    //     });
                    //   },
                    //   popupProps: PopupPropsMultiSelection.menu(
                    //     showSearchBox: true,
                    //     searchFieldProps: TextFieldProps(
                    //       decoration: InputDecoration(
                    //         hintText: 'Search and select styles',
                    //         border: OutlineInputBorder(),
                    //       ),
                    //     ),
                    //   ),
                    //   itemAsString: (String styleCode) => styleCode,
                    //   dropdownBuilder: (context, selectedItems) {
                    //     if (selectedItems == null || selectedItems.isEmpty) {
                    //       return Text('Select Styles');
                    //     } else {
                    //       return Text(selectedItems.join(', '));
                    //     }
                    //   },
                    // ),
                     DropdownSearch<String>.multiSelection(
                    items: styles.map((style) => style.styleKey).toList(),
                    selectedItems: selectedStyleKeys,
                    onChanged: (selectedItems) {
                      setState(() {
                        selectedStyleKeys = List.from(selectedItems ?? []);
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
                    itemAsString: (String styleKey) => styleKey,
                    dropdownBuilder: (context, selectedItems) {
                      if (selectedItems == null || selectedItems.isEmpty) {
                        return Text('Select Styles');
                      } else {
                        return Text(selectedItems.join(', '));
                      }
                    },
                  ),
                  ],
                ),
                SizedBox(height: 20),

                SizedBox(height: 16),
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
                              isCheckboxModeShade = value == 'Checkbox';
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
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (selectedShades.length == shades.length) {
                                selectedShades.clear();
                              } else {
                                selectedShades = List.from(shades);
                              }
                            });
                          },
                          child: Text(
                            selectedShades.length == shades.length
                                ? 'Deselect All'
                                : 'Select All',
                          ),
                        ),
                      ],
                    ),
                    if (isCheckboxModeShade)
                      _buildCheckboxSection<Shade>(
                        shades,
                        selectedShades,
                        (a, b) => a.shadeKey == b.shadeKey,
                        (s) => s.shadeName,
                        syncSelectedShades,
                      )
                    else
                      DropdownSearch<Shade>.multiSelection(
                        items: shades,
                        selectedItems: selectedShades,
                        onChanged:
                            (selectedItems) =>
                                syncSelectedShades(selectedItems ?? []),
                        popupProps: PopupPropsMultiSelection.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: 'Search and select shades',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        itemAsString: (Shade s) => s.shadeName,
                        compareFn: (a, b) => a.shadeKey == b.shadeKey,
                        dropdownBuilder:
                            (context, selectedItems) => Text(
                              selectedItems.isEmpty
                                  ? 'Select shades'
                                  : selectedItems
                                      .map((e) => e.shadeName)
                                      .join(', '),
                            ),
                      ),
                  ],
                  onExpansionChanged:
                      (expanded) => setState(() => isShadeExpanded = expanded),
                ),

                SizedBox(height: 16),

                // ✅ Sizes Filter
                ExpansionTile(
                  title: Text('Select Sizes'),
                  initiallyExpanded: isSizeExpanded,
                  tilePadding: EdgeInsets.all(0),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            setState(() {
                              isCheckboxModeSize = value == 'Checkbox';
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
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (selectedSizes.length == sizes.length) {
                                selectedSizes.clear();
                              } else {
                                selectedSizes = List.from(sizes);
                              }
                            });
                          },
                          child: Text(
                            selectedSizes.length == sizes.length
                                ? 'Deselect All'
                                : 'Select All',
                          ),
                        ),
                      ],
                    ),
                    if (isCheckboxModeSize)
                      _buildCheckboxSection<Sizes>(
                        sizes,
                        selectedSizes,
                        (a, b) => a.itemSizeKey == b.itemSizeKey,
                        (s) => s.sizeName,
                        syncSelectedSizes,
                      )
                    else
                      DropdownSearch<Sizes>.multiSelection(
                        items: sizes,
                        selectedItems: selectedSizes,
                        onChanged:
                            (selectedItems) =>
                                syncSelectedSizes(selectedItems ?? []),
                        popupProps: PopupPropsMultiSelection.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: 'Search and select sizes',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        itemAsString: (Sizes s) => s.sizeName,
                        compareFn: (a, b) => a.itemSizeKey == b.itemSizeKey,
                        dropdownBuilder:
                            (context, selectedItems) => Text(
                              selectedItems.isEmpty
                                  ? 'Select sizes'
                                  : selectedItems
                                      .map((e) => e.sizeName)
                                      .join(', '),
                            ),
                      ),
                  ],
                  onExpansionChanged:
                      (expanded) => setState(() => isSizeExpanded = expanded),
                ),

                SizedBox(height: 20),

                // ✅ Price Range Filter
                ExpansionTile(
                  title: Text('Price Range'),
                  tilePadding: EdgeInsets.all(0),
                  initiallyExpanded: true,
                  children: [
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
                  ],
                ),

                SizedBox(height: 20),

                // ✅ Date Range Filter
                ExpansionTile(
                  title: Text('Date'),
                  tilePadding: EdgeInsets.all(0),
                  initiallyExpanded: true,
                  children: [
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
                  ],
                ),
              ],
            ),
          ),

          // Filter Button at the Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  // Collect all selected values and return to previous screen
                  Map<String, dynamic> selectedFilters = {
                    'styles': selectedStyleKeys,
                    'shades': selectedShades,
                    'sizes': selectedSizes,
                    'fromMRP': fromMRPController.text,
                    'toMRP': toMRPController.text,
                    'fromDate': fromDateController.text,
                    'toDate': toDateController.text,
                  };

                  Navigator.pop(context, selectedFilters);
                },
                child: Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
