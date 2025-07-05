import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:vrs_erp_figma/screens/home_screen.dart';
import 'package:vrs_erp_figma/services/app_services.dart';
import 'package:vrs_erp_figma/viewOrder/Pdf_viewer_screen.dart';
import 'package:vrs_erp_figma/viewOrder/add_more_info.dart';
import 'package:vrs_erp_figma/viewOrder/customer_master.dart';
import 'package:vrs_erp_figma/viewOrder/style_card.dart';
import 'package:vrs_erp_figma/models/consignee.dart';
import 'package:vrs_erp_figma/models/PytTermDisc.dart';
import 'package:vrs_erp_figma/models/item.dart';

enum ActiveTab { transaction, customerDetails }

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
  List<Item> _bookingTypes = [];
  bool isLoading = true;
  bool barcodeMode = false;
  ActiveTab _activeTab = ActiveTab.transaction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('barcode')) {
        barcodeMode = args['barcode'] as bool;
      }
      _initializeData();
      _setInitialDates();
      fetchAndPrintSalesOrderNumber();
      _styleManager.updateTotalsCallback = _updateTotals;
      _loadBookingTypes();
    });
  }

  Future<void> _loadBookingTypes() async {
    try {
      final rawData = await ApiService.fetchBookingTypes(coBrId: UserSession.coBrId ?? '');
      setState(() {
        _bookingTypes = (rawData as List)
            .map(
              (json) => Item(
                itemKey: json['key'],
                itemName: json['name'],
                itemSubGrpKey: '',
              ),
            )
            .toList();
      });
    } catch (e) {
      print('Failed to load booking types: $e');
    }
  }

  Future<void> fetchPaymentTerms() async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.BASE_URL}/users/getPytTermDisc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"coBrId": UserSession.coBrId ?? ''}),
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
        }
      } else {
        print('API Error: ${responseMap['statusCode']}');
      }
    } catch (e) {
      print('Error fetching consignees: $e');
    }
  }

  Future<void> fetchAndPrintSalesOrderNumber() async {
    Map<String, dynamic> salesOrderData = await ApiService.getSalesOrderData(
      coBrId: UserSession.coBrId ?? '',
      userId: UserSession.userName ?? '',
      fcYrId: UserSession.userFcYr ?? '',
      barcode: "false",
    );

    if (salesOrderData.isNotEmpty && salesOrderData.containsKey('salesOrderNo')) {
      String salesOrderNo = salesOrderData['salesOrderNo'];
      _orderControllers.orderNo.text = salesOrderNo;
      print('Sales Order Number: $salesOrderNo');
    } else {
      print('Sales Order Number not found');
    }
  }
  

  Future<String> insertFinalSalesOrder(String orderDataJson) async {
    final Map<String, dynamic> body = {
      'userId': UserSession.userName ?? '',
      'coBrId': UserSession.coBrId ?? '',
      'fcYrId': UserSession.userFcYr ?? '',
      'data2': orderDataJson.toString(),
      'barcode': barcodeMode.toString(),
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.BASE_URL}/orderBooking/InsertFinalsalesorder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print("response body:${response.body}");

      if (response.statusCode == 200) {
        print('Success: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order saved successfully')));
            return response.body;
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
      _styleManager.fetchOrderItems(barcode: barcodeMode),
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
      print("Error parsing date: $e");
      return DateFormat("yyyy-MM-dd").format(DateTime.now());
    }
  }

  String calculateFutureDateFromString(String daysString) {
    final int? days = int.tryParse(daysString);
    if (days == null) {
      return "";
    }
    final DateTime futureDate = DateTime.now().add(Duration(days: days));
    return DateFormat('yyyy-MM-dd').format(futureDate);
  }

  String calculateDueDate() {
    final paymentDays = _additionalInfo['paymentdays'];
    if (paymentDays != null &&
        paymentDays is String &&
        int.tryParse(paymentDays) != null) {
      return calculateFutureDateFromString(paymentDays);
    }
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return today;
  }

  Future<void> _saveOrderLocally() async {
    if (!_formKey.currentState!.validate()) return;
    
      String? consigneeLedKey = '';
  String? stationStnKey = '';
  final selectedConsigneeName = _additionalInfo['consignee']?.toString();
  if (selectedConsigneeName != null && selectedConsigneeName.isNotEmpty) {
    final selectedConsignee = consignees.firstWhere(
      (consignee) => consignee.ledName == selectedConsigneeName,
      orElse: () => Consignee(
        ledKey: '',
        ledName: '',
        stnKey: '',
        stnName: '',
        paymentTermsKey: '',
        paymentTermsName: '',
        pytTermDiscdays: '0',
      ),
    );
    consigneeLedKey = selectedConsignee.ledKey;
    stationStnKey = selectedConsignee.stnKey;
  }


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
     "consignee": consigneeLedKey,
    "station": stationStnKey,  
      "paymentterms": _additionalInfo['paymentterms'] ??
          _orderControllers.pytTermDiscKey ??
          '',
      "paymentdays": _additionalInfo['paymentdays'] ??
          _orderControllers.creditPeriod?.toString() ??
          '0',
      "duedate": calculateDueDate(),
      "refno": _additionalInfo['refno'] ?? '',
      "date": '',
      "bookingtype": _additionalInfo['bookingtype'] ?? '',
      "salesman": _additionalInfo['salesman'] ??
          _orderControllers.salesPersonKey ??
          '',
    };
  final orderDataJson = jsonEncode(orderData);
  print("Saved Order Data:");
  print(orderDataJson);

  try {
    final response = await insertFinalSalesOrder(orderDataJson);
    if (response != null && response != "fail") {
      // Format the order number as "SO" + response body
      final formattedOrderNo = "SO$response";
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Order Saved'),
          content: Text('Order $formattedOrderNo saved successfully'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerScreen(
                      orderNo: formattedOrderNo,
                      whatsappNo: _orderControllers.whatsAppMobileNo,
                      partyName: _orderControllers.selectedPartyName ?? '', 
                      orderDate: _orderControllers.date.text,
                    ),
                  ),
                );
              },
              child: Text('View PDF'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text('Done'),
            ),
          ],
        ),
      );
    } else {
      // Handle failure case
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save order. Please try again.')),
      );
    }
  } catch (e) {
    print('Error during order saving: $e');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error saving order: $e')));
  }
}
void _updateTotals() {
  int totalQty = 0;
  double totalAmt = 0.0; // Use double for currency

  _styleManager.controllers.forEach((style, shades) {
    final itemsForStyle = _styleManager.groupedItems[style] ?? [];
    
    shades.forEach((shade, sizes) {
      sizes.forEach((size, controller) {
        final qty = int.tryParse(controller.text) ?? 0;
        totalQty += qty;

        // Find the item to get MRP
        final item = itemsForStyle.firstWhere(
          (item) => 
            (item['shadeName']?.toString() ?? '') == shade &&
            (item['sizeName']?.toString() ?? '') == size,
          orElse: () => {},
        );
        
        if (item.isNotEmpty) {
          final mrp = (item['mrp'] as num?)?.toDouble() ?? 0.0;
          totalAmt += qty * mrp;
        }
      });
    });
  });

  _orderControllers.totalQty.text = totalQty.toString();
  _orderControllers.totalItem.text = _styleManager.groupedItems.length.toString();
  _orderControllers.totalAmt.text = totalAmt.toStringAsFixed(2); // Format to 2 decimal places
  setState(() {});
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: _showForm
                    ? _OrderForm(
                        controllers: _orderControllers,
                        dropdownData: _dropdownData,
                        onPartySelected: _handlePartySelection,
                        updateTotals: _updateTotals,
                        saveOrder: _saveOrderLocally,
                        additionalInfo: _additionalInfo,
                        consignees: consignees,
                        paymentTerms: paymentTerms,
                        bookingTypes: _bookingTypes,
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
                        onUpdate: () async {
                          await _styleManager.refreshOrderItems(barcode: barcodeMode);
                          _updateTotals();
                        },
                      ),
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _activeTab = ActiveTab.transaction;
                    _showForm = false;
                  });
                },
                child: Text('Transaction'),
                style: TextButton.styleFrom(
                  foregroundColor: _activeTab == ActiveTab.transaction
                      ? AppColors.primaryColor
                      : Colors.grey,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _activeTab = ActiveTab.customerDetails;
                    _showForm = true;
                  });
                },
                child: Text('Customer Details'),
                style: TextButton.styleFrom(
                  foregroundColor: _activeTab == ActiveTab.customerDetails
                      ? AppColors.primaryColor
                      : Colors.grey,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 2,
          color: Colors.grey[300],
          child: AnimatedAlign(
            duration: Duration(milliseconds: 300),
            alignment: _activeTab == ActiveTab.transaction
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: 2,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: Text('CANCEL', style: TextStyle(color: Colors.red)),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_activeTab == ActiveTab.transaction) {
                setState(() {
                  _activeTab = ActiveTab.customerDetails;
                  _showForm = true;
                });
              } else {
                setState(() {
                  _activeTab = ActiveTab.transaction;
                  _showForm = false;
                });
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_activeTab == ActiveTab.customerDetails)
                  Icon(Icons.arrow_back_ios, color: Colors.blue, size: 16),
                Text(
                  _activeTab == ActiveTab.transaction ? 'NEXT' : 'BACK',
                  style: TextStyle(color: Colors.blue),
                ),
                if (_activeTab == ActiveTab.transaction)
                  Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 16),
              ],
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _handlePartySelection(String? val, String? key) async {
    if (key == null) return;
      setState(() {
    _orderControllers.selectedParty = val; // Store the display name
    _orderControllers.selectedPartyKey = key;
    _orderControllers.selectedPartyName = val; // Store for PDF
  });
    _orderControllers.selectedPartyKey = key;
    UserSession.userLedKey = key; // Assign selected party key to userLedKey
    try {
      await fetchAndMapConsignees(key: key, CoBrId: UserSession.coBrId ?? '');
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
      _orderControllers.whatsAppMobileNo = details['whatsAppMobileNo'];
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
  String? whatsAppMobileNo;


  final orderNo = TextEditingController();
  final date = TextEditingController();
  final comm = TextEditingController();
  final deliveryDays = TextEditingController();
  final deliveryDate = TextEditingController();
  final remark = TextEditingController();
  final totalItem = TextEditingController(text: '0');
  final totalQty = TextEditingController(text: '0');
  final totalAmt=TextEditingController(text: '0');

  String? selectedParty;
  String? selectedPartyKey;
    String? selectedPartyName;
  String? selectedTransporter;
  String? selectedTransporterKey;
  String? selectedBroker;
  String? selectedBrokerKey;

  static String formatDate(DateTime date) {
    return DateFormat("yyyy-MM-dd").format(date);
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
      selectedPartyName = selectedPartyName ?? details['ledgerName']?.toString(); 

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
      body: jsonEncode({"ledCat": ledCat, "coBrId": UserSession.coBrId ?? ''}),
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
  final Map<String, Map<String, Map<String, TextEditingController>>> controllers = {};
  VoidCallback? updateTotalsCallback;
  bool isOrderItemsLoaded = false;

  Map<String, List<dynamic>> get groupedItems {
    final map = <String, List<dynamic>>{};
    for (final item in _orderItems) {
      final styleCode = item['styleCode']?.toString() ?? 'No Style Code';
      if (removedStyles.contains(styleCode)) continue;
      map.putIfAbsent(styleCode, () => []).add(item);
    }
    return map;
  }

  Future<void> fetchOrderItems({required bool barcode}) async {
    final response = await http.post(
      Uri.parse('${AppConstants.BASE_URL}/orderBooking/GetViewOrder'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "coBrId": UserSession.coBrId ?? '',
        "userId": UserSession.userName ?? '',
        "fcYrId": UserSession.userFcYr ?? '',
        "barcode": barcode ? "true" : "false",
      }),
    );

    if (response.statusCode == 200) {
      _orderItems = json.decode(response.body);
      _initializeControllers();
      isOrderItemsLoaded = true;
    }
  }

  Future<void> refreshOrderItems({required bool barcode}) async {
    final response = await http.post(
      Uri.parse('${AppConstants.BASE_URL}/orderBooking/GetViewOrder'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "coBrId": UserSession.coBrId ?? '',
        "userId": UserSession.userName ?? '',
        "fcYrId": UserSession.userFcYr ?? '',
        "barcode": barcode ? "true" : "false",
      }),
    );

    if (response.statusCode == 200) {
      final newItems = json.decode(response.body);
      _orderItems = newItems;
      _updateControllers();
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

  void _updateControllers() {
    final currentControllers =
        Map<String, Map<String, Map<String, TextEditingController>>>.from(controllers);
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
          final existingController = currentControllers[entry.key]?[shade]?[size];
          final controller = existingController ??
              TextEditingController(text: item['clqty']?.toString() ?? '0')
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      ),
    );
  }
}

class _StyleCardsView extends StatelessWidget {
  final _StyleManager styleManager;
  final VoidCallback updateTotals;
  final Color Function(String) getColor;
  final VoidCallback onUpdate;

  const _StyleCardsView({
    required this.styleManager,
    required this.updateTotals,
    required this.getColor,
    required this.onUpdate,
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
                  styleManager.controllers.remove(entry.key);
                  updateTotals();
                },
                updateTotals: updateTotals,
                getColor: getColor,
                onUpdate: onUpdate,
              ),
            )
            .toList(),
      );
    }
  }
}

class _OrderForm extends StatefulWidget {
  final _OrderControllers controllers;
  final _DropdownData dropdownData;
  final Function(String?, String?) onPartySelected;
  final VoidCallback updateTotals;
  final Future<void> Function() saveOrder;
  final Map<String, dynamic> additionalInfo;
  final List<Consignee> consignees;
  final List<PytTermDisc> paymentTerms;
  final List<Item> bookingTypes;
  final Function(Map<String, dynamic>) onAdditionalInfoUpdated;

  const _OrderForm({
    required this.controllers,
    required this.dropdownData,
    required this.onPartySelected,
    required this.updateTotals,
    required this.saveOrder,
    required this.additionalInfo,
    required this.consignees,
    required this.paymentTerms,
    required this.bookingTypes,
    required this.onAdditionalInfoUpdated,
  });

  @override
  _OrderFormState createState() => _OrderFormState();
}

class _OrderFormState extends State<_OrderForm> {
  @override
  void initState() {
    super.initState();
    // Handle userType == 'C': Pre-select party and trigger onPartySelected
    if (UserSession.userType == 'C' && widget.controllers.selectedParty == null) {
      final party = widget.dropdownData.partyList.firstWhere(
        (e) => e['ledKey'] == UserSession.userLedKey,
        orElse: () => {'ledKey': '', 'ledName': ''},
      );
      if (party['ledKey']!.isNotEmpty) {
        widget.controllers.selectedParty = party['ledName'];
        widget.controllers.selectedPartyKey = party['ledKey'];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onPartySelected(party['ledName'], party['ledKey']);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No party found for userLedKey')),
          );
        });
      }
    }
    // Handle userType == 'S': Pre-select salesman
    if (UserSession.userType == 'S' && widget.controllers.salesPersonKey == null) {
      final salesman = widget.dropdownData.salesPersonList.firstWhere(
        (e) => e['ledKey'] == UserSession.userLedKey,
        orElse: () => {'ledKey': '', 'ledName': ''},
      );
      if (salesman['ledKey']!.isNotEmpty) {
        widget.controllers.salesPersonKey = salesman['ledKey'];
        widget.additionalInfo['salesman'] = salesman['ledKey'];
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No salesman found for userLedKey')),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // _buildResponsiveRow(
        //   context,
          // buildTextField(
          //   context,
          //   "Order No",
          //   widget.controllers.orderNo,
          //   isText: true,
          // ),
          buildTextField(
            context,
            "Select Date",
            widget.controllers.date,
            isDate: true,
            onTap: () => _selectDate(context, widget.controllers.date),
          ),
     //   ),
        _buildPartyDropdownRow(context),
        _buildDropdown(
          "Broker",
          "B",
          widget.controllers.selectedBroker,
          (val, key) async {
            widget.controllers.selectedBrokerKey = key;
            if (key != null) {
              final commission =
                  await widget.dropdownData.fetchCommissionPercentage(key);
              widget.controllers.comm.text = commission;
            }
          },
          isEnabled: UserSession.userType != 'C',
        ),
        buildTextField(context, "Comm (%)", widget.controllers.comm),
        _buildDropdown(
          "Transporter",
          "T",
          widget.controllers.selectedTransporter,
          (val, key) => widget.controllers.selectedTransporterKey = key,
        ),
        _buildResponsiveRow(
          context,
          buildTextField(
            context,
            "Delivery Days",
            widget.controllers.deliveryDays,
            readOnly: true,
          ),
          buildTextField(
            context,
            "Delivery Date",
            widget.controllers.deliveryDate,
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
                widget.controllers.deliveryDate.text =
                    _OrderControllers.formatDate(picked);
                widget.controllers.deliveryDays.text = difference.toString();
              }
            },
          ),
        ),
      buildFullField(context, "Remark", widget.controllers.remark, true),
_buildResponsiveRow(
  context,
  buildTextField(
    context,
    "Total Item",
    widget.controllers.totalItem,
    readOnly: true,
  ),
  buildTextField(
    context,
    "Total Quantity",
    widget.controllers.totalQty,
    readOnly: true,
  ),
),
// Add Total Amount field below the row
buildTextField(
  context,
  "Total Amount (₹)",
  widget.controllers.totalAmt,
  readOnly: true,
),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (UserSession.userType == 'S' &&
                      (widget.controllers.selectedPartyKey == null ||
                          widget.controllers.selectedPartyKey!.isEmpty)) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Party Selection Required'),
                        content: Text('Please select a party before adding more information.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  final salesPersonList = widget.dropdownData.salesPersonList;
                  final partyLedKey = widget.controllers.selectedPartyKey;
                  final result = await showDialog(
                    context: context,
                    builder: (context) => AddMoreInfoDialog(
                      salesPersonList: salesPersonList,
                      partyLedKey: partyLedKey,
                      pytTermDiscKey: widget.controllers.pytTermDiscKey,
                      salesPersonKey: widget.controllers.salesPersonKey,
                      creditPeriod: widget.controllers.creditPeriod,
                      salesLedKey: widget.controllers.salesLedKey,
                      ledgerName: widget.controllers.ledgerName,
                      additionalInfo: widget.additionalInfo,
                      consignees: widget.consignees,
                      paymentTerms: widget.paymentTerms,
                      bookingTypes: widget.bookingTypes,
                      onValueChanged: (newInfo) {
                        widget.onAdditionalInfoUpdated(newInfo);
                      },
                      isSalesmanDropdownEnabled: UserSession.userType != 'S',
                    ),
                  );
                  if (result != null) {
                    widget.onAdditionalInfoUpdated(result);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: Size(double.infinity, 50),
                                   shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // removes curve
      ),
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
                onPressed: widget.saveOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: Size(double.infinity, 50),
                                   shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // removes curve
      ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
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
            widget.controllers.selectedParty,
            widget.onPartySelected,
            isEnabled: UserSession.userType != 'C',
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
  onPressed: UserSession.userType == 'C'
      ? null
      : () => showDialog(
          context: context,
          builder: (_) => CustomerMasterDialog(),
        ),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.lightBlue,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero, // Removes curve
    ),
  ),
  child: const Text('+', style: TextStyle(color: Colors.white),),
)
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String ledCat,
    String? selectedValue,
    Function(String?, String?) onChanged, {
    bool isEnabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownSearch<String>(
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: _getSearchHint(label),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
        items: _getLedgerList(ledCat).map((e) => e['ledName']!).toList(),
        selectedItem: selectedValue,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
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
        onChanged: isEnabled ? (val) => onChanged(val, _getKeyFromValue(ledCat, val)) : null,
        enabled: isEnabled,
      ),
    );
  }

  List<Map<String, String>> _getLedgerList(String ledCat) {
    switch (ledCat) {
      case 'w':
        return widget.dropdownData.partyList;
      case 'B':
        return widget.dropdownData.brokerList;
      case 'T':
        return widget.dropdownData.transporterList;
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

  Widget _buildResponsiveRow(
    BuildContext context,
    Widget first,
    Widget second,
  ) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
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
}

Widget buildTextField(
  BuildContext context,
  String label,
  TextEditingController controller, {
  bool isDate = false,
  bool readOnly = false,
  VoidCallback? onTap,
  bool isText = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      readOnly: readOnly || isDate,
      keyboardType: isText ? TextInputType.text : TextInputType.number,
      onTap: onTap ?? (isDate ? () => _selectDate(context, controller) : null),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero
        ),
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
  bool? isText,
) {
  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: buildTextField(
      context,
      label,
      controller,
      isText: isText ?? false,
    ),
  );
}

// Placeholder implementation of AddMoreInfoDialog
class AddMoreInfoDialog extends StatefulWidget {
  final List<Map<String, String>> salesPersonList;
  final String? partyLedKey;
  final String? pytTermDiscKey;
  final String? salesPersonKey;
  final int? creditPeriod;
  final String? salesLedKey;
  final String? ledgerName;
  final Map<String, dynamic> additionalInfo;
  final List<Consignee> consignees;
  final List<PytTermDisc> paymentTerms;
  final List<Item> bookingTypes;
  final Function(Map<String, dynamic>) onValueChanged;
  final bool isSalesmanDropdownEnabled;

  const AddMoreInfoDialog({
    required this.salesPersonList,
    required this.partyLedKey,
    required this.pytTermDiscKey,
    required this.salesPersonKey,
    required this.creditPeriod,
    required this.salesLedKey,
    required this.ledgerName,
    required this.additionalInfo,
    required this.consignees,
    required this.paymentTerms,
    required this.bookingTypes,
    required this.onValueChanged,
    required this.isSalesmanDropdownEnabled,
  });

  @override
  _AddMoreInfoDialogState createState() => _AddMoreInfoDialogState();
}

class _AddMoreInfoDialogState extends State<AddMoreInfoDialog> {
  late TextEditingController _refNoController;
  late TextEditingController _stationController;
  late TextEditingController _paymentDaysController;
  String? _selectedSalesman;
  String? _selectedSalesmanKey;
  String? _selectedConsignee;
  String? _selectedPaymentTerm;
  String? _selectedBookingType;

  @override
  void initState() {
    super.initState();
    _refNoController = TextEditingController(text: widget.additionalInfo['refno'] ?? '');
    _stationController = TextEditingController(text: widget.additionalInfo['station'] ?? '');
    _paymentDaysController = TextEditingController(text: widget.additionalInfo['paymentdays'] ?? '');
    _selectedSalesman = widget.salesPersonList.firstWhere(
      (e) => e['ledKey'] == (widget.additionalInfo['salesman'] ?? widget.salesPersonKey),
      orElse: () => {'ledName': ''},
    )['ledName'];
    _selectedSalesmanKey = widget.additionalInfo['salesman'] ?? widget.salesPersonKey;
    _selectedConsignee = widget.additionalInfo['consignee'];
    _selectedPaymentTerm = widget.additionalInfo['paymentterms'] ?? widget.pytTermDiscKey;
    _selectedBookingType = widget.additionalInfo['bookingtype'];
  }

  @override
  void dispose() {
    _refNoController.dispose();
    _stationController.dispose();
    _paymentDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add More Information'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownSearch<String>(
              popupProps: PopupProps.menu(showSearchBox: true),
              items: widget.salesPersonList.map((e) => e['ledName']!).toList(),
              selectedItem: _selectedSalesman,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: 'Salesman',
                  border: OutlineInputBorder(),
                ),
              ),
              onChanged: widget.isSalesmanDropdownEnabled
                  ? (val) {
                      setState(() {
                        _selectedSalesman = val;
                        _selectedSalesmanKey = widget.salesPersonList.firstWhere(
                          (e) => e['ledName'] == val,
                          orElse: () => {'ledKey': ''},
                        )['ledKey'];
                      });
                    }
                  : null,
              enabled: widget.isSalesmanDropdownEnabled,
            ),
            SizedBox(height: 10),
            DropdownSearch<String>(
              popupProps: PopupProps.menu(showSearchBox: true),
              items: widget.consignees.map((e) => e.ledName).toList(),
              selectedItem: _selectedConsignee,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: 'Consignee',
                  border: OutlineInputBorder(),
                ),
              ),
              onChanged: (val) => setState(() => _selectedConsignee = val),
            ),
            SizedBox(height: 10),
            DropdownSearch<String>(
              popupProps: PopupProps.menu(showSearchBox: true),
              items: widget.paymentTerms.map((e) => e.name).toList(),
              selectedItem: _selectedPaymentTerm,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: 'Payment Terms',
                  border: OutlineInputBorder(),
                ),
              ),
              onChanged: (val) => setState(() => _selectedPaymentTerm = val),
            ),
            SizedBox(height: 10),
            DropdownSearch<String>(
              popupProps: PopupProps.menu(showSearchBox: true),
              items: widget.bookingTypes.map((e) => e.itemName).toList(),
              selectedItem: _selectedBookingType,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: 'Booking Type',
                  border: OutlineInputBorder(),
                ),
              ),
              onChanged: (val) => setState(() => _selectedBookingType = val),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _refNoController,
              decoration: InputDecoration(
                labelText: 'Reference No',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _stationController,
              decoration: InputDecoration(
                labelText: 'Station',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _paymentDaysController,
              decoration: InputDecoration(
                labelText: 'Payment Days',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final newInfo = {
              'salesman': _selectedSalesmanKey,
              'consignee': _selectedConsignee,
              'paymentterms': _selectedPaymentTerm,
              'bookingtype': _selectedBookingType,
              'refno': _refNoController.text,
              'station': _stationController.text,
              'paymentdays': _paymentDaysController.text,
            };
            widget.onValueChanged(newInfo);
            Navigator.pop(context, newInfo);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
