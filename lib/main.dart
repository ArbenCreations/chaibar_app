
import 'package:ChaatBar/model/request/verifyOtpChangePass.dart';
import 'package:ChaatBar/model/response/rf_bite/createOrderResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/productListResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/successCallbackResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/vendorListResponse.dart';
import 'package:ChaatBar/theme/AppTheme.dart';
import 'package:ChaatBar/utils/Helper.dart';
import 'package:ChaatBar/view/component/my_navigator_observer.dart';
import 'package:ChaatBar/view/component/toastMessage.dart';
import 'package:ChaatBar/view/screens/ChaatBar/active_upcoming_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/add_card_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/authenticationSection/splash_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/cart_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/choose_locality_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/edit_info_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/menu_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/dashboard_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/order_detail_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/order_overview_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/order_successful_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/product_detail_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/authenticationSection/signin_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/profile_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/vendor_location_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/vendor_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/authenticationSection/sign_up_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/authenticationSection/otp_verify_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/authenticationSection/forgot_password_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/authenticationSection/new_forgot_pass_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/authenticationSection/otp_forgot_pass_screen.dart';
import 'package:ChaatBar/view/screens/ChaatBar/bottom_nav.dart';
import 'package:ChaatBar/view/screens/coming_soon_screen.dart';
import 'package:ChaatBar/view_model/main_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'languageSection/AppLocalizationsDelegate.dart';
import 'languageSection/L10n.dart';
import 'model/response/notificationOtpResponse.dart';
import 'model/services/PushNotificationService.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await setupFlutterNotifications();
  print('Handling a background message ${message.messageId}');
}

late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Setup interaction with notifications
  await PushNotificationService().setupInteractedMessage();

  // Request notification permissions
  final permissionStatus = await Permission.notification.status;
  if (permissionStatus.isDenied) {
    await Permission.notification.request();
  }

  // Get initial message
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    print("FirebaseMessaging:: $initialMessage");
  }

  // Set preferred orientations and run app
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  runApp(MyApp(initialMessage: null));
}

class MyApp extends StatefulWidget {
  final RemoteMessage? initialMessage;

  MyApp({this.initialMessage});

  @override
  _MyAppState createState() => _MyAppState(initialMessage);
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  Locale _locale = const Locale('en');
  late String? _appTheme = 'Light';
  final RemoteMessage? initialMessage;

  ThemeMode _themeMode = ThemeMode.system;
  _MyAppState(this.initialMessage);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _toggleTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void setupNotificationHandlers(BuildContext context) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      ToastComponent.showToast(context: context, message: "$message");
      // Navigate to the ProfileScreen when the notification is clicked
      final notificationResponse = NotificationOtpResponse.fromJson(message.data);
     /* Navigator.push(
        navigatorKey.currentState!.context,
        MaterialPageRoute(
            builder: (context) => NotificationOtpScreen(
              data: notificationResponse,
            )),
      );*/
    });
  }


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: MainViewModel()),
      ],
      child: MaterialApp(
        navigatorObservers: [MyNavigatorObserver()],
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          title: 'Chaat-Bar',
          locale: _locale,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            // support localization string for Material Widget
            GlobalCupertinoLocalizations.delegate,
            // support localization string for Cupertino Widget
            GlobalWidgetsLocalizations.delegate,
            // support localization string for text format from right to left.
            AppLocalizationsDelegate()
          ],
          onGenerateRoute: (settings) {
            if (settings.name == '/CartScreen') {
              return _createPopupRoute();
            }
            return null;
          },
          supportedLocales: L10n.all,
          theme: AppTheme.getAppTheme(),
          themeMode: _themeMode,
          darkTheme: AppTheme.getDarkTheme(),
          initialRoute: '/',
          routes: {
            '/': (context) {
              NotificationOtpResponse? notificationResponse = NotificationOtpResponse(otp: "", notificationType: "");
              if(initialMessage?.data != null){
                notificationResponse = NotificationOtpResponse.fromJson(initialMessage!.data);
              }
              return /*SigninScreen();*/SplashScreen(data : notificationResponse);
            },
            '/SignInScreen': (context) {
              return SigninScreen();
            },
            '/ChooseLocalityScreen': (context) {
              final args =
              ModalRoute.of(context)!.settings.arguments as String?;
              return ChooseLocalityScreen(data: args,);
            },
            '/VendorLocationScreen': (context) {
              final args =
              ModalRoute.of(context)!.settings.arguments as String?;
              return VendorLocationScreen(data: args,);
            },
            '/ActiveOrUpcomingScreen': (context) {
              return ActiveOrUpcomingScreen();
            },
            '/VendorScreen': (context) {
              return VendorScreen();
            },
            '/DashboardScreen': (context) {
              return DashboardScreen();
            },
            '/CartScreen': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments as String;
              return CartScreen(theme: args,);
            },
            '/ProductDetailScreen': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments as ProductData;
              return ProductDetailScreen(data: args,);
            },
            '/MenuScreen': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments as VendorData;
              return MenuScreen(data: args,);
            },
            '/ProfileScreen': (context) {
              return ProfileScreen(onThemeChanged : _toggleTheme,);
            },
            '/BottomNav': (context) {
              return BottomNav(
                  onThemeChanged : _toggleTheme);
            },
            '/SignUpScreen': (context) {

              return SignUpScreen();
            },
            '/OTPVerifyScreen': (context) {
              final args =
              ModalRoute.of(context)!.settings.arguments as String?;
              return OTPVerifyScreen(data: args,);
            },
            '/OrderSuccessfulScreen': (context) {
              final args =
              ModalRoute.of(context)!.settings.arguments as SuccessCallbackResponse?;
              return OrderSuccessfulScreen(data: args);
            },
            '/OrderOverviewScreen': (context) {
              final args =
              ModalRoute.of(context)!.settings.arguments as CreateOrderResponse?;
              return OrderOverviewScreen(data: args);
            },
            '/EditInformationScreen': (context) {
              return EditInformationScreen();
            },
            '/OrderDetailScreen': (context) {
              final args =
              ModalRoute.of(context)!.settings.arguments as OrderDetails;
              return OrderDetailScreen(order: args);
            },
            '/ForgotPasswordScreen': (context) {
              return ForgotPasswordScreen();
            },
            '/OtpForgotPassScreen': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as String?;
              return OtpForgotPassScreen(data: args);
            },
            '/NewPassForgotPassScreen': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as VerifyOtChangePassRequest?;
              return NewPassForgotPassScreen(data: args);
            },
            '/AddCardScreen': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String,dynamic>?;
              return AddCardScreen(data: args?['data'] as String?,
                orderData: args?['orderData'] as CreateOrderResponse,);
            },
            '/ComingSoonScreen': (context) {
              return ComingSoonScreen();
            },


          }),

    );
  }


  void _fetchData() async {
    await Future.delayed(Duration(milliseconds: 2));
    var selectedLanguage = await Helper.getLocale();
    var selectedAppTheme = 'Light';
    print(selectedLanguage.languageCode);
    Helper.getAppThemeMode().then((appTheme) {
      setState(() {
        selectedAppTheme = "$appTheme" != "null" ? "$appTheme" : selectedAppTheme;
        _appTheme = '$selectedAppTheme';

        if("$_appTheme" == "Default") {
          print("value $_appTheme");
          _toggleTheme(ThemeMode.system);
        }else if("$_appTheme" == "Light")
        {
          _toggleTheme(ThemeMode.light);
        }else if("$_appTheme" == "Dark"){
          _toggleTheme(ThemeMode.dark);
        } else{
          _toggleTheme(ThemeMode.light);
        }
      });
    });
    // Ensure that setState is called synchronously after the async work is done
    if (mounted) {
      setState(() {
        _locale = Locale(selectedLanguage.languageCode);
      });
    }
  }

  Route _createPopupRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => CartScreen(theme: '',),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Scale transition for pop-up effect
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return ScaleTransition(
          scale: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
