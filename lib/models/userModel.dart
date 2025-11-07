import 'package:hamarakisan_front/models/pinnedMandiModel.dart';

class UserModel {
  String id;
  String firstName;
  String lastName;
  String? phone;
  String email;
  String? state;
  String? photoUrl;
  String idToken;
  String? district;
  bool isRegistered;
  List<PinnedMandi> pinnedMandis;
  List<String> interestedCommodities;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.pinnedMandis,
    required this.interestedCommodities,
    this.state = '',
    this.photoUrl,
    this.district,
    this.idToken = '',
    this.isRegistered = false,
  });

  setPinnedMandis(List<PinnedMandi> newMandis){
    pinnedMandis = newMandis;
  }

  static UserModel jsonToUser(Map userData) => UserModel(
    id: userData['id'],
    firstName: userData['firstName'],
    lastName: userData['lastName'],
    phone: userData['phone'],
    email: userData['email'],
    state: userData['state'],
    photoUrl: userData['photoUrl'],
    district: userData['district'],
    idToken: userData['idToken'],
    interestedCommodities: List<String>.from(userData['interestedCom'] ?? []),
    isRegistered: userData['isRegistered'] ?? false,
    pinnedMandis: (userData["pinnedMandis"] as List)
        .map((m) => PinnedMandi.fromJson(m))
        .toList(),

  );
}
