import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:parkxpert/Models/my_pending_owner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parkxpert/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';

class OwnerController extends GetxController {
  Rx<MyPendingOwner?> currentUser = Rx<MyPendingOwner?>(null);
  RxBool isLoadingParkingPic = false.obs;
  RxString parkingImage = "".obs;
  RxBool isFormSubmit = false.obs;
  Rx<File?> selectedParkingImage = Rx<File?>(null);
  RxList<Map<String, dynamic>> ownerParkings = <Map<String, dynamic>>[].obs;
  final Rx<File?> selectedProfileImage = Rx<File?>(null);
  final RxString profileImageBase64 = ''.obs;
  final Rx<TextEditingController> nameController = TextEditingController().obs;
  var addressSuggestions = <String>[].obs;
  RxDouble selectedLat = 0.0.obs;
  RxDouble selectedLon = 0.0.obs;

  Future<void> fetchAndCopyPendingOwner() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        // ignore: avoid_print
        print("No user is logged in.");
        return;
      }

      // ignore: avoid_print
      print("Fetching pending owner for UID: $uid");
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('pending_owner').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        // ignore: avoid_print
        print("No pending owner data found for UID: $uid");
        return;
      }

      final data = doc.data()!;

      try {
        currentUser.value = MyPendingOwner.fromJson(data);
      } catch (e) {
        // ignore: avoid_print
        print("Error parsing MyPendingOwner: $e");
      }

      final ownerData = {
        'uid': uid,
        'profilePic': data['profilePic'],
        'firstName': data['firstName'],
        'lastName': data['lastName'],
        'accountCreated': FieldValue.serverTimestamp(),
      };

      // 🔍 Check for duplicate parking
      final existingParking = await firestore
          .collection('parkings')
          .where('uid', isEqualTo: uid)
          .where('parkingName', isEqualTo: data['parkingName'])
          .where('parkingAddress', isEqualTo: data['parkingAddress'])
          .where('latitude', isEqualTo: data['latitude'])
          .where('longitude', isEqualTo: data['longitude'])
          .get();

      if (existingParking.docs.isNotEmpty) {
        // ignore: avoid_print
        print("Duplicate parking found. Skipping parking creation.");
      } else {
        final parkingDocRef = firestore.collection('parkings').doc();
        final randomPuid = parkingDocRef.id;

        final parkingData = {
          'uid': uid,
          'puid': randomPuid,
          'parkingName': data['parkingName'],
          'parkingAddress': data['parkingAddress'],
          'parkingImage': data['parkingImage'],
          'longitude': data['longitude'],
          'latitude': data['latitude'],
          'parkingEarning': 0,
          'price': 145,
          'isDisable': false,
          'accountCreated': FieldValue.serverTimestamp(),
        };

        await parkingDocRef.set(parkingData);
        // ignore: avoid_print
        print("Parking created with puid: $randomPuid");
      }

      // Always create/update owner data
      await firestore.collection('owners').doc(uid).set(ownerData);
      // ignore: avoid_print
      print("Owner created/updated for UID: $uid");
    } catch (e, stack) {
      // ignore: avoid_print
      print("Error copying pending owner: $e");
      // ignore: avoid_print
      print("Stacktrace: $stack");
    }
  }

  Future<void> createPendingParkingIfNotExists() async {
    // ignore: avoid_print
    print("createPendingParkingIfNotExists() called");

    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        // ignore: avoid_print
        print("UID is null, user not logged in.");
        return;
      }

      // ignore: avoid_print
      print("UID: $uid");

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot doc =
          await firestore.collection("pending_parking").doc(uid).get();

      // ignore: avoid_print
      print("Document exists: ${doc.exists}");

      if (!doc.exists) {
        await firestore.collection("pending_parking").doc(uid).set({
          'uid': uid,
          'parkingName': null,
          'parkingAddress': null,
          'parkingImage': null,
          'status': "pending",
          'isFormSubmit': false,
          'longitude': null,
          'latitude': null,
          'reason': "",
          'accountCreated': Timestamp.now(),
        });
        // ignore: avoid_print
        print("Document created for UID: $uid");
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error: $e");
      Utils.snackBar("Error", "Server Error", true);
    }
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      PermissionStatus cameraStatus = await Permission.camera.status;
      PermissionStatus photosStatus = await Permission.photos.status;

      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }
      if (!photosStatus.isGranted) {
        photosStatus = await Permission.photos.request();
      }

      if (cameraStatus.isPermanentlyDenied ||
          photosStatus.isPermanentlyDenied) {
        openAppSettings();
        return false;
      }

      return cameraStatus.isGranted && photosStatus.isGranted;
    } else if (Platform.isIOS) {
      PermissionStatus photosStatus = await Permission.photos.status;

      if (!photosStatus.isGranted) {
        photosStatus = await Permission.photos.request();
      }

      if (photosStatus.isPermanentlyDenied) {
        openAppSettings();
        return false;
      }

      return photosStatus.isGranted;
    }
    return false;
  }

  Future<File?> pickParkingImage(BuildContext context) async {
    bool hasPermission = await _requestPermissions();
    if (!hasPermission) {
      Utils.snackBar(
        "Permission Denied",
        "You need to grant permissions for camera and gallery.",
        true,
      );
      return null;
    }

    File? pickedFile;

    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Choose a Source',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading:
                        const Icon(Icons.camera_alt, color: Colors.cyanAccent),
                    title: const Text("Take a Photo",
                        style: TextStyle(color: Colors.white)),
                    onTap: () async {
                      Navigator.pop(context);
                      final picked = await ImagePicker()
                          .pickImage(source: ImageSource.camera);
                      if (picked != null) pickedFile = File(picked.path);
                      selectedParkingImage.value = pickedFile;
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library,
                        color: Colors.cyanAccent),
                    title: const Text("Choose from Gallery",
                        style: TextStyle(color: Colors.white)),
                    onTap: () async {
                      Navigator.pop(context);
                      final picked = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (picked != null) pickedFile = File(picked.path);
                      selectedParkingImage.value = pickedFile;
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return pickedFile;
  }

  Future<void> updateParkingPic(File imageFile) async {
    isLoadingParkingPic.value = true;

    if (!imageFile.existsSync()) {
      Utils.snackBar("Error", "Image file does not exist.", true);
      isLoadingParkingPic.value = false;
      return;
    }

    final compressedImage = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      quality: 30,
    );

    if (compressedImage == null || compressedImage.length > 256 * 1024) {
      Utils.snackBar("Error", "Image size should be less than 256 kb", true);
      isLoadingParkingPic.value = false;
      return;
    }

    try {
      String base64Image = base64Encode(compressedImage);
      String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      parkingImage.value = base64Image;
      if (uid.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection("pending_parking")
            .doc(uid)
            .update({
          "parkingImage": base64Image,
        });

        currentUser.update((user) {
          user?.parkingImage = base64Image;
        });
      } else {
        Utils.snackBar("Error", "User not authenticated.", true);
      }
    } catch (e) {
      Utils.snackBar("Error", "Something went wrong. Try again!", true);
    }

    isLoadingParkingPic.value = false;
  }

  // update parking details
  Future<void> updateParkingInfo(
      String parkingName, String parkingAddress, double lat, double lon) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        Utils.snackBar("Error", "User not authenticated.", true);
        return;
      }

      if (parkingName.trim().isEmpty || parkingAddress.trim().isEmpty) {
        Utils.snackBar(
            "Error", "Parking Name and Address cannot be empty.", true);
        return;
      }

      if (parkingImage.value.trim().isEmpty) {
        Utils.snackBar("Error", "Parking Image is required.", true);
        return;
      }

      final docRef =
          FirebaseFirestore.instance.collection("pending_parking").doc(uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        Utils.snackBar("Error", "Owner data not found.", true);
        return;
      }

      await docRef.update({
        "parkingName": parkingName.trim(),
        "parkingAddress": parkingAddress.trim(),
        "latitude": lat,
        "longitude": lon,
      });

      currentUser.update((user) {
        user?.parkingName = parkingName.trim();
        user?.parkingAddress = parkingAddress.trim();
      });
    } catch (e) {
      Utils.snackBar("Error", "Something went wrong. Try again!", true);
    }
  }

  Future<void> formSubmit() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Utils.snackBar("Error", "User not authenticated.", true);
      return;
    }

    isFormSubmit.value = true;

    try {
      await FirebaseFirestore.instance
          .collection("pending_parking")
          .doc(uid)
          .update({'isFormSubmit': true});

      currentUser.update((user) {
        user?.formSubmitted = true;
      });
    } catch (e) {
      Utils.snackBar("Error", "Something wents wrong", true);
    }
  }

  // get form submit value
  Future<void> loadFormSubmitStatus() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      isFormSubmit.value = false;
      return;
    }

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("pending_parking")
          .doc(uid)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        bool submitted = snapshot['isFormSubmit'] ?? false;
        isFormSubmit.value = submitted;
      }
    } catch (e) {
      isFormSubmit.value = false;
    }
  }

  // Fetch all parkings associated with the current owner UID
  Future<void> fetchOwnerParkings() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        // ignore: avoid_print
        print("User not logged in");
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('parkings')
          .where('uid', isEqualTo: uid)
          .get();

      ownerParkings.value = snapshot.docs
          .map((doc) => {
                'puid': doc.id, // include the parking UID
                // ignore: unnecessary_cast
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching parkings: $e');
    }
  }

  Future<void> loadOwnerProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('owners').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          nameController.value.text = data['firstName'] ?? '';
          profileImageBase64.value = data['profilePic'] ?? '';
        }
      }
    } catch (e) {
      Utils.snackBar("Error", "Failed to load profile", true);
    }
  }

  /// Save profile image + name to Firestore
  Future<void> saveOwnerProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final name = nameController.value.text.trim();
    if (name.isEmpty) {
      Utils.snackBar("Error", "Name cannot be empty", true);
      return;
    }

    String? finalBase64;
    if (selectedProfileImage.value != null) {
      final imageFile = selectedProfileImage.value!;
      final compressed = await FlutterImageCompress.compressWithFile(
          imageFile.path,
          quality: 30);
      if (compressed != null && compressed.length < 256 * 1024) {
        finalBase64 = base64Encode(compressed);
      } else {
        Utils.snackBar("Error", "Image must be under 256KB", true);
        return;
      }
    }

    try {
      final updateData = {
        'firstName': name,
      };
      if (finalBase64 != null) {
        updateData['profilePic'] = finalBase64;
        profileImageBase64.value = finalBase64;
      }

      await FirebaseFirestore.instance
          .collection('owners')
          .doc(uid)
          .update(updateData);
      Utils.snackBar("Success", "Profile updated", false);
    } catch (e) {
      Utils.snackBar("Error", "Failed to save profile", true);
    }
  }

  Future<File?> pickProfileImage(BuildContext context) async {
    bool hasPermission = await _requestPermissions();
    if (!hasPermission) {
      Utils.snackBar(
        "Permission Denied",
        "You need to grant permissions for camera and gallery.",
        true,
      );
      return null;
    }

    File? pickedFile;

    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Choose a Source',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading:
                        const Icon(Icons.camera_alt, color: Colors.cyanAccent),
                    title: const Text("Take a Photo",
                        style: TextStyle(color: Colors.white)),
                    onTap: () async {
                      Navigator.pop(context);
                      final picked = await ImagePicker()
                          .pickImage(source: ImageSource.camera);
                      if (picked != null) pickedFile = File(picked.path);
                      selectedProfileImage.value = pickedFile;
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library,
                        color: Colors.cyanAccent),
                    title: const Text("Choose from Gallery",
                        style: TextStyle(color: Colors.white)),
                    onTap: () async {
                      Navigator.pop(context);
                      final picked = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (picked != null) pickedFile = File(picked.path);
                      selectedProfileImage.value = pickedFile;
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return pickedFile;
  }

  Future<void> fetchAndCopyPendingParking() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        // ignore: avoid_print
        print("No user is logged in.");
        return;
      }

      // ignore: avoid_print
      print("Fetching pending parking for UID: $uid");

      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('pending_parking').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        // ignore: avoid_print
        print("No pending parking data found for UID: $uid");
        return;
      }

      final data = doc.data()!;
      final parkingName = data['parkingName'];
      final parkingAddress = data['parkingAddress'];
      final parkingImage = data['parkingImage'];
      final latitude = data['latitude'];
      final longitude = data['longitude'];

      final duplicateQuery = await firestore
          .collection('parkings')
          .where('uid', isEqualTo: uid)
          .where('parkingName', isEqualTo: parkingName)
          .where('parkingAddress', isEqualTo: parkingAddress)
          .where('latitude', isEqualTo: latitude)
          .where('longitude', isEqualTo: longitude)
          .get();

      if (duplicateQuery.docs.isNotEmpty) {
        // ignore: avoid_print
        print("Duplicate parking found. Skipping creation.");
        return;
      }

      final parkingDocRef = firestore.collection('parkings').doc();
      final randomPuid = parkingDocRef.id;

      final parkingData = {
        'uid': uid,
        'puid': randomPuid,
        'parkingName': parkingName,
        'parkingAddress': parkingAddress,
        'parkingImage': parkingImage,
        'longitude': longitude,
        'latitude': latitude,
        'parkingEarning': 0,
        'price': 145,
        'isDisable': false,
        'accountCreated': FieldValue.serverTimestamp(),
      };

      await parkingDocRef.set(parkingData);
      // ignore: avoid_print
      print("Parking created in 'parkings' collection with PUID: $randomPuid");
    } catch (e, stack) {
      // ignore: avoid_print
      print("Error copying pending parking: $e");
      // ignore: avoid_print
      print("Stacktrace: $stack");
    }
  }

  Future<void> deletePendingParking() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Utils.snackBar("Error", "User not logged in", true);
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("pending_parking")
          .doc(uid)
          .delete();
      // ignore: avoid_print
      print("Pending parking deleted for UID: $uid");
    } catch (e) {
      Utils.snackBar("Error", "Failed to delete pending parking", true);
    }
  }

  Future<void> fetchAddressSuggestions(String query) async {
    if (query.isEmpty) {
      addressSuggestions.clear();
      return;
    }

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5&countrycodes=pk');

    final response = await http.get(url, headers: {
      'User-Agent':
          'FlutterApp/1.0 (hk2795091@gmail.com)' // required by Nominatim
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      addressSuggestions.value =
          data.map((item) => item['display_name'] as String).toList();
    } else {
      addressSuggestions.clear();
    }
  }
}
