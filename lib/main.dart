import 'package:flutter/material.dart';
import 'package:flutter_machine_learning/common/styles.dart';
import 'package:flutter_machine_learning/services/navigation_service.dart';
import 'package:flutter_machine_learning/ui/home/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: lightTheme,
      initialRoute: HomeView.routeName,
      routes: {
        HomeView.routeName: (context) => const HomeView(),
      },
    );
  }
}
