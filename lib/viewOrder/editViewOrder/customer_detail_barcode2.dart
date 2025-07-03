import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vrs_erp_figma/models/CatalogOrderData.dart';
import 'package:vrs_erp_figma/viewOrder/editViewOrder/edit_order_data.dart';

class CustomerDetailBarcode2 extends StatefulWidget {
  const CustomerDetailBarcode2({super.key, });

  @override
  State<CustomerDetailBarcode2> createState() => _CustomerDetailBarcode2State();
}

class _CustomerDetailBarcode2State extends State<CustomerDetailBarcode2> {
  String? selectedBrokerKey;
  String? selectedTransporterKey;

  final TextEditingController commController = TextEditingController();
  final TextEditingController deliveryDaysController = TextEditingController();
  final TextEditingController deliveryDateController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Validate broker key exists
    if (EditOrderData.brokerList.any((item) => item['key'] == EditOrderData.brokerKey)) {
      selectedBrokerKey = EditOrderData.brokerKey;
    }

    // Validate transporter key exists
    if (EditOrderData.transporterList.any((item) => item['key'] == EditOrderData.transporterKey)) {
      selectedTransporterKey = EditOrderData.transporterKey;
    }

    commController.text = EditOrderData.commission;
    deliveryDaysController.text = EditOrderData.deliveryDays;
    deliveryDateController.text = EditOrderData.deliveryDate;
    remarkController.text = EditOrderData.remark;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildReadOnlyField('Date', EditOrderData.detailsForEdit),
          buildReadOnlyField('Party Name', EditOrderData.partyName),

          const SizedBox(height: 10),

          buildDropdownField(
            label: 'Broker',
            value: selectedBrokerKey,
            items: EditOrderData.brokerList,
            onChanged: (val) {
              setState(() => selectedBrokerKey = val);
            },
          ),

          buildTextField('Commission %', commController, TextInputType.number),

          buildDropdownField(
            label: 'Transporter',
            value: selectedTransporterKey,
            items: EditOrderData.transporterList,
            onChanged: (val) {
              setState(() => selectedTransporterKey = val);
            },
          ),

          buildTextField('Delivery Days', deliveryDaysController, TextInputType.number),

          GestureDetector(
            onTap: pickDeliveryDate,
            child: AbsorbPointer(
              child: buildTextField('Delivery Date', deliveryDateController, TextInputType.text),
            ),
          ),

          buildTextField('Remark', remarkController, TextInputType.text),
        ],
      ),
    );
  }

  /// 🔹 Read-only Display Field
  Widget buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(5),
            color: Colors.grey.shade100,
          ),
          child: Text(value),
        ),
      ],
    );
  }

  /// 🔹 Editable Input Field
  Widget buildTextField(String label, TextEditingController controller, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: type,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Dropdown Field
  Widget buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['key'],
                child: Text(item['name'] ?? ''),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Delivery Date Picker
  Future<void> pickDeliveryDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(deliveryDateController.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      deliveryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }
}
