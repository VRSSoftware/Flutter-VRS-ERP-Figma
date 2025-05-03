import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:vrs_erp_figma/viewOrder/add_more_info.dart';
import 'package:vrs_erp_figma/viewOrder/customer_master.dart';

class ViewOrderScreen extends StatefulWidget {
  @override
  _ViewOrderScreenState createState() => _ViewOrderScreenState();
}

class _ViewOrderScreenState extends State<ViewOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _showForm = false;
  final _orderControllers = _OrderControllers();
  final _dropdownData = _DropdownData();
  final _styleManager = _StyleManager();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setInitialDates();
    _styleManager.updateTotalsCallback = _updateTotals;
  }

  void _setInitialDates() {
    final today = DateTime.now();
    _orderControllers.date.text = _OrderControllers.formatDate(today);
    _orderControllers.deliveryDate.text = _OrderControllers.formatDate(today);
    _orderControllers.deliveryDays.text = '0';
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _styleManager.fetchOrderItems(),
      _dropdownData.loadAllDropdownData(),
    ]);
    _updateTotals();
    setState(() {});
  }

  void _updateTotals() {
    int totalQty = 0;
    _styleManager.controllers.forEach((style, shades) {
      shades.forEach((shade, sizes) {
        sizes.forEach((size, controller) {
          totalQty += int.tryParse(controller.text) ?? 0;
        });
      });
    });
    
    _orderControllers.totalQty.text = totalQty.toString();
    _orderControllers.totalItem.text = _styleManager.groupedItems.length.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildMainContent(),
          _NavigationControls(
            showForm: _showForm,
            onBack: () => setState(() => _showForm = false),
            onNext: () => setState(() => _showForm = true),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('View Order', style: TextStyle(color: Colors.white)),
      backgroundColor: AppColors.primaryColor,
      elevation: 1,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: _showForm 
                ? _OrderForm(
                    controllers: _orderControllers,
                    dropdownData: _dropdownData,
                    constraints: constraints,
                    onPartySelected: _handlePartySelection,
                    updateTotals: _updateTotals,
                  )
                : _StyleCardsView(
                    styleManager: _styleManager,
                    updateTotals: _updateTotals,
                  ),
          ),
        );
      },
    );
  }

  void _handlePartySelection(String? val, String? key) async {
    if (key == null) return;
    
    try {
      final details = await _dropdownData.fetchLedgerDetails(key);
      _dropdownData.updateDependentFields(
        details,
        _orderControllers.selectedBrokerKey,
        _orderControllers.selectedTransporterKey,
      );

      final commission = await _dropdownData.fetchCommissionPercentage(key);
      setState(() {
        _orderControllers.updateFromPartyDetails(
          details,
          _dropdownData.brokerList,
          _dropdownData.transporterList,
        );
        _orderControllers.comm.text = commission;
      });
    } catch (e) {
      print('Error fetching party details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load party details')));
    }
  }
}

class _OrderControllers {

    String? pytTermDiscKey;
  String? salesPersonKey;
  int? creditPeriod;
  String? salesLedKey;
  String? ledgerName;

  final orderNo = TextEditingController();
  final date = TextEditingController();
  final comm = TextEditingController();
  final deliveryDays = TextEditingController();
  final deliveryDate = TextEditingController();
  final remark = TextEditingController();
  final totalItem = TextEditingController(text: '0');
  final totalQty = TextEditingController(text: '0');

  String? selectedParty;
  String? selectedPartyKey;
  String? selectedTransporter;
  String? selectedTransporterKey;
  String? selectedBroker;
  String? selectedBrokerKey;

  static String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }


  void updateFromPartyDetails(
    Map<String, dynamic> details,
    List<Map<String, String>> brokers,
    List<Map<String, String>> transporters,
  ) {
    // Update basic fields
    pytTermDiscKey = details['pytTermDiscKey']?.toString();
    salesPersonKey = details['salesPersonKey']?.toString();
    creditPeriod = details['creditPeriod'] as int?;
    salesLedKey = details['salesLedKey']?.toString();
    ledgerName = details['ledgerName']?.toString();


    // Update broker information
    final partyBrokerKey = details['brokerKey']?.toString() ?? '';
    if (partyBrokerKey.isNotEmpty) {
      final broker = brokers.firstWhere(
        (e) => e['ledKey'] == partyBrokerKey,
        orElse: () => {'ledName': ''},
      );
      selectedBroker = broker['ledName'];
      selectedBrokerKey = partyBrokerKey;
    }

    // Update transporter information
    final partyTrspKey = details['trspKey']?.toString() ?? '';
    if (partyTrspKey.isNotEmpty) {
      final transporter = transporters.firstWhere(
        (e) => e['ledKey'] == partyTrspKey,
        orElse: () => {'ledName': ''},
      );
      selectedTransporter = transporter['ledName'];
      selectedTransporterKey = partyTrspKey;
    }
  }
}


class _DropdownData {
  List<Map<String, String>> partyList = [];
  List<Map<String, String>> brokerList = [];
  List<Map<String, String>> transporterList = [];

  Future<void> loadAllDropdownData() async {
    try {
      final results = await Future.wait([
        _fetchLedgers("w"),
        _fetchLedgers("B"),
        _fetchLedgers("T"),
      ]);
      partyList = results[0];
      brokerList = results[1];
      transporterList = results[2];
    } catch (e) {
      print('Error loading dropdown data: $e');
    }
  }

  Future<Map<String, dynamic>> fetchLedgerDetails(String ledKey) async {
    final response = await http.post(
      Uri.parse('${AppConstants.BASE_URL}/users/getLedgerDetails'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"ledKey": ledKey}),
    );
    print("ssssssssssssssssssresponse data:${response.body}");
    return response.statusCode == 200 
        ? jsonDecode(response.body)
        : throw Exception('Failed to load details');
  }

  void updateDependentFields(
    Map<String, dynamic> details,
    String? currentBrokerKey,
    String? currentTransporterKey,
  ) {}

  Future<List<Map<String, String>>> _fetchLedgers(String ledCat) async {
    final response = await http.post(
      Uri.parse('${AppConstants.BASE_URL}/users/getLedger'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"ledCat": ledCat, "coBrId": "01"}),
    );
     print("lllllllllllllllllresponse data:${response.body}");
    return response.statusCode == 200
        ? (jsonDecode(response.body) as List).map((e) => {
            'ledKey': e['ledKey'].toString(),
            'ledName': e['ledName'].toString(),
          }).toList()
        : throw Exception("Failed to load ledgers");
  }

  Future<String> fetchCommissionPercentage(String ledKey) async {
    final response = await http.post(
      Uri.parse('${AppConstants.BASE_URL}/users/getCommPerc'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"ledKey": ledKey}),
    );
    return response.statusCode == 200 ? response.body : '0';
  }
}

class _StyleManager {
   List<dynamic> _orderItems = []; 
  final Set<String> removedStyles = {};
  final Map<String, Map<String, Map<String, TextEditingController>>> controllers = {};
  VoidCallback? updateTotalsCallback;

  Map<String, List<dynamic>> get groupedItems {
    final map = <String, List<dynamic>>{};
    for (final item in _orderItems) {
      final styleCode = item['styleCode']?.toString() ?? 'No Style Code';
      if (removedStyles.contains(styleCode)) continue;
      map.putIfAbsent(styleCode, () => []).add(item);
    }
    return map;
  }

   Future<void> fetchOrderItems() async {
    final response = await http.post(
      Uri.parse('${AppConstants.BASE_URL}/orderBooking/GetViewOrder'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "coBrId": "01",
        "userId": "Admin",
        "fcYrId": "24",
        "barcode": "false",
      }),
    );

    if (response.statusCode == 200) {
      _orderItems = json.decode(response.body); // Direct assignment to List
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    controllers.clear();
    for (final entry in groupedItems.entries) {
      final items = entry.value;
      final sizes = _getSortedUniqueValues(items, 'sizeName');
      final shades = _getSortedUniqueValues(items, 'shadeName');

      controllers[entry.key] = {};
      for (final shade in shades) {
        controllers[entry.key]![shade] = {};
        for (final size in sizes) {
          final item = items.firstWhere(
            (i) => (i['shadeName']?.toString() ?? '') == shade 
                 && (i['sizeName']?.toString() ?? '') == size,
            orElse: () => {'clqty': 0},
          );
          final controller = TextEditingController(text: item['clqty']?.toString() ?? '0')
            ..addListener(() => updateTotalsCallback?.call());
          controllers[entry.key]![shade]![size] = controller;
        }
      }
    }
  }

  List<String> _getSortedUniqueValues(List<dynamic> items, String field) => 
      items.map((e) => e[field]?.toString() ?? '').toSet().toList()..sort();
}

class _NavigationControls extends StatelessWidget {
  final bool showForm;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _NavigationControls({
    required this.showForm,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 80,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showForm)
            _buildNavigationButton(
              label: 'Back',
              icon: Icons.arrow_back_ios,
              onPressed: onBack,
            ),
          if (!showForm)
            _buildNavigationButton(
              label: 'Next',
              icon: Icons.arrow_forward_ios,
              onPressed: onNext,
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.paleYellow,
        foregroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _StyleCardsView extends StatelessWidget {
  final _StyleManager styleManager;
  final VoidCallback updateTotals;

  const _StyleCardsView({
    required this.styleManager,
    required this.updateTotals,
  });

  @override
  Widget build(BuildContext context) {
    return styleManager.groupedItems.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: styleManager.groupedItems.entries
                .map((entry) => _StyleCard(
                      styleCode: entry.key,
                      items: entry.value,
                      controllers: styleManager.controllers[entry.key]!,
                      onRemove: () {
                        styleManager.removedStyles.add(entry.key);
                        updateTotals();
                      },
                      updateTotals: updateTotals,
                    ))
                .toList(),
          );
  }
}

class _StyleCard extends StatelessWidget {
  final String styleCode;
  final List<dynamic> items;
  final Map<String, Map<String, TextEditingController>> controllers;
  final VoidCallback onRemove;
  final VoidCallback updateTotals;

  const _StyleCard({
    required this.styleCode,
    required this.items,
    required this.controllers,
    required this.onRemove,
    required this.updateTotals,
  });

  @override
  Widget build(BuildContext context) {
    final firstItem = items.first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderSection(firstItem),
            const SizedBox(height: 16),
            _buildPriceTable(context),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> firstItem) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (firstItem['fullImagePath'] != null)
          _buildItemImage(firstItem['fullImagePath']),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                styleCode,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              if (firstItem['itemSubGrpName'] != null)
                _buildDetailRow('Category:', firstItem['itemSubGrpName']),
              if (firstItem['itemName'] != null)
                _buildDetailRow('Product:', firstItem['itemName']),
              if (firstItem['brandName'] != null)
                _buildDetailRow('Brand:', firstItem['brandName']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemImage(String imagePath) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.network(
        _getImageUrl(imagePath),
        fit: BoxFit.fitWidth,
        loadingBuilder: (context, child, loadingProgress) =>
            loadingProgress == null ? child : const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error, stackTrace) => const _ImageErrorWidget(),
      ),
    );
  }

  String _getImageUrl(String fullImagePath) => 
      fullImagePath.startsWith('http') 
          ? fullImagePath 
          : '${AppConstants.BASE_URL}/images/${fullImagePath.split('/').last.split('?').first}';

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTable(BuildContext context) {
    final sizeDetails = _getSizeDetails(items);
    final sortedSizes = sizeDetails.keys.toList()..sort();
    final sortedShades = _getSortedShades(items);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 64,
        ),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
          columnWidths: _buildColumnWidths(sortedSizes),
          children: [
            _buildTableRow('MRP', sortedSizes, sizeDetails, 'mrp'),
            _buildTableRow('WSP', sortedSizes, sizeDetails, 'wsp'),
            _buildHeaderRow(sortedSizes),
            ...sortedShades.map((shade) => _buildShadeRow(shade, sortedSizes)),
          ],
        ),
      ),
    );
  }

  Map<String, Map<String, num>> _getSizeDetails(List<dynamic> items) {
    final details = <String, Map<String, num>>{};
    for (final item in items) {
      final size = item['sizeName']?.toString() ?? 'N/A';
      details[size] = {
        'mrp': (item['mrp'] as num?) ?? 0,
        'wsp': (item['wsp'] as num?) ?? 0,
      };
    }
    return details;
  }

  List<String> _getSortedShades(List<dynamic> items) => 
      items.map((e) => e['shadeName']?.toString() ?? '').toSet().toList()..sort();

  Map<int, TableColumnWidth> _buildColumnWidths(List<String> sizes) => {
        0: const FixedColumnWidth(100),
        for (var i = 0; i < sizes.length; i++) i + 1: const FixedColumnWidth(80),
      };

  TableRow _buildTableRow(
    String label,
    List<String> sizes,
    Map<String, Map<String, num>> details,
    String key,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(label),
        ),
        ...sizes.map((size) => Center(
              child: Text(
                '${details[size]![key]?.toStringAsFixed(0) ?? '0'}',
              ),
            )),
      ],
    );
  }

  TableRow _buildHeaderRow(List<String> sizes) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade100),
      children: [
        const TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: _TableHeaderCell(),
        ),
        ...sizes.map((size) => Center(child: Text(size))),
      ],
    );
  }

  TableRow _buildShadeRow(String shade, List<String> sizes) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Text(shade),
            ],
          ),
        ),
        ...sizes.map((size) => Padding(
              padding: const EdgeInsets.all(4),
              child: TextField(
                controller: controllers[shade]?[size],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (_) => updateTotals(),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          _buildActionButton(
            label: 'Update',
            icon: Icons.update,
            color: AppColors.primaryColor,
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            label: 'Remove',
            icon: Icons.delete,
            color: Colors.grey,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 20, color: color),
        label: Text(label, style: TextStyle(color: color)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _OrderForm extends StatelessWidget {
  final _OrderControllers controllers;
  final _DropdownData dropdownData;
  final BoxConstraints constraints;
  final Function(String?, String?) onPartySelected;
  final VoidCallback updateTotals;

  const _OrderForm({
    required this.controllers,
    required this.dropdownData,
    required this.constraints,
    required this.onPartySelected,
    required this.updateTotals,
  });

@override
Widget build(BuildContext context) {
  final isWideScreen = constraints.maxWidth > 600;
  return Column(
    children: [
      _buildResponsiveRow(
        isWideScreen,
        buildTextField(context, "Order No", controllers.orderNo),
        buildTextField(
          context,
          "Select Date",
          controllers.date,
          isDate: true,
          onTap: () => _selectDate(context, controllers.date),
        ),
      ),
      _buildPartyDropdownRow(context),
      _buildDropdown("Broker", "B", controllers.selectedBroker, 
          (val, key) => controllers.selectedBrokerKey = key),
      buildTextField(context, "Comm (%)", controllers.comm),
      _buildDropdown("Transporter", "T", controllers.selectedTransporter,
          (val, key) => controllers.selectedTransporterKey = key),
      _buildResponsiveRow(
        isWideScreen,
        buildTextField(
          context,
          "Delivery Days",
          controllers.deliveryDays,
          readOnly: true,
        ),
        buildTextField(
          context,
          "Delivery Date",
          controllers.deliveryDate,
          isDate: true,
          onTap: () async {
            final today = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: today,
              firstDate: today,
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              final difference = picked.difference(today).inDays;
              controllers.deliveryDate.text = _OrderControllers.formatDate(picked);
              controllers.deliveryDays.text = difference.toString();
            }
          },
        ),
      ),
      buildFullField(context, "Remark", controllers.remark),
      _buildResponsiveRow(
        isWideScreen,
        buildTextField(context, "Total Item", controllers.totalItem, readOnly: true),
        buildTextField(context, "Total Quantity", controllers.totalQty, readOnly: true),
      ),
      const SizedBox(height: 20),
      _buildActionButtons(context),
    ],
  );
}


  Widget _buildPartyDropdownRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            "Party Name",
            "w",
            controllers.selectedParty,
            onPartySelected,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => CustomerMasterDialog(),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
          child: const Text('+ Add'),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String ledCat,
    String? selectedValue,
    Function(String?, String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownSearch<String>(
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: _getSearchHint(label),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
        items: _getLedgerList(ledCat).map((e) => e['ledName']!).toList(),
        selectedItem: selectedValue,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        dropdownBuilder: (context, selectedItem) {
          return Text(
            selectedItem ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          );
        },
        onChanged: (val) => onChanged(val, _getKeyFromValue(ledCat, val)),
      ),
    );
  }

  List<Map<String, String>> _getLedgerList(String ledCat) {
    switch (ledCat) {
      case 'w': return dropdownData.partyList;
      case 'B': return dropdownData.brokerList;
      case 'T': return dropdownData.transporterList;
      default: return [];
    }
  }

  String? _getKeyFromValue(String ledCat, String? value) =>
      _getLedgerList(ledCat).firstWhere(
        (e) => e['ledName'] == value,
        orElse: () => {'ledKey': ''},
      )['ledKey'];

  String _getSearchHint(String label) {
    switch (label.toLowerCase()) {
      case 'party name': return 'Search party...';
      case 'broker': return 'Search broker...';
      case 'transporter': return 'Search transporter...';
      default: return 'Search...';
    }
  }

  Widget _buildResponsiveRow(bool isWideScreen, Widget first, Widget second) {
    return isWideScreen
        ? Row(children: [Expanded(child: first), const SizedBox(width: 10), Expanded(child: second)])
        : Column(children: [first, second]);
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
Expanded(
  child: ElevatedButton(
    onPressed: () => showDialog(
      context: context,
      builder: (context) => AddMoreInfoDialog(
        pytTermDiscKey: controllers.pytTermDiscKey, // Changed to use local controllers
        salesPersonKey: controllers.salesPersonKey,
        creditPeriod: controllers.creditPeriod,
        salesLedKey: controllers.salesLedKey,
        ledgerName: controllers.ledgerName,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor,
    ),
    child: const Text(
      'Add More Info',
      style: TextStyle(color: Colors.white),
    ),
  ),
),

        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {/* Save logic */},
            child: const Text(
      'Save',
      style: TextStyle(color: AppColors.primaryColor),
    ),
          ),
        ),
      ],
    );
  }
}

Widget buildTextField(
  BuildContext context,  // Add context parameter
  String label,
  TextEditingController controller, {
  bool isDate = false,
  bool readOnly = false,
  VoidCallback? onTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      readOnly: readOnly || isDate,
      keyboardType: TextInputType.numberWithOptions(
        signed: false,
        decimal: true,
      ),
      onTap: onTap ?? (isDate ? () => _selectDate(context, controller) : null),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (picked != null) {
    controller.text = _OrderControllers.formatDate(picked);
  }
}

Widget buildFullField(BuildContext context, String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: buildTextField(context, label, controller),
  );
}

class _ImageErrorWidget extends StatelessWidget {
  const _ImageErrorWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 40),
          SizedBox(height: 8),
          Text('Image not available', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  const _TableHeaderCell();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      child: CustomPaint(
        painter: _DiagonalLinePainter(),
        child: const Stack(
          children: [
            Positioned(
              left: 12,
              top: 20,
              child: Text('Shade', style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              )),
            ),
            Positioned(
              right: 14,
              bottom: 20,
              child: Text('Size', style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1
      ..style; PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}