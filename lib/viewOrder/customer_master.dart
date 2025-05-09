import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vrs_erp_figma/models/keyName.dart';
import 'package:vrs_erp_figma/services/app_services.dart';

class CustomerMasterDialog extends StatefulWidget {
  @override
  _CustomerMasterDialogState createState() => _CustomerMasterDialogState();
}

class _CustomerMasterDialogState extends State<CustomerMasterDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController partyNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController creditDaysController = TextEditingController();

  KeyName? selectedSalesType;
  KeyName? selectedStation;
  KeyName? selectedBroker;
  KeyName? selectedTransporter;
  KeyName? selectedSalesPerson;
  KeyName? selectedPaymentTerms;

  List<KeyName> salesTypes = [];
  List<KeyName> stations = [];
  List<KeyName> brokers = [];
  List<KeyName> transporters = [];
  List<KeyName> salesPersons = [];
  List<KeyName> paymentTerms = [];

  @override
  void initState() {
    super.initState();
    fetchDropdowns();
  }

  Future<void> fetchDropdowns() async {
    final st = await ApiService.fetchLedgers(ledCat: 'L', coBrId: '01');
    final station = await ApiService.fetchStations( coBrId: '01');
    final broker = await ApiService.fetchLedgers(ledCat: 'B', coBrId: '01');
    final trans = await ApiService.fetchLedgers(ledCat: 'T', coBrId: '01');
    final sales = await ApiService.fetchLedgers(ledCat: 'S', coBrId: '01');
    final pay = await ApiService.fetchPayTerms( coBrId: '01');

    setState(() {
      salesTypes = List<KeyName>.from(st['result']);
      stations = List<KeyName>.from(station['result']);
      brokers = List<KeyName>.from(broker['result']);
      transporters = List<KeyName>.from(trans['result']);
      salesPersons = List<KeyName>.from(sales['result']);
      paymentTerms = List<KeyName>.from(pay['result']);
    });
  }

  @override
  Widget build(BuildContext context) {
    double dialogWidth = MediaQuery.of(context).size.width * 0.8;
    if (dialogWidth > 600) dialogWidth = 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        width: dialogWidth,
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Customer Master", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                buildTextField("Party Name", partyNameController),
                buildTextField("Contact Person", contactPersonController),
                buildTextField("Whatsapp No", whatsappController, keyboardType: TextInputType.phone, validator: (val) {
                  if (val == null || val.length != 10) return "Enter 10 digit number";
                  return null;
                }),
                buildDropdown("Sales Type", salesTypes, selectedSalesType, (val) => setState(() => selectedSalesType = val)),
                buildTextField("GST No", gstController, validator: (val) {
                  if (val == null || val.length > 15) return "Max 15 characters";
                  return null;
                }),
                buildTextField("Address", addressController, maxLines: 3),
                buildDropdown("Station", stations, selectedStation, (val) => setState(() => selectedStation = val)),
                buildDropdown("Broker", brokers, selectedBroker, (val) => setState(() => selectedBroker = val)),
                buildDropdown("Transporter", transporters, selectedTransporter, (val) => setState(() => selectedTransporter = val)),
                buildDropdown("SalesPerson", salesPersons, selectedSalesPerson, (val) => setState(() => selectedSalesPerson = val)),
                buildDropdown("Payment Terms", paymentTerms, selectedPaymentTerms, (val) => setState(() => selectedPaymentTerms = val)),
                buildTextField("Credit Days", creditDaysController, keyboardType: TextInputType.number),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: Text("Save"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text("Close"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget buildDropdown(String label, List<KeyName> items, KeyName? selected, Function(KeyName?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<KeyName>(
        value: selected,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items
            .map((item) => DropdownMenuItem<KeyName>(
                  value: item,
                  child: Text(item.name),
                ))
            .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? "Select $label" : null,
      ),
    );
  }

  void onSave() {
    if (_formKey.currentState!.validate()) {
      final data = {
        "partyname": partyNameController.text,
        "contactperson": contactPersonController.text,
        "whatsappno": whatsappController.text,
        "salestypeDDL": selectedSalesType?.key,
        "gstno": gstController.text,
        "address": addressController.text,
        "stationDDL": selectedStation?.key,
        "brokerDDL": selectedBroker?.key,
        "transportDDL": selectedTransporter?.key,
        "salespersonDDL": selectedSalesPerson?.key,
        "paymenttermsDDL": selectedPaymentTerms?.key,
        "creditdays": creditDaysController.text,
        "createddate": DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
      };

      print(data);
      Navigator.pop(context);
    }
  }
}
