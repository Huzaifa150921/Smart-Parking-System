import 'package:cloud_firestore/cloud_firestore.dart';

class MyBookings {
  String? userId;
  bool? isReviewed;
  String? parkingId;
  String? ownerId;
  int? slotid;
  String? transectionId;
  String? plateNo;
  String? parkingName;
  String? parkingAddress;
  Timestamp? startTime;
  Timestamp? endTime;
  int? durationInDays;
  double? price;
  int? fine;
  bool? isFine;
  String? paymentStatus;
  Timestamp? createdAt;
  String? status;

  MyBookings({
    this.userId,
    this.parkingId,
    this.isReviewed,
    this.ownerId,
    this.slotid,
    this.fine,
    this.isFine,
    this.transectionId,
    this.plateNo,
    this.parkingName,
    this.parkingAddress,
    this.startTime,
    this.endTime,
    this.durationInDays,
    this.price,
    this.paymentStatus,
    this.createdAt,
    this.status,
  });

  factory MyBookings.fromJson(Map<String, dynamic> json) {
    return MyBookings(
      userId: json['userId'],
      parkingId: json['parkingId'],
      isReviewed: json['isReviewed'],
      ownerId: json['ownerId'],
      slotid: json['slotid'],
      fine: json['fine'],
      isFine: json['isFine'],
      transectionId: json['transectionId'],
      plateNo: json['plateNo'],
      parkingName: json['parkingName'],
      parkingAddress: json['parkingAddress'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      durationInDays: json['durationInDays'],
      price: (json['price'] as num?)?.toDouble(),
      paymentStatus: json['paymentStatus'],
      createdAt: json['createdAt'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'ownerId': ownerId,
      'parkingId': parkingId,
      'isReviewed': isReviewed,
      'slotid': slotid,
      'transectionId': transectionId,
      'fine': fine,
      'isFine': isFine,
      'plateNo': plateNo,
      'parkingName': parkingName,
      'parkingAddress': parkingAddress,
      'startTime': startTime,
      'endTime': endTime,
      'durationInDays': durationInDays,
      'price': price,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
      'status': status,
    };
  }
}
