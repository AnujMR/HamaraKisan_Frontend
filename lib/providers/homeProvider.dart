import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../apis.dart';

class HomeProvider with ChangeNotifier {
  List<Map<String, dynamic>> tableData = [];
  Map<String, Map<String, dynamic>> priceTrend = {};
  Map<String, dynamic> topDistricts = {};
  int selectedPage = 1;

  void setSelectedPage(int page) {
    selectedPage = page;
    notifyListeners();
  }

Future<void> getTableData(Map<String, dynamic> reqBody) async {
    try {
      final response = await http.post(
        Uri.parse(getTableDataEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        // print(list); 
        tableData = List<Map<String, dynamic>>.from(list);
        notifyListeners();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error fetching table data: $e");
    }
  }

Future<void> getHomePageGraphs(Map<String, dynamic> reqBody, String uid) async {
    try {
      final response = await http.post(
        Uri.parse("$getHomePageGraphsEndpoint/$uid"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> list = jsonDecode(response.body);
        // print(list); 
        priceTrend = {};
        if (list["priceTrend"] != null) {
          list["priceTrend"].forEach((district, value) {
            priceTrend[district] = Map<String, dynamic>.from(value);
          });
        }
        if (list["topDistricts"] != null) {
          topDistricts = Map<String, dynamic>.from(list["topDistricts"]);
        }

        notifyListeners();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error fetching table data: $e");
    }
  }
}
