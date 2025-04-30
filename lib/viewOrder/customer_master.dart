import 'package:flutter/material.dart';

class CustomerMasterDialog extends StatelessWidget {
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController creditDaysController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get screen width and height using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    // Set the dialog width to 80% of the screen width, with a max width limit
    double dialogWidth = screenWidth * 0.8;
    if (dialogWidth > 600) dialogWidth = 600; // Maximum width of 600px

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Remove curve
      child: Container(
        width: dialogWidth, // Set dialog width
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Customer Master",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              buildTextField("Party Name"),
              buildTextField("Contact Person"),
              buildTextField("Whatsapp No"),
              buildDropdown("Sales Type"),
              buildTextField("GST No"),
              buildTextField("Address", maxLines: 3),
              buildDropdown("Station"),
              buildDropdown("Broker"),
              buildDropdown("Transporter"),
              buildDropdown("SalesPerson"),
              buildDropdown("Payment Terms"),
              buildTextField("Credit Days"),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Save logic here
                      Navigator.pop(context);
                    },
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
    );
  }

  Widget buildTextField(String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildDropdown(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: ['Option 1', 'Option 2']
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) {},
      ),
    );
  }
}
