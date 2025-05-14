import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/catalog.dart';


class CreateOrderScreen extends StatefulWidget {
  final List<Catalog> catalogs;

  const CreateOrderScreen({Key? key, required this.catalogs}) : super(key: key);

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
   List<Catalog> updatedCatalogList = [];
  final List<String> items = [
    'Red',
    'Blue',
    'Black',
    'Green',
    'Yellow',
    'White',
    'Pink',
  ];
    @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }
    Future<void> _loadOrderDetails() async {
    List<Catalog> tempList = [];

    for (var item in widget.catalogs) {
      final payload = {
        "itemSubGrpKey": item.itemSubGrpKey,
        "itemKey": item.itemKey,
        "styleKey": item.styleKey,
        "userId": "Admin",
        "coBrId": "01",
        "fcYrId": "24"
      };

      final response = await http.post(
        Uri.parse('${AppConstants.BASE_URL}/api/v1/catalog/GetOrderDetails'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        for (var entry in data) {
          tempList.add(
            Catalog(
              itemSubGrpKey: item.itemSubGrpKey,
              itemSubGrpName: item.itemSubGrpName,
              itemKey: item.itemKey,
              itemName: item.itemName,
              brandKey: item.brandKey,
              brandName: item.brandName,
              styleKey: item.styleKey,
              styleCode: entry['styleCode'] ?? item.styleCode,
              shadeKey: item.shadeKey,
              shadeName: entry['shadeName'] ?? '',
              styleSizeId: item.styleSizeId,
              sizeName: entry['sizeName'] ?? '',
              mrp: (entry['mrp'] ?? 0).toDouble(),
              wsp: (entry['wsp'] ?? 0).toDouble(),
              onlyMRP: (entry['mrp'] ?? 0).toDouble(),
              clqty: 0,
              fullImagePath: item.fullImagePath,
              remark: item.remark,
              imageId: item.imageId,
            ),
          );
        }
      }
    }

    setState(() {
      updatedCatalogList = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Order Booking', style: TextStyle(color: Colors.white)),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.signal_cellular_alt),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('Total : ₹402.00', style: TextStyle(color: Colors.white)),
              VerticalDivider(color: Colors.white),
              Text('Total Item : 1', style: TextStyle(color: Colors.white)),
              VerticalDivider(color: Colors.white, thickness: 2),
              Text('Total Qty : 332', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text('LK00001'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          // Add copy logic
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Rate',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Boys Jeans (102)'),
              subtitle: const Text('Total Qty: 332\nWip Stock: 0\nPending Qty: 0'),
              trailing: Image.network(
                '${AppConstants.BASE_URL}/images/NoImage.jpg',
              ),
            ),
            const Divider(),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: items.map((color) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(color, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
            ),
            const Divider(),
            _buildColorSection('BLACK'),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 15),
            _buildColorSection('BLUE'),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () {}, child: const Text('BACK')),
              TextButton(onPressed: () {}, child: const Text('SAVE')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSection(String color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(color, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [Text('Quantity : 0'), Text('Price : 0')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Size", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.remove, color: Colors.transparent),
                ),
                const Text("Qty", style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.transparent),
                ),
              ],
            ),
            const Text("Rate", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("WIP", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("Stock", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        _buildSizeRow(24, 10, 1099, 0, -2),
        _buildSizeRow(26, 10, 1099, 0, -2),
        _buildSizeRow(28, 10, 1099, 0, -2),
        _buildSizeRow(30, 10, 1099, 0, 0),
        _buildSizeRow(32, 10, 1099, 0, 0),
        _buildSizeRow(34, 10, 1099, 0, 2),
      ],
    );
  }

  Widget _buildSizeRow(int size, int qty, int rate, int wip, int stock) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(size.toString()),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.remove)),
              Text(qty.toString()),
              IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
            ],
          ),
          Text(rate.toString()),
          Text(wip.toString()),
          Text(stock.toString()),
        ],
      ),
    );
  }
}
