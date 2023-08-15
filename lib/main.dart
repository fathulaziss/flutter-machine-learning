import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_machine_learning/common/styles.dart';
import 'package:flutter_machine_learning/provider/picture_provider.dart';
import 'package:flutter_machine_learning/services/navigation_service.dart';
import 'package:flutter_machine_learning/ui/home/home_view.dart';
import 'package:flutter_machine_learning/ui/picture/picture_view.dart';
import 'package:flutter_machine_learning/utils/app_utils.dart';
import 'package:provider/provider.dart';

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PictureProvider>(
          create: (context) => PictureProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: lightTheme,
        darkTheme: darkTheme,
        initialRoute: HomeView.routeName,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.22),
            child: GestureDetector(
              onTap: AppUtils.dismissKeyboard,
              child: child,
            ),
          );
        },
        routes: {
          HomeView.routeName: (context) => const HomeView(),
          PictureView.routeName: (context) => const PictureView(),
        },
      ),
    );
  }
}
