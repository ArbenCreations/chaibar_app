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
    Helper.getActiveOrderCounts().then((count) {
      if (mounted) {
        setState(() {
          activeOrderCount= 0;
          activeOrderCount = count;
        });
      }
    });
    setState(() {
      _selectedIndex = index;
    });
    _animationController.forward(from: 0.0);
    // Fetch updated active order count on screen change

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
              _selectedIndex = index;
              _onItemTapped(index);
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
                alignment: Alignment.topRight,
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.history,
                    size: 24,
                    color: _selectedIndex == 0 ? Colors.white : Colors.white54,
                  ),
                  if (activeOrderCount! > 0)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$activeOrderCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
