import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_machine_learning/services/classifier_quant.dart';
import 'package:flutter_machine_learning/services/machine_learning_picture_service.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

class PictureProvider extends ChangeNotifier {
  PictureProvider() {
    initData();
  }

  late MachineLearningPictureService _classifier;

  Category category = Category('', 0);

  late File _image = File('');

  File get image => _image;

  void initData() {
    _classifier = ClassifierQuant();
    notifyListeners();
  }

  Future<void> predict() async {
    final imageInput = img.decodeImage(image.readAsBytesSync())!;
    final pred = _classifier.predict(imageInput);
    category = pred;
    notifyListeners();
  }

  Future<void> takePhoto() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);
      _image = imageTemp;
      notifyListeners();

      await predict();
    } on PlatformException catch (e) {
      log('Failed to pick image: $e');
    }
  }
}
