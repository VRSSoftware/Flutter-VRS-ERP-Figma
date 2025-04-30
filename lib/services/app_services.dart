import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/models/brand.dart';
import 'package:vrs_erp_figma/models/catalog.dart';
import 'package:vrs_erp_figma/models/category.dart';
import 'package:vrs_erp_figma/models/item.dart';
import 'package:vrs_erp_figma/models/shade.dart';
import 'package:vrs_erp_figma/models/size.dart';
import 'package:vrs_erp_figma/models/style.dart';
import '../constants/app_constants.dart';

class ApiService {
  static Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('${AppConstants.BASE_URL}/itemSubGrp'),
    );
    // print("RRRRRRRRRRRRRRRRRresponse data:${response.body}");
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<Item>> fetchItemsByCategory(String categoryKey) async {
    if (categoryKey.isEmpty) {
      throw Exception('Invalid category selected');
    }
    final response = await http.get(
      Uri.parse('${AppConstants.BASE_URL}/item/$categoryKey'),
    );
    print("Item API response for $categoryKey: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items for itemSubGrpKey: $categoryKey');
    }
  }

  static Future<List<Item>> fetchAllItems() async {
    final response = await http.get(Uri.parse('${AppConstants.BASE_URL}/item'));

    // print("@@@@@@@@@@@@@@@@@@Item API response for${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items  ');
    }
  }

  static Future<List<Style>> fetchStylesByItemKey(String itemKey) async {
    if (itemKey.isEmpty) {
      throw Exception('Invalid item selected');
    }
    final response = await http.get(
      Uri.parse('${AppConstants.BASE_URL}/style/$itemKey'),
    );
    // print("Style API response for $itemKey: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Style.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load styles for itemKey: $itemKey');
    }
  }

  // Fetch Shades by Item Key (returning Shade objects)
  static Future<List<Shade>> fetchShadesByItemKey(String itemKey) async {
    if (itemKey.isEmpty) {
      throw Exception('Invalid item selected');
    }

    final response = await http.get(
      Uri.parse('${AppConstants.BASE_URL}/shade/GetShadeByItem/$itemKey'),
    );
    // print("ShADEEEEEEEEEEEEEEEEEEE API response for${response.body}");
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Return a list of Shade objects
      return data.map((json) => Shade.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load shades for itemKey: $itemKey');
    }
  }

  // Fetch Style Sizes by Item Key (returning StyleSize objects)
  static Future<List<Sizes>> fetchStylesSizeByItemKey(String itemKey) async {
    if (itemKey.isEmpty) {
      throw Exception('Invalid item selected');
    }

    final response = await http.get(
      Uri.parse(
        '${AppConstants.BASE_URL}/stylesize/GetStylesSizeByItem/$itemKey',
      ),
    );
    // print("SizeeeeeeeeeeeeeeeeeAPI response for${response.body}");
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Return a list of StyleSize objects
      return data.map((json) => Sizes.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load style sizes for itemKey: $itemKey');
    }
  }

  static Future<List<Shade>> fetchShadesByStyleKey(String styleKey) async {
    if (styleKey.isEmpty) {
      throw Exception('Invalid style selected');
    }
    final response = await http.get(
      Uri.parse('${AppConstants.BASE_URL}/shade/$styleKey'),
    );
    //  print("Shade API response for $styleKey: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Shade.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load shades for styleKey: $styleKey');
    }
  }

  static Future<List<Sizes>> fetchSizesByStyleKey(String styleKey) async {
    if (styleKey.isEmpty) {
      throw Exception('Invalid style selected');
    }
    final response = await http.get(
      Uri.parse('${AppConstants.BASE_URL}/stylesize/$styleKey'),
    );
    // print("Size API response for $styleKey: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Sizes.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sizes for styleKey: $styleKey');
    }
  }

  static Future<List<Brand>> fetchBrands() async {
    final response = await http.get(
      Uri.parse('${AppConstants.BASE_URL}/brand'),
    );
    //  print("Brand API response: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Brand.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }

  static Future<List<Catalog>> fetchCatalog({
    required String itemSubGrpKey,
    required String itemKey,
    String? brandKey,
    String? styleKey,
    String? shadeKey,
    String? sizeKey,
    double? fromMRP,
    double? toMRP,
    String coBr = '01',
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.BASE_URL}/catalog'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'itemSubGrpKey': itemSubGrpKey,
        'itemKey': itemKey,
        'brandKey': brandKey,
        'styleKey': styleKey,
        'shadeKey': shadeKey,
        'sizeKey': sizeKey,
        'fromMRP': fromMRP,
        'toMRP': toMRP,
        'coBr': coBr,
      }),
    );
    //  print("response body:${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Catalog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load catalog');
    }
  }

  static Future<List<dynamic>> getBarcodeDetails(String barcode) async {
    final url = Uri.parse(
      '${AppConstants.BASE_URL}/orderBooking/GetBarcodeDetails',
    );

    final body = {
      "coBrId": "01",
      "userId": "Admin",
      "fcYrId": "24",
      "barcode": barcode,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    print("response barcode:${response.body}");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch barcode details');
    }
  }

  static Future<List<Catalog>> fetchCatalogItem({
    required String itemSubGrpKey,
    required String itemKey,
    required String cobr,
    String? brandKey,
    String? styleKey,
    String? shadeKey,
    String? sizeKey,
    String? fromMRP,
    String? toMRP,
  }) async {
    final url = Uri.parse('${AppConstants.BASE_URL}/catalog');

    final Map<String, dynamic> body = {
      "itemSubGrpKey": itemSubGrpKey,
      "itemKey": itemKey,
      "brandKey": brandKey,
      "styleKey": styleKey,
      "shadeKey": shadeKey,
      "sizeKey": sizeKey,
      "fromMRP": fromMRP,
      "toMRP": toMRP,
      "cobr": cobr,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Catalog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load catalog');
    }
  }
}
