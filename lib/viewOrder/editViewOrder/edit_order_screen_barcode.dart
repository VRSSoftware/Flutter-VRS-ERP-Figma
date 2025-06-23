import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:vrs_erp_figma/OrderBooking/barcode/barcodewidget.dart';
import 'package:vrs_erp_figma/catalog/imagezoom.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:vrs_erp_figma/screens/home_screen.dart';
import 'package:vrs_erp_figma/services/app_services.dart';
import 'package:vrs_erp_figma/viewOrder/Pdf_viewer_screen.dart';
import 'package:vrs_erp_figma/viewOrder/add_more_info.dart';
import 'package:vrs_erp_figma/viewOrder/customer_master.dart';
import 'package:vrs_erp_figma/models/consignee.dart';
import 'package:vrs_erp_figma/models/PytTermDisc.dart';
import 'package:vrs_erp_figma/models/item.dart';
import 'package:vrs_erp_figma/models/catalog.dart';
import 'package:vrs_erp_figma/models/OrderMatrix.dart';
import 'package:vrs_erp_figma/models/CatalogOrderData.dart';
import 'package:vrs_erp_figma/viewOrder/editViewOrder/edit_order_data.dart';
import 'package:vrs_erp_figma/viewOrder/editViewOrder/more_order_using_barcode.dart';

enum ActiveTab { transaction, customerDetails }

class EditOrderScreenBarcode extends StatefulWidget {
  final String docId;

  const EditOrderScreenBarcode({Key? key, required this.docId})
    : super(key: key);

  @override
  _EditOrderScreenBarcodeState createState() => _EditOrderScreenBarcodeState();
}

class _EditOrderScreenBarcodeState extends State<EditOrderScreenBarcode> {
  late String docId;
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
  Map<String, Map<String, Map<String, int>>> quantities = {};
  Map<String, Set<String>> selectedColors = {};

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
    setState(() {
      docId = widget.docId;
      _styleManager.docId = docId; // Pass docId to _StyleManager
    });
  }

  double _calculateTotalAmount() {
    double total = 0.0;
    for (final catalogOrder in EditOrderData.data) {
      final styleCode = catalogOrder.catalog.styleCode;
      final shades = catalogOrder.orderMatrix.shades;
      final sizes = catalogOrder.orderMatrix.sizes;
      for (var shadeIndex = 0; shadeIndex < shades.length; shadeIndex++) {
        final shade = shades[shadeIndex];
        for (var sizeIndex = 0; sizeIndex < sizes.length; sizeIndex++) {
          final size = sizes[sizeIndex];
          final qty =
              int.tryParse(
                _styleManager.controllers[styleCode]?[shade]?[size]?.text ??
                    '0',
              ) ??
              0;
          final mrp =
              double.tryParse(
                catalogOrder.orderMatrix.matrix[shadeIndex][sizeIndex].split(
                  ',',
                )[0],
              ) ??
              0.0;
          total += qty * mrp;
        }
      }
    }
    return total;
  }

  int _calculateTotalItems() {
    return EditOrderData.data.length;
  }

  int _calculateTotalQuantity() {
    int total = 0;
    for (final catalogOrder in EditOrderData.data) {
      final styleCode = catalogOrder.catalog.styleCode;
      final shades = catalogOrder.orderMatrix.shades;
      final sizes = catalogOrder.orderMatrix.sizes;
      for (var shade in shades) {
        for (var size in sizes) {
          total +=
              int.tryParse(
                _styleManager.controllers[styleCode]?[shade]?[size]?.text ??
                    '0',
              ) ??
              0;
        }
      }
    }
    return total;
  }

  Future<void> _loadBookingTypes() async {
    try {
      final rawData = await ApiService.fetchBookingTypes(
        coBrId: UserSession.coBrId ?? '',
      );
      setState(() {
        _bookingTypes =
            (rawData as List)
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
          paymentTerms =
              data
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
            consignees =
                responseMap['result']
                    .map((e) => Consignee.fromJson(e))
                    .toList();
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
      barcode: "true",
    );

    if (salesOrderData.isNotEmpty &&
        salesOrderData.containsKey('salesOrderNo')) {
      String salesOrderNo = salesOrderData['salesOrderNo'];
      _orderControllers.orderNo.text = (int.tryParse(EditOrderData.doc_id)! - 1).toString();
      print('Sales Order Number: $salesOrderNo');
    } else {
      print('Sales Order Number not found');
    }
  }

  Future<String> insertFinalSalesOrder(String orderDataJson) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${AppConstants.BASE_URL}/orderRegister/saveEditedSalesOrder',
        ),
        headers: {'Content-Type': 'application/json'},
        body: orderDataJson, // Send the new JSON structure directly
      );

      if (response.statusCode == 200) {
        print('Success: ${response.body}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Order saved successfully')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving order: $e')));
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
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    List<Map<String, dynamic>> addedItems = [];
    if (args != null && args.containsKey('addedItems')) {
      addedItems = List<Map<String, dynamic>>.from(args['addedItems']);
      print('Initial addedItems: $addedItems');
    }
    if (docId == "-1") {
      _styleManager._initializeControllers();
      _initializeQuantitiesAndColors();
    }

    // Fetch dropdown data first to ensure partyList is populated
    await _dropdownData.loadAllDropdownData();
    print(
      'Dropdown data loaded: partyList=${_dropdownData.partyList.length} parties',
    );

    // Fetch order details from the new API
    if (docId != '-1') {
      try {
        final response = await http.post(
          Uri.parse('${AppConstants.BASE_URL}/users/detailsForEdit'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"doc_id": docId}),
        );

        print(
          'detailsForEdit API Response: ${response.statusCode}, Body: ${response.body}',
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('Order details fetched: $data');
          setState(() {
            // Set party
            final party = _dropdownData.partyList.firstWhere(
              (e) => e['ledKey'] == data['Led_Key']?.toString(),
              orElse: () => {'ledKey': '', 'ledName': 'Select Party'},
            );
            _orderControllers.selectedPartyKey = data['Led_Key']?.toString();
            _orderControllers.selectedParty =
                party['ledName']?.isNotEmpty ?? false
                    ? party['ledName']
                    : 'Select Party';
            print(
              'Set party: ${_orderControllers.selectedParty} (${_orderControllers.selectedPartyKey})',
            );

            // Set broker
            final broker = _dropdownData.brokerList.firstWhere(
              (e) => e['ledKey'] == data['Broker_Key']?.toString(),
              orElse: () => {'ledKey': '', 'ledName': ''},
            );
            _orderControllers.selectedBrokerKey =
                data['Broker_Key']?.toString();
            _orderControllers.selectedBroker =
                broker['ledName']?.isNotEmpty ?? false
                    ? broker['ledName']
                    : null;
            _orderControllers.comm.text =
                data['Broker_Comm']?.toString() ?? '0.00';

            // Set transporter
            final transporter = _dropdownData.transporterList.firstWhere(
              (e) => e['ledKey'] == data['Trsp_Key']?.toString(),
              orElse: () => {'ledKey': '', 'ledName': ''},
            );
            _orderControllers.selectedTransporterKey =
                data['Trsp_Key']?.toString();
            _orderControllers.selectedTransporter =
                transporter['ledName']?.isNotEmpty ?? false
                    ? transporter['ledName']
                    : null;

            // Set payment days, delivery date, and remark
            _orderControllers.deliveryDays.text =
                data['PytDays']?.toString() ?? '0';
            _orderControllers.deliveryDate.text =
                data['DlvDate'] != null
                    ? _OrderControllers.formatDate(
                      DateTime.parse(data['DlvDate']),
                    )
                    : _OrderControllers.formatDate(DateTime.now());
            _orderControllers.remark.text = data['Remark']?.toString() ?? '';

            // Update additionalInfo
            _additionalInfo.addAll({
              'paymentdays': data['PytDays']?.toString() ?? '0',
              'refno': data['RefNo']?.toString() ?? '',
            });
          });

          // Fetch consignees after setting party
          if (_orderControllers.selectedPartyKey != null) {
            await fetchAndMapConsignees(
              key: _orderControllers.selectedPartyKey!,
              CoBrId: UserSession.coBrId ?? '',
            );
            print('Consignees fetched: ${consignees.length}');
          }
        } else {
          print('Error fetching order details: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to fetch order details: ${response.statusCode}',
              ),
            ),
          );
        }
      } catch (e) {
        print('Error fetching order details: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching order details: $e')),
        );
      }
    }

    await Future.wait([
      _styleManager.fetchOrderItems(
        barcode: barcodeMode,
        doc_Id: docId.toString(),
      ),
      fetchPaymentTerms(),
    ]);

    if (docId == '-1' && addedItems.isNotEmpty) {
      print('Processing addedItems for docId == -1');
      setState(() {
        EditOrderData.data.clear();
        for (var item in addedItems) {
          final styleCode = item['styleCode']?.toString() ?? 'No Style Code';
          final catalogOrder = _styleManager._convertToCatalogOrderData(
            styleCode,
            [item],
          );
          EditOrderData.data.add(catalogOrder);
          print(
            'Added item for style $styleCode: Matrix ${catalogOrder.orderMatrix.matrix}',
          );
        }
        _styleManager._initializeControllers();
        _initializeQuantitiesAndColors();
      });
    }

    _initializeQuantitiesAndColors();
    setState(() {
      isLoading = false;
    });
    print(
      'EditOrderData.data after initialization: ${EditOrderData.data.map((e) => e.catalog.styleCode)}',
    );
  }

  void _initializeQuantitiesAndColors() {
    quantities.clear();
    selectedColors.clear();
    print(
      'Initializing quantities and colors for ${EditOrderData.data.length} items',
    );

    for (var catalogOrder in EditOrderData.data) {
      final styleKey = catalogOrder.catalog.styleCode;
      final items = catalogOrder.orderMatrix;
      final shades = items.shades;
      final sizes = items.sizes;

      print(
        'Processing quantities for style: $styleKey, Shades: $shades, Sizes: $sizes',
      );

      selectedColors[styleKey] = shades.toSet();
      quantities[styleKey] = {};

      for (var shade in shades) {
        quantities[styleKey]![shade] = {};
        for (var size in sizes) {
          final shadeIndex = shades.indexOf(shade);
          final sizeIndex = sizes.indexOf(size);
          if (shadeIndex == -1 || sizeIndex == -1) {
            print(
              'Warning: Invalid indices for $styleKey/$shade/$size '
              '(shadeIndex: $shadeIndex, sizeIndex: $sizeIndex)',
            );
            quantities[styleKey]![shade]![size] = 0;
            continue;
          }
          final qty =
              int.tryParse(
                catalogOrder.orderMatrix.matrix[shadeIndex][sizeIndex].split(
                  ',',
                )[2],
              ) ??
              0;
          quantities[styleKey]![shade]![size] = qty;
          print('Quantity set for $styleKey/$shade/$size: $qty');
        }
      }
    }
    print('Quantities after initialization: $quantities');
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

    // Calculate totQty per style code
    final styleQuantities = <String, int>{};
    for (final catalogOrder in EditOrderData.data) {
      final styleCode = catalogOrder.catalog.styleCode;
      int totalQty = 0;
      final shades = catalogOrder.orderMatrix.shades;
      final sizes = catalogOrder.orderMatrix.sizes;
      for (var shade in shades) {
        for (var size in sizes) {
          totalQty +=
              int.tryParse(
                _styleManager.controllers[styleCode]?[shade]?[size]?.text ??
                    '0',
              ) ??
              0;
        }
      }
      styleQuantities[styleCode] = totalQty;
    }

    final orderData = {
      "doc_id": EditOrderData.doc_id,
      "login_id": UserSession.userName ?? 'admin',
      "coBr_id": UserSession.coBrId ?? '01',
      "fcYr_id": UserSession.userFcYr ?? '25',
      "data": {
        "customer": _orderControllers.selectedPartyKey ?? '',
        "consignee": _additionalInfo['consignee'] ?? '',
        "salesman":
            _additionalInfo['salesman'] ??
            _orderControllers.salesPersonKey ??
            '',
        "orderdate": formatDate(_orderControllers.date.text, false),
        "delivarydate": formatDate(_orderControllers.deliveryDate.text, false),
        "refno": _additionalInfo['refno'] ?? '',
        "date": '',
        "paymentterms":
            _additionalInfo['paymentterms'] ??
            _orderControllers.pytTermDiscKey ??
            '',
        "paymentdays":
            _additionalInfo['paymentdays'] ??
            _orderControllers.creditPeriod?.toString() ??
            '0',
        "duedate": calculateDueDate(),
        "broker": _orderControllers.selectedBrokerKey ?? '',
        "comission":
            _orderControllers.comm.text.isEmpty
                ? '0.00'
                : _orderControllers.comm.text,
        "transporter": _orderControllers.selectedTransporterKey ?? '',
        "remark": _orderControllers.remark.text,
        "delivaryday":
            _orderControllers.deliveryDays.text.isEmpty
                ? '0'
                : _orderControllers.deliveryDays.text,
        "bookingtype": _additionalInfo['bookingtype'] ?? '',
      },
      "items":
          EditOrderData.data
              .map((catalogOrder) {
                final styleCode = catalogOrder.catalog.styleCode;
                final shades = catalogOrder.orderMatrix.shades;
                final sizes = catalogOrder.orderMatrix.sizes;
                return shades
                    .asMap()
                    .entries
                    .map((shadeEntry) {
                      final shadeIndex = shadeEntry.key;
                      final shade = shadeEntry.value;
                      return sizes.asMap().entries.map((sizeEntry) {
                        final sizeIndex = sizeEntry.key;
                        final size = sizeEntry.value;
                        final qty =
                            _styleManager
                                .controllers[styleCode]?[shade]?[size]
                                ?.text ??
                            '0';
                        final matrixData = catalogOrder
                            .orderMatrix
                            .matrix[shadeIndex][sizeIndex]
                            .split(',');
                        return {
                          'style_code': styleCode,
                          'shade': shade,
                          'size': size,
                          'qty': int.tryParse(qty) ?? 0,
                          'totQty': styleQuantities[styleCode] ?? 0,
                          'mrp': double.tryParse(matrixData[0]) ?? 0.0,
                          'wsp':
                              double.tryParse(
                                matrixData.length > 1 ? matrixData[1] : '0',
                              ) ??
                              0.0,
                          'barcode':
                              catalogOrder
                                  .catalog
                                  .barcode, // Not available in current data
                          'note': "",
                        };
                      }).toList();
                    })
                    .expand((i) => i)
                    .toList();
              })
              .expand((i) => i)
              .where(
                (item) => (item['qty'] as int) > 0,
              ) // Exclude items with qty 0
              .toList(),
    };

    final orderDataJson = jsonEncode(orderData);
    print("Saved Order Data:");
    print(orderDataJson);

    try {
      await insertFinalSalesOrder(orderDataJson);
    } catch (e) {
      print('Error during order saving: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving order: $e')));
    }
  }

  void _updateTotals() {
    int totalQty = 0;
    double totalAmt = 0.0;

    _styleManager.controllers.forEach((style, shades) {
      final catalogOrder = EditOrderData.data.firstWhere(
        (order) => order.catalog.styleCode == style,
      );

      shades.forEach((shade, sizes) {
        final shadeIndex = catalogOrder.orderMatrix.shades.indexOf(shade);
        if (shadeIndex == -1) return;

        sizes.forEach((size, controller) {
          final qty = int.tryParse(controller.text) ?? 0;
          totalQty += qty;

          final sizeIndex = catalogOrder.orderMatrix.sizes.indexOf(size);
          if (sizeIndex == -1) return;

          final mrp =
              double.tryParse(
                catalogOrder.orderMatrix.matrix[shadeIndex][sizeIndex].split(
                  ',',
                )[0],
              ) ??
              0.0;
          totalAmt += qty * mrp;
        });
      });
    });

    _orderControllers.totalQty.text = totalQty.toString();
    _orderControllers.totalItem.text =
        _styleManager.groupedItems.length.toString();
    _orderControllers.totalAmt.text = totalAmt.toStringAsFixed(2);
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
                child:
                    _showForm
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
                            await _styleManager.refreshOrderItems(
                              barcode: barcodeMode,
                            );
                            _initializeQuantitiesAndColors();
                            _updateTotals();
                          },
                          quantities: quantities,
                          selectedColors: selectedColors,
                        ),
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddAction,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Item',
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
                  foregroundColor:
                      _activeTab == ActiveTab.transaction
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
                  foregroundColor:
                      _activeTab == ActiveTab.customerDetails
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
            alignment:
                _activeTab == ActiveTab.transaction
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
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
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
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Update Order ', style: TextStyle(color: Colors.white)),
      backgroundColor: AppColors.primaryColor,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: AppColors.primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Total: ₹${_calculateTotalAmount().toStringAsFixed(2)}',
                  style: GoogleFonts.roboto(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: Colors.white.withOpacity(0.5),
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
              ),
              Flexible(
                child: Text(
                  'Items: ${_calculateTotalItems()}',
                  style: GoogleFonts.roboto(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: Colors.white.withOpacity(0.5),
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
              ),
              Flexible(
                child: Text(
                  'Qty: ${_calculateTotalQuantity()}',
                  style: GoogleFonts.roboto(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePartySelection(String? val, String? key) async {
    if (key == null) return;
    _orderControllers.selectedPartyKey = key;
    UserSession.userLedKey = key;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load party details')));
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

  void _handleAddAction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MoreOrderBarcodePage(
              onFilterPressed: (String filter) {},
              edit: true,
            ),
      ),
    ).then((result) {
      if (result != null && result is List<Map<String, dynamic>>) {
        print('Received items from MoreOrderBarcodePage: $result');
        setState(() {
          // Group new items by styleCode
          final groupedByStyle = <String, List<dynamic>>{};
          for (var item in result) {
            final styleCode = item['styleCode']?.toString() ?? 'No Style Code';
            groupedByStyle.putIfAbsent(styleCode, () => []).add(item);
          }

          // Add or update CatalogOrderData for each style
          for (var entry in groupedByStyle.entries) {
            final styleCode = entry.key;
            final items = entry.value;
            final existingIndex = EditOrderData.data.indexWhere(
              (order) => order.catalog.styleCode == styleCode,
            );
            final catalogOrder = _styleManager._convertToCatalogOrderData(
              styleCode,
              items,
            );
            if (existingIndex != -1) {
              EditOrderData.data[existingIndex] = catalogOrder;
              print('Updated existing style: $styleCode');
            } else {
              EditOrderData.data.add(catalogOrder);
              print('Added new style: $styleCode');
            }
          }

          // Remove any styles in removedStyles
          EditOrderData.data.removeWhere(
            (order) =>
                _styleManager.removedStyles.contains(order.catalog.styleCode),
          );

          // Reinitialize controllers and quantities
          _styleManager._initializeControllers();
          _initializeQuantitiesAndColors();
          _updateTotals();
        });
        print(
          'EditOrderData.data after adding items: ${EditOrderData.data.map((e) => e.catalog.styleCode)}',
        );
      } else {
        print('No items returned from MoreOrderBarcodePage');
      }
    });
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
  final totalAmt = TextEditingController(text: '0');

  String? selectedParty;
  String? selectedPartyKey;
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
  final Set<String> removedStyles = {};
  final Map<String, Map<String, Map<String, TextEditingController>>>
  controllers = {};
  VoidCallback? updateTotalsCallback;
  bool isOrderItemsLoaded = false;
  String? docId;

  Map<String, List<CatalogOrderData>> get groupedItems {
    final map = <String, List<CatalogOrderData>>{};
    for (final catalogOrder in EditOrderData.data) {
      final styleCode = catalogOrder.catalog.styleCode;
      if (removedStyles.contains(styleCode)) continue;
      map.putIfAbsent(styleCode, () => []).add(catalogOrder);
    }
    return map;
  }

  CatalogOrderData _convertToCatalogOrderData(
    String styleKey,
    List<dynamic> items,
  ) {
    print('Converting to CatalogOrderData for style: $styleKey, Items: $items');
    if (items.isEmpty) {
      print('Error: Empty items list for style $styleKey');
      return CatalogOrderData(
        catalog: Catalog(
          itemSubGrpKey: '',
          itemSubGrpName: '',
          itemKey: '',
          itemName: 'Unknown',
          brandKey: '',
          brandName: '',
          styleKey: styleKey,
          styleCode: styleKey,
          shadeKey: '',
          shadeName: '',
          styleSizeId: '',
          sizeName: '',
          mrp: 0.0,
          wsp: 0.0,
          onlyMRP: 0.0,
          clqty: 0,
          total: 0,
          fullImagePath: '/NoImage.jpg',
          remark: '',
          imageId: '',
          sizeDetails: '',
          sizeDetailsWithoutWSp: '',
          sizeWithMrp: '',
          styleCodeWithcount: styleKey,
          onlySizes: '',
          sizeWithWsp: '',
          createdDate: '',
          shadeImages: '',
          upcoming_Stk: '0',
        ),
        orderMatrix: OrderMatrix(shades: [], sizes: [], matrix: []),
      );
    }

    final shades =
        items
            .map((i) => i['shadeName']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();
    final sizes =
        items
            .map((i) => i['sizeName']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();
    final firstItem = items.first;

    if (shades.isEmpty || sizes.isEmpty) {
      print(
        'Error: Empty shades or sizes for style $styleKey (Shades: $shades, Sizes: $sizes)',
      );
    }

    final matrix = List.generate(shades.length, (shadeIndex) {
      return List.generate(sizes.length, (sizeIndex) {
        final item = items.firstWhere(
          (i) =>
              (i['shadeName']?.toString() ?? '') == shades[shadeIndex] &&
              (i['sizeName']?.toString() ?? '') == sizes[sizeIndex],
          orElse: () => {},
        );
        final mrp = item['mrp']?.toString() ?? '0';
        final wsp = item['wsp']?.toString() ?? '0';
        final qty = item['clqty']?.toString() ?? '0';
        final stkQty = item['upcoming_Stk']?.toString() ?? '0';
        final matrixEntry = '$mrp,$wsp,$qty,$stkQty';
        print(
          'Matrix entry for $styleKey/$shadeIndex/$sizeIndex: $matrixEntry',
        );
        return matrixEntry;
      });
    });

    final catalog = Catalog(
      itemSubGrpKey: '',
      itemSubGrpName: '',
      itemKey: '',
      itemName: firstItem['itemName']?.toString() ?? 'Unknown',
      brandKey: '',
      brandName: '',
      styleKey: styleKey,
      styleCode: firstItem['styleCode']?.toString() ?? styleKey,
      shadeKey: '',
      shadeName: shades.join(','),
      styleSizeId: '',
      sizeName: sizes.join(','),
      mrp: double.tryParse(firstItem['mrp']?.toString() ?? '0') ?? 0.0,
      wsp: double.tryParse(firstItem['wsp']?.toString() ?? '0') ?? 0.0,
      onlyMRP: double.tryParse(firstItem['mrp']?.toString() ?? '0') ?? 0.0,
      clqty: int.tryParse(firstItem['clqty']?.toString() ?? '0') ?? 0,
      total: items.fold(
        0,
        (sum, i) => sum + (int.tryParse(i['clqty']?.toString() ?? '0') ?? 0),
      ),
      fullImagePath: firstItem['imagePath']?.toString() ?? '/NoImage.jpg',
      remark: firstItem['remark']?.toString() ?? '',
      imageId: '',
      sizeDetails: sizes
          .map((s) => '$s (${firstItem['mrp']},${firstItem['wsp']})')
          .join(','),
      sizeDetailsWithoutWSp: sizes
          .map((s) => '$s (${firstItem['mrp']})')
          .join(','),
      sizeWithMrp: sizes.map((s) => '$s (${firstItem['mrp']})').join(','),
      styleCodeWithcount: styleKey,
      onlySizes: sizes.join(','),
      sizeWithWsp: sizes.map((s) => '$s (${firstItem['wsp']})').join(','),
      createdDate: '',
      shadeImages: '',
      upcoming_Stk: firstItem['upcoming_Stk']?.toString() ?? '0',
      barcode: firstItem['barcode']?.toString() ?? 'Unknown',
    );

    print('Catalog created for $styleKey: ${catalog.toJson()}');
    return CatalogOrderData(
      catalog: catalog,
      orderMatrix: OrderMatrix(shades: shades, sizes: sizes, matrix: matrix),
    );
  }

  Future<void> fetchOrderItems({
    required bool barcode,
    required String doc_Id,
  }) async {
    docId = doc_Id;
    if (doc_Id != '-1') {
      EditOrderData.doc_id = doc_Id;
      try {
        final response = await http.post(
          Uri.parse('${AppConstants.BASE_URL}/orderRegister/editOrderData'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({"doc_id": doc_Id}),
        );

        print(
          'Fetch API Response: ${response.statusCode}, Body: ${response.body}',
        );

        if (response.statusCode == 200) {
          final items = json.decode(response.body);
          if (items is List && items.isNotEmpty) {
            final groupedByStyle = <String, List<dynamic>>{};
            for (var item in items) {
              final styleCode =
                  item['styleCode']?.toString() ?? 'No Style Code';
              groupedByStyle.putIfAbsent(styleCode, () => []).add(item);
            }
            EditOrderData.data =
                groupedByStyle.entries.map((entry) {
                  final catalogOrder = _convertToCatalogOrderData(
                    entry.key,
                    entry.value,
                  );
                  print(
                    'Fetched style: ${entry.key}, Matrix: ${catalogOrder.orderMatrix.matrix}',
                  );
                  return catalogOrder;
                }).toList();
            _initializeControllers();
          } else {
            print('No items found in response');
            EditOrderData.data = [];
          }
        } else {
          print('API Error: ${response.statusCode}');
          EditOrderData.data = [];
        }
      } catch (e) {
        print('Error fetching order items: $e');
        EditOrderData.data = [];
      }
    }
    isOrderItemsLoaded = true;
  }

  Future<void> refreshOrderItems({required bool barcode}) async {
    if (docId != null && docId != '-1') {
      try {
        final response = await http.post(
          Uri.parse('${AppConstants.BASE_URL}/orderRegister/editOrderData'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({"doc_id": docId}),
        );

        print(
          'Refresh API Response: ${response.statusCode}, Body: ${response.body}',
        );

        if (response.statusCode == 200) {
          final newItems = json.decode(response.body);
          if (newItems is List && newItems.isNotEmpty) {
            final groupedByStyle = <String, List<dynamic>>{};
            for (var item in newItems) {
              final styleCode =
                  item['styleCode']?.toString() ?? 'No Style Code';
              groupedByStyle.putIfAbsent(styleCode, () => []).add(item);
            }
            EditOrderData.data =
                groupedByStyle.entries.map((entry) {
                  final catalogOrder = _convertToCatalogOrderData(
                    entry.key,
                    entry.value,
                  );
                  print(
                    'Refreshed style: ${entry.key}, Matrix: ${catalogOrder.orderMatrix.matrix}',
                  );
                  return catalogOrder;
                }).toList();
            _initializeControllers();
          } else {
            print('No items found in refresh response');
            EditOrderData.data = [];
          }
        } else {
          print('Error refreshing order items: ${response.statusCode}');
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Failed to refresh order items')),
          // );
        }
      } catch (e) {
        print('Error refreshing order items: $e');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Error refreshing order items: $e')),
        // );
      }
    } else {
      print('Invalid docId: $docId');
    }
  }

  void copyStyle(String styleKey) {
    final catalogOrders = groupedItems[styleKey];
    if (catalogOrders != null && catalogOrders.isNotEmpty) {
      _initializeControllers();
      updateTotalsCallback?.call();
    }
  }

  void removeStyle(String styleKey) {
    removedStyles.add(styleKey);
    controllers.remove(styleKey);
    EditOrderData.data =
        EditOrderData.data
            .where((e) => e.catalog.styleCode != styleKey)
            .toList();
    updateTotalsCallback?.call();
  }

  void _initializeControllers() {
    final currentControllers =
        Map<String, Map<String, Map<String, TextEditingController>>>.from(
          controllers,
        );
    print(
      'Initializing controllers for styles: ${groupedItems.keys}, Removed styles: $removedStyles',
    );

    for (final entry in groupedItems.entries) {
      final styleKey = entry.key;
      final catalogOrder = entry.value.first;
      final sizes = catalogOrder.orderMatrix.sizes;
      final shades = catalogOrder.orderMatrix.shades;

      print('Processing style: $styleKey, Shades: $shades, Sizes: $sizes');

      controllers.putIfAbsent(styleKey, () => {});
      for (final shade in shades) {
        controllers[styleKey]!.putIfAbsent(shade, () => {});
        for (final size in sizes) {
          final matrix = catalogOrder.orderMatrix.matrix;
          String qty = '0';
          if (matrix.isNotEmpty) {
            final shadeIndex = shades.indexOf(shade);
            final sizeIndex = sizes.indexOf(size);
            if (shadeIndex >= 0 &&
                sizeIndex >= 0 &&
                shadeIndex < matrix.length &&
                sizeIndex < matrix[shadeIndex].length) {
              qty = matrix[shadeIndex][sizeIndex].split(',')[2];
            } else {
              print(
                'Warning: Invalid matrix indices for $styleKey/$shade/$size '
                '(shadeIndex: $shadeIndex, sizeIndex: $sizeIndex, matrix: $matrix)',
              );
            }
          } else {
            print('Warning: Empty matrix for style $styleKey');
          }
          final existingController =
              currentControllers[styleKey]?[shade]?[size];
          final controller =
              existingController ?? TextEditingController(text: qty)
                ..addListener(() => updateTotalsCallback?.call());
          controllers[styleKey]![shade]![size] = controller;
          print(
            'Controller set for $styleKey/$shade/$size: ${controller.text}',
          );
        }
      }
    }
  }
}

class _StyleCardsView extends StatelessWidget {
  final _StyleManager styleManager;
  final VoidCallback updateTotals;
  final Color Function(String) getColor;
  final VoidCallback onUpdate;
  final Map<String, Map<String, Map<String, int>>> quantities;
  final Map<String, Set<String>> selectedColors;

  const _StyleCardsView({
    required this.styleManager,
    required this.updateTotals,
    required this.getColor,
    required this.onUpdate,
    required this.quantities,
    required this.selectedColors,
  });

  @override
  Widget build(BuildContext context) {
    if (!styleManager.isOrderItemsLoaded) {
      return const Center(child: CircularProgressIndicator());
    } else if (EditOrderData.data.isEmpty ||
        styleManager.groupedItems.isEmpty) {
      return const Center(
        child: Text(
          'No items added',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    } else {
      return Column(
        children:
            EditOrderData.data
                .where(
                  (catalogOrder) =>
                      !styleManager.removedStyles.contains(
                        catalogOrder.catalog.styleCode,
                      ),
                )
                .map((catalogOrder) {
                  final styleKey = catalogOrder.catalog.styleCode;
                  return StyleCard(
                    styleCode: styleKey,
                    catalogOrder: catalogOrder,
                    quantities: quantities[styleKey] ?? {},
                    selectedColors: selectedColors[styleKey] ?? {},
                    getColor: getColor,
                    onUpdate: onUpdate,
                    styleManager: styleManager,
                  );
                })
                .toList(),
      );
    }
  }
}

class StyleCard extends StatelessWidget {
  final String styleCode;
  final CatalogOrderData catalogOrder;
  final Map<String, Map<String, int>> quantities;
  final Set<String> selectedColors;
  final Color Function(String) getColor;
  final VoidCallback onUpdate;
  final _StyleManager styleManager;

  const StyleCard({
    Key? key,
    required this.styleCode,
    required this.catalogOrder,
    required this.quantities,
    required this.selectedColors,
    required this.getColor,
    required this.onUpdate,
    required this.styleManager,
  }) : super(key: key);

  int _calculateCatalogQuantity(CatalogOrderData catalogOrder) {
    int total = 0;
    quantities.forEach((shade, sizes) {
      sizes.forEach((size, qty) {
        total += qty;
      });
    });
    return total;
  }

  int _calculateStockQuantity(CatalogOrderData catalogOrder) {
    int total = 0;
    final matrix = catalogOrder.orderMatrix;
    for (var shadeIndex = 0; shadeIndex < matrix.shades.length; shadeIndex++) {
      for (var sizeIndex = 0; sizeIndex < matrix.sizes.length; sizeIndex++) {
        final matrixData = matrix.matrix[shadeIndex][sizeIndex].split(',');
        final stock =
            int.tryParse(matrixData.length > 3 ? matrixData[3] : '0') ?? 0;
        total += stock;
      }
    }
    return total;
  }

  double _calculateCatalogPrice(CatalogOrderData catalogOrder) {
    double total = 0;
    final matrix = catalogOrder.orderMatrix;
    for (var shade in quantities.keys) {
      final shadeIndex = matrix.shades.indexOf(shade.trim());
      if (shadeIndex == -1) continue;
      for (var size in quantities[shade]!.keys) {
        final sizeIndex = matrix.sizes.indexOf(size.trim());
        if (sizeIndex == -1) continue;
        final rate =
            double.tryParse(
              matrix.matrix[shadeIndex][sizeIndex].split(',')[0],
            ) ??
            0;
        final quantity = quantities[shade]![size]!;
        total += rate * quantity;
      }
    }
    return total;
  }

  Widget buildOrderItem(CatalogOrderData catalogOrder, BuildContext context) {
    final catalog = catalogOrder.catalog;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: GestureDetector(
                      onDoubleTap: () {
                        final imageUrl =
                            catalog.fullImagePath.contains("http")
                                ? catalog.fullImagePath
                                : '${AppConstants.BASE_URL}/images${catalog.fullImagePath}';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ImageZoomScreen(
                                  imageUrls: [imageUrl],
                                  initialIndex: 0,
                                ),
                          ),
                        );
                      },
                      child: Image.network(
                        catalog.fullImagePath.contains("http")
                            ? catalog.fullImagePath
                            : '${AppConstants.BASE_URL}/images${catalog.fullImagePath}',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.error, size: 60),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              catalog.styleCode,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                                color: Colors.red.shade900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: Text(
                                      'Are you sure you want to delete style ${catalog.styleCode}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          styleManager.removeStyle(
                                            catalog.styleCode,
                                          );
                                          onUpdate();
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Style ${catalog.styleCode} removed',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          tooltip: 'Delete Style',
                        ),
                      ],
                    ),
                    Text(
                      catalog.shadeName,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Table(
                      columnWidths: const {
                        0: FixedColumnWidth(100),
                        1: FixedColumnWidth(10),
                        2: FlexColumnWidth(100),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      children: [
                        _buildTableRow('Remark', catalog.remark),
                        _buildTableRow(
                          'Stk Type',
                          catalog.upcoming_Stk == '1' ? 'Upcoming' : 'Ready',
                        ),
                        _buildTableRow(
                          'Stock Qty',
                          _calculateStockQuantity(catalogOrder).toString(),
                          valueColor: Colors.green[700],
                        ),
                        _buildTableRow(
                          'Order Qty',
                          _calculateCatalogQuantity(catalogOrder).toString(),
                          valueColor: Colors.orange[800],
                        ),
                        _buildTableRow(
                          'Order Amount',
                          _calculateCatalogPrice(
                            catalogOrder,
                          ).toStringAsFixed(2),
                          valueColor: Colors.purple[800],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        ...selectedColors.map(
          (color) => Column(
            children: [
              _buildColorSection(catalogOrder, color),
              const SizedBox(height: 8),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value, {Color? valueColor}) {
    return TableRow(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(label, style: GoogleFonts.roboto(fontSize: 14)),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(":", style: TextStyle(fontSize: 14)),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSection(CatalogOrderData catalogOrder, String shade) {
    final sizes = catalogOrder.orderMatrix.sizes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Divider(height: 1, color: Colors.grey.shade300),
              Row(
                children: [
                  _buildHeader("Size", 1),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        "Qty",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lora(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                  ),
                  _buildHeader("MRP", 1),
                  _buildHeader("WSP", 1),
                  _buildHeader("Stock", 1),
                ],
              ),
              Divider(height: 1, color: Colors.grey.shade300),
              for (var size in sizes) ...[
                _buildSizeRow(catalogOrder, shade, size),
                Divider(height: 1, color: Colors.grey.shade300),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String text, int flex) => Expanded(
    flex: flex,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.lora(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.red.shade900,
        ),
      ),
    ),
  );

  Widget _buildSizeRow(
    CatalogOrderData catalogOrder,
    String shade,
    String size,
  ) {
    final matrix = catalogOrder.orderMatrix;
    final shadeIndex = matrix.shades.indexOf(shade.trim());
    final sizeIndex = matrix.sizes.indexOf(size.trim());

    String rate = '0';
    String wsp = '0';
    String qty = '0';
    String stock = '0';
    TextEditingController? controller;

    if (shadeIndex != -1 && sizeIndex != -1) {
      final matrixData = matrix.matrix[shadeIndex][sizeIndex].split(',');
      rate = matrixData[0];
      wsp = matrixData.length > 1 ? matrixData[1] : '0';
      qty = matrixData.length > 2 ? matrixData[2] : '0';
      stock = matrixData.length > 3 ? matrixData[3] : '0';
      controller = styleManager.controllers[styleCode]?[shade]?[size];
      print('Controller for $styleCode/$shade/$size: ${controller?.text}');
    }

    return Row(
      children: [
        _buildCell(size, 1),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 22,
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      hintText: stock,
                      hintStyle: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    style: GoogleFonts.roboto(fontSize: 14),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onChanged: (value) {
                      final newQuantity =
                          int.tryParse(value.isEmpty ? '0' : value) ?? 0;
                      if (quantities[shade] != null) {
                        quantities[shade]![size] = newQuantity;
                        if (shadeIndex != -1 && sizeIndex != -1) {
                          final matrixData = matrix
                              .matrix[shadeIndex][sizeIndex]
                              .split(',');
                          matrix.matrix[shadeIndex][sizeIndex] =
                              '${matrixData[0]},${matrixData[1]},$newQuantity,${matrixData.length > 3 ? matrixData[3] : '0'}';
                          print(
                            'Updated matrix for $styleCode/$shade/$size: ${matrix.matrix[shadeIndex][sizeIndex]}',
                          );
                        }
                        styleManager.updateTotalsCallback?.call();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildCell(rate, 1),
        _buildCell(wsp, 1),
        _buildCell(stock, 1),
      ],
    );
  }

  Widget _buildCell(String text, int flex) => Expanded(
    flex: flex,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.roboto(fontSize: 14),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return buildOrderItem(catalogOrder, context);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
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
  String? _partyValue;
  String? _brokerValue;
  String? _transporterValue;

  @override
  void initState() {
    super.initState();
    _partyValue = widget.controllers.selectedParty;
    _brokerValue = widget.controllers.selectedBroker;
    _transporterValue = widget.controllers.selectedTransporter;

    print(
      'OrderForm initState: userType=${UserSession.userType}, '
      'selectedParty=${widget.controllers.selectedParty}, '
      'selectedPartyKey=${widget.controllers.selectedPartyKey}, '
      'partyList=${widget.dropdownData.partyList.length} parties',
    );

    if (UserSession.userType == 'C' &&
        widget.controllers.selectedParty == null) {
      final party = widget.dropdownData.partyList.firstWhere(
        (e) => e['ledKey'] == UserSession.userLedKey,
        orElse: () => {'ledKey': '', 'ledName': 'Select Party'},
      );
      if (party['ledKey']!.isNotEmpty) {
        print(
          'Setting party for customer: ${party['ledName']} (${party['ledKey']})',
        );
        setState(() {
          _partyValue = party['ledName'];
          widget.controllers.selectedParty = party['ledName'];
          widget.controllers.selectedPartyKey = party['ledKey'];
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onPartySelected(party['ledName'], party['ledKey']);
        });
      } else {
        print('No party found for userLedKey=${UserSession.userLedKey}');
        setState(() {
          _partyValue = 'Select Party';
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No party found for userLedKey')),
          );
        });
      }
    }

    if (UserSession.userType == 'S' &&
        widget.controllers.salesPersonKey == null) {
      final salesman = widget.dropdownData.salesPersonList.firstWhere(
        (e) => e['ledKey'] == UserSession.userLedKey,
        orElse: () => {'ledKey': '', 'ledName': ''},
      );
      if (salesman['ledKey']!.isNotEmpty) {
        print(
          'Setting salesman: ${salesman['ledName']} (${salesman['ledKey']})',
        );
        widget.controllers.salesPersonKey = salesman['ledKey'];
        widget.additionalInfo['salesman'] = salesman['ledKey'];
      } else {
        print('No salesman found for userLedKey=${UserSession.userLedKey}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No salesman found for userLedKey')),
          );
        });
      }
    }

    // Trigger party selection if already set
    if (widget.controllers.selectedParty != null &&
        widget.controllers.selectedPartyKey != null &&
        widget.controllers.selectedParty != 'Select Party') {
      print(
        'Triggering onPartySelected for existing party: '
        '${widget.controllers.selectedParty} (${widget.controllers.selectedPartyKey})',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onPartySelected(
          widget.controllers.selectedParty,
          widget.controllers.selectedPartyKey,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildResponsiveRow(
          context,
          buildTextField(
            context,
            "Order No",
            widget.controllers.orderNo,
            isText: true,
          ),
          buildTextField(
            context,
            "Select Date",
            widget.controllers.date,
            isDate: true,
            onTap: () => _selectDate(context, widget.controllers.date),
          ),
        ),
        _buildPartyDropdownRow(context),
        _buildDropdown("Broker", "B", _brokerValue, (val, key) async {
          widget.controllers.selectedBrokerKey = key;
          _brokerValue = val;
          if (key != null) {
            final commission = await widget.dropdownData
                .fetchCommissionPercentage(key);
            widget.controllers.comm.text = commission;
          }
          setState(() {});
        }, isEnabled: UserSession.userType != 'C'),
        buildTextField(context, "Comm (%)", widget.controllers.comm),
        _buildDropdown("Transporter", "T", _transporterValue, (val, key) {
          widget.controllers.selectedTransporterKey = key;
          _transporterValue = val;
          setState(() {});
        }),
        _buildResponsiveRow(
          context,
          buildTextField(
            context,
            "Delivery Days",
            widget.controllers.deliveryDays,
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
                widget
                    .controllers
                    .deliveryDate
                    .text = _OrderControllers.formatDate(picked);
                widget.controllers.deliveryDays.text = difference.toString();
              }
            },
          ),
        ),
        buildFullField(context, "Remark", widget.controllers.remark, true),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: widget.saveOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
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
          child: _buildDropdown("Party Name", "w", _partyValue, (
            val,
            key,
          ) async {
            print('Party selected: $val ($key)');
            setState(() {
              _partyValue = val ?? 'Select Party';
              widget.controllers.selectedParty = val;
              widget.controllers.selectedPartyKey = key;
            });
            if (key != null) {
              await widget.onPartySelected(val, key);
            }
          }, isEnabled: UserSession.userType != 'C'),
        ),
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
        key: ValueKey('$ledCat-$selectedValue'),
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: _getSearchHint(label),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
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
            selectedItem ?? 'Select $label',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          );
        },
        onChanged:
            isEnabled
                ? (val) {
                  final key = _getKeyFromValue(ledCat, val);
                  onChanged(val, key);
                  setState(() {
                    if (label == 'Party Name') _partyValue = val;
                    if (label == 'Broker') _brokerValue = val;
                    if (label == 'Transporter') _transporterValue = val;
                  });
                }
                : null,
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
        : Column(children: [first, const SizedBox(height: 10), second]);
  }

  Widget buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    bool isText = false,
    bool isDate = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: isDate,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
      ),
      keyboardType: isText ? TextInputType.text : TextInputType.number,
      onTap: onTap,
      // validator: (value) {
      //   if (value == null || value.isEmpty) {
      //     return 'Please enter $label';
      //   }
      //   return null;
      // },
    );
  }

  Widget buildFullField(
    BuildContext context,
    String label,
    TextEditingController controller,
    bool isMultiline,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
        ),
        maxLines: isMultiline ? 3 : 1,
        // validator: (value) {
        //   if (value == null || value.isEmpty) {
        //     return 'Please enter $label';
        //   }
        //   return null;
        // },
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = _OrderControllers.formatDate(picked);
    }
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
        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
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
    child: buildTextField(context, label, controller, isText: isText ?? false),
  );
}

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
    _refNoController = TextEditingController(
      text: widget.additionalInfo['refno'] ?? '',
    );
    _stationController = TextEditingController(
      text: widget.additionalInfo['station'] ?? '',
    );
    _paymentDaysController = TextEditingController(
      text: widget.additionalInfo['paymentdays'] ?? '',
    );
    _selectedSalesman =
        widget.salesPersonList.firstWhere(
          (e) =>
              e['ledKey'] ==
              (widget.additionalInfo['salesman'] ?? widget.salesPersonKey),
          orElse: () => {'ledName': ''},
        )['ledName'];
    _selectedSalesmanKey =
        widget.additionalInfo['salesman'] ?? widget.salesPersonKey;
    _selectedConsignee = widget.additionalInfo['consignee'];
    _selectedPaymentTerm =
        widget.additionalInfo['paymentterms'] ?? widget.pytTermDiscKey;
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
              onChanged:
                  widget.isSalesmanDropdownEnabled
                      ? (val) {
                        setState(() {
                          _selectedSalesman = val;
                          _selectedSalesmanKey =
                              widget.salesPersonList.firstWhere(
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
