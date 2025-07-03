import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/CatalogOrderData.dart';
import 'package:vrs_erp_figma/models/OrderMatrix.dart';
import 'package:vrs_erp_figma/models/catalog.dart';
import 'package:vrs_erp_figma/viewOrder/editViewOrder/customer_detail_barcode2.dart';
import 'package:vrs_erp_figma/viewOrder/editViewOrder/transaction_barcode2.dart';

class EditOrderBarcode2 extends StatefulWidget {
  final String docId;

  const EditOrderBarcode2({super.key, required this.docId});

  @override
  State<EditOrderBarcode2> createState() => _EditOrderBarcode2State();
}

class _EditOrderBarcode2State extends State<EditOrderBarcode2>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isOrderItemsLoaded = false;

  List<CatalogOrderData> orderData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchOrderItems(doc_Id: widget.docId);
  }

  /// ✅ Fetch Order Items API
  Future<void> fetchOrderItems({required String doc_Id}) async {
    if (doc_Id != '-1') {
      try {
        final response = await http.post(
          Uri.parse('${AppConstants.BASE_URL}/orderRegister/editOrderData'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({"doc_id": doc_Id}),
        );

        print(
            'Fetch API Response: ${response.statusCode}, Body: ${response.body}');

        if (response.statusCode == 200) {
          final items = json.decode(response.body);
          if (items is List && items.isNotEmpty) {
            final groupedByStyle = <String, List<dynamic>>{};
            for (var item in items) {
              final styleCode = item['styleCode']?.toString() ?? 'No Style Code';
              groupedByStyle.putIfAbsent(styleCode, () => []).add(item);
            }

            setState(() {
              orderData = groupedByStyle.entries.map((entry) {
                final catalogOrder =
                    _convertToCatalogOrderData(entry.key, entry.value);
                print(
                    'Fetched style: ${entry.key}, Matrix: ${catalogOrder.orderMatrix.matrix}');
                return catalogOrder;
              }).toList();
              isOrderItemsLoaded = true;
            });
          } else {
            print('No items found');
            setState(() {
              orderData = [];
              isOrderItemsLoaded = true;
            });
          }
        } else {
          print('API Error');
          setState(() {
            orderData = [];
            isOrderItemsLoaded = true;
          });
        }
      } catch (e) {
        print('Error fetching order items: $e');
        setState(() {
          orderData = [];
          isOrderItemsLoaded = true;
        });
      }
    }
  }

  /// ✅ Convert to CatalogOrderData
  CatalogOrderData _convertToCatalogOrderData(
    String styleKey,
    List<dynamic> items,
  ) {
    final shades = items
        .map((i) => i['shadeName']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    final sizes = items
        .map((i) => i['sizeName']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    final firstItem = items.first;

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
        final stkQty = item['data2']?.toString() ?? '0';
        final matrixEntry = '$mrp,$wsp,$qty,$stkQty';
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
      sizeDetailsWithoutWSp:
          sizes.map((s) => '$s (${firstItem['mrp']})').join(','),
      sizeWithMrp: sizes.map((s) => '$s (${firstItem['mrp']})').join(','),
      styleCodeWithcount: styleKey,
      onlySizes: sizes.join(','),
      sizeWithWsp: sizes.map((s) => '$s (${firstItem['wsp']})').join(','),
      createdDate: '',
      shadeImages: '',
      upcoming_Stk: firstItem['upcoming_Stk']?.toString() ?? '0',
      barcode: firstItem['barcode']?.toString() ?? '',
    );

    return CatalogOrderData(
      catalog: catalog,
      orderMatrix: OrderMatrix(shades: shades, sizes: sizes, matrix: matrix),
    );
  }

  /// ✅ UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Total: ₹${_calculateTotalAmount().toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _divider(),
                    Flexible(
                      child: Text(
                        'Items: ${_calculateTotalItems()}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _divider(),
                    Flexible(
                      child: Text(
                        'Qty: ${_calculateTotalQuantity()}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Transactions'),
                  Tab(text: 'Customer Details'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TransactionBarcode2(orderData: orderData),
          CustomerDetailBarcode2(orderData: orderData),
        ],
      ),
    );
  }

  /// ✅ Divider widget
  Widget _divider() {
    return Container(
      width: 1,
      height: 20,
      color: Colors.white.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }

  /// ✅ Calculation Functions
  double _calculateTotalAmount() {
    return orderData.fold(
        0.0, (sum, item) => sum + (item.catalog.mrp * item.catalog.clqty));
  }

  int _calculateTotalItems() {
    return orderData.length;
  }

  double _calculateTotalQuantity() {
    return orderData.fold(0.0, (sum, item) => sum + item.catalog.clqty);
  }
}
