import 'package:flutter/material.dart';
import 'package:vrs_erp_figma/constants/app_constants.dart';


class AddMoreInfoDialog extends StatefulWidget {
  @override
  _AddMoreInfoDialogState createState() => _AddMoreInfoDialogState();
}

class _AddMoreInfoDialogState extends State<AddMoreInfoDialog> {
  String? selectedConsignee;
  String? selectedPaymentTerms = '5% DISCOUNT';
  String? selectedSalesman;
  String? selectedBookingType;

  final TextEditingController paymentDaysController = TextEditingController(text: "46");
  final TextEditingController dueDateController = TextEditingController(text: "17-06-2025");
  final TextEditingController referenceNoController = TextEditingController();
  final TextEditingController dateController = TextEditingController(text: "dd-mm-yyyy");
  
@override
Widget build(BuildContext context) {
  return Dialog(
    insetPadding: EdgeInsets.all(20),
    shape: RoundedRectangleBorder( // Remove curve by setting borderRadius to 0
      borderRadius: BorderRadius.zero,
    ),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Text("Add More Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: 8),
            _buildDropdown("Consignee", selectedConsignee, ['A', 'B', 'C'], (val) {
              setState(() => selectedConsignee = val);
            }),
            SizedBox(height: 12),
            _buildDropdown("Payment Terms", selectedPaymentTerms, ['5% DISCOUNT', '10% ADVANCE'], (val) {
              setState(() => selectedPaymentTerms = val);
            }),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField("Payment Days", paymentDaysController)),
                SizedBox(width: 12),
                Expanded(child: _buildDateField("Due Date", dueDateController)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField("Reference No", referenceNoController)),
                SizedBox(width: 12),
                Expanded(child: _buildDateField("Date", dateController)),
              ],
            ),
            SizedBox(height: 12),
        Row(
  children: [
    Expanded(
      child: _buildDropdown("Salesman Name", selectedSalesman, ['John', 'Jane'], (val) {
        setState(() => selectedSalesman = val);
      }),
    ),
    SizedBox(width: 12),
    Expanded(
      child: _buildDropdown("Booking Type", selectedBookingType, ['Normal', 'Urgent'], (val) {
        setState(() => selectedBookingType = val);
      }),
    ),
  ],
),

            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text("Close", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
  return DropdownButtonFormField<String>(
    value: value,
    items: items.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w500),
      hintText: label,
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    ),
  );
}

Widget _buildTextField(String label, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w500),
      hintText: label,
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    ),
  );
}

Widget _buildDateField(String label, TextEditingController controller) {
  return TextField(
    controller: controller,
    readOnly: true,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w500),
      hintText: label,
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(),
      suffixIcon: Icon(Icons.calendar_today),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    ),
    onTap: () async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        controller.text = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      }
    },
  );
}

}
