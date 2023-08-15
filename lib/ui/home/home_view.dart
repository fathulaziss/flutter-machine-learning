import 'package:flutter/material.dart';
import 'package:flutter_machine_learning/common/styles.dart';
import 'package:flutter_machine_learning/services/navigation_service.dart';
import 'package:flutter_machine_learning/ui/picture/picture_view.dart';
import 'package:flutter_machine_learning/ui/video/video_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () =>
                  NavigationService.pushNamed(PictureView.routeName),
              child: Text(
                'Machine Learning Picture',
                style: textStyle.labelMedium!.copyWith(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () => NavigationService.pushNamed(VideoView.routeName),
              child: Text(
                'Machine Learning Video',
                style: textStyle.labelMedium!.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
