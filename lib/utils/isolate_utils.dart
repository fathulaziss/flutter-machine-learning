import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter_machine_learning/services/machine_learning_video_service.dart';
import 'package:flutter_machine_learning/utils/image_utils.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class IsolateUtils {
  late Isolate _isolate;
  final ReceivePort _receivePort = ReceivePort();
  late SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  Isolate get isolate => _isolate;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: 'InferenceIsolate',
    );

    _sendPort = await _receivePort.first;
  }

  static Future<void> entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final IsolateData isolateData in port) {
      print('cek ini $isolateData');
      final classifier = MachineLearningVideoService(
        interpreter: Interpreter.fromAddress(isolateData.interpreterAddress!),
        labels: isolateData.labels,
      );
      var image = ImageUtils.convertCameraImage(isolateData.cameraImage!);
      if (Platform.isAndroid) {
        image = img.copyRotate(image, 90);
      }
      final results = classifier.predict(image);
      isolateData.responsePort!.send(results);
    }
  }
}

/// Bundles data to pass between Isolate
class IsolateData {
  IsolateData({
    this.cameraImage,
    this.interpreterAddress,
    this.labels,
    this.responsePort,
  });

  CameraImage? cameraImage;
  int? interpreterAddress;
  List<String>? labels;
  SendPort? responsePort;

  @override
  String toString() {
    return 'IsolateData(interpreter_address : $interpreterAddress, labels : $labels)';
  }
}
