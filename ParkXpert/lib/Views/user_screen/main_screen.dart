import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parkxpert/Views/Widgets/extra%20features/double_tap_exit_feature.dart';
import 'package:parkxpert/Views/Widgets/user_screens/drawer/user_drawer.dart';
import 'package:parkxpert/Views/user_screen/active_bookings.dart';
import 'package:parkxpert/Views/user_screen/map_screen.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Color navigationBarColor = Colors.black;
  int selectedIndex = 0;
  late PageController pageController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;
    return DoubleTapExitFeature(
      bgColor: Colors.white,
      textColor: Colors.black,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: navigationBarColor,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          key: _scaffoldKey,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(screenheight * 0.0001),
            child: AppBar(
              centerTitle: true,
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
          ),
          extendBodyBehindAppBar: true,
          drawer: UserDrawer(),
          body: Stack(
            children: [
              PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                children: <Widget>[
                  SizedBox(
                    child: MapScreen(),
                  ),
                  SizedBox(
                    child: ActiveBookings(),
                  ),
                ],
              ),
              Positioned(
                top: screenheight * 0.07,
                left: screenwidth * 0.05,
                child: GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 2,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.menu, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: WaterDropNavBar(
            backgroundColor: navigationBarColor,
            waterDropColor: Colors.blue,
            onItemSelected: (int index) {
              setState(() {
                selectedIndex = index;
              });
              pageController.animateToPage(selectedIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutQuad);
            },
            selectedIndex: selectedIndex,
            barItems: <BarItem>[
              BarItem(
                  filledIcon: Icons.pin_drop,
                  outlinedIcon: Icons.pin_drop_outlined),
              BarItem(
                  filledIcon: Icons.save, outlinedIcon: Icons.save_outlined),
            ],
          ),
        ),
      ),
    );
  }
}
