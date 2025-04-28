import 'package:flutter/material.dart';

class ToggleOptionsScreen extends StatefulWidget {
  const ToggleOptionsScreen({Key? key}) : super(key: key);

  @override
  _ToggleOptionsScreenState createState() => _ToggleOptionsScreenState();
}

class _ToggleOptionsScreenState extends State<ToggleOptionsScreen> {
  bool includeDesign = true;
  bool includeShade = true;
  bool includeRate = true;
  bool includeSize = true;
  bool includeProduct = true;
  bool includeRemark = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Share Options'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, {
                'design': includeDesign,
                'shade': includeShade,
                'rate': includeRate,
                'size': includeSize,
                'product': includeProduct,
                'remark': includeRemark,
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Include Design'),
            value: includeDesign,
            onChanged: (value) => setState(() => includeDesign = value),
          ),
          SwitchListTile(
            title: const Text('Include Shade'),
            value: includeShade,
            onChanged: (value) => setState(() => includeShade = value),
          ),
          SwitchListTile(
            title: const Text('Include Rate'),
            value: includeRate,
            onChanged: (value) => setState(() => includeRate = value),
          ),
          SwitchListTile(
            title: const Text('Include Size'),
            value: includeSize,
            onChanged: (value) => setState(() => includeSize = value),
          ),
          SwitchListTile(
            title: const Text('Include Product'),
            value: includeProduct,
            onChanged: (value) => setState(() => includeProduct = value),
          ),
          SwitchListTile(
            title: const Text('Include Remark'),
            value: includeRemark,
            onChanged: (value) => setState(() => includeRemark = value),
          ),
        ],
      ),
    );
  }
}
