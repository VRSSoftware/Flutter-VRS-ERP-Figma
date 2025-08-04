class PartyWithSpclMarkDwn {
  final String ledKey;
  final String ledName;
  final double splMkDown;

  PartyWithSpclMarkDwn({
    required this.ledKey,
    required this.ledName,
    required this.splMkDown,
  });

  factory PartyWithSpclMarkDwn.fromJson(Map<String, dynamic> json) {
    return PartyWithSpclMarkDwn(
      ledKey: json['Led_Key'].toString(),
      ledName: json['Led_Name'].toString(),
      splMkDown: double.tryParse(json['SplMkDown'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Led_Key': ledKey,
      'Led_Name': ledName,
      'SplMkDown': splMkDown,
    };
  }
}
