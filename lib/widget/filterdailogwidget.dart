import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final Set<String> initialFilters;

  const FilterDialog({super.key, required this.initialFilters});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late Set<String> _selectedFilters;

  @override
  void initState() {
    super.initState();
    _selectedFilters = Set.from(widget.initialFilters);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: const Text('MRP'),
            value: _selectedFilters.contains('mrp'),
            onChanged: (bool? value) {
              setState(() {
                value ?? false 
                  ? _selectedFilters.add('mrp')
                  : _selectedFilters.remove('mrp');
              });
            },
          ),
          CheckboxListTile(
            title: const Text('WSP'),
            value: _selectedFilters.contains('wsp'),
            onChanged: (bool? value) {
              setState(() {
                value ?? false 
                  ? _selectedFilters.add('wsp')
                  : _selectedFilters.remove('wsp');
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Shades'),
            value: _selectedFilters.contains('shades'),
            onChanged: (bool? value) {
              setState(() {
                value ?? false 
                  ? _selectedFilters.add('shades')
                  : _selectedFilters.remove('shades');
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Style Code'),
            value: _selectedFilters.contains('stylecode'),
            onChanged: (bool? value) {
              setState(() {
                value ?? false 
                  ? _selectedFilters.add('stylecode')
                  : _selectedFilters.remove('stylecode');
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _selectedFilters);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}