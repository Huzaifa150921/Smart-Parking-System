import 'package:get/get.dart';
import 'package:parkxpert/Views/Auth/login_screen.dart';
import 'package:parkxpert/Views/Auth/owner_registration.dart';
import 'package:parkxpert/Views/Auth/signup_screen.dart';
import 'package:parkxpert/Views/Auth/welcome_screen.dart';
import 'package:parkxpert/Views/Intro%20Screen/intro.dart';
import 'package:parkxpert/Views/Owner%20Screen/main_owner_screen.dart';
import 'package:parkxpert/Views/Owner%20Screen/owner_desition.dart';
import 'package:parkxpert/Views/Owner%20Screen/owner_help_screen.dart';
import 'package:parkxpert/Views/Owner%20Screen/owner_parking_detail_screen.dart';
import 'package:parkxpert/Views/Owner%20Screen/owner_parking_screen.dart';
import 'package:parkxpert/Views/Owner%20Screen/owner_profile_screen.dart';
import 'package:parkxpert/Views/Owner%20Screen/owner_rateus_screen.dart';
import 'package:parkxpert/Views/Owner%20Screen/owner_register_parking_screen.dart';
import 'package:parkxpert/Views/Owner%20Screen/owner_registration_parking_status.dart';
import 'package:parkxpert/Views/Owner%20Screen/owner_registration_status.dart';
import 'package:parkxpert/Views/Owner%20Screen/owner_review_screen.dart';
import 'package:parkxpert/Views/Owner%20Screen/owner_support_screen.dart';
import 'package:parkxpert/Views/Owner%20Screen/revenue.dart';
import 'package:parkxpert/Views/Widgets/Owner%20Screen/ownerRegistration/owner_registration_screen.dart';
import 'package:parkxpert/Views/Widgets/user_screens/displayparking/displayparking.dart';
import 'package:parkxpert/Views/Widgets/user_screens/drawe_screens/Notifications_screen.dart';
import 'package:parkxpert/Views/Widgets/user_screens/drawe_screens/help_screen.dart';
import 'package:parkxpert/Views/Widgets/user_screens/drawe_screens/rateus_screen.dart';
import 'package:parkxpert/Views/Widgets/user_screens/drawe_screens/support_screen.dart';
import 'package:parkxpert/Views/Widgets/user_screens/drawe_screens/profile_screen.dart';
import 'package:parkxpert/Views/Widgets/user_screens/drawe_screens/settings_screen.dart';
import 'package:parkxpert/Views/Widgets/user_screens/drawe_screens/user_bookings_screen.dart';
import 'package:parkxpert/Views/splash_screen.dart';
import 'package:parkxpert/Views/user_screen/booking_detail_screen.dart';
import 'package:parkxpert/Views/user_screen/fine_screen.dart';

import 'package:parkxpert/Views/user_screen/main_screen.dart';
import 'package:parkxpert/Views/user_screen/parking_route.dart';
import 'package:parkxpert/Views/user_screen/parking_route_for_active_booking.dart';
import 'package:parkxpert/Views/user_screen/pending_review.dart';
import 'package:parkxpert/Views/user_screen/rules_and_terms.dart';
import 'package:parkxpert/res/routes/route_name.dart';

class Approutes {
  static appRoutes() => [
        // Splash Screen Route
        GetPage(
          name: RouteName.splashScreen,
          page: () => SplashScreen(),
        ),

        // Intro Screen Route
        GetPage(
          name: RouteName.intro,
          page: () => Intro(),
          transition: Transition.downToUp,
          transitionDuration: Duration(seconds: 1),
        ),

        // User Auth Route
        GetPage(
          name: RouteName.login,
          page: () => LoginScreen(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.signup,
          page: () => SignupScreen(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),

        // User Screens Route
        GetPage(
          name: RouteName.userScreen,
          page: () => MainScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.displayParking,
          page: () => DisplayParking(),
          transition: Transition.downToUp,
          transitionDuration: Duration(milliseconds: 600),
        ),
        GetPage(
          name: RouteName.profileScreen,
          page: () => ProfileScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(milliseconds: 600),
        ),
        GetPage(
          name: RouteName.bookingScreen,
          page: () => UserBookingsScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(milliseconds: 600),
        ),
        GetPage(
          name: RouteName.notificationScreen,
          page: () => NotificationsScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(milliseconds: 600),
        ),
        GetPage(
          name: RouteName.settingScreen,
          page: () => SettingsScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(milliseconds: 600),
        ),
        GetPage(
          name: RouteName.helpScreen,
          page: () => HelpScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(milliseconds: 600),
        ),
        GetPage(
          name: RouteName.supportScreen,
          page: () => SupportScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(milliseconds: 600),
        ),
        GetPage(
          name: RouteName.rateusScreen,
          page: () => RateusScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(milliseconds: 600),
        ),

        // Owner Screen Route
        GetPage(
          name: RouteName.ownerDesitionScreen,
          page: () => OwnerDesition(),
          transition: Transition.leftToRight,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerRegistration,
          page: () => OwnerRegistration(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerRegistrationTrack,
          page: () => OwnerRegistrationScreen(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerRegistrationStatus,
          page: () => OwnerRegistrationStatus(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.mainOwnerScreen,
          page: () => MainOwnerScreen(),
          transition: Transition.leftToRight,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerProfile,
          page: () => OwnerProfileScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(seconds: 1),
        ),

        GetPage(
          name: RouteName.ownerparking,
          page: () => OwnerParkingScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerparkingdetail,
          page: () => OwnerParkingDetailScreen(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerReview,
          page: () => OwnerReviewScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerRegisterParking,
          page: () => OwnerRegisterParkingScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerHelp,
          page: () => OwnerHelpScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerRateUs,
          page: () => OwnerRateusScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerSupport,
          page: () => OwnerSupportScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerRegistrationParkingStatus,
          page: () => OwnerRegistrationParkingStatus(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.parkingRoute,
          page: () => ParkingRoute(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.parkingRouteActiveBooking,
          page: () => ParkingRouteForActiveBooking(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.bookingDetailScreen,
          page: () => BookingDetailScreen(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.userScreenfadein,
          page: () => MainScreen(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerProfilefadein,
          page: () => OwnerProfileScreen(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerparkingfadein,
          page: () => OwnerParkingScreen(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerReviewfadein,
          page: () => OwnerReviewScreen(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerHelpfadein,
          page: () => OwnerHelpScreen(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerSupportfadein,
          page: () => OwnerHelpScreen(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.mainOwnerScreenfade,
          page: () => MainOwnerScreen(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerDesitionScreenfade,
          page: () => OwnerDesition(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.revenueScreen,
          page: () => Revenue(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.welcomeScreen,
          page: () => WelcomeScreen(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.ownerRegisterParkingfade,
          page: () => OwnerRegisterParkingScreen(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.userFineScreen,
          page: () => FineScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.pendingReview,
          page: () => PendingReview(),
          transition: Transition.downToUp,
          transitionDuration: Duration(seconds: 1),
        ),
        GetPage(
          name: RouteName.rulesTerms,
          page: () => RulesAndTerms(),
          transition: Transition.fadeIn,
          transitionDuration: Duration(seconds: 1),
        ),
      ];
}
