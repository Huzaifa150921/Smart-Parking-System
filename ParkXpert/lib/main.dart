import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:parkxpert/Controller/LocationController/location_controller.dart';
import 'package:parkxpert/Controller/NotificationTracker/notification_controller.dart';
import 'package:parkxpert/Controller/Owner%20Controller/owner_controller.dart';
import 'package:parkxpert/Controller/Owner%20Controller/owner_registration_track_controller.dart';
import 'package:parkxpert/Controller/UserController/user_controller.dart';
import 'package:parkxpert/res/getxLocalization/languages.dart';
import 'package:parkxpert/res/routes/route_name.dart';
import 'package:parkxpert/res/routes/routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  Stripe.publishableKey = 'Your Api key';
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(UserController());
  Get.put(OwnerRegistrationTrackController());
  Get.put(OwnerController());
  Get.put(LocationController());
  Get.put(NotificationController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Park Xpert',
      translations: Languages(),
      locale: Locale('en', 'US'),
      fallbackLocale: Locale('en', 'US'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      getPages: Approutes.appRoutes(),
      debugShowCheckedModeBanner: false,
      initialRoute: RouteName.splashScreen,
    );
  }
}
