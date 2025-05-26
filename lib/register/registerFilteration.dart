import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/keyName.dart';
import 'package:vrs_erp_figma/services/app_services.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';

class RegisterFilterPage extends StatefulWidget {
  @override
  State<RegisterFilterPage> createState() => _FilterPageState();
}
class _FilterPageState extends State<RegisterFilterPage> {
  List<KeyName> ledgerList = [];
  List<KeyName> salespersonList = [];
  KeyName? selectedLedger;
  KeyName? selectedSalesperson;
  bool isLedgerExpanded = true;
  bool isSalespersonExpanded = true;


@override
  void initState() {
    super.initState();
    // Retrieve arguments passed from RegisterPage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          ledgerList = args['ledgerList'] ?? [];
          salespersonList = args['salespersonList'] ?? [];
          selectedLedger = args['selectedLedger'];
          selectedSalesperson = args['selectedSalesperson'];
        });
      }
    });
  }


  // Common ExpansionTile Widget
Widget _buildExpansionTile({
    required String title,
    required List<Widget> children,
    bool initiallyExpanded = true,
    ValueChanged<bool>? onExpansionChanged,
  }) {
    return CustomExpansionTile(
      title: title,
      initiallyExpanded: initiallyExpanded,
      onExpansionChanged: onExpansionChanged,
      children: children,
    );
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
      appBar: AppBar(
        title: Text('Filter Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(
              children: [
                // Ledger Section
                _buildExpansionTile(
                  title: 'Select Ledger',
                  initiallyExpanded: isLedgerExpanded,
                  onExpansionChanged: (expanded) => setState(() => isLedgerExpanded = expanded),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: DropdownSearch<KeyName>(
                        items: ledgerList,
                        selectedItem: selectedLedger,
                        itemAsString: (KeyName? u) => u?.name ?? '',
                        onChanged: (KeyName? value) {
                          setState(() {
                            selectedLedger = value;
                          });
                        },
                        popupProps: PopupPropsMultiSelection.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: 'Search ledger',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.primaryColor),
                              ),
                            ),
                          ),
                        ),
                        dropdownBuilder: (context, selectedItem) => Text(
                          selectedItem == null ? 'Select ledger' : selectedItem.name,
                        ),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Select Ledger',
                            labelStyle: TextStyle(color: Color(0xFF87898A)),
                            floatingLabelStyle: TextStyle(color: AppColors.primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.secondaryColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.primaryColor),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Salesperson Section
                _buildExpansionTile(
                  title: 'Select Salesperson',
                  initiallyExpanded: isSalespersonExpanded,
                  onExpansionChanged: (expanded) => setState(() => isSalespersonExpanded = expanded),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: DropdownSearch<KeyName>(
                        items: salespersonList,
                        selectedItem: selectedSalesperson,
                        itemAsString: (KeyName? u) => u?.name ?? '',
                        onChanged: (KeyName? value) {
                          setState(() {
                            selectedSalesperson = value;
                          });
                        },
                        popupProps: PopupPropsMultiSelection.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: 'Search salesperson',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.primaryColor),
                              ),
                            ),
                          ),
                        ),
                        dropdownBuilder: (context, selectedItem) => Text(
                          selectedItem == null ? 'Select salesperson' : selectedItem.name,
                        ),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Select Salesperson',
                            labelStyle: TextStyle(color: Color(0xFF87898A)),
                            floatingLabelStyle: TextStyle(color: AppColors.primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.secondaryColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.primaryColor),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Apply Filters Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Map<String, dynamic> selectedFilters = {
                    'ledger': selectedLedger,
                    'salesperson': selectedSalesperson,
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
// Custom ExpansionTile (same as the reference code)
class CustomExpansionTile extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  const CustomExpansionTile({
    required this.title,
    required this.children,
    this.initiallyExpanded = true,
    this.onExpansionChanged,
  });

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        initiallyExpanded: widget.initiallyExpanded,
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
          widget.onExpansionChanged?.call(expanded);
        },
        tilePadding: EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: Colors.grey.withOpacity(0.1),
        collapsedBackgroundColor: Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        trailing: RotationTransition(
          turns: AlwaysStoppedAnimation(_isExpanded ? 0.5 : 0),
          child: Icon(
            Icons.keyboard_arrow_down,
            size: 24,
            color: AppColors.primaryColor,
          ),
        ),
        children: widget.children,
      ),
    );
  }
}