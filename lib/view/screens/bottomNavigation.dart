import 'package:ChaiBar/view/screens/order/couponsScreen.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../theme/CustomAppColor.dart';
import '../../utils/Helper.dart';
import 'history/orderHistoryScreen.dart';
import 'order/homeScreen.dart';
import 'profile/profileScreen.dart';

class BottomNavigation extends StatefulWidget {
  final int? data; // Make it nullable
  BottomNavigation({this.data});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 1;
  final LocalAuthentication auth = LocalAuthentication();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _authOnResume = false;
  bool? isUserAuthenticated;
  static List<Widget> _widgetOptions = <Widget>[];
  Color primaryColor = CustomAppColor.Primary;
  Color? secondaryColor = Colors.red[100];
  Color? lightColor = Colors.red[50];
  int? activeOrderCount = 0;
  late PageController _pageController;

  @override
  void initState() {
    //_initializeBiometrics();
    super.initState();
    _selectedIndex = widget.data ?? 1;
    _pageController = PageController(initialPage: _selectedIndex);
    _widgetOptions = <Widget>[
      OrderHistoryScreen(),
      HomeScreen(),
      CouponsScreen(),
      ProfileScreen(),
    ];
    Helper.getUserAuthenticated().then((onValue) {
      isUserAuthenticated = onValue;
    });
    Helper.getActiveOrderCounts().then((count) {
      setState(() {
        activeOrderCount = count;
      });
    });
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceIn,
    );

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _widgetOptions,
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: BottomNavyBar(
          borderRadius: BorderRadius.circular(30),
          backgroundColor: CustomAppColor.BottomNavColor,
          selectedIndex: _selectedIndex,
          showElevation: true,
          onItemSelected: (index) {
            setState(() {
              _onItemTapped(index);
              _selectedIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
          spreadRadius: 2,
          items: [
            BottomNavyBarItem(
              icon: Stack(
                children: [
                  Icon(
                    Icons.history,
                    size: 24,
                    color: _selectedIndex == 0 ? Colors.white : Colors.white54,
                  ),
                  if (activeOrderCount! > 0)
                    Positioned(
                      right: 0,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 10,
                          minHeight: 10,
                        ),
                        child: Text(
                          '$activeOrderCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              textAlign: TextAlign.center,
              title: Text(
                '   Orders',
                style: TextStyle(fontSize: 12),
              ),
              activeColor: _selectedIndex == 0 ? Colors.white : Colors.white54,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.home_rounded),
              textAlign: TextAlign.center,
              title: Text(
                '   Home',
                style: TextStyle(fontSize: 12),
              ),
              activeColor: _selectedIndex == 1 ? Colors.white : Colors.white54,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.discount),
              textAlign: TextAlign.center,
              title: Text(
                '   Coupons',
                style: TextStyle(fontSize: 12),
              ),
              activeColor: _selectedIndex == 2 ? Colors.white : Colors.white54,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.person),
              textAlign: TextAlign.center,
              title: Text(
                '   Profile',
                style: TextStyle(fontSize: 12),
              ),
              activeColor: _selectedIndex == 3 ? Colors.white : Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
