import 'package:cloud_firestore/cloud_firestore.dart';

class MyNotifications {
  String? id;
  String? uid;
  String? title;
  String? body;
  String? type;
  bool? isread;
  Map<String, dynamic>? data;
  Timestamp? timestamp;

  MyNotifications({
    this.id,
    this.uid,
    this.isread,
    this.title,
    this.body,
    this.type,
    this.data,
    this.timestamp,
  });

  factory MyNotifications.fromJson(Map<String, dynamic> json, {String? id}) {
    return MyNotifications(
      id: id,
      uid: json['uid'],
      title: json['title'],
      isread: json['isread'],
      body: json['body'],
      type: json['type'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      timestamp: json['timestamp'],
    );
  }
  factory MyNotifications.fromMap(Map<String, dynamic> map, {String? id}) {
    return MyNotifications.fromJson(map, id: id);
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'title': title,
      'isread': isread,
      'body': body,
      'type': type,
      'data': data,
      'timestamp': timestamp,
    };
  }
}
