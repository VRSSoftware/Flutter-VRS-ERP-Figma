// models/stock_report_item.dart
class StockReportItem {
  final String? itemSubGrpKey;
  final String? itemSubGrpName;
  final String? itemKey;
  final String? itemName;
  final String? brandKey;
  final String? brandName;
  final String? styleKey;
  final String? styleCode;
  final String? shadeKey;
  final String? shadeName;
  final String? styleSizeId;
  final String? sizeName;
  final double? mrp;
  final double? wsp;
  final double? onlyMRP;
  final int? clqty;
  final String? fullImagePath;
  final String? remark;
  final int? total;
  final String? details;
  final String? type;

  StockReportItem({
    this.itemSubGrpKey,
    this.itemSubGrpName,
    this.itemKey,
    this.itemName,
    this.brandKey,
    this.brandName,
    this.styleKey,
    this.styleCode,
    this.shadeKey,
    this.shadeName,
    this.styleSizeId,
    this.sizeName,
    this.mrp,
    this.wsp,
    this.onlyMRP,
    this.clqty,
    this.fullImagePath,
    this.remark,
    this.total,
    this.details,
    this.type,
  });

  factory StockReportItem.fromJson(Map<String, dynamic> json) {
    return StockReportItem(
      itemSubGrpKey: json['itemSubGrpKey'],
      itemSubGrpName: json['itemSubGrpName'],
      itemKey: json['itemKey'],
      itemName: json['itemName'],
      brandKey: json['brandKey'],
      brandName: json['brandName'],
      styleKey: json['styleKey'],
      styleCode: json['styleCode'],
      shadeKey: json['shadeKey'],
      shadeName: json['shadeName'],
      styleSizeId: json['styleSizeId'],
      sizeName: json['sizeName'],
      mrp: json['mrp'] != null ? double.tryParse(json['mrp'].toString()) : null,
      wsp: json['wsp'] != null ? double.tryParse(json['wsp'].toString()) : null,
      onlyMRP: json['onlyMRP'] != null ? double.tryParse(json['onlyMRP'].toString()) : null,
      clqty: json['clqty'] != null ? int.tryParse(json['clqty'].toString()) : null,
      fullImagePath: json['fullImagePath'],
      remark: json['remark'],
      total: json['total'] != null ? int.tryParse(json['total'].toString()) : null,
      details: json['details'],
      type: json['type'],
    );
  }
}