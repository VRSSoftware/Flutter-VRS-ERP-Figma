class Category {
  final String itemSubGrpKey;
  final String itemSubGrpName;

  Category({required this.itemSubGrpKey, required this.itemSubGrpName});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      itemSubGrpKey: json['itemSubGrpKey'],
      itemSubGrpName: json['itemSubGrpName'],
    );
  }
}
