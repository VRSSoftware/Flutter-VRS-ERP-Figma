import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:vrs_erp_figma/viewOrder/customer_master.dart';


class ViewOrderScreen extends StatefulWidget {
  @override
  _ViewOrderScreenState createState() => _ViewOrderScreenState();
}

class _ViewOrderScreenState extends State<ViewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  List<dynamic> orderItems = [];
  Map<String, List<dynamic>> groupedItems = {};
  Map<String, Map<String, Map<String, int>>> modifiedQuantities = {};
  Map<String, int> styleTotals = {};
  Set<String> removedStyles = {};

  // Controllers
  final TextEditingController orderNoController = TextEditingController(text: 'SO100');
  final TextEditingController dateController = TextEditingController(text: '22-04-2025');
  final TextEditingController partyController = TextEditingController();
  final TextEditingController brokerController = TextEditingController();
  final TextEditingController commController = TextEditingController();
  final TextEditingController transporterController = TextEditingController();
  final TextEditingController deliveryDaysController = TextEditingController();
  final TextEditingController deliveryDateController = TextEditingController(text: '22-04-2025');
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController totalItemController = TextEditingController(text: '0');
  final TextEditingController totalQtyController = TextEditingController(text: '0');

  List<String> transporterList = ['DHL', 'FedEx', 'Blue Dart', 'Gati'];
  String? selectedTransporter;

  @override
  void initState() {
    super.initState();
    fetchOrderItems();
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
        _initializeTotals();
      });
    } else {
      print('Failed to load order items');
    }
  }
void _initializeTotals() {
  int totalQty = 0;
  for (var style in groupedItems.keys) {
    int styleTotal = groupedItems[style]!.fold<int>(0, (sum, item) {
      // Handle item['clqty'] as a String and convert it to int
      var clqty = item['clqty'];
      int clqtyInt = 0;

      if (clqty != null) {
       
        if (clqty is String) {
          clqtyInt = int.tryParse(clqty) ?? 0; 
        } else if (clqty is num) {
          clqtyInt = clqty.toInt(); 
        }
      }

      return sum + clqtyInt;
    });
    styleTotals[style] = styleTotal;
    totalQty += styleTotal;
  }
  totalItemController.text = groupedItems.length.toString();
  totalQtyController.text = totalQty.toString();
}


  void groupItemsByStyle() {
    groupedItems = {};
    for (var item in orderItems) {
      String styleCode = item['styleCode'];
      if (removedStyles.contains(styleCode)) continue;
      if (!groupedItems.containsKey(styleCode)) {
        groupedItems[styleCode] = [];
      }
      groupedItems[styleCode]!.add(item);
    }
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

  Widget buildStyleCard(String styleCode, List<dynamic> items) {
    Map<String, dynamic> sizes = {};
    Set<String> shades = {};
    Map<String, TextEditingController> qtyControllers = {};

    for (var item in items) {
      String sizeName = item['sizeName'];
      if (!sizes.containsKey(sizeName)) {
        sizes[sizeName] = {'mrp': item['mrp'], 'wsp': item['wsp']};
      }
      shades.add(item['shadeName']);
    }

    List<String> sizeList = sizes.keys.toList();
    List<String> shadeList = shades.toList();

    for (var shade in shadeList) {
      for (var size in sizeList) {
        var item = items.firstWhere(
          (i) => i['shadeName'] == shade && i['sizeName'] == size,
          orElse: () => null,
        );

        if (item != null) {
          int qty = _getModifiedQty(styleCode, shade, size) ?? item['clqty'] ?? 0;
          qtyControllers['$shade-$size'] = TextEditingController(text: qty.toString());
        }
      }
    }

    var firstItem = items.first;
    int currentTotal = styleTotals[styleCode] ?? 0;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(_getImageUrl(firstItem["fullImagePath"] ?? "")),
            SizedBox(height: 10),
            Text(
              styleCode,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: {0: FixedColumnWidth(60)},
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Size", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...sizeList.map((size) => Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(size, textAlign: TextAlign.center),
                    )),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("MRP", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...sizeList.map((size) => Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(sizes[size]['mrp'].toString(), textAlign: TextAlign.center),
                    )),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("WSP", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...sizeList.map((size) => Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(sizes[size]['wsp'].toString(), textAlign: TextAlign.center),
                    )),
                  ],
                ),
                ...shadeList.map((shade) => TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text(shade)),
                    ...sizeList.map((size) {
                      String key = '$shade-$size';
                      return Padding(
                        padding: EdgeInsets.all(4),
                        child: TextField(
                          controller: qtyControllers[key],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: '0',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                )),
              ],
            ),
            SizedBox(height: 10),
            Text("Note: ${firstItem["note"] ?? ''}"),
            SizedBox(height: 8),
            Row(
              children: [
                Text("TotQty: "),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: TextEditingController(text: currentTotal.toString()),
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStyleQuantities(styleCode, shadeList, sizeList, qtyControllers),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                    child: Text("Update", style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _removeStyle(styleCode),
                    style: ElevatedButton.styleFrom(backgroundColor:Colors.blueGrey),
                    child: Text("Remove", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int? _getModifiedQty(String styleCode, String shade, String size) {
    return modifiedQuantities[styleCode]?[shade]?[size];
  }

  void _updateStyleQuantities(
    String styleCode,
    List<String> shadeList,
    List<String> sizeList,
    Map<String, TextEditingController> qtyControllers,
  ) {
    Map<String, Map<String, int>> shadeMap = {};
    int newTotal = 0;

    for (var shade in shadeList) {
      Map<String, int> sizeMap = {};
      for (var size in sizeList) {
        String key = '$shade-$size';
        TextEditingController? controller = qtyControllers[key];
        if (controller != null) {
          int qty = int.tryParse(controller.text) ?? 0;
          sizeMap[size] = qty;
          newTotal += qty;
        }
      }
      shadeMap[shade] = sizeMap;
    }

    setState(() {
      modifiedQuantities[styleCode] = shadeMap;
      styleTotals[styleCode] = newTotal;
      totalQtyController.text = styleTotals.values.fold(0, (a, b) => a + b).toString();
    });
  }

  void _removeStyle(String styleCode) {
    setState(() {
      removedStyles.add(styleCode);
      groupItemsByStyle();
      styleTotals.remove(styleCode);
      modifiedQuantities.remove(styleCode);
      totalItemController.text = groupedItems.length.toString();
      totalQtyController.text = styleTotals.values.fold(0, (a, b) => a + b).toString();
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    drawer: DrawerScreen(),
    appBar: AppBar(
      title: Text('View Order', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.deepPurple,
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
                isWideScreen
                    ? Row(
                        children: [
                          Expanded(child: buildTextField("Order No", orderNoController)),
                          SizedBox(width: 10),
                          Expanded(child: buildTextField("Select Date", dateController, isDate: true)),
                        ],
                      )
                    : Column(
                        children: [
                          buildTextField("Order No", orderNoController),
                          buildTextField("Select Date", dateController, isDate: true),
                        ],
                      ),
                buildRowTextFieldWithAdd("Party", partyController),
                isWideScreen
                    ? Row(
                        children: [
                          Expanded(child: buildTextField("Broker", brokerController)),
                          SizedBox(width: 10),
                          Expanded(child: buildTextField("Comm (%)", commController)),
                        ],
                      )
                    : Column(
                        children: [
                          buildTextField("Broker", brokerController),
                          buildTextField("Comm (%)", commController),
                        ],
                      ),
                buildTransporterDropdown(),
                isWideScreen
                    ? Row(
                        children: [
                          Expanded(child: buildTextField("Delivery Days", deliveryDaysController)),
                          SizedBox(width: 10),
                          Expanded(child: buildTextField("Delivery Date", deliveryDateController, isDate: true)),
                        ],
                      )
                    : Column(
                        children: [
                          buildTextField("Delivery Days", deliveryDaysController),
                          buildTextField("Delivery Date", deliveryDateController, isDate: true),
                        ],
                      ),
                buildFullField("Remark", remarkController),
                isWideScreen
                    ? Row(
                        children: [
                          Expanded(child: buildTextField("Total Item", totalItemController)),
                          SizedBox(width: 10),
                          Expanded(child: buildTextField("Total Quantity", totalQtyController)),
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                        child: Text('Add More Info', style: TextStyle(color: Colors.white)),
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
                SizedBox(height: 30),
                if (groupedItems.isNotEmpty)
                  ...groupedItems.entries.map((entry) => buildStyleCard(entry.key, entry.value)).toList()
                else
                  Center(child: CircularProgressIndicator()),
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

  Widget buildTransporterDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedTransporter,
        decoration: InputDecoration(
          labelText: 'Transporter',
          border: OutlineInputBorder(),
        ),
        items:
            transporterList.map((String transporter) {
              return DropdownMenuItem<String>(
                value: transporter,
                child: Text(transporter),
              );
            }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedTransporter = newValue;
            transporterController.text = newValue ?? '';
          });
        },
      ),
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
