import 'package:ChaatBar/theme/AppColor.dart';
import 'package:ChaatBar/view/screens/ChaatBar/dashboard_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/profile_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../utils/Helper.dart';
import 'history_screen.dart';

class BottomNav extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  BottomNav({ required this.onThemeChanged});
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 1;
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometric = false;
  bool _authenticationAttempted = false; // Add this flag
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _authOnResume = false;
  bool? isUserAuthenticated;
  static List<Widget> _widgetOptions = <Widget>[];
  int _page = 1;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  String? theme = "";
  Color primaryColor = AppColor.PRIMARY;
  Color? secondaryColor = Colors.red[100];
  Color? lightColor = Colors.red[50];

  @override
  void initState() {
    //_initializeBiometrics();
    super.initState();
    Helper.getVendorTheme().then((onValue) {
      print("theme : $onValue");
      setState(() {
        theme = onValue;
        // setThemeColor();
      });
    });
    _widgetOptions = <Widget>[
      HistoryScreen(),
      DashboardScreen(),
      ProfileScreen(
          onThemeChanged : widget.onThemeChanged),

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

    if (state == AppLifecycleState.resumed) {
      if (!_authOnResume) {
        setState(() {
          _authenticationAttempted = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void setThemeColor() {
    if (theme == "blue") {
      setState(() {
        primaryColor = Colors.blue.shade900;
        secondaryColor = Colors.blue[100];
        lightColor = Colors.blue[50];
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CurvedNavigationBar(
        height: 56,
        key: _bottomNavigationKey,
        index: 1,
        items: <Widget>[
          Icon(Icons.history,
              size: 30, color: _page == 0 ? AppColor.SECONDARY : Colors.grey),
          Icon(Icons.home_rounded,
              size: 30, color: _page == 1 ? AppColor.SECONDARY : Colors.grey),
          Icon(Icons.person,
              size: 30, color: _page == 2 ? AppColor.SECONDARY : Colors.grey),
        ],
        color: isDarkMode ? AppColor.DARK_CARD_COLOR :Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: AppColor.PRIMARY,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _page = index;
            _onItemTapped(_page);
          });
        },
        letIndexChange: (index) => true,
      ),
      /*BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 56,
        color: Colors.blue, // Adjust color as needed
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () => {_onItemTapped(0)},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: _selectedIndex == 0 ? Colors.white : Colors.grey,
                      size: 25,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => {_onItemTapped(1)},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list,
                      color: _selectedIndex == 1 ? Colors.white : Colors.grey,
                      size: 25,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 48), // Space for the floating button
            GestureDetector(
              onTap: () => {_onItemTapped(2)},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.open_in_full,
                      color: _selectedIndex == 2 ? Colors.white : Colors.grey,
                      size: 25,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => {_onItemTapped(3)},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      color: _selectedIndex == 3 ? Colors.white : Colors.grey,
                      size: 25,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),*/
    );
  }
}
