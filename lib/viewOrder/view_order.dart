// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:vrs_erp/constants/app_constants.dart';
// import 'package:vrs_erp/screens/drawer_screen.dart';
// import 'package:vrs_erp/viewOrder/customer_master.dart';

// class ViewOrderScreen extends StatefulWidget {
//   @override
//   _ViewOrderScreenState createState() => _ViewOrderScreenState();
// }

// class _ViewOrderScreenState extends State<ViewOrderScreen> {
//   final _formKey = GlobalKey<FormState>();
//   List<dynamic> orderItems = [];

//   // Controllers
//   final TextEditingController orderNoController = TextEditingController(
//     text: 'SO100',
//   );
//   final TextEditingController dateController = TextEditingController(
//     text: '22-04-2025',
//   );
//   final TextEditingController partyController = TextEditingController();
//   final TextEditingController brokerController = TextEditingController();
//   final TextEditingController commController = TextEditingController();
//   final TextEditingController transporterController = TextEditingController();
//   final TextEditingController deliveryDaysController = TextEditingController();
//   final TextEditingController deliveryDateController = TextEditingController(
//     text: '22-04-2025',
//   );
//   final TextEditingController remarkController = TextEditingController();
//   final TextEditingController totalItemController = TextEditingController(
//     text: '11',
//   );
//   final TextEditingController totalQtyController = TextEditingController(
//     text: '367',
//   );

//   List<String> transporterList = ['DHL', 'FedEx', 'Blue Dart', 'Gati'];
//   String? selectedTransporter;

//   @override
//   void initState() {
//     super.initState();
//     fetchOrderItems();
//   }

//   Future<void> fetchOrderItems() async {
//     final url = Uri.parse('${AppConstants.BASE_URL}/orderBooking/GetViewOrder');

//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         "coBrId": "01",
//         "userId": "Admin",
//         "fcYrId": "24",
//         "barcode": "false",
//       }),
//     );
//     print("response body:${response.body}");
//     if (response.statusCode == 200) {
//       setState(() {
//         orderItems = json.decode(response.body);
//       });
//     } else {
//       print('Failed to load order items');
//     }
//   }

//   void _showCustomerMasterDialog(BuildContext context) {
//     showDialog(context: context, builder: (_) => CustomerMasterDialog());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: DrawerScreen(),
//       appBar: AppBar(
//         title: Text('View Order', style: TextStyle(color: Colors.white)),
//         backgroundColor: AppColors.violet,
//         elevation: 1,
//         leading: Builder(
//           builder:
//               (context) => IconButton(
//                 icon: Icon(Icons.menu, color: Colors.white),
//                 onPressed: () => Scaffold.of(context).openDrawer(),
//               ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               buildRow(
//                 "Order No",
//                 orderNoController,
//                 "Select Date",
//                 dateController,
//               ),
//               buildRowDropdownWithAdd("Party", partyController),
//               buildRow("Broker", brokerController, "Comm (%)", commController),
//               buildTransporterDropdown(),
//               buildRow(
//                 "Delivery Days",
//                 deliveryDaysController,
//                 "Delivery Date",
//                 deliveryDateController,
//               ),
//               buildFullField("Remark", remarkController),
//               buildRow(
//                 "Total Item",
//                 totalItemController,
//                 "Total Quantity",
//                 totalQtyController,
//               ),
//               SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.violet,
//                         foregroundColor: Colors.white,
//                       ),
//                       child: Text('Add More Info'),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (_formKey.currentState!.validate()) {
//                           // Save logic
//                         }
//                       },
//                       child: Text('Save'),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 30),
//               if (orderItems.isNotEmpty)
//                 ...orderItems.map((item) => buildItemCard(item)).toList()
//               else
//                 Center(child: CircularProgressIndicator()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildItemCard(dynamic item) {
//     List<String> sizes = [
//       "28",
//       "30",
//       "32",
//       "34",
//       "36",
//     ]; // Replace with item["sizes"] if dynamic
//     List<String> colors = [
//       "Yellow",
//       "Red",
//     ]; // Replace with item["colors"] if dynamic

//     Map<String, TextEditingController> qtyControllers = {};

//     for (var color in colors) {
//       for (var size in sizes) {
//         qtyControllers['$color-$size'] = TextEditingController();
//       }
//     }

//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 12),
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Align(
//               alignment: Alignment.topRight,
//               child: Icon(Icons.close, size: 20, color: Colors.grey),
//             ),
//             Row(
//               children: [
//                 Image.network(
//                   '${AppConstants.BASE_URL}${item["fullImagePath"]}',
//                   height: 80,
//                   width: 80,
//                   errorBuilder:
//                       (context, error, stackTrace) => Icon(Icons.image),
//                 ),
//                 SizedBox(width: 12),
//                 Text(
//                   item["styleCode"] ?? '',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.blue,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             Table(
//               border: TableBorder.all(color: Colors.grey),
//               columnWidths: {0: FixedColumnWidth(60)},
//               children: [
//                 TableRow(
//                   children: [
//                     SizedBox(),
//                     ...sizes.map(
//                       (s) => Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(s, textAlign: TextAlign.center),
//                       ),
//                     ),
//                   ],
//                 ),
//                 TableRow(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.all(8),
//                       child: Text(
//                         "MRP",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     ...sizes.map(
//                       (_) => Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           "${item["mrp"]}",
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 TableRow(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.all(8),
//                       child: Text(
//                         "WSP",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     ...sizes.map(
//                       (_) => Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           "${item["wsp"]}",
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 ...colors.map((color) {
//                   return TableRow(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           color,
//                           style: TextStyle(
//                             color:
//                                 color == "Yellow" ? Colors.amber : Colors.red,
//                           ),
//                         ),
//                       ),
//                       ...sizes.map((size) {
//                         String key = '$color-$size';
//                         return Padding(
//                           padding: const EdgeInsets.all(4.0),
//                           child: TextField(
//                             controller: qtyControllers[key],
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               hintText: '0',
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ],
//                   );
//                 }).toList(),
//               ],
//             ),
//             SizedBox(height: 10),
//             Text("Note: ${item["note"] ?? ''}"),
//             SizedBox(height: 8),
//             Row(
//               children: [
//                 Text("TotQty: "),
//                 SizedBox(
//                   width: 100,
//                   child: TextFormField(
//                     initialValue: "${item['totQty']}",
//                     readOnly: true,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       isDense: true,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // handle update
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                     ),
//                     child: Text("Update"),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // handle remove
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.pink,
//                     ),
//                     child: Text("Remove"),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildRow(
//     String label1,
//     TextEditingController controller1,
//     String label2,
//     TextEditingController controller2,
//   ) {
//     return Row(
//       children: [
//         Expanded(child: buildTextField(label1, controller1)),
//         SizedBox(width: 10),
//         Expanded(child: buildTextField(label2, controller2, isDate: true)),
//       ],
//     );
//   }

//   Widget buildRowDropdownWithAdd(
//     String label,
//     TextEditingController controller,
//   ) {
//     return Row(
//       children: [
//         Expanded(
//           flex: 3,
//           child: TextField(
//             controller: controller,
//             decoration: InputDecoration(labelText: 'Party'),
//           ),
//         ),
//         SizedBox(width: 8),
//         ElevatedButton(
//           onPressed: () => _showCustomerMasterDialog(context),
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
//           child: Text('+ Add'),
//         ),
//       ],
//     );
//   }

//   Widget buildFullField(String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 12.0),
//       child: buildTextField(label, controller),
//     );
//   }

//   Widget buildTransporterDropdown() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: DropdownButtonFormField<String>(
//         value: selectedTransporter,
//         decoration: InputDecoration(
//           labelText: 'Transporter',
//           border: OutlineInputBorder(),
//         ),
//         items:
//             transporterList.map((String transporter) {
//               return DropdownMenuItem<String>(
//                 value: transporter,
//                 child: Text(transporter),
//               );
//             }).toList(),
//         onChanged: (String? newValue) {
//           setState(() {
//             selectedTransporter = newValue;
//             transporterController.text = newValue ?? '';
//           });
//         },
//       ),
//     );
//   }

//   Widget buildTextField(
//     String label,
//     TextEditingController controller, {
//     bool isDate = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         readOnly: isDate,
//         onTap:
//             isDate
//                 ? () async {
//                   DateTime? picked = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime(2100),
//                   );
//                   if (picked != null) {
//                     controller.text =
//                         "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
//                   }
//                 }
//                 : null,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/screens/drawer_screen.dart';
import 'package:vrs_erp_figma/viewOrder/add_more_info.dart';
import 'package:vrs_erp_figma/viewOrder/customer_master.dart';

class ViewOrderScreens extends StatefulWidget {
  @override
  _ViewOrderScreenState createState() => _ViewOrderScreenState();
}

class _ViewOrderScreenState extends State<ViewOrderScreens> {
  final _formKey = GlobalKey<FormState>();
  List<dynamic> orderItems = [];

  // Controllers
  final TextEditingController orderNoController = TextEditingController(
    text: 'SO100',
  );
  final TextEditingController dateController = TextEditingController(
    text: '22-04-2025',
  );
  final TextEditingController partyController = TextEditingController();
  final TextEditingController brokerController = TextEditingController();
  final TextEditingController commController = TextEditingController();
  final TextEditingController transporterController = TextEditingController();
  final TextEditingController deliveryDaysController = TextEditingController();
  final TextEditingController deliveryDateController = TextEditingController(
    text: '22-04-2025',
  );
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController totalItemController = TextEditingController(
    text: '11',
  );
  final TextEditingController totalQtyController = TextEditingController(
    text: '367',
  );

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
      });
    } else {
      print('Failed to load order items');
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
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildRow(
                "Order No",
                orderNoController,
                "Select Date",
                dateController,
              ),
              buildRowDropdownWithAdd("Party", partyController),
              buildRow("Broker", brokerController, "Comm (%)", commController),
              buildTransporterDropdown(),
              buildRow(
                "Delivery Days",
                deliveryDaysController,
                "Delivery Date",
                deliveryDateController,
              ),
              buildFullField("Remark", remarkController),
              buildRow(
                "Total Item",
                totalItemController,
                "Total Quantity",
                totalQtyController,
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
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Add More Info'),
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
              if (orderItems.isNotEmpty)
                ...orderItems.map((item) => buildItemCard(item)).toList()
              else
                Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItemCard(dynamic item) {
    // Get dynamic size and color information from the fetched data
    String size = item["sizeName"] ?? "Free"; // Single size as per your example
    String color =
        item["shadeName"] ?? "Unknown"; // Single color as per your example

    // Create a map of controllers for quantities (if needed later)
    Map<String, TextEditingController> qtyControllers = {
      '$color-$size': TextEditingController(),
    };

    // Build the item card
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display image based on the fullImagePath field
            if (item["fullImagePath"] != null)
              _buildImageSection(_getImageUrl(item["fullImagePath"])),

            const SizedBox(height: 10),

            // Display style code
            Text(
              item["styleCode"] ?? 'Unknown',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 10),

            // Display item name and brand
            Text(
              item["itemName"] ?? 'Item Name',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              item["brandName"] ?? 'Brand Name',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 10),

            // Display MRP and WSP
            Row(
              children: [
                Text(
                  "MRP: ${item["mrp"] ?? 'N/A'}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                Text(
                  "WSP: ${item["wsp"] ?? 'N/A'}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Display size and color
            Row(
              children: [
                Text(
                  "Size: $size",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                Text(
                  "Color: $color",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Display total quantity (TotQty)
            Row(
              children: [
                const Text("TotQty: "),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    initialValue: "${item['totQty'] ?? 0}",
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Display note if available
            if ((item["note"] ?? '').isNotEmpty) Text("Note: ${item["note"]}"),

            const SizedBox(height: 10),

            // Buttons for Update and Remove
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add update logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Text(
                      "Update",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add remove logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                    ),
                    child: const Text(
                      "Remove",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

  Widget buildRowDropdownWithAdd(
    String label,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Party'),
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
