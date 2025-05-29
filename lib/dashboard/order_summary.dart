import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  DateTime fromDate = DateTime(2025, 1, 1);
  DateTime toDate = DateTime(2025, 12, 31);
  String selectedRange = 'This Year';

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? fromDate : toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Summary',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: selectedRange,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: <String>['Custom', 'Today', 'This Week','This Month',
                                        'This Quarter', 'This Year', 'Yesterday','Previous Week'
                                        'Previous Month','Previous Quarter','Previous Year']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRange = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'From Date',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _selectDate(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${fromDate.day.toString().padLeft(2, '0')}/${fromDate.month.toString().padLeft(2, '0')}/${fromDate.year}',
                                        ),
                                        const Icon(Icons.calendar_today,
                                            size: 20, color: Colors.grey),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                    'To Date',
                                    style: TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _selectDate(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${toDate.day.toString().padLeft(2, '0')}/${toDate.month.toString().padLeft(2, '0')}/${toDate.year}',
                                        ),
                                        const Icon(Icons.calendar_today,
                                            size: 20, color: Colors.grey),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // First Row of Cards
            Row(
              children: [
                Expanded(
                  child: _buildOrderCard('TOTAL ORDER', '0', '0', true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOrderCard('PENDING ORDER', '0', '0', true),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Second Row of Cards
            Row(
              children: [
                Expanded(
                  child: _buildOrderCard('PACKED ORDER', '0', '0', true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOrderCard('CANCELED ORDER', '0', '0', true),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Third Row of Cards
            Row(
              children: [
                Expanded(
                  child: _buildOrderCard('INVOICED ORDER', '0', '0', true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(), // Empty container for balance
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Inventory Summary Section
            const Text(
              'Inventory Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildOrderCard('IN HAND', '4305', '0', false),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOrderCard('TO BE RECEIVED', '14', '0', false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(String title, String value, String qty, bool showQty) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showQty) ...[
              const SizedBox(height: 4),
              Text(
                'Qty: $qty',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}