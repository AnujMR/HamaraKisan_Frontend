import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../apis.dart';

class HomeProvider with ChangeNotifier {
  List<Map<String, dynamic>> tableData = [];
  Map<String, Map<String, dynamic>> priceTrend = {};
  Map<String, dynamic> topDistricts = {};
  Map<String, Map<String, dynamic>> pinnedMandiComparison = {};
  int selectedPage = 1;

  void setSelectedPage(int page) {
    selectedPage = page;
    notifyListeners();
  }

Future<void> getTableData(Map<String, dynamic> reqBody, String idToken) async {
    try {
      final response = await http.post(
        Uri.parse(getTableDataEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({...reqBody, "token": idToken}),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        final List<dynamic> list = res['mandis'];
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

Future<void> getHomePageGraphs(Map<String, dynamic> reqBody, String uid,
    String idToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$getHomePageGraphsEndpoint/$uid"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({...reqBody, "token": idToken}),
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
        if (list["pinnedMandiComparison"] != null) {
          // print("The data we received : " + list["pinnedMandiComparison"]);
          pinnedMandiComparison = Map<String, Map<String, dynamic>>.from(list["pinnedMandiComparison"]);
          // print("The data converted : ");
          // print(pinnedMandiComparison);
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
