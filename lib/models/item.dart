class Item {
  final String itemKey;
  final String itemName;

  Item({required this.itemKey, required this.itemName});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemKey: json['itemKey'],
      itemName: json['itemName'],
    );
  }
}
