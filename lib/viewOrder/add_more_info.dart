import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/models/salesman.dart';
import 'package:vrs_erp_figma/services/app_services.dart';
import 'package:vrs_erp_figma/models/consignee.dart';  // Ensure it's the correct file

class AddMoreInfoDialog extends StatefulWidget {
   final String? ledKey; 
  final String? pytTermDiscKey;
  final String? salesPersonKey;
  final int? creditPeriod;
  final String? salesLedKey;
  final String? ledgerName;
  final Function(Map<String, dynamic>) onValueChanged;

  const AddMoreInfoDialog({
    super.key,
    this.ledKey, 
    this.pytTermDiscKey,
    this.salesPersonKey,
    this.creditPeriod,
    this.salesLedKey,
    this.ledgerName,
    required this.onValueChanged,
  });

  @override
  _AddMoreInfoDialogState createState() => _AddMoreInfoDialogState();
}

class _AddMoreInfoDialogState extends State<AddMoreInfoDialog> {
  late DateTime _baseDate;
Consignee? selectedConsignee;
  String? selectedPaymentTerms;
  String? selectedBookingType;

  final TextEditingController paymentDaysController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController referenceNoController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  List<PytTermDisc> _paymentTerms = [];
  List<Salesman> _salesmen = [];
  
   List<Consignee> consignees = []; 
  bool _isLoadingPaymentTerms = false;
  bool _isLoadingSalesmen = false;
  String? _selectedPytTermDiscKey;
  String? _selectedSalesmanKey;
  String? selectedSalesmanName;

  void _sendValueToParent(Map<String, dynamic> formData) {
    // widget.onValueChanged(formData['referenceNo'] , formData['dueDate']); 
    widget.onValueChanged(formData); 
  }

  @override
  void initState() {
    super.initState();
     fetchAndMapConsignees(key: '0190', CoBrId: '01');
    _baseDate = DateTime.now();
    paymentDaysController.text = widget.creditPeriod?.toString() ?? '0';
    dateController.text = _formatDate(_baseDate);
    _loadPaymentTerms();
    _loadSalesmen();
    _updateDueDate();
    paymentDaysController.addListener(_updateDueDate);
    dueDateController.addListener(_updatePaymentDays);

  }

void fetchAndMapConsignees({
  required String key,
  required String CoBrId,
}) async {
  try {
    Map<String, dynamic> responseMap = await ApiService.fetchConsinees(
      key: key,
      CoBrId: CoBrId,
    );

    if (responseMap['statusCode'] == 200) {
      setState(() {
        consignees = (responseMap['result'] as List).cast<Consignee>();
      });
      print('Loaded ${consignees.length} consignees');
    } else {
      print('API Error: ${responseMap['statusCode']}');
    }
  } catch (e) {
    print('Error fetching consignees: $e');
  }
}

  Future<void> _loadPaymentTerms() async {
    setState(() => _isLoadingPaymentTerms = true);
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.BASE_URL}/users/getPytTermDisc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"coBrId": "01"}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        _paymentTerms =
            data
                .map(
                  (e) => PytTermDisc(
                    key: e['pytTermDiscKey']?.toString() ?? '',
                    name: e['pytTermDiscName']?.toString() ?? '',
                  ),
                )
                .toList();

        if (widget.pytTermDiscKey != null && _paymentTerms.isNotEmpty) {
          final initialTerm = _paymentTerms.firstWhere(
            (term) => term.key == widget.pytTermDiscKey,
            orElse: () => PytTermDisc(key: '', name: ''),
          );
          if (initialTerm.key.isNotEmpty) {
            _selectedPytTermDiscKey = initialTerm.key;
            selectedPaymentTerms = initialTerm.name;
          }
        }
      }
    } catch (e) {
      print('Error loading payment terms: $e');
    } finally {
      setState(() => _isLoadingPaymentTerms = false);
    }
  }

  Future<void> _loadSalesmen() async {
    setState(() => _isLoadingSalesmen = true);
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.BASE_URL}/users/getSalesmanLedger'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"ledCat": "S", "coBrId": "01"}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        _salesmen =
            data
                .map(
                  (e) => Salesman(
                    key: e['ledKey']?.toString() ?? '',
                    name: e['ledgerName']?.toString() ?? '',
                  ),
                )
                .toList();

        if (widget.salesPersonKey != null && _salesmen.isNotEmpty) {
          final initialSalesman = _salesmen.firstWhere(
            (s) => s.key == widget.salesPersonKey,
            orElse: () => Salesman(key: '', name: ''),
          );
          if (initialSalesman.key.isNotEmpty) {
            _selectedSalesmanKey = initialSalesman.key;
            selectedSalesmanName = initialSalesman.name;
          }
        }
      }
    } catch (e) {
      print('Error loading salesmen: $e');
    } finally {
      setState(() => _isLoadingSalesmen = false);
    }
  }

  void _updateDueDate() {
    final days = int.tryParse(paymentDaysController.text) ?? 0;
    final newDueDate = _baseDate.add(Duration(days: days));
    dueDateController.text = _formatDate(newDueDate);
  }

  void _updatePaymentDays() {
    final dueDate = _parseDate(dueDateController.text);
    if (dueDate != null) {
      final difference = dueDate.difference(_baseDate).inDays;
      paymentDaysController.text = difference.toString();
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (e) {
      return null;
    }
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _parseDate(controller.text) ?? _baseDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          controller.text = _formatDate(picked);
          _baseDate = picked.subtract(
            Duration(days: int.tryParse(paymentDaysController.text) ?? 0),
          );
        }
      },
    );
  }

  Widget _buildPaymentTermsDropdown() {
    return DropdownSearch<PytTermDisc>(
      popupProps: PopupProps.menu(
        showSearchBox: true,
        itemBuilder:
            (context, item, isSelected) => ListTile(title: Text(item.name)),
      ),
      items: _paymentTerms,
      itemAsString: (item) => item.name,
      selectedItem: _paymentTerms.firstWhere(
        (e) => e.key == _selectedPytTermDiscKey,
        orElse: () => PytTermDisc(key: '', name: ''),
      ),
      onChanged: (value) {
        setState(() {
          _selectedPytTermDiscKey = value?.key;
          selectedPaymentTerms = value?.name;
        });
      },
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Payment Terms',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSalesmanDropdown() {
    return DropdownSearch<Salesman>(
      popupProps: PopupProps.menu(
        showSearchBox: true,
        itemBuilder:
            (context, item, isSelected) => ListTile(title: Text(item.name)),
      ),
      items: _salesmen,
      itemAsString: (item) => item.name,
      selectedItem: _salesmen.firstWhere(
        (e) => e.key == _selectedSalesmanKey,
        orElse: () => Salesman(key: '', name: ''),
      ),
      onChanged: (value) {
        setState(() {
          _selectedSalesmanKey = value?.key;
          selectedSalesmanName = value?.name;
        });
      },
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Salesman Name',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _saveFormData() {

    // Save the selected data here, this is just an example
    Map<String, dynamic> formData = {
      'consignee': {
      'key': selectedConsignee?.ledKey,
      'name': selectedConsignee?.ledName,
    
    },
      'paymentterms': _selectedPytTermDiscKey,
      'bookingtype': selectedBookingType,
      'paymentdays': paymentDaysController.text,
      'duedate': dueDateController.text,
      'refno': referenceNoController.text,
      'date': dateController.text,
      'salesman': selectedSalesmanName,
      'station' :'',
    };
 widget.onValueChanged(formData);
  Navigator.pop(context, formData);
    _sendValueToParent(formData);

    print('Form Data: $formData');
    // Handle the form submission logic here (e.g., send data to an API)
  }

  @override
  void dispose() {
    paymentDaysController.removeListener(_updateDueDate);
    dueDateController.removeListener(_updatePaymentDays);
    super.dispose();
  }

  Map<String, dynamic> _getDialogData() {
    return {
      'pytTermDiscKey': _selectedPytTermDiscKey,
      'salesPersonKey': _selectedSalesmanKey,
      'dueDate': dueDateController.text,
      'referenceNo': referenceNoController.text,
        'consignee': {
      'key': selectedConsignee?.ledKey,
      'name': selectedConsignee?.ledName,
    },
      'bookingType': selectedBookingType,
    };
  }
Widget _buildConsigneeDropdown() {
  return DropdownSearch<Consignee>(
    popupProps: PopupProps.menu(
      showSearchBox: true,
      itemBuilder: (context, item, isSelected) =>
          ListTile(title: Text(item.ledName ?? '')),
    ),
    items: consignees,
    itemAsString: (item) => item.ledName ?? '',
    selectedItem: selectedConsignee,
    onChanged: (value) {
      setState(() {
        selectedConsignee = value;
      });
    },
    dropdownDecoratorProps: DropDownDecoratorProps(
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Consignee',
        border: OutlineInputBorder(),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Add More Info",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context, _getDialogData()),
                  ),
                ],
              ),
              const SizedBox(height: 8),
             _buildConsigneeDropdown(),
              const SizedBox(height: 12),
              _isLoadingPaymentTerms
                  ? CircularProgressIndicator()
                  : _buildPaymentTermsDropdown(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      "Payment Days",
                      paymentDaysController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField("Due Date", dueDateController),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      "Reference No",
                      referenceNoController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDateField("Date", dateController)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child:
                        _isLoadingSalesmen
                            ? CircularProgressIndicator()
                            : _buildSalesmanDropdown(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      "Booking Type",
                      selectedBookingType,
                      [],
                      (val) {
                        setState(() => selectedBookingType = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // _sendValueToParent();
                      _saveFormData();
                      //Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
                    ),
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

class PytTermDisc {
  final String key;
  final String name;

  PytTermDisc({required this.key, required this.name});
}

