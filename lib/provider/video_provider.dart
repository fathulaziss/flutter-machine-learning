import 'package:flutter/material.dart';
import 'package:flutter_machine_learning/services/machine_learning_video_service.dart';

class VideoProvider extends ChangeNotifier {
  VideoProvider() {
    initData();
  }

  late MachineLearningVideoService classifier;

  void initData() {
    classifier = MachineLearningVideoService();
    notifyListeners();
  }
}
