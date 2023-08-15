import 'package:flutter/material.dart';
import 'package:flutter_machine_learning/common/styles.dart';
import 'package:flutter_machine_learning/provider/picture_provider.dart';
import 'package:provider/provider.dart';

class PictureView extends StatelessWidget {
  const PictureView({super.key});

  static String routeName = '/picture';

  @override
  Widget build(BuildContext context) {
    return Consumer<PictureProvider>(
      builder: (context, pictureProvider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Machine Learning Picture')),
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (pictureProvider.image.path.isNotEmpty)
                  Image.file(pictureProvider.image),
                const SizedBox(height: 20),
                if (pictureProvider.category.label.isNotEmpty)
                  Text(
                    'Tag : ${pictureProvider.category.label}\n Akurasi : ${pictureProvider.category.score.toStringAsFixed(3)} %',
                    textAlign: TextAlign.center,
                  ),
                ElevatedButton.icon(
                  onPressed: () {
                    pictureProvider.takePhoto();
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
