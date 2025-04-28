class Sizes {
  final String itemSizeKey;
  final String sizeName;

  Sizes({required this.itemSizeKey, required this.sizeName});

  factory Sizes.fromJson(Map<String, dynamic> json) {
    return Sizes(
      itemSizeKey: json['itemSizeKey'] ?? '',
      sizeName: json['sizeName'] ?? '',
    );
  }
}