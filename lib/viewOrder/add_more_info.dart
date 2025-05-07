import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/models/item.dart';
import 'package:vrs_erp_figma/services/app_services.dart';
import 'package:vrs_erp_figma/models/PytTermDisc.dart';
import 'package:vrs_erp_figma/models/salesman.dart';
import 'package:vrs_erp_figma/models/consignee.dart';

class AddMoreInfoDialog extends StatefulWidget {
  final List<Map<String, String>> salesPersonList;
  final String? partyLedKey;
  final String? pytTermDiscKey;
  final String? salesPersonKey;
  final int? creditPeriod;
  final String? salesLedKey;
  final String? ledgerName;
  final Map<String, dynamic>? additionalInfo;
  final List<Consignee> consignees;
  final List<PytTermDisc> paymentTerms;
  final Function(Map<String, dynamic>) onValueChanged;

  const AddMoreInfoDialog({
    super.key,
    required this.salesPersonList,
    required this.partyLedKey,
    this.pytTermDiscKey,
    this.salesPersonKey,
    this.creditPeriod,
    this.salesLedKey,
    this.ledgerName,
    this.additionalInfo,
    required this.consignees,
    required this.paymentTerms,
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
  String? selectedSalesmanKey;
  String? selectedSalesmanName;

  final TextEditingController paymentDaysController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController referenceNoController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  bool _isLoadingBookingTypes = false;
  Item? _selectedBookingType;

  String? _selectedPytTermDiscKey;
  String? _selectedSalesmanKey;
  List<Item> _bookingTypes = [];

  @override
  void initState() {
    super.initState();
    _baseDate = DateTime.now();

    paymentDaysController.text =
        widget.creditPeriod?.toString() ??
        widget.additionalInfo?['paymentdays'] ??
        '0';
    dateController.text =
        widget.additionalInfo?['date'] ?? _formatDate(_baseDate);
    dueDateController.text =
        widget.additionalInfo?['duedate'] ?? _formatDate(_baseDate);
    referenceNoController.text = widget.additionalInfo?['refno'] ?? '';
    _selectedPytTermDiscKey =
        widget.pytTermDiscKey ?? widget.additionalInfo?['paymentterms'];
    selectedBookingType = widget.additionalInfo?['bookingtype'];
    _selectedSalesmanKey =
        widget.salesPersonKey ?? widget.additionalInfo?['salesman'];
    selectedSalesmanName =
        widget.salesPersonList.firstWhere(
          (e) => e['ledKey'] == _selectedSalesmanKey,
          orElse: () => {'ledName': ''},
        )['ledName'];

    if (widget.additionalInfo?['consignee'] != null &&
        widget.additionalInfo!['consignee'].isNotEmpty) {
      _initializeConsignee();
    }

    _updateDueDate();
    paymentDaysController.addListener(_updateDueDate);
    dueDateController.addListener(_updatePaymentDays);
    dateController.addListener(_updatePaymentDays);
    _loadBookingTypes();
  }

  void _initializeConsignee() {
    setState(() {
      selectedConsignee = widget.consignees.firstWhere(
        (c) => c.ledKey == widget.additionalInfo!['consignee'],
        orElse: () => Consignee(
          ledKey: '',
          ledName: '',
          stnKey: '',
          stnName: '',
          paymentTermsKey: '',
          paymentTermsName: '',
          pytTermDiscdays: '0',
        ),
      );
      if (selectedConsignee?.paymentTermsKey.isNotEmpty ?? false) {
        _selectedPytTermDiscKey = selectedConsignee!.paymentTermsKey;
        selectedPaymentTerms = selectedConsignee!.paymentTermsName;
      }
    });
  }

  Future<void> _loadBookingTypes() async {
    setState(() => _isLoadingBookingTypes = true);
    try {
      final rawData = await ApiService.fetchBookingTypes(coBrId: '01');
      final data = (rawData as List)
          .map((json) => Item(
                itemKey: json['key'],
                itemName: json['name'],
                itemSubGrpKey: '',
              ))
          .toList();

      setState(() {
        _bookingTypes = data;
        _selectedBookingType = _bookingTypes.firstWhere(
          (item) => item.itemKey == selectedBookingType,
        //  orElse: () => _bookingTypes.isNotEmpty ? _bookingTypes[0] : null,
        );
      });
    } catch (e) {
      print('Failed to load booking types: $e');
    } finally {
      setState(() => _isLoadingBookingTypes = false);
    }
  }

  void _updateDueDate() {
    final days = int.tryParse(paymentDaysController.text) ?? 0;
    final newDueDate = _baseDate.add(Duration(days: days));
    dueDateController.text = _formatDate(newDueDate);
  }

  void _updatePaymentDays() {
    final dateStr = dateController.text;
    final dueDateStr = dueDateController.text;

    final baseDate = _parseDate(dateStr);
    final dueDate = _parseDate(dueDateStr);

    if (baseDate != null && dueDate != null) {
      _baseDate = baseDate;
      final days = dueDate.difference(baseDate).inDays;
      paymentDaysController.text = days.toString();
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          if (label == 'Date') {
            _baseDate = picked;
            _updateDueDate();
          } else if (label == 'Due Date') {
            _updatePaymentDays();
          }
        }
      },
    );
  }

  Widget _buildConsigneeDropdown() {
    return DropdownSearch<Consignee>(
      popupProps: PopupProps.menu(
        showSearchBox: true,
        itemBuilder: (context, item, isSelected) =>
            ListTile(title: Text(item.ledName ?? '')),
      ),
      items: widget.consignees,
      itemAsString: (item) => item.ledName ?? '',
      selectedItem: selectedConsignee,
      onChanged: (value) {
        setState(() {
          selectedConsignee = value;

          if (value?.paymentTermsKey.isNotEmpty ?? false) {
            _selectedPytTermDiscKey = value!.paymentTermsKey;
            selectedPaymentTerms = value.paymentTermsName;
          }

          // DO NOT UPDATE paymentDaysController.text
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

  Widget _buildPaymentTermsDropdown() {
    return DropdownSearch<PytTermDisc>(
      popupProps: PopupProps.menu(
        showSearchBox: true,
        itemBuilder: (context, item, isSelected) =>
            ListTile(title: Text(item.name)),
      ),
      items: widget.paymentTerms,
      itemAsString: (item) => item.name,
      selectedItem: widget.paymentTerms.firstWhere(
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

  Widget _buildBookingTypeDropdown() {
    return DropdownButton<Item>(
      value: _selectedBookingType,
      hint: const Text("Select booking type"),
      isExpanded: true,
      items: _bookingTypes.map((Item item) {
        return DropdownMenuItem<Item>(
          value: item,
          child: Text(item.itemName),
        );
      }).toList(),
      onChanged: (Item? newValue) {
        setState(() {
          _selectedBookingType = newValue;
        });
      },
    );
  }

  Widget _buildSalesmanDropdown() {
    final salesmenFromConstructor = widget.salesPersonList
        .map((e) => Salesman(key: e['ledKey'] ?? '', name: e['ledName'] ?? ''))
        .toList();

    return DropdownSearch<Salesman>(
      popupProps: PopupProps.menu(
        showSearchBox: true,
        itemBuilder: (context, item, isSelected) =>
            ListTile(title: Text(item.name)),
      ),
      items: salesmenFromConstructor,
      itemAsString: (item) => item.name,
      selectedItem: salesmenFromConstructor.firstWhere(
        (e) => e.key == _selectedSalesmanKey,
        orElse: () => Salesman(key: '', name: ''),
      ),
      onChanged: (value) {
        setState(() {
          _selectedSalesmanKey = value?.key ?? '';
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
    final formData = {
      'consignee': selectedConsignee?.ledKey ?? '',
      'station': selectedConsignee?.stnKey ?? '',
      'paymentterms': _selectedPytTermDiscKey ?? '',
      'paymentdays': paymentDaysController.text,
      'duedate': dueDateController.text,
      'refno': referenceNoController.text,
      'date': dateController.text,
      'bookingtype': _selectedBookingType?.itemKey ?? '',
      'salesman': _selectedSalesmanKey ?? '',
    };
    widget.onValueChanged(formData);
    Navigator.pop(context, formData);
  }

  @override
  void dispose() {
    paymentDaysController.removeListener(_updateDueDate);
    dueDateController.removeListener(_updatePaymentDays);
    dateController.removeListener(_updatePaymentDays);
    paymentDaysController.dispose();
    dueDateController.dispose();
    referenceNoController.dispose();
    dateController.dispose();
    super.dispose();
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildConsigneeDropdown(),
              const SizedBox(height: 12),
              _buildPaymentTermsDropdown(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField("Payment Days", paymentDaysController),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDateField("Due Date", dueDateController)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField("Reference No", referenceNoController),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDateField("Date", dateController)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildSalesmanDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildBookingTypeDropdown()),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _saveFormData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text("OK", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text("Close", style: TextStyle(color: Colors.white)),
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
