import 'package:cloud_firestore/cloud_firestore.dart';

class MyPendingOwner {
  String? uid;
  String? profilePic;
  String? firstName;
  String? lastName;
  String? parkingImage;
  String? parkingName;
  String? parkingAddress;
  bool? basicInfoDone;
  bool? parkingInfoDone;
  bool? formSubmitted;
  String? status;
  Timestamp? accountCreated;
  double? latitude;
  double? longitude;
  String? reason;

  MyPendingOwner({
    this.uid,
    this.profilePic = "",
    this.firstName = "",
    this.reason = "",
    this.lastName = "",
    this.parkingImage = "",
    this.parkingName = "",
    this.parkingAddress = "",
    this.basicInfoDone = false,
    this.parkingInfoDone = false,
    this.formSubmitted = false,
    this.status = "pending",
    this.accountCreated,
    this.latitude,
    this.longitude,
  });

  factory MyPendingOwner.fromJson(Map<String, dynamic> json) {
    return MyPendingOwner(
      uid: json['uid'],
      profilePic: json['profilePic'],
      firstName: json['firstName'],
      reason: json['reason'],
      lastName: json['lastName'],
      parkingImage: json['parkingImage'],
      parkingName: json['parkingName'],
      parkingAddress: json['parkingAddress'],
      basicInfoDone: json['basicInfoDone'] ?? false,
      parkingInfoDone: json['parkingInfoDone'] ?? false,
      formSubmitted: json['formSubmitted'] ?? false,
      status: json['status'] ?? "pending",
      accountCreated: json['accountCreated'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'profilePic': profilePic,
      'firstName': firstName,
      'reason': reason,
      'lastName': lastName,
      'parkingImage': parkingImage,
      'parkingName': parkingName,
      'parkingAddress': parkingAddress,
      'basicInfoDone': basicInfoDone,
      'parkingInfoDone': parkingInfoDone,
      'formSubmitted': formSubmitted,
      'status': status,
      'accountCreated': accountCreated,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
