import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:parkxpert/Models/my_pending_owner.dart';
import 'package:parkxpert/utils/utils.dart';

class OwnerRegistrationTrackController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rxn<MyPendingOwner> currentOwner = Rxn<MyPendingOwner>();

  @override
  void onInit() {
    super.onInit();
    _loadOwnerData();
  }

  Future<void> _loadOwnerData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc =
          await _firestore.collection("pending_owner").doc(user.uid).get();
      if (doc.exists) {
        currentOwner.value = MyPendingOwner.fromJson(doc.data()!);
      }
    } catch (e) {
      // ignore: avoid_print
      print("Failed to load owner data: $e");
    }
  }

  Future<void> refreshOwnerData() async {
    await _loadOwnerData();
  }

  Future<void> createPendingOwnerIfNotExists(String uid) async {
    if (uid.isEmpty) {
      Utils.snackBar("Error", "Invalid user ID", true);
      return;
    }

    final docRef = _firestore.collection("pending_owner").doc(uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      final newPendingOwner = MyPendingOwner(
        uid: uid,
        profilePic: "",
        firstName: "",
        reason: "",
        lastName: "",
        parkingImage: "",
        parkingAddress: "",
        parkingName: "",
        latitude: null,
        longitude: null,
        basicInfoDone: false,
        parkingInfoDone: false,
        formSubmitted: false,
        status: 'pending',
        accountCreated: Timestamp.now(),
      );

      await docRef.set(newPendingOwner.toJson());
      currentOwner.value = newPendingOwner;
      // ignore: avoid_print
      print("pending_owner created for $uid");
    } else {
      // ignore: avoid_print
      print("pending_owner already exists for $uid");
      currentOwner.value = MyPendingOwner.fromJson(snapshot.data()!);
    }
  }

  Future<void> uploadBasicInfoWithBase64({
    required File profileImage,
    required String firstName,
    required String lastName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      Utils.snackBar("Error", "User not logged in", true);
      return;
    }

    try {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        profileImage.path,
        quality: 50,
      );

      if (compressedBytes == null) throw "Image compression failed";

      final base64Image = base64Encode(compressedBytes);

      await _firestore.collection("pending_owner").doc(user.uid).update({
        "firstName": firstName,
        "lastName": lastName,
        "profilePic": base64Image,
        "basicInfoDone": true,
      });

      await refreshOwnerData();
    } catch (e) {
      // ignore: avoid_print
      print("Basic info error: $e");
      Utils.snackBar("Error", "Failed to save basic info", true);
    }
  }

  Future<void> uploadParkingInfoWithBase64({
    required File imageFile,
    required String parkingName,
    required String parkingAddress,
    double? latitude,
    double? longitude,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      Utils.snackBar("Error", "User not logged in", true);
      return;
    }

    try {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        quality: 50,
      );

      if (compressedBytes == null) throw "Image compression failed";

      final base64Image = base64Encode(compressedBytes);

      await _firestore.collection("pending_owner").doc(user.uid).update({
        "parkingName": parkingName,
        "parkingAddress": parkingAddress,
        "parkingImage": base64Image,
        "latitude": latitude,
        "longitude": longitude,
        "parkingInfoDone": true,
      });

      await refreshOwnerData();
    } catch (e) {
      // ignore: avoid_print
      print("Parking info error: $e");
      Utils.snackBar("Error", "Failed to save parking info", true);
    }
  }

  Future<void> submitForm() async {
    final user = _auth.currentUser;
    if (user == null) {
      Utils.snackBar("Error", "User not logged in", true);
      return;
    }

    try {
      await _firestore.collection("pending_owner").doc(user.uid).update({
        "formSubmitted": true,
        "status": "pending",
      });

      await refreshOwnerData();
    } catch (e) {
      // ignore: avoid_print
      print("Form submission error: $e");
      Utils.snackBar("Error", "Failed to submit form", true);
    }
  }
}
