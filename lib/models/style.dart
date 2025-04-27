class Style {
  final String styleKey;
  final String styleCode;

  Style({required this.styleKey, required this.styleCode});

  factory Style.fromJson(Map<String, dynamic> json) {
    return Style(
      styleKey: json['styleKey'] ?? '',
      styleCode: json['styleCode'] ?? '',
    );
  }

  @override
  String toString() => styleCode; // This makes the dropdown show styleCode by default
}