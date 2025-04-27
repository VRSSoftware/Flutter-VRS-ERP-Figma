class Item {
  final String itemKey;
  final String itemName;
  final String? itemSubGrpKey;

  Item({required this.itemKey, required this.itemName, this.itemSubGrpKey});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemKey: json['itemKey'],
      itemName: json['itemName'],
      itemSubGrpKey: json['itemSubGrpKey'],
    );
  }
}
