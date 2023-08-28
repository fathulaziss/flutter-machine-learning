import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_machine_learning/model/camera_model.dart';

class RecognitionModel {
  RecognitionModel({
    this.id,
    this.label,
    this.location,
    this.score,
  });

  int? id;
  String? label;
  double? score;
  Rect? location;

  int? get ids => id;

  String? get labels => label;

  double? get scores => score;

  Rect? get locations => location;

  Rect get renderLocation {
    // ratioX = screenWidth / imageInputWidth
    // ratioY = ratioX if image fits screenWidth with aspectRatio = constant

    final ratioX = CameraModel.ratio;
    final ratioY = ratioX;

    final transLeft = max(0.1, location!.left * ratioX!);
    final transTop = max(0.1, location!.top * ratioY!);
    final transWidth =
        min(location!.width * ratioX, CameraModel.actualPreviewSize.width);
    final transHeight =
        min(location!.height * ratioY, CameraModel.actualPreviewSize.height);

    final transformedRect =
        Rect.fromLTWH(transLeft, transTop, transWidth, transHeight);
    return transformedRect;
  }

  @override
  String toString() {
    return 'RecognitionModel(id: $id, label: $label, score: $score, location: $location)';
  }
}
