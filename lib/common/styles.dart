import 'package:flutter/material.dart';

TextStyle textBase = const TextStyle(fontFamily: 'DIN Pro');

final textStyle = TextTheme(
  titleLarge: textBase.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
  titleMedium: textBase.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
  titleSmall: textBase.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
  labelLarge: textBase.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
  labelMedium: textBase.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
  labelSmall: textBase.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
  bodyLarge: textBase.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
  bodyMedium: textBase.copyWith(fontSize: 12, fontWeight: FontWeight.normal),
  bodySmall: textBase.copyWith(fontSize: 10, fontWeight: FontWeight.normal),
);

final darkTheme = ThemeData(
  appBarTheme: AppBarTheme(
    color: Colors.transparent,
    titleTextStyle: textStyle.titleSmall!.copyWith(color: Colors.white),
  ),
  brightness: Brightness.dark,
  colorScheme: ThemeData.dark().colorScheme.copyWith(
        primary: Colors.white,
        onPrimary: Colors.black,
        secondary: Colors.green,
      ),
  cardColor: Colors.grey.shade800,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.green),
      surfaceTintColor: MaterialStateProperty.all(Colors.green),
      overlayColor: MaterialStateProperty.all(Colors.greenAccent),
    ),
  ),
  fontFamily: 'DIN Pro',
  indicatorColor: Colors.orange,
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.green),
    ),
  ),
  textTheme: textStyle,
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.black,
);

final lightTheme = ThemeData(
  appBarTheme: AppBarTheme(
    color: Colors.green,
    titleTextStyle: textStyle.titleSmall!.copyWith(color: Colors.white),
  ),
  brightness: Brightness.light,
  colorScheme: ThemeData.light().colorScheme.copyWith(
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Colors.green,
      ),
  cardColor: Colors.white,
  cardTheme:
      const CardTheme(color: Colors.white, surfaceTintColor: Colors.white),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.green),
      surfaceTintColor: MaterialStateProperty.all(Colors.green),
      overlayColor: MaterialStateProperty.all(Colors.greenAccent),
    ),
  ),
  fontFamily: 'DIN Pro',
  indicatorColor: Colors.orange,
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.green),
    ),
  ),
  scaffoldBackgroundColor: const Color(0xFFF9F9F9),
  textTheme: textStyle,
  useMaterial3: true,
);

InputDecoration inputDecoration({
  required String hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  TextStyle? hintStyle,
  EdgeInsets? padding,
  Color? hintColor,
}) {
  return InputDecoration(
    isDense: true,
    // filled: true,
    contentPadding:
        padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    hintText: hintText,
    border: InputBorder.none,
    errorMaxLines: 5,
    prefixIcon: prefixIcon,
    prefixIconConstraints: const BoxConstraints(minHeight: 30, minWidth: 30),
    suffixIconConstraints: const BoxConstraints(minHeight: 30, minWidth: 30),
    suffixIcon: suffixIcon,
    hintStyle: hintStyle ??
        textStyle.bodyMedium!
            .copyWith(color: hintColor ?? const Color(0xFFC1BABA)),
  );
}
