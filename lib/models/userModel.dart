class UserModel {
  String id;
  String firstName;
  String lastName;
  String? phone;
  String email;
  String? state;
  String? photoUrl;
  List? fcmToken;
  String? district;
  bool isRegistered;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.state = '',
    this.photoUrl,
    this.district,
    this.fcmToken,
    this.isRegistered = false,
  });

  static UserModel jsonToUser(Map userData) => UserModel(
    id: userData['id'],
    firstName: userData['firstName'],
    lastName: userData['lastName'],
    phone: userData['phone'],
    email: userData['email'],
    state: userData['state'],
    photoUrl: userData['photoUrl'],
    district: userData['district'],
    fcmToken: userData['fcmToken'],
    isRegistered: userData['isRegistered'] ?? false,
  );
}
