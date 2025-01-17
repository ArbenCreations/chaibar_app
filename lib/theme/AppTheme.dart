import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'AppColor.dart';

class AppTheme {
  static ThemeData getAppTheme() {
    return ThemeData(
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.getFont('Poppins',
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: AppColor.BLACK,
            letterSpacing: 0.5),
        actionsIconTheme: const IconThemeData(color: AppColor.BLACK),
        iconTheme: const IconThemeData(color: AppColor.BLACK),
        backgroundColor: AppColor.WHITE,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColor.WHITE4,
      ),
      tabBarTheme: TabBarTheme(
        dividerColor: Colors.black,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black45,
        indicatorColor: Colors.black,
        unselectedLabelStyle: TextStyle(
            fontSize: 12), /*indicatorSize: TabBarIndicatorSize.label*/
      ),
      timePickerTheme: TimePickerThemeData(
          backgroundColor: AppColor.WHITE,
          dialBackgroundColor: Colors.blue,
          dialHandColor: AppColor.WHITE,
          confirmButtonStyle: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue)),
          cancelButtonStyle: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.redAccent)),
          hourMinuteColor: Colors.blue,
          timeSelectorSeparatorColor:
              WidgetStateProperty.all(Colors.transparent),
          entryModeIconColor: Colors.blue),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColor.PRIMARY,
      ),
      cardTheme: const CardTheme(color: AppColor.WHITE),
      primaryColor: AppColor.PRIMARY,
      highlightColor: AppColor.PRIMARY,
      scaffoldBackgroundColor: AppColor.BG_COLOR,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.getFont(
          'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.normal,
          color: AppColor.BLACK,
        ),
        displayMedium: GoogleFonts.getFont('Poppins',
            fontSize: 18, fontWeight: FontWeight.normal, color: AppColor.BLACK),
        displaySmall: GoogleFonts.getFont('Poppins',
            fontSize: 18, fontWeight: FontWeight.normal, color: AppColor.BLACK),
        titleLarge: GoogleFonts.getFont('Poppins',
            fontSize: 18, fontWeight: FontWeight.normal, color: AppColor.BLACK),
        titleMedium: GoogleFonts.getFont('Poppins',
            fontSize: 14, fontWeight: FontWeight.normal, color: AppColor.BLACK),
        titleSmall: GoogleFonts.getFont('Poppins',
            fontSize: 12, fontWeight: FontWeight.normal, color: AppColor.BLACK),
        bodyLarge: GoogleFonts.getFont('Poppins',
            fontSize: 16, fontWeight: FontWeight.normal, color: AppColor.BLACK),
        bodyMedium: GoogleFonts.getFont(
          'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColor.BLACK,
        ),
        bodySmall: GoogleFonts.getFont('Poppins',
            fontSize: 12, fontWeight: FontWeight.normal, color: AppColor.BLACK),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.getFont('Poppins',
            fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey),
        iconColor: Colors.grey,
        suffixIconColor: AppColor.BLACK,
        prefixIconColor: AppColor.BLACK,
      ),
      listTileTheme: ListTileThemeData(
          iconColor: AppColor.BLACK,
          textColor: AppColor.BLACK,
          selectedColor: AppColor.PRIMARY),
      dialogTheme: DialogTheme(
          backgroundColor: AppColor.WHITE,
          titleTextStyle: TextStyle(color: AppColor.BLACK, fontSize: 22),
          iconColor: AppColor.BLACK),
      datePickerTheme: DatePickerThemeData(
        dayStyle: TextStyle(color: Colors.black, fontSize: 12),
        shape: Border(),
      ),
      iconTheme: IconThemeData(color: AppColor.PRIMARY),
      iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        foregroundColor: MaterialStateProperty.all<Color>(AppColor.PRIMARY),
      )),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(AppColor.PRIMARY),
              foregroundColor: MaterialStateProperty.all<Color>(AppColor.WHITE),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)))))),
      toggleButtonsTheme: ToggleButtonsThemeData(
        selectedColor: AppColor.PRIMARY,
        fillColor: AppColor.PRIMARY.withOpacity(0.1),
        textStyle: const TextStyle(color: AppColor.WHITE),
        selectedBorderColor: AppColor.PRIMARY,
        borderRadius: BorderRadius.circular(8.0),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColor.PRIMARY,
        onPrimary: AppColor.PRIMARY,
        secondary: AppColor.SECONDARY,
        onSecondary: AppColor.SECONDARY,
        surface: AppColor.BG_COLOR,
        onSurface: AppColor.BG_COLOR,
        error: Colors.red,
        onError: Colors.red,
        background: AppColor.BG_COLOR,
        onBackground: AppColor.BG_COLOR,
        brightness: Brightness.light,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: Colors.black),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.getFont('Poppins',
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColor.WHITE),
        actionsIconTheme: const IconThemeData(color: AppColor.WHITE),
        iconTheme: const IconThemeData(color: AppColor.WHITE),
        backgroundColor: AppColor.DARK_BG_COLOR,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColor.PRIMARY,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColor.DARK_CARD_COLOR,
      ),
      datePickerTheme:
          DatePickerThemeData(dayStyle: TextStyle(color: Colors.white)),
      cardTheme: const CardTheme(
        color: AppColor.DARK_CARD_COLOR,
      ),
      primaryColor: AppColor.PRIMARY,
      highlightColor: AppColor.PRIMARY,
      scaffoldBackgroundColor: AppColor.DARK_BG_COLOR,
      dialogTheme: DialogTheme(
        backgroundColor: AppColor.DARK_CARD_COLOR,
        titleTextStyle: TextStyle(color: AppColor.WHITE, fontSize: 22),
        iconColor: AppColor.WHITE,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white24,
        indicatorColor: Colors.white,
        unselectedLabelStyle: TextStyle(
            fontSize: 12), /*indicatorSize: TabBarIndicatorSize.label*/
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.getFont('Poppins',
            fontSize: 20, fontWeight: FontWeight.normal, color: AppColor.WHITE),
        displayMedium: GoogleFonts.getFont('Poppins',
            fontSize: 18, fontWeight: FontWeight.normal, color: AppColor.WHITE),
        displaySmall: GoogleFonts.getFont('Poppins',
            fontSize: 18, fontWeight: FontWeight.normal, color: AppColor.WHITE),
        titleLarge: GoogleFonts.getFont('Poppins',
            fontSize: 18, fontWeight: FontWeight.normal, color: AppColor.WHITE),
        titleMedium: GoogleFonts.getFont('Poppins',
            fontSize: 14, fontWeight: FontWeight.normal, color: AppColor.WHITE),
        titleSmall: GoogleFonts.getFont('Poppins',
            fontSize: 12, fontWeight: FontWeight.normal, color: AppColor.WHITE),
        bodyLarge: GoogleFonts.getFont('Poppins',
            fontSize: 16, fontWeight: FontWeight.normal, color: AppColor.WHITE),
        bodyMedium: GoogleFonts.getFont('Poppins',
            fontSize: 14, fontWeight: FontWeight.normal, color: AppColor.WHITE),
        bodySmall: GoogleFonts.getFont('Poppins',
            fontSize: 12, fontWeight: FontWeight.normal, color: AppColor.WHITE),
      ),
      inputDecorationTheme: InputDecorationTheme(
          hintStyle: GoogleFonts.getFont('Poppins',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white70),
          iconColor: Colors.white70,
          suffixIconColor: AppColor.WHITE,
          prefixIconColor: AppColor.WHITE),
      iconTheme: IconThemeData(color: AppColor.WHITE),
      iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        foregroundColor: MaterialStateProperty.all<Color>(AppColor.PRIMARY),
      )),
      listTileTheme: ListTileThemeData(
          iconColor: AppColor.WHITE,
          textColor: AppColor.WHITE,
          selectedColor: AppColor.PRIMARY),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(AppColor.DARK_BG_COLOR),
              foregroundColor: MaterialStateProperty.all<Color>(AppColor.WHITE),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)))))),
      toggleButtonsTheme: ToggleButtonsThemeData(
        selectedColor: AppColor.DARK_BG_COLOR,
        fillColor: AppColor.DARK_BG_COLOR.withOpacity(0.1),
        textStyle: const TextStyle(color: AppColor.WHITE),
        selectedBorderColor: AppColor.DARK_BG_COLOR,
        borderRadius: BorderRadius.circular(8.0),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColor.PRIMARY,
        onPrimary: AppColor.PRIMARY,
        secondary: AppColor.SECONDARY,
        onSecondary: AppColor.SECONDARY,
        surface: AppColor.DARK_BG_COLOR,
        onSurface: AppColor.DARK_BG_COLOR,
        error: Colors.red,
        onError: Colors.red,
        background: AppColor.DARK_BG_COLOR,
        onBackground: AppColor.DARK_BG_COLOR,
        brightness: Brightness.dark,
      ),
    );
  }
}
