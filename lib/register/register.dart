import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:vrs_erp_figma/models/registerModel.dart';
import 'package:vrs_erp_figma/models/keyName.dart';
import 'package:vrs_erp_figma/register/registerFilteration.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/services/app_services.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isLoading = false;
  List<RegisterOrder> registerOrderList = [];
  DateTime? fromDate;
  DateTime? toDate;
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  KeyName? selectedLedger;
  KeyName? selectedSalesperson;
  List<KeyName> ledgerList = [];
  List<KeyName> salespersonList = [];
  bool isLoadingLedgers = true;
  bool isLoadingSalesperson = true;
  Map<String, bool> checkedOrders = {}; // Map to track checkbox state by orderNo

  @override
  void initState() {
    super.initState();
    fromDate = DateTime.now().subtract(Duration(days: 30));
    toDate = DateTime.now();
    fromDateController.text = DateFormat('yyyy-MM-dd').format(fromDate!);
    toDateController.text = DateFormat('yyyy-MM-dd').format(toDate!);
    _loadDropdownData();
    fetchOrders();
  }

  Future<void> _loadDropdownData() async {
    setState(() {
      isLoadingLedgers = true;
      isLoadingSalesperson = true;
    });

    try {
      final fetchedLedgersResponse = await ApiService.fetchLedgers(ledCat: 'w', coBrId: '01');
      final fetchedSalespersonResponse = await ApiService.fetchLedgers(ledCat: 's', coBrId: '01');

      setState(() {
        ledgerList = List<KeyName>.from(fetchedLedgersResponse['result'] ?? []);
        salespersonList = List<KeyName>.from(fetchedSalespersonResponse['result'] ?? []);
        isLoadingLedgers = false;
        isLoadingSalesperson = false;
      });
    } catch (e) {
      setState(() {
        isLoadingLedgers = false;
        isLoadingSalesperson = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dropdown data: $e')),
      );
    }
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });
    try {
      final orders = await ApiService.fetchOrderRegister(
        fromDate: fromDateController.text,
        toDate: toDateController.text,
        custKey: selectedLedger?.key,
        coBrId: '01',
        salesPerson: selectedSalesperson?.key,
        status: null,
        dlvFromDate: null,
        dlvToDate: null,
        userName: 'Admin',
        lastSavedOrderId: null,
      );
      setState(() {
        registerOrderList = orders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching orders: $e')),
      );
    }
  }

  double _calculateTotalAmount() {
    return registerOrderList.fold(0.0, (sum, registerOrder) => sum + registerOrder.amount);
  }

  int _calculateTotalQuantity() {
    return registerOrderList.fold(0, (sum, registerOrder) => sum + registerOrder.quantity);
  }

  void _submitRegisterOrders() {
    // Handle register submission logic
  }

  Widget buildOrderItem(RegisterOrder registerOrder) {
    // Initialize checkbox state for this order if not already set
    checkedOrders.putIfAbsent(registerOrder.orderNo, () => false);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 24,
                    child: Marquee(
                      text: registerOrder.itemName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      blankSpace: 20.0,
                      velocity: 50.0,
                      pauseAfterRound: const Duration(seconds: 1),
                      startPadding: 10.0,
                      accelerationDuration: const Duration(seconds: 1),
                      accelerationCurve: Curves.linear,
                      decelerationDuration: const Duration(milliseconds: 500),
                      decelerationCurve: Curves.easeOut,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black54),
                  onSelected: (value) {
                    switch (value) {
                      case 'checkbox':
                        setState(() {
                          checkedOrders[registerOrder.orderNo] = !checkedOrders[registerOrder.orderNo]!;
                        });
                        break;
                      case 'whatsapp':
                        // Implement WhatsApp sharing logic
                        break;
                      case 'download':
                        // Implement download logic
                        break;
                      case 'view':
                        // Implement view logic
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'checkbox',
                      child: Row(
                        children: [
                          Checkbox(
                            value: checkedOrders[registerOrder.orderNo],
                            onChanged: (bool? value) {
                              setState(() {
                                checkedOrders[registerOrder.orderNo] = value ?? false;
                              });
                              Navigator.pop(context);
                            },
                            activeColor: AppColors.primaryColor,
                            checkColor: Colors.white,
                            side: BorderSide(color: AppColors.primaryColor),
                          ),
                          const SizedBox(width: 8),
                          Text('with image', style: GoogleFonts.poppins(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'whatsapp',
                      child: Row(
                        children: [
                          Icon(Icons.message, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text('WhatsApp', style: GoogleFonts.poppins(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text('Download', style: GoogleFonts.poppins(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.purple, size: 20),
                          const SizedBox(width: 8),
                          Text('View', style: GoogleFonts.poppins(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Colors.white,
                  elevation: 4,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    registerOrder.orderNo,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    registerOrder.city,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: registerOrder.deliveryType == 'Approved'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    registerOrder.deliveryType,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: registerOrder.deliveryType == 'Approved' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Date:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '${registerOrder.orderDate} ${registerOrder.createdTime}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Quantity:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '${registerOrder.quantity}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Amount:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '₹${registerOrder.amount.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                if (registerOrder.salesPersonName.isNotEmpty)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          'Salesperson:',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          registerOrder.salesPersonName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
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
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, DateTime? initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (controller == fromDateController) {
          fromDate = picked;
          controller.text = DateFormat('yyyy-MM-dd').format(picked);
        } else if (controller == toDateController) {
          toDate = picked;
          controller.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
      fetchOrders();
    }
  }

  Widget _buildDateInput(TextEditingController controller, String label, DateTime? date) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF87898A)),
        floatingLabelStyle: TextStyle(color: AppColors.primaryColor),
        hintStyle: const TextStyle(color: Color(0xFF87898A)),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today, color: AppColors.primaryColor),
          onPressed: () => _selectDate(context, controller, date),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.secondaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Register',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.receipt_long),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Column(
            children: [
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Total: ₹${_calculateTotalAmount().toStringAsFixed(2)}',
                    style: GoogleFonts.roboto(color: Colors.white),
                  ),
                  const VerticalDivider(color: Colors.white),
                  Text(
                    'Total Orders: ${registerOrderList.length}',
                    style: GoogleFonts.roboto(color: Colors.white),
                  ),
                  const VerticalDivider(color: Colors.white, thickness: 2),
                  Text(
                    'Total Qty: ${_calculateTotalQuantity()}',
                    style: GoogleFonts.roboto(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Stack(
              children: [
                Container(color: Colors.black.withOpacity(0.2)),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateInput(fromDateController, 'From Date', fromDate),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDateInput(toDateController, 'To Date', toDate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  ...registerOrderList.map(
                    (order) => Column(
                      children: [
                        buildOrderItem(order),
                        const Divider(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('BACK', style: GoogleFonts.montserrat()),
              ),
              TextButton(
                onPressed: _calculateTotalQuantity() > 0 ? _submitRegisterOrders : null,
                child: Text(
                  'SUBMIT',
                  style: GoogleFonts.montserrat(
                    color: _calculateTotalQuantity() > 0 ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => RegisterFilterPage(),
                settings: RouteSettings(
                  arguments: {
                    'ledgerList': ledgerList,
                    'salespersonList': salespersonList,
                    'selectedLedger': selectedLedger,
                    'selectedSalesperson': selectedSalesperson,
                  },
                ),
                transitionDuration: Duration(milliseconds: 500),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return ScaleTransition(
                    scale: animation,
                    alignment: Alignment.bottomRight,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
              ),
            );
            if (result != null) {
              setState(() {
                selectedLedger = result['ledger'];
                selectedSalesperson = result['salesperson'];
              });
              fetchOrders();
            }
          },
          child: const Icon(Icons.filter_list, color: Colors.white),
          tooltip: 'Filter Orders',
        ),
      ),
    );
  }
}