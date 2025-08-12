import 'package:cloud_firestore/cloud_firestore.dart';

class MyPendingParking {
  String? uid;
  String? parkingName;
  String? parkingAddress;
  String? parkingImage;
  String? status;
  bool? isFormSubmit;
  Timestamp? accountCreated;
  double? latitude;
  double? longitude;

  MyPendingParking({
    this.uid,
    this.parkingName,
    this.parkingAddress,
    this.parkingImage,
    this.status = "pending",
    this.isFormSubmit = false,
    this.accountCreated,
    this.latitude,
    this.longitude,
  });

  factory MyPendingParking.fromJson(Map<String, dynamic> json) {
    return MyPendingParking(
      uid: json['uid'],
      parkingName: json['parkingName'],
      parkingAddress: json['parkingAddress'],
      parkingImage: json['parkingImage'],
      status: json['status'],
      isFormSubmit: json['isFormSubmit'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accountCreated: json['accountCreated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'parkingName': parkingName,
      'parkingAddress': parkingAddress,
      'parkingImage': parkingImage,
      'status': status,
      'isFormSubmit': isFormSubmit,
      'latitude': latitude,
      'longitude': longitude,
      'accountCreated': accountCreated,
    };
  }
}
