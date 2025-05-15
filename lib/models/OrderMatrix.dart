class OrderMatrix {
  final List<String> shades;
  final List<String> sizes;
  final List<List<String>> matrix; // Each cell will store "mrp,wsp"

  OrderMatrix({
    required this.shades,
    required this.sizes,
    required this.matrix,
  });

  factory OrderMatrix.fromJson(Map<String, dynamic> json) {
    return OrderMatrix(
      shades: List<String>.from(json['shades']),
      sizes: List<String>.from(json['sizes']),
      matrix: List<List<String>>.from(
        json['matrix'].map((row) => List<String>.from(row)).toList(),
      ),
    );
  }
}
