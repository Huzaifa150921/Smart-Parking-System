import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:parkxpert/Controller/UserController/user_controller.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _box = GetStorage();

  final RxMap<String, Map<String, dynamic>> _statusCache =
      <String, Map<String, dynamic>>{}.obs;
  final RxMap<String, Map<String, dynamic>> _statusParkingCache =
      <String, Map<String, dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();

    final storedOwnerCacheRaw = _box.read('ownerStatusCache');
    final storedParkingCacheRaw = _box.read('parkingStatusCache');

    // Owner Cache Load and Migration
    if (storedOwnerCacheRaw is Map) {
      _statusCache.value = storedOwnerCacheRaw.map((key, value) {
        if (value is String) {
          return MapEntry(key, {
            'status': value,
            'formSubmitted': false,
          });
        } else if (value is Map) {
          return MapEntry(key, Map<String, dynamic>.from(value));
        } else {
          return MapEntry(key, {
            'status': '',
            'formSubmitted': false,
          });
        }
      });
    }

    // Parking Cache Load and Migration
    if (storedParkingCacheRaw is Map) {
      _statusParkingCache.value = storedParkingCacheRaw.map((key, value) {
        if (value is String) {
          return MapEntry(key, {
            'status': value,
            'formSubmitted': false,
          });
        } else if (value is Map) {
          return MapEntry(key, Map<String, dynamic>.from(value));
        } else {
          return MapEntry(key, {
            'status': '',
            'formSubmitted': false,
          });
        }
      });
    }

    listenToOwnerStatusChanges();
    listenToParkingStatusChanges();
    listenToBookingExpiryReminders();
    listenToCompletedBookingsForReview();
    // listenToUnstartedExpiredBookings();
  }

  // ------------------ OWNER LISTENER ------------------
  void listenToOwnerStatusChanges() {
    _firestore.collection('pending_owner').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String docId = doc.id;

        final String newStatus = data['status'] ?? '';
        final bool formSubmitted = data['formSubmitted'] ?? false;
        final String uid = data['uid'] ?? '';

        if (uid.isEmpty || newStatus.isEmpty) continue;

        final previous = _statusCache.putIfAbsent(
          docId,
          () => {'status': '', 'formSubmitted': false},
        );

        final bool statusChanged = previous['status'] != newStatus;
        final bool formChanged = previous['formSubmitted'] != formSubmitted;

        if (newStatus == 'pending' &&
            formSubmitted &&
            (statusChanged || formChanged)) {
          handleOwnerStatusChange(docId, data);
        }

        if ((newStatus == 'approved' || newStatus == 'rejected') &&
            statusChanged) {
          handleOwnerStatusChange(docId, data);
        }
      }
    });
  }

  void handleOwnerStatusChange(String docId, Map<String, dynamic> data) {
    final String uid = data['uid'] ?? '';
    final String newStatus = data['status'] ?? '';
    final bool formSubmitted = data['formSubmitted'] ?? false;

    _statusCache[docId] = {
      'status': newStatus,
      'formSubmitted': formSubmitted,
    };
    _box.write('ownerStatusCache', _statusCache);

    if (!Get.isRegistered<UserController>()) return;
    final controller = Get.find<UserController>();

    final commonData = {
      'status': newStatus,
      'firstName': data['firstName'] ?? '',
      'lastName': data['lastName'] ?? '',
      'parkingName': data['parkingName'] ?? '',
      'parkingAddress': data['parkingAddress'] ?? '',
    };

    switch (newStatus) {
      case 'approved':
        controller.sendInAppNotification(
          uid: uid,
          title: 'Request Approved',
          body: 'Your owner verification has been approved.',
          type: 'verification_status',
          data: commonData,
        );
        break;
      case 'rejected':
        controller.sendInAppNotification(
          uid: uid,
          title: 'Request Rejected',
          body: 'Your owner verification has been rejected.',
          type: 'verification_status',
          data: commonData,
        );
        break;
      case 'pending':
        if (formSubmitted) {
          controller.sendInAppNotification(
            uid: uid,
            title: 'Request Pending',
            body: 'Your owner request has been received.',
            type: 'verification_status',
            data: commonData,
          );
        }
        break;
    }
  }

  // ------------------ PARKING LISTENER ------------------
  void listenToParkingStatusChanges() {
    _firestore.collection('pending_parking').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String docId = doc.id;

        final String newStatus = data['status'] ?? '';
        final bool formSubmitted = data['isFormSubmit'] ?? false;
        final String uid = data['uid'] ?? '';

        if (uid.isEmpty || newStatus.isEmpty) continue;

        final previous = _statusParkingCache.putIfAbsent(
          docId,
          () => {'status': '', 'formSubmitted': false},
        );

        final bool statusChanged = previous['status'] != newStatus;
        final bool formChanged = previous['formSubmitted'] != formSubmitted;

        if (newStatus == 'pending' &&
            formSubmitted &&
            (statusChanged || formChanged)) {
          handleParkingStatusChange(docId, data);
        }

        if ((newStatus == 'approved' || newStatus == 'rejected') &&
            statusChanged) {
          handleParkingStatusChange(docId, data);
        }
      }
    });
  }

  Future<void> handleParkingStatusChange(
      String docId, Map<String, dynamic> data) async {
    final String uid = data['uid'] ?? '';
    final String newStatus = data['status'] ?? '';
    final bool formSubmitted = data['isFormSubmit'] ?? false;

    _statusParkingCache[docId] = {
      'status': newStatus,
      'formSubmitted': formSubmitted,
    };
    _box.write('parkingStatusCache', _statusParkingCache);

    if (!Get.isRegistered<UserController>()) return;
    final controller = Get.find<UserController>();

    String firstName = '';
    String lastName = '';

    try {
      final ownerDoc = await _firestore.collection('owners').doc(uid).get();
      final ownerData = ownerDoc.data();
      if (ownerData != null) {
        firstName = ownerData['firstName'] ?? '';
        lastName = ownerData['lastName'] ?? '';
      }
    } catch (_) {}

    final commonData = {
      'status': newStatus,
      'firstName': firstName,
      'lastName': lastName,
      'parkingName': data['parkingName'] ?? '',
      'parkingAddress': data['parkingAddress'] ?? '',
    };

    switch (newStatus) {
      case 'approved':
        controller.sendInAppNotification(
          uid: uid,
          title: 'Request Approved',
          body: 'Your parking has been approved.',
          type: 'parking_status',
          data: commonData,
        );
        break;
      case 'rejected':
        controller.sendInAppNotification(
          uid: uid,
          title: 'Request Rejected',
          body: 'Your parking has been rejected.',
          type: 'parking_status',
          data: commonData,
        );
        break;
      case 'pending':
        if (formSubmitted) {
          controller.sendInAppNotification(
            uid: uid,
            title: 'Request Pending',
            body: 'Your parking request has been received.',
            type: 'parking_status',
            data: commonData,
          );
        }
        break;
    }
  }

  // ------------------ Expiry Booking LISTENER ------------------
  void listenToBookingExpiryReminders() {
    _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String bookingId = doc.id;

        // Safely extract fields
        final Timestamp? createdAt = data['createdAt'];
        final int durationInDays = data['durationInDays'] ?? 0;
        final String userId = data['userId'] ?? '';
        final String parkingId = data['parkingId'] ?? '';
        final String slotId = data['slotid'] ?? '';
        final String plateNo = data['plateNo'] ?? '';

        // Skip if critical info is missing
        if (userId.isEmpty || createdAt == null || durationInDays == 0)
          continue;

        final expiryTime =
            createdAt.toDate().add(Duration(days: durationInDays));
        final now = DateTime.now();

        final difference = expiryTime.difference(now);

        // Check if expiring within next 30 mins (but not already expired)
        if (difference.inMinutes <= 30 && difference.inMinutes > 0) {
          // Avoid duplicate notifications
          if (_box.read('expiry_notified_$bookingId') == true) continue;

          _box.write('expiry_notified_$bookingId', true); // Mark as notified

          // Fetch parking name
          _firestore
              .collection('parkings')
              .doc(parkingId)
              .get()
              .then((parkingDoc) {
            final parkingName =
                parkingDoc.data()?['parkingName'] ?? 'your parking';

            if (Get.isRegistered<UserController>()) {
              final controller = Get.find<UserController>();

              controller.sendInAppNotification(
                uid: userId,
                title: 'Booking Expiring Soon',
                body:
                    "Reminder: Your booking at '$parkingName' in slot '$slotId' for vehicle '$plateNo' is expiring soon.",
                type: 'booking_expiry',
                data: {
                  'parkingName': parkingName,
                  'slotId': slotId,
                  'plateNo': plateNo,
                  'bookingId': bookingId,
                  'expiryTime': expiryTime.toIso8601String(),
                },
              );
            }
          });
        }
      }
    });
  }

  void listenToCompletedBookingsForReview() {
    _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'complete')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String bookingId = doc.id;
        final String userId = data['userId'] ?? '';
        final String parkingId = data['parkingId'] ?? '';
        final String plateNo = data['plateNo'] ?? '';
        final String status = data['status'] ?? '';

        if (userId.isEmpty || status != 'complete') {
          continue;
        }

        // Prevent duplicate notifications
        if (_box.read('review_notified_$bookingId') == true) continue;
        _box.write('review_notified_$bookingId', true);

        _firestore
            .collection('parkings')
            .doc(parkingId)
            .get()
            .then((parkingDoc) {
          final parkingName =
              parkingDoc.data()?['parkingName'] ?? 'your parking';

          final controller = Get.find<UserController>();
          controller.sendInAppNotification(
            uid: userId,
            title: 'Rate Your Parking Experience',
            body:
                "Please take a moment to rate your experience at '$parkingName' for vehicle '$plateNo'.",
            type: 'review_reminder',
            data: {
              'bookingId': bookingId,
              'parkingId': parkingId,
              'parkingName': parkingName,
              'plateNo': plateNo,
            },
          );
        });
      }
    });
  }

  // ------------------ listenToUnstartedExpiredBookings ------------------

  // void listenToUnstartedExpiredBookings() {
  //   _firestore
  //       .collection('bookings')
  //       .where('status', isEqualTo: 'active')
  //       .snapshots()
  //       .listen((snapshot) async {
  //     print("🔄 Checking active bookings snapshot...");

  //     for (var doc in snapshot.docs) {
  //       final data = doc.data();
  //       final String bookingId = doc.id;

  //       final Timestamp? createdAt = data['createdAt'];
  //       final int durationInDays = data['durationInDays'] ?? 0;
  //       final String userId = data['userId'] ?? '';
  //       final String parkingId = data['parkingId'] ?? '';
  //       final dynamic slotIdRaw = data['slotid'];
  //       final dynamic startTime = data['startTime'];

  //       print("📄 Booking ID: $bookingId");
  //       print("📅 CreatedAt: $createdAt | Duration (days): $durationInDays");
  //       print(
  //           "👤 userId: $userId | 📍 parkingId: $parkingId | 🕳️ slotId: $slotIdRaw");
  //       print("🚗 startTime: $startTime");

  //       if (userId.isEmpty ||
  //           createdAt == null ||
  //           durationInDays == 0 ||
  //           slotIdRaw == null) {
  //         print("❌ Skipping due to missing required data");
  //         continue;
  //       }

  //       final expiryTime =
  //           createdAt.toDate().add(Duration(days: durationInDays));
  //       final now = DateTime.now();

  //       print("⏳ ExpiryTime: $expiryTime | ⏰ Now: $now");

  //       if ((now.isAtSameMomentAs(expiryTime) || now.isAfter(expiryTime)) &&
  //           startTime == null) {
  //         print(
  //             "⚠️ Booking has expired and not started. Marking as completed...");

  //         try {
  //           // Step 1: Update booking status
  //           await _firestore.collection('bookings').doc(bookingId).update({
  //             'status': 'completed',
  //           });
  //           print("✅ Booking marked as completed");

  //           final int slotId = int.tryParse(slotIdRaw.toString()) ?? -1;
  //           if (slotId == -1) {
  //             print("❌ Invalid slot ID, skipping slot update");
  //             continue;
  //           }

  //           // Step 2: Free the slot in slot_monitoring_model_results
  //           final monitoringQuery = await _firestore
  //               .collection('slot_monitoring_model_results')
  //               .where('puid', isEqualTo: parkingId)
  //               .limit(1)
  //               .get();

  //           if (monitoringQuery.docs.isNotEmpty) {
  //             final doc = monitoringQuery.docs.first;
  //             final ref = doc.reference;
  //             final List<dynamic> slots = doc['slots'] ?? [];
  //             int freeSlots = (doc['free'] ?? 0) as int;

  //             final updatedSlots = slots.map((slot) {
  //               if (slot['slot_id'] == slotId) {
  //                 print("🔄 Changing slot $slotId status to 'free'");
  //                 return {
  //                   ...slot,
  //                   'status': 'free',
  //                 };
  //               }
  //               return slot;
  //             }).toList();

  //             await ref.update({
  //               'slots': updatedSlots,
  //               'free': freeSlots + 1,
  //             });
  //             print("✅ Slot updated and free count incremented");
  //           }

  //           // Step 3: Notify user
  //           if (Get.isRegistered<UserController>()) {
  //             final controller = Get.find<UserController>();
  //             controller.sendInAppNotification(
  //               uid: userId,
  //               title: 'Booking Marked as Completed',
  //               body:
  //                   'Your parking time has ended, and you didn’t arrive in time. The booking is now marked as completed.',
  //               type: 'auto_completed_no_show',
  //               data: {
  //                 'bookingId': bookingId,
  //                 'parkingId': parkingId,
  //                 'slotId': slotId,
  //               },
  //             );
  //             print("📩 Notification sent to user: $userId");
  //           } else {
  //             print("⚠️ UserController not registered, notification skipped");
  //           }
  //         } catch (e) {
  //           print("❗ Error while processing booking $bookingId: $e");
  //         }
  //       } else {
  //         print("✅ Booking still valid or already started.");
  //       }
  //     }
  //   });
  // }
}
