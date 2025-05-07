import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:vrs_erp_figma/services/app_services.dart';
import 'package:vrs_erp_figma/viewOrder/add_more_info.dart';
import 'package:vrs_erp_figma/viewOrder/customer_master.dart';
import 'package:vrs_erp_figma/viewOrder/style_card.dart';
import 'package:vrs_erp_figma/models/consignee.dart';
import 'package:vrs_erp_figma/models/PytTermDisc.dart';

class ViewOrderScreen extends StatefulWidget {
  @override
  _ViewOrderScreenState createState() => _ViewOrderScreenState();
}

class _ViewOrderScreenState extends State<ViewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _additionalInfo = {};
  bool _showForm = false;
  final _orderControllers = _OrderControllers();
  final _dropdownData = _DropdownData();
  final _styleManager = _StyleManager();
  List<Consignee> consignees = [];
  List<PytTermDisc> paymentTerms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setInitialDates();
    fetchAndPrintSalesOrderNumber();
    _styleManager.updateTotalsCallback = _updateTotals;
  }

  Future<void> fetchPaymentTerms() async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.BASE_URL}/users/getPytTermDisc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"coBrId": "01"}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          paymentTerms = data
              .map(
                (e) => PytTermDisc(
                  key: e['pytTermDiscKey']?.toString() ?? '',
                  name: e['pytTermDiscName']?.toString() ?? '',
                ),
              )
              .toList();
        });
      } else {
        print('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching payment terms: $e');
    }
  }

  Future<void> fetchAndMapConsignees({
    required String key,
    required String CoBrId,
  }) async {
    try {
      Map<String, dynamic> responseMap = await ApiService.fetchConsinees(
        key: key,
        CoBrId: CoBrId,
      );

      if (responseMap['statusCode'] == 200) {
        if (responseMap['result'] is List) {
          setState(() {
            consignees = responseMap['result'];
          });
        } else {
          // consignees = []; // Set to empty if response is not a valid list
        }
      } else {
        print('API Error: ${responseMap['statusCode']}');
      }
    } catch (e) {
      print('Error fetching consignees: $e');
    }
  }

  Future<void> fetchAndPrintSalesOrderNumber() async {
    Map<String, dynamic> salesOrderData = await ApiService.fetchSalesOrderNo(
      coBrId: "01",
      userId: "Admin",
      fcYrId: 24,
      barcode: "false",
    );

    if (salesOrderData.isNotEmpty &&
        salesOrderData.containsKey('salesOrderNo')) {
      String salesOrderNo = salesOrderData['salesOrderNo'];
      _orderControllers.orderNo.text = salesOrderNo;
      print('Sales Order Number: $salesOrderNo');
    } else {
      print('Sales Order Number not found');
    }
  }

  Future<String> insertFinalSalesOrder(String orderDataJson) async {
    final String baseUrl = AppConstants.BASE_URL;

    final Map<String, dynamic> body = {
      'userId': 'Admin',
      'coBrId': '01',
      'fcYrId': 24,
      'data2': orderDataJson.toString(),
      // 'barcodewise': false,
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.BASE_URL}/orderBooking/InsertFinalsalesorder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Success: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order saved successfully')));
        return response.statusCode.toString();
      } else {
        print('Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save order: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving order: $e')));
    }
    return "fail";
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
      fetchPaymentTerms(),
    ]);
    _updateTotals();
    setState(() {
      isLoading = false;
    });
  }

  String formatDate(String date, bool time) {
    try {
      DateTime parsedDate = DateFormat("yyyy-MM-dd").parse(date);
      String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
      if (time) {
        String currentTime = DateFormat("HH:mm:ss").format(DateTime.now());
        return "$formattedDate $currentTime";
      } else {
        return formattedDate;
      }
    } catch (e) {
      print("Error: $e");
      return "Invalid date format";
    }
  }

  String getDateAfterDays(int days) {
    DateTime today = DateTime.now();
    DateTime futureDate = today.add(Duration(days: days));
    String formattedDate = DateFormat("yyyy-MM-dd").format(futureDate);
    return formattedDate;
  }

  Future<void> _saveOrderLocally() async {
    if (!_formKey.currentState!.validate()) return;

    final orderData = {
      "saleorderno": _orderControllers.orderNo.text,
      "orderdate": formatDate(_orderControllers.date.text, true),
      "customer": _orderControllers.selectedPartyKey ?? '',
      "broker": _orderControllers.selectedBrokerKey ?? '',
      "comission": _orderControllers.comm.text,
      "transporter": _orderControllers.selectedTransporterKey ?? '',
      "delivaryday": _orderControllers.deliveryDays.text,
      "delivarydate": formatDate(_orderControllers.deliveryDate.text, false),
      "totitem": _orderControllers.totalItem.text,
      "totqty": _orderControllers.totalQty.text,
      "remark": _orderControllers.remark.text,
      "consignee": _additionalInfo['consignee'] ?? '',
      "station": _additionalInfo['station'] ?? '',
      "paymentterms":
          _additionalInfo['paymentterms'] ??
              _orderControllers.pytTermDiscKey ??
              '',
      "paymentdays":
          _additionalInfo['paymentdays'] ??
              _orderControllers.creditPeriod?.toString() ??
              '0',
      "duedate": formatDate(_additionalInfo['duedate'], false),
      "refno": _additionalInfo['refno'] ?? '',
      "date": '',
      "bookingtype": _additionalInfo['bookingtype'] ?? '',
      "salesman":
          _additionalInfo['salesman'] ?? _orderControllers.salesLedKey ?? '',
    };

    final orderDataJson = jsonEncode(orderData);
    print("Saved Order Data:");
    print(orderDataJson);

    String StatusCode = await insertFinalSalesOrder(orderDataJson);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Saved Order Data'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(orderDataJson),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
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
    _orderControllers.totalItem.text =
        _styleManager.groupedItems.length.toString();
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
                    saveOrder: _saveOrderLocally,
                    additionalInfo: _additionalInfo,
                    consignees: consignees,
                    paymentTerms: paymentTerms,
                    onAdditionalInfoUpdated: (newInfo) {
                      setState(() {
                        _additionalInfo = newInfo;
                      });
                    },
                  )
                : _StyleCardsView(
                    styleManager: _styleManager,
                    updateTotals: _updateTotals,
                    getColor: _getColorCode,
                  ),
          ),
        );
      },
    );
  }

  void _handlePartySelection(String? val, String? key) async {
    if (key == null) return;
    _orderControllers.selectedPartyKey = key;
    try {
      await fetchAndMapConsignees(key: key, CoBrId: '01');

      final details = await _dropdownData.fetchLedgerDetails(key);
      _dropdownData.updateDependentFields(
        details,
        _orderControllers.selectedBrokerKey,
        _orderControllers.selectedTransporterKey,
      );
      _orderControllers.pytTermDiscKey = details['pytTermDiscKey'];
      _orderControllers.salesPersonKey = details['salesPersonKey'];
      _orderControllers.creditPeriod = details['creditPeriod'];
      _orderControllers.selectedTransporterKey = details['trspKey'];

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

  Color _getColorCode(String color) {
    switch (color.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow[800]!;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.grey;
      default:
        return Colors.black;
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
    pytTermDiscKey = details['pytTermDiscKey']?.toString();
    salesPersonKey = details['salesPersonKey']?.toString();
    creditPeriod = details['creditPeriod'] as int?;
    salesLedKey = details['salesLedKey']?.toString();
    ledgerName = details['ledgerName']?.toString();

    final partyBrokerKey = details['brokerKey']?.toString() ?? '';
    if (partyBrokerKey.isNotEmpty) {
      final broker = brokers.firstWhere(
        (e) => e['ledKey'] == partyBrokerKey,
        orElse: () => {'ledName': ''},
      );
      selectedBroker = broker['ledName'];
      selectedBrokerKey = partyBrokerKey;
    }

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
  List<Map<String, String>> salesPersonList = [];

  Future<void> loadAllDropdownData() async {
    try {
      final results = await Future.wait([
        _fetchLedgers("w"),
        _fetchLedgers("B"),
        _fetchLedgers("T"),
        _fetchLedgers("S"),
      ]);
      partyList = results[0];
      brokerList = results[1];
      transporterList = results[2];
      salesPersonList = results[3];
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
    return response.statusCode == 200
        ? (jsonDecode(response.body) as List)
            .map(
              (e) => {
                'ledKey': e['ledKey'].toString(),
                'ledName': e['ledName'].toString(),
              },
            )
            .toList()
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
  final Map<String, Map<String, Map<String, TextEditingController>>> controllers =
      {};
  VoidCallback? updateTotalsCallback;
  bool isOrderItemsLoaded = false; // Flag to track API completion

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
      _orderItems = json.decode(response.body);
      _initializeControllers();
    }
    isOrderItemsLoaded = true; // Set flag after API call
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
            (i) =>
                (i['shadeName']?.toString() ?? '') == shade &&
                (i['sizeName']?.toString() ?? '') == size,
            orElse: () => {'clqty': 0},
          );
          final controller = TextEditingController(
            text: item['clqty']?.toString() ?? '0',
          )..addListener(() => updateTotalsCallback?.call());
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _StyleCardsView extends StatelessWidget {
  final _StyleManager styleManager;
  final VoidCallback updateTotals;
  final Color Function(String) getColor;

  const _StyleCardsView({
    required this.styleManager,
    required this.updateTotals,
    required this.getColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!styleManager.isOrderItemsLoaded) {
      return const Center(child: CircularProgressIndicator());
    } else if (styleManager.groupedItems.isEmpty) {
      return const Center(
        child: Text(
          'No item added',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    } else {
      return Column(
        children: styleManager.groupedItems.entries
            .map(
              (entry) => StyleCard(
                styleCode: entry.key,
                items: entry.value,
                controllers: styleManager.controllers[entry.key]!,
                onRemove: () {
                  styleManager.removedStyles.add(entry.key);
                  updateTotals();
                },
                updateTotals: updateTotals,
                getColor: getColor,
              ),
            )
            .toList(),
      );
    }
  }
}

class _OrderForm extends StatelessWidget {
  final _OrderControllers controllers;
  final _DropdownData dropdownData;
  final BoxConstraints constraints;
  final Function(String?, String?) onPartySelected;
  final VoidCallback updateTotals;
  final Future<void> Function() saveOrder;
  final Map<String, dynamic> additionalInfo;
  final List<Consignee> consignees;
  final List<PytTermDisc> paymentTerms;
  final Function(Map<String, dynamic>) onAdditionalInfoUpdated;

  const _OrderForm({
    required this.controllers,
    required this.dropdownData,
    required this.constraints,
    required this.onPartySelected,
    required this.updateTotals,
    required this.saveOrder,
    required this.additionalInfo,
    required this.consignees,
    required this.paymentTerms,
    required this.onAdditionalInfoUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final isWideScreen = constraints.maxWidth > 600;
    return Column(
      children: [
        _buildResponsiveRow(
          isWideScreen,
          buildTextField(
            context,
            "Order No",
            controllers.orderNo,
            isText: true,
          ),
          buildTextField(
            context,
            "Select Date",
            controllers.date,
            isDate: true,
            onTap: () => _selectDate(context, controllers.date),
          ),
        ),
        _buildPartyDropdownRow(context),
        _buildDropdown(
          "Broker",
          "B",
          controllers.selectedBroker,
          (val, key) => controllers.selectedBrokerKey = key,
        ),
        buildTextField(context, "Comm (%)", controllers.comm),
        _buildDropdown(
          "Transporter",
          "T",
          controllers.selectedTransporter,
          (val, key) => controllers.selectedTransporterKey = key,
        ),
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
                controllers.deliveryDate.text =
                    _OrderControllers.formatDate(picked);
                controllers.deliveryDays.text = difference.toString();
              }
            },
          ),
        ),
        buildFullField(context, "Remark", controllers.remark),
        _buildResponsiveRow(
          isWideScreen,
          buildTextField(
            context,
            "Total Item",
            controllers.totalItem,
            readOnly: true,
          ),
          buildTextField(
            context,
            "Total Quantity",
            controllers.totalQty,
            readOnly: true,
          ),
        ),
        if (additionalInfo.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Additional Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (additionalInfo['refno'] != null)
                    _buildInfoRow('Reference No:', additionalInfo['refno']),
                  if (additionalInfo['duedate'] != null)
                    _buildInfoRow('Due Date:', additionalInfo['duedate']),
                  if (additionalInfo['paymentterms'] != null)
                    _buildInfoRow(
                      'Payment Terms:',
                      additionalInfo['paymentterms'],
                    ),
                  if (additionalInfo['salesman'] != null)
                    _buildInfoRow('Sales Person:', additionalInfo['salesman']),
                  if (additionalInfo['paymentdays'] != null)
                    _buildInfoRow(
                      'Credit Period:',
                      '${additionalInfo['paymentdays']} days',
                    ),
                  if (additionalInfo['bookingtype'] != null)
                    _buildInfoRow(
                      'Booking Type:',
                      additionalInfo['bookingtype'],
                    ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
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
          child: const Text('+'),
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
      case 'w':
        return dropdownData.partyList;
      case 'B':
        return dropdownData.brokerList;
      case 'T':
        return dropdownData.transporterList;
      default:
        return [];
    }
  }

  String? _getKeyFromValue(String ledCat, String? value) =>
      _getLedgerList(ledCat).firstWhere(
        (e) => e['ledName'] == value,
        orElse: () => {'ledKey': ''},
      )['ledKey'];

  String _getSearchHint(String label) {
    switch (label.toLowerCase()) {
      case 'party name':
        return 'Search party...';
      case 'broker':
        return 'Search broker...';
      case 'transporter':
        return 'Search transporter...';
      default:
        return 'Search...';
    }
  }

  Widget _buildResponsiveRow(bool isWideScreen, Widget first, Widget second) {
    return isWideScreen
        ? Row(
            children: [
              Expanded(child: first),
              const SizedBox(width: 10),
              Expanded(child: second),
            ],
          )
        : Column(children: [first, second]);
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final salesPersonList = dropdownData.salesPersonList;
              final partyLedKey = controllers.selectedPartyKey;
              final result = await showDialog(
                context: context,
                builder: (context) => AddMoreInfoDialog(
                  salesPersonList: salesPersonList,
                  partyLedKey: partyLedKey,
                  pytTermDiscKey: controllers.pytTermDiscKey,
                  salesPersonKey: controllers.salesPersonKey,
                  creditPeriod: controllers.creditPeriod,
                  salesLedKey: controllers.salesLedKey,
                  ledgerName: controllers.ledgerName,
                  additionalInfo: additionalInfo,
                  consignees: consignees,
                  paymentTerms: paymentTerms,
                  onValueChanged: (newInfo) {
                    onAdditionalInfoUpdated(newInfo);
                  },
                ),
              );
              if (result != null) {
                onAdditionalInfoUpdated(result);
              }
            },
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
            onPressed: saveOrder,
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
  BuildContext context,
  String label,
  TextEditingController controller, {
  bool isDate = false,
  bool readOnly = false,
  VoidCallback? onTap,
  bool? isText = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      readOnly: readOnly || isDate,
      keyboardType: isText == true
          ? TextInputType.text
          : TextInputType.numberWithOptions(signed: false, decimal: true),
      onTap: onTap ?? (isDate ? () => _selectDate(context, controller) : null),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

Future<void> _selectDate(
  BuildContext context,
  TextEditingController controller,
) async {
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

Widget buildFullField(
  BuildContext context,
  String label,
  TextEditingController controller,
) {
  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: buildTextField(context, label, controller),
  );
}