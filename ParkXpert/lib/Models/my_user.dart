import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  String? uid;
  String? name;
  String? email;
  String? password;
  String? phoneNumber;
  String? role;

  bool? isOwner;
  bool? isUserScreen;
  String? profilePic;
  bool? firstTime;
  Timestamp? accountcreated;

  MyUser({
    this.uid,
    this.name,
    this.email,
    this.password,
    this.phoneNumber,
    this.role,
    this.isOwner = false,
    this.isUserScreen = true,
    this.profilePic,
    this.firstTime = true,
    this.accountcreated,
  });

  factory MyUser.fromJson(Map<String, dynamic> json) {
    return MyUser(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      isOwner: json['isOwner'],
      isUserScreen: json['isUserScreen'],
      firstTime: json['firstTime'],
      accountcreated: json['accountcreated'],
      profilePic: json['profilePic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'isOwner': isOwner,
      'isUserScreen': isUserScreen,
      'firstTime': firstTime,
      'accountcreated': accountcreated,
      'profilePic': profilePic,
    };
  }
}
