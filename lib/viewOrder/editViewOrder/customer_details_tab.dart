import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KeyName {
  final String key;
  final String name;

  KeyName({required this.key, required this.name});
}

class CustomerDetailTab extends StatefulWidget {
  const CustomerDetailTab({super.key});

  @override
  State<CustomerDetailTab> createState() => _CustomerDetailTabState();
}

class _CustomerDetailTabState extends State<CustomerDetailTab> {
  // Read-only
  String orderDate = '2025-06-27';
  String partyName = 'ABC Garments';

  // Dropdown data
  List<KeyName> brokerList = [
    KeyName(key: 'B1', name: 'Broker One'),
    KeyName(key: 'B2', name: 'Broker Two'),
    KeyName(key: 'B3', name: 'Broker Three'),
  ];

  List<KeyName> transporterList = [
    KeyName(key: 'T1', name: 'Transporter One'),
    KeyName(key: 'T2', name: 'Transporter Two'),
    KeyName(key: 'T3', name: 'Transporter Three'),
  ];

  // Selected values
  KeyName? selectedBroker;
  KeyName? selectedTransporter;

  // Controllers
  final TextEditingController commController = TextEditingController();
  final TextEditingController deliveryDaysController = TextEditingController();
  final TextEditingController deliveryDateController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Example preset (simulate API fetch)
    selectedBroker = brokerList.first;
    selectedTransporter = transporterList[1];
    commController.text = '5';
    deliveryDaysController.text = '7';
    deliveryDateController.text = '2025-07-05';
    remarkController.text = 'Handle with care';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Date
          buildReadOnlyField('Date', orderDate),

          // 🔹 Party Name
          buildReadOnlyField('Party Name', partyName),

          // 🔹 Broker (Searchable Dropdown)
          buildSearchableDropdown(
            label: 'Broker',
            value: selectedBroker,
            items: brokerList,
            onSelected: (val) => setState(() => selectedBroker = val),
          ),

          // 🔹 Commission %
          buildTextField('Commission %', commController, TextInputType.number),

          // 🔹 Transporter (Searchable Dropdown)
          buildSearchableDropdown(
            label: 'Transporter',
            value: selectedTransporter,
            items: transporterList,
            onSelected: (val) => setState(() => selectedTransporter = val),
          ),

          // 🔹 Delivery Days
          buildTextField('Delivery Days', deliveryDaysController, TextInputType.number),

          // 🔹 Delivery Date (Date Picker)
          GestureDetector(
            onTap: pickDeliveryDate,
            child: AbsorbPointer(
              child: buildTextField('Delivery Date', deliveryDateController, TextInputType.text),
            ),
          ),

          // 🔹 Remark
          buildTextField('Remark', remarkController, TextInputType.text),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 🔥 Read-Only Field
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

  /// 🔥 Text Input Field
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

  /// 🔥 Searchable Dropdown (Manual)
  Widget buildSearchableDropdown({
    required String label,
    required KeyName? value,
    required List<KeyName> items,
    required Function(KeyName) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => _DropdownSearchDialog(
                  label: label,
                  items: items,
                  selected: value,
                  onSelected: onSelected,
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value?.name ?? 'Select $label'),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 Date Picker for Delivery Date
  void pickDeliveryDate() async {
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

/// 🔥 Custom Dialog for Searchable Dropdown
class _DropdownSearchDialog extends StatefulWidget {
  final String label;
  final List<KeyName> items;
  final KeyName? selected;
  final Function(KeyName) onSelected;

  const _DropdownSearchDialog({
    required this.label,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_DropdownSearchDialog> createState() => _DropdownSearchDialogState();
}

class _DropdownSearchDialogState extends State<_DropdownSearchDialog> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<KeyName> filteredItems = widget.items
        .where((e) => e.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return AlertDialog(
      title: Text('Select ${widget.label}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search...',
              isDense: true,
            ),
            onChanged: (val) {
              setState(() => searchQuery = val);
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final isSelected = widget.selected?.key == item.key;
                return ListTile(
                  title: Text(item.name),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    widget.onSelected(item);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
