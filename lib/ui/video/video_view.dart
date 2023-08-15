import 'package:flutter/material.dart';
import 'package:flutter_machine_learning/provider/video_provider.dart';
import 'package:provider/provider.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key});

  static String routeName = '/video';

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, videoProvider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Machine Learning Video')),
        );
      },
    );
  }
}
