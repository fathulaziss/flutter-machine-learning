import 'package:flutter/material.dart';
import 'package:flutter_machine_learning/common/styles.dart';
import 'package:flutter_machine_learning/provider/home_provider.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static String routeName = '/home';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Home View')),
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (homeProvider.image.path.isNotEmpty)
                  Image.file(homeProvider.image),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    homeProvider.takePhoto();
                  },
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Take Photo',
                    style: textStyle.labelMedium!.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
