import 'package:cloud_firestore/cloud_firestore.dart';

class MyParkings {
  String? uid;
  int? price;
  bool? isDisable;
  String? puid;
  String? parkingName;
  String? parkingAddress;
  String? parkingImage;
  int? parkingEarning;
  String? reason;
  double? latitude;
  double? longitude;
  Timestamp? accountCreated;

  MyParkings({
    this.uid,
    this.price,
    this.isDisable,
    this.reason,
    this.puid,
    this.parkingName,
    this.parkingEarning,
    this.parkingAddress,
    this.parkingImage,
    this.latitude,
    this.longitude,
    this.accountCreated,
  });

  factory MyParkings.fromJson(Map<String, dynamic> json) {
    return MyParkings(
      uid: json['uid'],
      price: json['price'],
      isDisable: json['isDisable'],
      puid: json['puid'],
      reason: json['reason'],
      parkingEarning: json['parkingEarning'],
      parkingName: json['parkingName'],
      parkingAddress: json['parkingAddress'],
      parkingImage: json['parkingImage'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accountCreated: json['accountCreated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'price': price,
      'isDisable': isDisable,
      'reason': reason,
      'puid': puid,
      'parkingEarning': parkingEarning,
      'parkingName': parkingName,
      'parkingAddress': parkingAddress,
      'parkingImage': parkingImage,
      'latitude': latitude,
      'longitude': longitude,
      'accountCreated': accountCreated,
    };
  }
}
