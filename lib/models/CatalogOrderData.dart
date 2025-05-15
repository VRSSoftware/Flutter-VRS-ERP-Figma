import 'package:vrs_erp_figma/models/OrderMatrix.dart';
import 'package:vrs_erp_figma/models/catalog.dart';

class CatalogOrderData {
  final Catalog catalog;
  final OrderMatrix orderMatrix;

  CatalogOrderData({
    required this.catalog,
    required this.orderMatrix,
  });
}
