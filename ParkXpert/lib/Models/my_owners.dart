import 'package:cloud_firestore/cloud_firestore.dart';

class MyOwner {
  String? uid;
  String? profilePic;
  String? firstName;
  String? lastName;
  Timestamp? accountCreated;

  MyOwner({
    this.uid,
    this.profilePic,
    this.firstName,
    this.lastName,
    this.accountCreated,
  });

  factory MyOwner.fromJson(Map<String, dynamic> json) {
    return MyOwner(
      uid: json['uid'],
      profilePic: json['profilePic'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'profilePic': profilePic,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
