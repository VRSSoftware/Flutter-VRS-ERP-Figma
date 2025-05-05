class Consignee {
  final String ledKey;
  final String ledName;
  final String stnKey;
  final String stnName;
  final String paymentTermsKey;
  final String paymentTermsName;
  final String pytTermDiscdays;

  Consignee({
    required this.ledKey,
    required this.ledName,
    required this.stnKey,
    required this.stnName,
    required this.paymentTermsKey,
    required this.paymentTermsName,
    required this.pytTermDiscdays,
  });

  // Factory constructor to create a Consignee from JSON
  factory Consignee.fromJson(Map<String, dynamic> json) {
    return Consignee(
      ledKey: json['led_Key'] ?? '',
      ledName: json['led_Name'] ?? '',
      stnKey: json['stnKey'] ?? '',
      stnName: json['stnName'] ?? '',
      paymentTermsKey: json['paymentTermskey'] ?? '',
      paymentTermsName: json['paymentTermsName'] ?? '',
      pytTermDiscdays: json['pytTermDiscdays'] ?? '0',
    );
  }

  // Method to convert Consignee object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'led_Key': ledKey,
      'led_Name': ledName,
      'stnKey': stnKey,
      'stnName': stnName,
      'paymentTermskey': paymentTermsKey,
      'paymentTermsName': paymentTermsName,
      'pytTermDiscdays': pytTermDiscdays,
    };
  }
}
