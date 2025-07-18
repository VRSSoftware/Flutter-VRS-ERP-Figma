import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerOrderDetailReportScreen extends StatelessWidget {
  final String customerName;
  final DateTime fromDate;
  final DateTime toDate;
  final List<Map<String, dynamic>> reportData;

  const CustomerOrderDetailReportScreen({
    super.key,
    required this.customerName,
    required this.fromDate,
    required this.toDate,
    required this.reportData,
  });

  @override
  Widget build(BuildContext context) {
    // Group data by ItemName + OrderNo + Color
    Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in reportData) {
      String key = '${item['ItemName']}_${item['OrderNo']}_${item['Color']}';
      groupedData.putIfAbsent(key, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Register - Party Wise'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VRS Software Pvt Ltd\n1234567890',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Date: ${DateFormat('dd-MM-yyyy').format(fromDate)} to ${DateFormat('dd-MM-yyyy').format(toDate)}',
              ),
              Divider(thickness: 2),
              Text(
                customerName.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 16),
              // Table
              Table(
                border: TableBorder.all(),
                columnWidths: {
                  0: FixedColumnWidth(30), // No
                  1: FlexColumnWidth(2),   // ItemName
                  2: FlexColumnWidth(1.5), // Order No.
                  3: FlexColumnWidth(1),   // Color
                  4: FixedColumnWidth(40),  // Size
                  5: FixedColumnWidth(50),  // Order Qty
                  6: FixedColumnWidth(50),  // Delv Qty
                  7: FixedColumnWidth(50),  // Settle Qty
                  8: FixedColumnWidth(50),  // Pend Qty
                },
                children: [
                  // Table Header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    children: [
                      Center(child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      Center(child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('ItemName', style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      Center(child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('Order No.', style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      Center(child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      Center(child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      Center(child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('Order Qty.', style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      Center(child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('Delv. Qty.', style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      Center(child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('Settle Qty.', style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      Center(child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('Pend. Qty.', style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                    ],
                  ),
                  // Table Data Rows
                  ...groupedData.entries.map((entry) {
                    final items = entry.value;
                    return List<TableRow>.generate(items.length, (index) {
                      final item = items[index];
                      return TableRow(
                        children: [
                          // No - only show on first row of group
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Center(
                              child: Text(index == 0 
                                ? (groupedData.keys.toList().indexOf(entry.key) + 1).toString() 
                                : ''),
                            ),
                          ),
                          // ItemName - only show on first row of group
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(index == 0 ? item['ItemName'] ?? '' : ''),
                          ),
                          // Order No - only show on first row of group
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(index == 0 ? item['OrderNo']?.split('\n').first ?? '' : ''),
                          ),
                          // Color - only show on first row of group
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(index == 0 ? item['Color'] ?? '' : ''),
                          ),
                          // Size
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Center(child: Text(item['Size']?.toString() ?? '')),
                          ),
                          // Order Qty
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Center(child: Text(item['OrderQty']?.toString() ?? '0')),
                          ),
                          // Delv Qty
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Center(child: Text(item['DelvQty']?.toString() ?? '0')),
                          ),
                          // Settle Qty
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Center(child: Text(item['SettleQty']?.toString() ?? '0')),
                          ),
                          // Pend Qty
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Center(child: Text(item['PendingQty']?.toString() ?? '0')),
                          ),
                        ],
                      );
                    });
                  }).expand((i) => i),
                  // Total Row
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Center(child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(''),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(''),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(''),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(''),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Center(
                          child: Text(
                            reportData.fold<int>(0, (sum, item) => sum + (item['OrderQty'] as int? ?? 0)).toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Center(
                          child: Text(
                            reportData.fold<int>(0, (sum, item) => sum + (item['DelvQty'] as int? ?? 0)).toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Center(
                          child: Text(
                            reportData.fold<int>(0, (sum, item) => sum + (item['SettleQty'] as int? ?? 0)).toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Center(
                          child: Text(
                            reportData.fold<int>(0, (sum, item) => sum + (item['PendingQty'] as int? ?? 0)).toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}