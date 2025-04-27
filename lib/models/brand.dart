class Brand {
  final String brandKey;
  final String brandName;

  Brand({required this.brandKey, required this.brandName});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      brandKey: json['brandKey'] ?? '',
      brandName: json['brandName'] ?? '',
    );
  }
}