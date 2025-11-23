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
        Uri.parse(getHomePageGraphsEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({...reqBody, "token": idToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> list = jsonDecode(response.body);
        // print(list); 
        priceTrend = {};
        if (list["lineInfo"] != null) {
          priceTrend = Map<String, Map<String, dynamic>>.from(list["lineInfo"]);
        }
        if (list["barInfo"] != null) {
          topDistricts = Map<String, dynamic>.from(list["barInfo"]);
        }

        notifyListeners();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error fetching graph data: $e");
    }
  }

Future<void> getMainGraph(Map<String, dynamic> reqBody, String uid,
    String idToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$getMainGraphEndpoint/$uid"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({...reqBody, "token": idToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> res = jsonDecode(response.body);
        // print(list); 
        pinnedMandiComparison = {};
        // print("Main Graph Response:");
        // print(res);
        pinnedMandiComparison = Map<String, Map<String, dynamic>>.from(res["graph"]);

        notifyListeners();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error fetching main graph data: $e");
    }
  }

Future<Map<String, dynamic>?> getPinnedMandiData(Map<String, dynamic> reqBody, String uid,
    String idToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$pinMandiTableEndpoint/$uid"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({...reqBody, "token": idToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> res = jsonDecode(response.body);
        // print(list); 
        // pinnedMandiComparison = {};
        // print("Main Graph Response:");
        print(res);
        // pinnedMandiComparison = Map<String, Map<String, dynamic>>.from(res["graph"]);
        notifyListeners();
        return res;
      } else {
        
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error fetching main graph data: $e");
    }
  }
}
