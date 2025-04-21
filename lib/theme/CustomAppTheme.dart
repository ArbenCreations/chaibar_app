import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'CustomAppColor.dart';

class CustomAppTheme {
  static ThemeData getAppTheme() {
    return ThemeData(
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.getFont('DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.black,
            letterSpacing: 0.5),
        actionsIconTheme: const IconThemeData(color: Colors.black),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: CustomAppColor.PrimaryAccent,
      ),
      bottomSheetTheme: BottomSheetThemeData(),
      tabBarTheme: TabBarTheme(
        dividerColor: Colors.black,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black45,
        indicatorColor: Colors.black,
        unselectedLabelStyle: TextStyle(
            fontSize: 12), /*indicatorSize: TabBarIndicatorSize.label*/
      ),
      timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          dialBackgroundColor: Colors.blue,
          dialHandColor: Colors.white,
          confirmButtonStyle: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue)),
          cancelButtonStyle: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.redAccent)),
          hourMinuteColor: Colors.blue,
          timeSelectorSeparatorColor:
              WidgetStateProperty.all(Colors.transparent),
          entryModeIconColor: Colors.blue),
      popupMenuTheme: PopupMenuThemeData(
        color: CustomAppColor.Primary,
      ),
      cardTheme: const CardTheme(color: Colors.white),
      primaryColor: CustomAppColor.Primary,
      highlightColor: CustomAppColor.Primary,
      scaffoldBackgroundColor: CustomAppColor.Background,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.getFont(
          'DM Sans',
          fontSize: 20,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
        displayMedium: GoogleFonts.getFont('DM Sans',
            fontSize: 18, fontWeight: FontWeight.normal, color: Colors.black),
        displaySmall: GoogleFonts.getFont('DM Sans',
            fontSize: 18, fontWeight: FontWeight.normal, color: Colors.black),
        titleLarge: GoogleFonts.getFont('DM Sans',
            fontSize: 18, fontWeight: FontWeight.normal, color: Colors.black),
        titleMedium: GoogleFonts.getFont('DM Sans',
            fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
        titleSmall: GoogleFonts.getFont('DM Sans',
            fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black),
        bodyLarge: GoogleFonts.getFont('DM Sans',
            fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
        bodyMedium: GoogleFonts.getFont(
          'DM Sans',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
        bodySmall: GoogleFonts.getFont('DM Sans',
            fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.getFont('DM Sans',
            fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey),
        iconColor: Colors.grey,
        suffixIconColor: Colors.black,
        prefixIconColor: Colors.black,
      ),
      listTileTheme: ListTileThemeData(
          iconColor: Colors.black,
          textColor: Colors.black,
          selectedColor: CustomAppColor.Primary),
      dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 22),
          iconColor: Colors.black),
      datePickerTheme: DatePickerThemeData(
        dayStyle: TextStyle(color: Colors.black, fontSize: 12),
        shape: Border(),
      ),
      iconTheme: IconThemeData(color: CustomAppColor.Primary),
      iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        foregroundColor: MaterialStateProperty.all<Color>(CustomAppColor.Primary),
      )),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(CustomAppColor.Primary),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)))))),
      toggleButtonsTheme: ToggleButtonsThemeData(
        selectedColor: CustomAppColor.Primary,
        fillColor: CustomAppColor.Primary.withOpacity(0.1),
        textStyle: const TextStyle(color: Colors.white),
        selectedBorderColor: CustomAppColor.Primary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: CustomAppColor.Primary,
        onPrimary: CustomAppColor.Primary,
        secondary: CustomAppColor.PrimaryAccent,
        onSecondary: CustomAppColor.PrimaryAccent,
        surface: Colors.black54,
        onSurface: CustomAppColor.Background,
        error: Colors.red,
        onError: Colors.red,
        background: Colors.black54,
        onBackground: Colors.black54,
        brightness: Brightness.light,
      ),
        pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            }
        ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: Colors.black),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.getFont('DM Sans',
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: CustomAppColor.DarkBackground,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: CustomAppColor.Primary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: CustomAppColor.DarkCardColor,
      ),
      datePickerTheme:
          DatePickerThemeData(dayStyle: TextStyle(color: Colors.white)),
      cardTheme: const CardTheme(
        color: CustomAppColor.DarkCardColor,
      ),
      primaryColor: CustomAppColor.Primary,
      highlightColor: CustomAppColor.Primary,
      scaffoldBackgroundColor: CustomAppColor.DarkBackground,
      dialogTheme: DialogTheme(
        backgroundColor: CustomAppColor.DarkCardColor,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 22),
        iconColor: Colors.white,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white24,
        indicatorColor: Colors.white,
        unselectedLabelStyle: TextStyle(
            fontSize: 12), /*indicatorSize: TabBarIndicatorSize.label*/
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.getFont('DM Sans',
            fontSize: 20, fontWeight: FontWeight.normal, color: Colors.white),
        displayMedium: GoogleFonts.getFont('DM Sans',
            fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white),
        displaySmall: GoogleFonts.getFont('DM Sans',
            fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white),
        titleLarge: GoogleFonts.getFont('DM Sans',
            fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white),
        titleMedium: GoogleFonts.getFont('DM Sans',
            fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white),
        titleSmall: GoogleFonts.getFont('DM Sans',
            fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white),
        bodyLarge: GoogleFonts.getFont('DM Sans',
            fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
        bodyMedium: GoogleFonts.getFont('DM Sans',
            fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white),
        bodySmall: GoogleFonts.getFont('DM Sans',
            fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
          hintStyle: GoogleFonts.getFont('DM Sans',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white70),
          iconColor: Colors.white70,
          suffixIconColor: Colors.white,
          prefixIconColor: Colors.white),
      iconTheme: IconThemeData(color: Colors.white),
      iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        foregroundColor: MaterialStateProperty.all<Color>(CustomAppColor.Primary),
      )),
      listTileTheme: ListTileThemeData(
          iconColor: Colors.white,
          textColor: Colors.white,
          selectedColor: CustomAppColor.Primary),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(CustomAppColor.DarkBackground),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)))))),
      toggleButtonsTheme: ToggleButtonsThemeData(
        selectedColor: CustomAppColor.DarkBackground,
        fillColor: CustomAppColor.DarkBackground.withOpacity(0.1),
        textStyle: const TextStyle(color: Colors.white),
        selectedBorderColor: CustomAppColor.DarkBackground,
        borderRadius: BorderRadius.circular(8.0),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: CustomAppColor.Primary,
        onPrimary: CustomAppColor.Primary,
        secondary: CustomAppColor.PrimaryAccent,
        onSecondary: CustomAppColor.PrimaryAccent,
        surface: CustomAppColor.DarkBackground,
        onSurface: CustomAppColor.DarkBackground,
        error: Colors.red,
        onError: Colors.red,
        background: CustomAppColor.DarkBackground,
        onBackground: CustomAppColor.DarkBackground,
        brightness: Brightness.dark,
      ),
      pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          }
      ),
    );
  }
}
