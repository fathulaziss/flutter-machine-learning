import 'package:flutter/material.dart';
import 'package:flutter_machine_learning/model/recognition_model.dart';
import 'package:flutter_machine_learning/model/stats_model.dart';
import 'package:flutter_machine_learning/provider/video_provider.dart';
import 'package:flutter_machine_learning/widgets/box_widget.dart';
import 'package:flutter_machine_learning/widgets/camera_view.dart';
import 'package:provider/provider.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key});

  static String routeName = '/video';

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  /// Results to draw bounding boxes
  List<RecognitionModel> results = [];

  /// Realtime stats
  StatsModel stats = StatsModel();

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<RecognitionModel> results) {
    setState(() {
      this.results = results;
    });
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(StatsModel stats) {
    setState(() {
      this.stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, videoProvider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Machine Learning Video')),
          body: Stack(
            children: [
              // Camera View
              CameraView(
                classifier: videoProvider.classifier,
                resultsCallback: resultsCallback,
                statsCallback: statsCallback,
              ),

              // Bounding boxes
              boundingBoxes(results),
            ],
          ),
        );
      },
    );
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<RecognitionModel>? results) {
    print('cek results : $results');
    if (results == null) {
      return Container();
    }
    return Stack(
      children: results.map((e) => BoxWidget(result: e)).toList(),
    );
  }
}
