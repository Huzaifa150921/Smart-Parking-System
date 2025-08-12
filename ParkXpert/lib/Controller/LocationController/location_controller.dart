import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';

class LocationController extends GetxController {
  final box = GetStorage();

  Rx<LatLng?> currentLocation = Rx<LatLng?>(null);

  void setLocation(LatLng location) {
    currentLocation.value = location;

    // Save location persistently
    box.write('latitude', location.latitude);
    box.write('longitude', location.longitude);
  }

  void loadSavedLocation() {
    final lat = box.read('latitude');
    final lng = box.read('longitude');

    if (lat != null && lng != null) {
      currentLocation.value = LatLng(lat, lng);
    }
  }
}
