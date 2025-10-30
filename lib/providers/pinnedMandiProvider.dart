import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hamarakisan_front/apis.dart';
import 'package:http/http.dart' as http;

class PinnedMandiProvider with ChangeNotifier{

  Future<void> pinMandi(Map<String, dynamic> reqBody) async {
    try {
      final response = await http.post(
        Uri.parse(pinMandiEndpoint),
        headers: {"Content-Type": "application/json"}, 
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        // tableData = List<Map<String, dynamic>>.from(list);
        notifyListeners();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error fetching table data: $e");
    }
  }

}