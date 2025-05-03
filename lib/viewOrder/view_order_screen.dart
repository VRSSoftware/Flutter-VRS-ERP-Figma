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
  List<dynamic> orderItems = [];
  Map<String, List<dynamic>> groupedItems = {};
  Map<String, Map<String, Map<String, TextEditingController>>> controllers = {};
  Map<String, int> styleTotals = {};
  Set<String> removedStyles = {};

  // Controllers
  final TextEditingController orderNoController = TextEditingController(text: 'SO100');
  final TextEditingController dateController = TextEditingController(text: '22-04-2025');
  final TextEditingController commController = TextEditingController();
  final TextEditingController deliveryDaysController = TextEditingController();
  final TextEditingController deliveryDateController = TextEditingController(text: '22-04-2025');
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController totalItemController = TextEditingController(text: '0');
  final TextEditingController totalQtyController = TextEditingController(text: '0');


  // Dropdown Values
  String? selectedParty;
  String? selectedPartyKey;
  String? selectedTransporter;
  String? selectedTransporterKey;
  String? selectedBroker;
  String? selectedBrokerKey;
  
  // Lists
  List<Map<String, String>> partyList = [];
  List<Map<String, String>> brokerList = [];
  List<Map<String, String>> transporterList = [];

  @override
  void initState() {
    super.initState();
    fetchOrderItems();
    _fetchInitialData();
  }
    Future<void> _fetchInitialData() async {
    brokerList = await fetchLedgers("B");
    transporterList = await fetchLedgers("T");
    setState(() {});
  }


  Future<List<Map<String, String>>> fetchLedgers(String ledCat) async {
    final response = await http.post(
      Uri.parse('${AppConstants.BASE_URL}/users/getLedger'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"ledCat": ledCat, "coBrId": "01"}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map<Map<String, String>>((e) => {
        'ledKey': e['ledKey'].toString(),
        'ledName': e['ledName'].toString(),
      }).toList();
    } else {
      throw Exception("Failed to load ledgers");
    }
  }

  Future<Map<String, dynamic>> fetchLedgerDetails(String ledKey) async {
    final response = await http.post(
      Uri.parse('${AppConstants.BASE_URL}/users/getLedgerDetails'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"ledKey": ledKey}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load ledger details');
    }
  }



  Future<void> fetchOrderItems() async {
    final url = Uri.parse('${AppConstants.BASE_URL}/orderBooking/GetViewOrder');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "coBrId": "01",
        "userId": "Admin",
        "fcYrId": "24",
        "barcode": "false",
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        orderItems = json.decode(response.body);
        groupItemsByStyle();
        _initializeControllers();
        _calculateTotals();
      });
    } else {
      print('Failed to load order items');
    }
  }

  void groupItemsByStyle() {
    groupedItems = {};
    for (var item in orderItems) {
      String styleCode = item['styleCode']?.toString() ?? 'No Style Code';
      if (removedStyles.contains(styleCode)) continue;
      if (!groupedItems.containsKey(styleCode)) {
        groupedItems[styleCode] = [];
      }
      groupedItems[styleCode]!.add(item);
    }
  }

  void _initializeControllers() {
    controllers = {};
    for (var styleEntry in groupedItems.entries) {
      final styleCode = styleEntry.key;
      final items = styleEntry.value;

      final sizes =
          items.map((e) => e['sizeName']?.toString() ?? '').toSet().toList()
            ..sort();

      final shades =
          items.map((e) => e['shadeName']?.toString() ?? '').toSet().toList();

      controllers[styleCode] = {};

      for (var shade in shades) {
        controllers[styleCode]![shade] = {};
        for (var size in sizes) {
          final item = items.firstWhere(
            (i) =>
                (i['shadeName']?.toString() ?? '') == shade &&
                (i['sizeName']?.toString() ?? '') == size,
            orElse: () => {'clqty': 0},
          );

          controllers[styleCode]![shade]![size] = TextEditingController(
            text: (item['clqty']?.toString() ?? '0'),
          );
        }
      }
    }
  }

  void _calculateTotals() {
    int totalQty = 0;
    styleTotals = {};

    for (var styleEntry in groupedItems.entries) {
      int styleTotal = 0;
      for (var item in styleEntry.value) {
        styleTotal += int.tryParse(item['clqty']?.toString() ?? '0') ?? 0;
      }
      styleTotals[styleEntry.key] = styleTotal;
      totalQty += styleTotal;
    }

    totalItemController.text = groupedItems.length.toString();
    totalQtyController.text = totalQty.toString();
  }

  void _showCustomerMasterDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => CustomerMasterDialog());
  }

  String _getImageUrl(String fullImagePath) {
    if (fullImagePath.startsWith('http')) return fullImagePath;
    final imageName = fullImagePath.split('/').last.split('?').first;
    return '${AppConstants.BASE_URL}/images/$imageName';
  }

  Widget _buildImageSection(String imageUrl) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.network(
            imageUrl,
            fit: BoxFit.fitWidth,
            width: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) => _buildImageError(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_not_supported, size: 40),
          SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

Widget _buildStyleCard(String styleCode, List<dynamic> items) {
  final firstItem = items.isNotEmpty ? items.first : {};
  final sizeDetails = <String, Map<String, num>>{};
  final shades = <String>{};

  final itemSubGrpName = firstItem['itemSubGrpName']?.toString() ?? 'N/A';
  final itemName = firstItem['itemName']?.toString() ?? 'N/A';
  final brandName = firstItem['brandName']?.toString() ?? 'N/A';

  for (final item in items) {
    final size = item['sizeName']?.toString() ?? 'N/A';
    final shade = item['shadeName']?.toString() ?? 'N/A';

    if (!sizeDetails.containsKey(size)) {
      sizeDetails[size] = {
        'mrp': (item['mrp'] as num?) ?? 0,
        'wsp': (item['wsp'] as num?) ?? 0,
      };
    }
    shades.add(shade);
  }

  final sortedSizes = sizeDetails.keys.toList()..sort();
  final sortedShades = shades.toList()..sort();

 return Card(
  color: Colors.white70.withOpacity(0.9),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image and Details Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (items.isNotEmpty && items.first['fullImagePath'] != null)
              Container(
                width: 100,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildImageSection(
                  _getImageUrl(items.first['fullImagePath']),
                ),
              ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    styleCode,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (itemSubGrpName.isNotEmpty)
                    _buildDetailRow('Category:', itemSubGrpName),
                  if (itemName.isNotEmpty)
                    _buildDetailRow('Product:', itemName),
                  if (brandName.isNotEmpty)
                    _buildDetailRow('Brand:', brandName),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Table Section
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 64,
            ),
            child: Table(
              border: TableBorder.all(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
              columnWidths: {
                0: FixedColumnWidth(100),
                for (var i = 0; i < sortedSizes.length; i++)
                  (i + 1): FixedColumnWidth(80),
              },
              children: [
                // MRP Row
                TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text('MRP')),
                    ...sortedSizes.map(
                      (size) => Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(
                          child: Text(
                            '${sizeDetails[size]!['mrp']?.toStringAsFixed(0) ?? '0'}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // WSP Row
                TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text('WSP')),
                    ...sortedSizes.map(
                      (size) => Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(
                          child: Text(
                            '${sizeDetails[size]!['wsp']?.toStringAsFixed(0) ?? '0'}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Header Row with Diagonal
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        height: 48,
                        child: CustomPaint(
                          painter: _DiagonalLinePainter(),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 12,
                                top: 20,
                                child: Text(
                                  'Shade',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 14,
                                bottom: 20,
                                child: Text(
                                  'Size',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ...sortedSizes.map(
                      (size) => Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: Text(size)),
                      ),
                    ),
                  ],
                ),
                // Normal Shade Rows
                ...sortedShades.map(
                  (shade) => TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            
                            SizedBox(width: 8),
                            Text(shade),
                          ],
                        ),
                      ),
                      ...sortedSizes.map(
                        (size) => Padding(
                          padding: EdgeInsets.all(4),
                          child: TextField(
                            controller: controllers[styleCode]?[shade]?[size],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              hintText: '0',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (_) => _updateTotals(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),
        _buildNoteSection(items),
        _buildTotalSection(items),
        _buildActionButtons(styleCode, sortedShades, sortedSizes),
      ],
    ),
  ),
);
}
 
  
  Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[800],
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}

  Widget _buildPricingRow(
    String label,
    List<String> sizes, [
    Map<String, Map<String, num>>? sizeDetails,
    String? priceKey,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          ...sizes.map(
            (size) => Expanded(
              child: Center(
                child: Text(
                  priceKey != null
                      ? '${sizeDetails?[size]?[priceKey]?.toStringAsFixed(0) ?? '0'}'
                      : size,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShadeRow(
    String styleCode,
    String shade,
    List<String> sizes,
    List<dynamic> items,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Row(
              children: [
                // Icon(Icons.circle, size: 12, color: _getColorCode(shade)),
                SizedBox(width: 8),
                Flexible(child: Text(shade)),
              ],
            ),
          ),
          ...sizes.map(
            (size) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: controllers[styleCode]?[shade]?[size],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(),
                    hintText: '0',
                  ),
                  onChanged: (_) => _updateTotals(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(List<dynamic> items) {
    final note = items.isNotEmpty ? items.first['note']?.toString() ?? '' : '';

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Note',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(12),
        ),
        controller: TextEditingController(text: note),
      ),
    );
  }

  Widget _buildTotalSection(List<dynamic> items) {
    final total = items.fold<int>(
      0,
      (sum, item) =>
          sum + (int.tryParse(item['clqty']?.toString() ?? '0') ?? 0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            'Total Quantity:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              readOnly: true,
              controller: TextEditingController(text: total.toString()),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildActionButtons(
  String styleCode,
  List<String> shades,
  List<String> sizes,
) {
  return Padding(
    padding: const EdgeInsets.only(top: 14),
    child: Row(
      children: [
        // Update Button
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(Icons.update, size: 20, color: AppColors.primaryColor),
            label: Text(
              'Update',
              style: TextStyle(color: AppColors.primaryColor),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.transparent,
            ),
            onPressed: () => _updateStyle(styleCode, shades, sizes),
          ),
        ),
        SizedBox(width: 16),

        // Remove Button
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(Icons.delete, size: 20, color: Colors.grey),
            label: Text(
              'Remove',
              style: TextStyle(color: Colors.grey),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.transparent,
            ),
            onPressed: () => _removeStyle(styleCode),
          ),
        ),
      ],
    ),
  );
}

  void _updateStyle(String styleCode, List<String> shades, List<String> sizes) {
    // Implement update logic
    print('Updating style: $styleCode');
    _calculateTotals();
  }

  void _removeStyle(String styleCode) {
    setState(() {
      removedStyles.add(styleCode);
      groupedItems.remove(styleCode);
      controllers.remove(styleCode);
      _calculateTotals();
    });
  }

  void _updateTotals() {
    int newTotal = 0;
    for (var styleEntry in controllers.entries) {
      for (var shadeEntry in styleEntry.value.entries) {
        for (var sizeEntry in shadeEntry.value.entries) {
          newTotal += int.tryParse(sizeEntry.value.text) ?? 0;
        }
      }
    }
    totalQtyController.text = newTotal.toString();
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

  Widget buildDropdownSearch(String label, String ledCat, Function(String?, String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FutureBuilder<List<Map<String, String>>>(
        future: fetchLedgers(ledCat),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LinearProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            final items = snapshot.data!;
            if (ledCat == "w") partyList = items;

            String? selected;
            if (label == "Party Name") selected = selectedParty;
            else if (label == "Broker") selected = selectedBroker;
            else if (label == "Transporter") selected = selectedTransporter;

            return DropdownSearch<String>(
              items: items.map((e) => e['ledName']!).toList(),
              selectedItem: selected,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(),
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Search $label...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              onChanged: (val) {
                final selectedItem = items.firstWhere(
                  (e) => e['ledName'] == val,
                  orElse: () => {"ledKey": ""},
                );
                onChanged(val, selectedItem['ledKey']);
              },
            );
          }
        },
      ),
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: DrawerScreen(),
      appBar: AppBar(
        title: Text('View Order', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          bool isWideScreen = width > 600;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
               if (groupedItems.isNotEmpty)
                    ...groupedItems.entries
                        .map((entry) => _buildStyleCard(entry.key, entry.value))
                        .toList()
                  else
                    Center(child: CircularProgressIndicator()),  

                         SizedBox(width: 8),    
                              isWideScreen
                      ? Row(
                        children: [
                          Expanded(
                            child: buildTextField(
                              "Order No",
                              orderNoController,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: buildTextField(
                              "Select Date",
                              dateController,
                              isDate: true,
                            ),
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          buildTextField("Order No", orderNoController),
                          buildTextField(
                            "Select Date",
                            dateController,
                            isDate: true,
                          ),
                        ],
                      ),
                  // Party Dropdown with Add Button
                  Row(
                    children: [
                     Expanded(
  child: buildDropdownSearch("Party Name", "w", (val, key) async {
    selectedParty = val;
    selectedPartyKey = key;
    if (key != null) {
      try {
        final details = await fetchLedgerDetails(key);
        print('Party Details: $details'); // Debug log

        // Convert numeric keys to strings for comparison
        final partyBrokerKey = details['brokerKey']?.toString() ?? '';
        final partyTrspKey = details['trspKey']?.toString() ?? '';

        // Update broker only if not manually selected
        if ((selectedBrokerKey == null || selectedBrokerKey!.isEmpty) && 
            partyBrokerKey.isNotEmpty) {
          final broker = brokerList.firstWhere(
            (e) => e['ledKey'] == partyBrokerKey,
            orElse: () => {'ledName': ''},
          );
          if (broker['ledName'] != null) {
            selectedBroker = broker['ledName'];
            selectedBrokerKey = partyBrokerKey;
          }
        }

        // Update transporter only if not manually selected
        if ((selectedTransporterKey == null || selectedTransporterKey!.isEmpty) && 
            partyTrspKey.isNotEmpty) {
          final transporter = transporterList.firstWhere(
            (e) => e['ledKey'] == partyTrspKey,
            orElse: () => {'ledName': ''},
          );
          if (transporter['ledName'] != null) {
            selectedTransporter = transporter['ledName'];
            selectedTransporterKey = partyTrspKey;
          }
        }

        setState(() {});
      } catch (e) {
        print('Error fetching party details: $e');
      }
    }
  }),
),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _showCustomerMasterDialog(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                        child: Text('+ Add'),
                      ),
                    ],
                  ),

                  // Broker Dropdown
                  buildDropdownSearch("Broker", "B", (val, key) {
                    selectedBroker = val;
                    selectedBrokerKey = key;
                    setState(() {});
                  }),

                  // Commission Field
                  buildTextField("Comm (%)", commController),

                  // Transporter Dropdown
                  buildDropdownSearch("Transporter", "T", (val, key) {
                    selectedTransporter = val;
                    selectedTransporterKey = key;
                    setState(() {});
                  }),
                  isWideScreen
                      ? Row(
                        children: [
                          Expanded(
                            child: buildTextField(
                              "Delivery Days",
                              deliveryDaysController,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: buildTextField(
                              "Delivery Date",
                              deliveryDateController,
                              isDate: true,
                            ),
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          buildTextField(
                            "Delivery Days",
                            deliveryDaysController,
                          ),
                          buildTextField(
                            "Delivery Date",
                            deliveryDateController,
                            isDate: true,
                          ),
                        ],
                      ),
                  buildFullField("Remark", remarkController),
                  isWideScreen
                      ? Row(
                        children: [
                          Expanded(
                            child: buildTextField(
                              "Total Item",
                              totalItemController,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: buildTextField(
                              "Total Quantity",
                              totalQtyController,
                            ),
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          buildTextField("Total Item", totalItemController),
                          buildTextField("Total Quantity", totalQtyController),
                        ],
                      ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                              showDialog(
                          context: context,
                          builder: (context) => AddMoreInfoDialog(),
                        );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: Text(
                            'Add More Info',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Save logic
                            }
                          },
                          child: Text('Save'),
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height: 30),
                  // if (groupedItems.isNotEmpty)
                  //   ...groupedItems.entries
                  //       .map((entry) => _buildStyleCard(entry.key, entry.value))
                  //       .toList()
                  // else
                  //   Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }












  Widget buildRow(
    String label1,
    TextEditingController controller1,
    String label2,
    TextEditingController controller2,
  ) {
    return Row(
      children: [
        Expanded(child: buildTextField(label1, controller1)),
        SizedBox(width: 10),
        Expanded(child: buildTextField(label2, controller2, isDate: true)),
      ],
    );
  }

  Widget buildRowTextFieldWithAdd(
    String label,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _showCustomerMasterDialog(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
          child: Text('+ Add'),
        ),
      ],
    );
  }

  Widget buildFullField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: buildTextField(label, controller),
    );
  }



  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool isDate = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: isDate,
        onTap:
            isDate
                ? () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    controller.text =
                        "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                  }
                }
                : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
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
      ..style = PaintingStyle.stroke;

    // Draw main diagonal line
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, size.height),
      paint,
    );

  
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}