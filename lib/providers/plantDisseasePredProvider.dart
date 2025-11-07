import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hamarakisan_front/apis.dart';
import 'package:http/http.dart' as http;

class PlantDiseasePredProvider with ChangeNotifier{
  Future<Map<String, dynamic>> uploadPlantImage({required Uint8List? fileBytes, required String fileName, required String idToken}) async {
    var uri = Uri.parse(plantDiseasePredEndpoint);
  try{
      var request = http.MultipartRequest('POST', uri);
      request.fields['token'] = idToken;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes!,
          filename: fileName,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var resString = await response.stream.bytesToString();
        return {"success": true, "data": jsonDecode(resString)};
      } else {
        var resString = await response.stream.bytesToString();
        print("Error: ${response.statusCode}, error is: ${resString}");
        return {"success": false, "error": "Status Code: ${response.statusCode}"};
      }
  }catch(e){
    print("Exception: $e");
    return {"success": false, "error": e.toString()};
  }

  }


  Future<Map<String, dynamic>> getRemedy({required String disease, required String idToken})async{
        try {
      final response = await http.post(
        Uri.parse(getRemedyEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"disease": disease, "token": idToken}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print(result);
        notifyListeners();
        return {"success": true, "data": result["data"]};
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return {"success": false, "error": response.body};
      }
    } catch (e) {
      print("Error fetching table data: $e");
      return {"success": false, "error": e.toString()};
    }
  }
}