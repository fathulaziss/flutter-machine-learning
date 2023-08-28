import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_machine_learning/main.dart';
import 'package:flutter_machine_learning/model/camera_model.dart';
import 'package:flutter_machine_learning/model/recognition_model.dart';
import 'package:flutter_machine_learning/model/stats_model.dart';
import 'package:flutter_machine_learning/services/machine_learning_video_service.dart';
import 'package:flutter_machine_learning/utils/isolate_utils.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    super.key,
    required this.classifier,
    required this.resultsCallback,
    required this.statsCallback,
  });

  final MachineLearningVideoService classifier;
  // final Function(List<RecognitionModel> value) resultsCallback;
  final ValueSetter<List<RecognitionModel>> resultsCallback;
  final Function(StatsModel value) statsCallback;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  /// List of available cameras
  // late List<CameraDescription> cameras;

  /// Controller
  late CameraController cameraController;

  /// true when inference is ongoing
  bool predicting = false;

  /// Instance of [IsolateUtils]
  late IsolateUtils isolateUtils;

  @override
  void initState() {
    initStateAsync();
    super.initState();
  }

  Future<void> initStateAsync() async {
    WidgetsBinding.instance.addObserver(this);

    // Camera initialization
    await initializeCamera();

    // Spawn a new isolate
    isolateUtils = IsolateUtils();
    await isolateUtils.start();

    predicting = false;
  }

  /// Initializes the camera by setting [cameraController]
  Future<void> initializeCamera() async {
    // cameras = await availableCameras();

    // cameras[0] for rear-camera
    setState(() {
      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.low,
        enableAudio: false,
      );
    });

    await cameraController.initialize().then((_) async {
      // Stream of image passed to [onLatestImageAvailable] callback
      await cameraController.startImageStream(onLatestImageAvailable);

      /// previewSize is size of each image frame captured by controller
      ///
      /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
      final previewSize = cameraController.value.previewSize;

      /// previewSize is size of raw input image to the model
      CameraModel.inputImageSize = previewSize;

      // the display width of image on screen is
      // same as screenWidth while maintaining the aspectRatio
      // ignore: use_build_context_synchronously
      final screenSize = MediaQuery.of(context).size;
      CameraModel.screenSize = screenSize;
      CameraModel.ratio = screenSize.width / previewSize!.height;
    });
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  onLatestImageAvailable(CameraImage cameraImage) async {
    if (predicting) {
      return;
    }

    setState(() {
      predicting = true;
    });

    final uiThreadTimeStart = DateTime.now().millisecondsSinceEpoch;

    // Data to be passed to inference isolate
    final isolateData = IsolateData(
      cameraImage: cameraImage,
      interpreterAddress: widget.classifier.interpreter.address,
      labels: widget.classifier.labels,
    );

    // We could have simply used the compute method as well however
    // it would be as in-efficient as we need to continuously passing data
    // to another isolate.

    /// perform inference in separate isolate
    final inferenceResults = await inference(isolateData);
    print('cek inferenceResults : $inferenceResults');

    final uiThreadInferenceElapsedTime =
        DateTime.now().millisecondsSinceEpoch - uiThreadTimeStart;

    // pass results to HomeView
    widget.resultsCallback(inferenceResults['recognitions']);

    // pass stats to HomeView
    widget.statsCallback(
      (inferenceResults['stats'] as StatsModel)
        ..totalElapsedTime = uiThreadInferenceElapsedTime,
    );

    // set predicting to false to allow new frames
    setState(() {
      predicting = false;
    });
  }

  /// Runs inference in another isolate
  Future<Map<String, dynamic>> inference(IsolateData isolateData) async {
    final responsePort = ReceivePort();
    isolateUtils.sendPort
        .send(isolateData..responsePort = responsePort.sendPort);
    final results = await responsePort.first;
    return results;
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        await cameraController.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        if (!cameraController.value.isStreamingImages) {
          await cameraController.startImageStream(onLatestImageAvailable);
        }
        break;
      // ignore: no_default_cases
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (cameraController.value.isInitialized)
        ? AspectRatio(
            aspectRatio: cameraController.value.aspectRatio,
            child: CameraPreview(cameraController),
          )
        : const SizedBox();
  }
}
