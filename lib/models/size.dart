class Size {
  final String itemSizeKey;
  final String sizeName;

  Size({required this.itemSizeKey, required this.sizeName});

  factory Size.fromJson(Map<String, dynamic> json) {
    return Size(
      itemSizeKey: json['itemSizeKey'] ?? '',
      sizeName: json['sizeName'] ?? '',
    );
  }
}