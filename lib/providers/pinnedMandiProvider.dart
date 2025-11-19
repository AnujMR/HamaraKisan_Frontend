import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hamarakisan_front/apis.dart';
import 'package:hamarakisan_front/models/pinnedMandiModel.dart';
import 'package:http/http.dart' as http;

class PinnedMandiProvider with ChangeNotifier {
  Future<Map> pinMandi({
    required Map<String, dynamic> reqBody,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$pinMandiEndpoint/$userId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        print(res);
        if (!res["success"]) {
          print("Error on server side while pinning a mandi");
          return {"success": false};
        }
        notifyListeners();
        List<PinnedMandi> pinnedMandis = [];
        res["pinnedMandis"].forEach((mandiJson) {
          pinnedMandis.add(PinnedMandi.fromJson(mandiJson));
        });
        return {"success": true, "pinnedMandis": pinnedMandis};
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return {"success": false};
      }
    } catch (e) {
      print("Error while pinning a mandi: $e");
      return {"success": false};
    }
  }
  Future<Map> unpinMandi({
    required Map<String, dynamic> reqBody,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$unpinMandiEndpoint/$userId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        print(res);
        if (!res["success"]) {
          print("Error on server side while unpinning a mandi");
          return {"success": false};
        }
        notifyListeners();
        List<PinnedMandi> pinnedMandis = [];
        res["pinnedMandis"].forEach((mandiJson) {
          pinnedMandis.add(PinnedMandi.fromJson(mandiJson));
        });
        return {"success": true, "pinnedMandis": pinnedMandis};
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return {"success": false};
      }
    } catch (e) {
      print("Error while unpinning a mandi: $e");
      return {"success": false};
    }
  }
}
