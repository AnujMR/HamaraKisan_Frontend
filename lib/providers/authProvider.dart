import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hamarakisan_front/apis.dart';
import 'package:hamarakisan_front/models/dashboardData.dart';
import 'package:hamarakisan_front/models/pinnedMandiModel.dart';
import 'package:hamarakisan_front/models/userModel.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

class AuthProvider with ChangeNotifier {
  late UserModel user;
  List<DashboardData> dashboardData = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  updatePinnedMandis(List<PinnedMandi> newMandis){
    user.setPinnedMandis(newMandis);
    notifyListeners();
  }

  Future<bool> checkIfLoggedIn() async {
    final User? currentUser = _auth.currentUser;
    UserModel? existingUser;
    if (currentUser != null) {
      String? idToken = await  currentUser.getIdToken();
      existingUser = await getUser(userid: currentUser.uid, idToken: idToken!);
      if (existingUser != null) {
        user = existingUser;
        getDashboardData();
        return true;
      }
    }
    return false;
  }

  Future<UserModel?> loginWithGoogle() async {
    try {
      // final googleUser = await GoogleSignIn.instance.authenticate();

      // final googleAuth = await googleUser?.authentication;

      // final cred = GoogleAuthProvider.credential(
      //   idToken: googleAuth?.idToken,
      //   // accessToken: googleAuth?.accessToken,
      // );

      final userData = await signInWithGoogleWeb();
      String? idToken = await userData.user!.getIdToken();

      final existingUser = await getUser(userid: userData.user!.uid, idToken: idToken!);

      if (existingUser == null) {
        Map<String, dynamic> dataMap = {
          "id": userData.user!.uid,
          "firstName": userData.user!.displayName!.split(" ")[0],
          "lastName": userData.user!.displayName!.split(" ").length > 1
              ? userData.user!.displayName!.split(" ")[1]
              : "",
          "email": userData.user!.email!,
          "photoUrl": null, // userData.user!.photoURL,
          "district": "",
          "state": "",
          "phone": "",
          "interestedCom":[],
          "pinnedMandis":[],
          "isRegistered": false
        };
        final newUser = await createUser(
          userData: dataMap,
          uid: userData.user!.uid,
          idToken: idToken!
        );
        if (newUser != null) {
          user = newUser;
          }
        return newUser;
      } else {
        getDashboardData();
        return existingUser;
      }
    } catch (e) {
      print("Error while login with Google : $e");
    }
    return null;
  }

  Future<UserCredential> signInWithGoogleWeb() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    // You can add scopes if needed
    // googleProvider.addScope('email');
    // googleProvider.addScope('profile');

    // Sign in with popup (works in web)
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);

    // Alternatively, you can use redirect:
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }

  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userData = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel? newUser = await getUser(userid: userData.user!.uid, idToken: "");
      if (newUser != null) user = newUser;
      return newUser;
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Future<UserModel?> signupWithEmail({
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     final userData = await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );

  //     Map<String, dynamic> dataMap = {
  //       "id": userData.user!.uid,
  //       "fullName": userData.user!.displayName!,
  //       "email": userData.user!.email!,
  //       "levelsCompleted": [],
  //       "avatar": null,
  //       "currentLevel": "S1L1",
  //       "introWatched": false,
  //     };

  //     UserModel? newUser = await createUser(
  //       userData: dataMap,
  //       uid: userData.user!.uid,
  //     );
  //     if (newUser != null) user = newUser;
  //     return newUser;
  //   } catch (e) {
  //     print(e);
  //   }
  //   return null;
  // }

  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<UserModel?> getUser({required String userid, required String idToken}) async {
    try {
      final userData = await firestore.collection("users").doc(userid).get();
      user = UserModel.jsonToUser({...userData.data() as Map, "idToken": idToken});
      return user;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<UserModel?> createUser({
    required Map<String, dynamic> userData,
    required String uid,
    required String idToken
  }) async {
    try {
      await firestore.collection("users").doc(uid).set(userData);
      UserModel? newUser = await getUser(userid: uid, idToken: idToken);
      final dashboardData = {
        "data": []
      };
      await firestore.collection("dashboard").doc(uid).set(dashboardData);
      return newUser;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<UserModel?> updateUser({
    required Map<String, dynamic> userData,
    required String idToken
  }) async {
    try {
      await firestore.collection("users").doc(user.id).update(userData);
      UserModel? newUser = await getUser(userid: user.id, idToken: idToken);
      if (newUser != null) {
        user = newUser;
      }
      notifyListeners();
      return newUser;
    } catch (e) {
      print(e);
      return null;
    }
  }

  setItemInLocalStorage({required String key, required String value}) async {
    await initLocalStorage();
    localStorage.setItem(key, value);
  }

  getDashboardData() async {
    try {
      final dashboardData = await firestore.collection("dashboard").doc(user.id).get();
      final data = dashboardData.data();
      if (data != null) {
        List<dynamic> dataList = data['data'];
        this.dashboardData = dataList.map((e) => DashboardData.fromJson(e)).toList();
        notifyListeners();
      } 
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map> addRecordInDashboard(
    {required Map<String, dynamic> reqBody,
    required String idToken,
    required String uid}
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$addRecordEnpoint/$uid"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({...reqBody, "token": idToken}),
      );

      if (response.statusCode == 200) {
        dashboardData.add(DashboardData.fromJson({...reqBody, "index": dashboardData.length.toString(), "total": reqBody["price"] * reqBody["quantity"]}));
        notifyListeners();
        getDashboardData();
        notifyListeners();
        return {"success": true};
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return {
          "success": false,
          "message": 'Error: ${response.statusCode} - ${response.body}'
        };
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
      return {
        "success": false,
        "message": 'Error: $e'
      };
    }
  }

  
}