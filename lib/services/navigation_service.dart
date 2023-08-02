import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NavigationService {
  static intentWithData(String routeName, Object arguments) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> pushNamed(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> pushReplacementNamed(
    String routeName, {
    dynamic arguments,
  }) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> pushNamedAndRemoveUntil(
    String routeName, {
    dynamic arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (Route route) => false,
      arguments: arguments,
    );
  }

  static void pop({dynamic result}) {
    navigatorKey.currentState!.pop(result);
  }

  static void popUntil(String routeName, {dynamic arguments}) {
    navigatorKey.currentState!.popUntil((route) {
      return route.settings.name == routeName;
    });
  }
}
