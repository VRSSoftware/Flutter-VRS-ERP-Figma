class Shade {
  final String shadeKey;
  final String shadeName;

  Shade({required this.shadeKey, required this.shadeName});

  factory Shade.fromJson(Map<String, dynamic> json) {
    return Shade(
      shadeKey: json['shadeKey'] ?? '',
      shadeName: json['shadeName'] ?? '',
    );
  }
}