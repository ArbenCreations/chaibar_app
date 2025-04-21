import 'package:ChaiBar/view/screens/authentication/changePasswordScreen.dart';
import 'package:ChaiBar/view/screens/authentication/forgotPassword/forgotPasswordScreen.dart';
import 'package:ChaiBar/view/screens/authentication/getStartedScreen.dart';
import 'package:ChaiBar/view/screens/authentication/loginScreen.dart';
import 'package:ChaiBar/view/screens/authentication/otpVerifyScreen.dart';
import 'package:ChaiBar/view/screens/authentication/registerScreen.dart';
import 'package:ChaiBar/view/screens/authentication/signup.dart';
import 'package:ChaiBar/view/screens/authentication/vendorsListScreen.dart';
import 'package:ChaiBar/view/screens/profile/locationListScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'language/AppLocalizationsDelegate.dart';
import 'language/LanguageList.dart';
import 'model/request/verifyOtpChangePass.dart';
import 'model/response/createOrderResponse.dart';
import 'model/response/productListResponse.dart';
import 'model/response/successCallbackResponse.dart';
import 'model/response/vendorListResponse.dart';
import 'model/services/AuthenticationProvider.dart';
import 'model/viewModel/mainViewModel.dart';
import 'theme/CustomAppTheme.dart';
import 'view/component/my_navigator_observer.dart';
import 'view/screens/authentication/forgotPassword/forgotPasswordOtpScreen.dart';
import 'view/screens/authentication/splashScreen.dart';
import 'view/screens/bottomNavigation.dart';
import 'view/screens/history/activeOrdersScreen.dart';
import 'view/screens/order/couponsScreen.dart';
import 'view/screens/order/homeScreen.dart';
import 'view/screens/order/menuScreen.dart';
import 'view/screens/order/myCartScreen.dart';
import 'view/screens/order/order_detail_screen.dart';
import 'view/screens/order/order_overview_screen.dart';
import 'view/screens/order/order_successful_screen.dart';
import 'view/screens/order/paymentCardScreen.dart';
import 'view/screens/order/product_detail_screen.dart';
import 'view/screens/profile/editInfoScreen.dart';
import 'view/screens/profile/editProfileScreen.dart';
import 'view/screens/profile/profileScreen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Clear all notifications when app is resumed or opened
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterLocalNotificationsPlugin().cancelAll();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>(
          create: (_) => FirebaseAuth.instance,
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AuthenticationProvider(context.read<FirebaseAuth>()),
        ),
        ChangeNotifierProvider(create: (context) => MainViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        navigatorObservers: [MyNavigatorObserver()],
        locale: const Locale('en'),
        supportedLocales: LanguageList.all,
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        title: 'Chai-Bar',
        theme: CustomAppTheme.getAppTheme(),
        darkTheme: CustomAppTheme.getDarkTheme(),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(), // splash does initialization
          '/SignInScreen': (context) {
            return SigninScreen();
          },
          '/VendorsListScreen': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as String?;

            return VendorsListScreen(data: args);
          },
          '/ActiveOrdersScreen': (context) {
            return ActiveOrdersScreen();
          },
          '/HomeScreen': (context) {
            return HomeScreen();
          },
          '/MyCartScreen': (context) {
            return MyCartScreen();
          },
          '/SignUpPage': (context) {
            return SignUpPage();
          },
          '/ProductDetailScreen': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments as ProductData;
            return ProductDetailScreen(
              data: args,
            );
          },
          '/MenuScreen': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments as VendorData;
            return MenuScreen(
              data: args,
            );
          },
          '/ProfileScreen': (context) {
            return ProfileScreen();
          },
          '/BottomNavigation': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as int?;
            return BottomNavigation(
                data: args ?? 0); // Provide a default value if null
          },
          '/RegisterScreen': (context) {
            return RegisterScreen();
          },
          '/OTPVerifyScreen': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as String?;
            return OTPVerifyScreen(
              data: args,
            );
          },
          '/OrderSuccessfulScreen': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>?;
            return OrderSuccessfulScreen(
              data: args?['data'] as SuccessCallbackResponse?,
              orderData: args?['orderData'] as CreateOrderResponse,
              pointsEarned: args?['pointsEarned'] as String,
            );
          },
          '/OrderOverviewScreen': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as CreateOrderResponse?;
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
            final args = ModalRoute.of(context)!.settings.arguments as String?;
            return OtpForgotPassScreen(data: args);
          },
          '/NewPassForgotPassScreen': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as VerifyOtChangePassRequest?;
            return NewPassForgotPassScreen(data: args);
          },
          '/PaymentCardScreen': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>?;
            return PaymentCardScreen(
              data: args?['data'] as String?,
              rewardPoints: args?['rewardPoints'] as String?,
              orderData: args?['orderData'] as CreateOrderResponse,
            );
          },
          '/EditProfileScreen': (context) {
            return EditProfileScreen();
          },
          '/CouponsScreen': (context) {
            return CouponsScreen();
          },
          '/LocationListScreen': (context) {
            return LocationListScreen();
          },
          '/GetStartedScreen': (context) {
            return GetStartedScreen();
          },
          // other routes...
        },
      ),
    );
  }
}
