import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_machine_learning/model/recognition_model.dart';
import 'package:flutter_machine_learning/model/stats_model.dart';
import 'package:image/image.dart' as image;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

class MachineLearningVideoService {
  MachineLearningVideoService({
    Interpreter? interpreter,
    List<String>? labels,
  }) {
    loadModel(interpreter: interpreter);
    loadLabel(labels: labels);
  }

  late Interpreter _interpreter;

  /// Shapes of output tensors
  late List<List<int>> _outputShapes;

  /// Types of output tensors
  late List<TensorType> _outputTypes;

  /// Labels file loaded as list
  late List<String> _labels;

  /// Padding the image to transform into square
  late int padSize;

  /// [ImageProcessor] used to pre-process the image
  late ImageProcessor imageProcessor;

  /// Input size of image (height = width = 300)
  int inputSize = 300;

  /// Number of results to show
  int numResult = 10;

  /// Result score threshold
  double threshold = 0.5;

  /// Gets the interpreter instance
  Interpreter get interpreter => _interpreter;

  /// Labels file get as list
  List<String> get labels => _labels;

  /// Loads interpreter from asset
  Future<void> loadModel({Interpreter? interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            'assets/datasets/detect.tflite',
            options: InterpreterOptions()..threads = 4,
          );

      if (kDebugMode) {
        print('Interpreter Created Successfully');
      }

      final outputTensors = _interpreter.getOutputTensors();

      _outputShapes = [];
      _outputTypes = [];

      for (final tensor in outputTensors) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unable to create interpreter, Caught Exception: $e');
      }
    }
  }

  /// Load labels from assets
  Future<void> loadLabel({List<String>? labels}) async {
    try {
      final data =
          labels ?? await FileUtil.loadLabels('assets/datasets/labelmap.txt');
      _labels = data;
      if (kDebugMode) {
        print('Labels loaded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unable to load labels: $e');
      }
    }
  }

  /// Pre-process the image
  TensorImage getProcessedImage(TensorImage inputImage) {
    padSize = max(inputImage.height, inputImage.width);
    imageProcessor = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(padSize, padSize))
        .add(ResizeOp(inputSize, inputSize, ResizeMethod.bilinear))
        .build();

    final resultImage = imageProcessor.process(inputImage);
    return resultImage;
  }

  /// Runs object detection on the input image
  Map<String, dynamic> predict(image.Image image) {
    final predictStartTime = DateTime.now().millisecondsSinceEpoch;

    final preProcessStart = DateTime.now().millisecondsSinceEpoch;

    // Create TensorImage from image
    var inputImage = TensorImage.fromImage(image);

    // Pre-process TensorImage
    inputImage = getProcessedImage(inputImage);

    final preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;

    // TensorBuffers for output tensors
    final outputLocations = TensorBufferFloat(_outputShapes[0]);
    final outputClasses = TensorBufferFloat(_outputShapes[1]);
    final outputScores = TensorBufferFloat(_outputShapes[2]);
    final numLocations = TensorBufferFloat(_outputShapes[3]);

    // Inputs object for runForMultipleInputs
    // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference
    final inputs = [inputImage.buffer];

    // Outputs map
    final outputs = {
      0: outputLocations.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocations.buffer,
    };

    final inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;

    // run inference
    interpreter.runForMultipleInputs(inputs, outputs);

    final inferenceTimeElapsed =
        DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;

    // Maximum number of results to show
    final resultsCount = min(numResult, numLocations.getIntValue(0));

    // Using labelOffset = 1 as ??? at index 0
    const labelOffset = 1;

    // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>
    final locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      valueIndex: [1, 0, 3, 2],
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.boundaries,
      coordinateType: CoordinateType.ratio,
      height: inputSize,
      width: inputSize,
    );

    final recognitions = <RecognitionModel>[];

    for (var i = 0; i < resultsCount; i++) {
      // Prediction score
      final score = outputScores.getDoubleValue(i);

      // Label string
      final labelIndex = outputClasses.getIntValue(i) + labelOffset;
      final label = _labels.elementAt(labelIndex);

      if (score > threshold) {
        // inverse of rect
        // [locations] corresponds to the image size 300 X 300
        // inverseTransformRect transforms it our [inputImage]
        final transformedRect = imageProcessor.inverseTransformRect(
          locations[i],
          image.height,
          image.width,
        );

        recognitions.add(
          RecognitionModel(
            id: i,
            label: label,
            score: score,
            location: transformedRect,
          ),
        );
      }
    }

    final predictElapsedTime =
        DateTime.now().millisecondsSinceEpoch - predictStartTime;

    return {
      'recognitions': recognitions,
      'stats': StatsModel(
        totalPredictTime: predictElapsedTime,
        inferenceTime: inferenceTimeElapsed,
        preProcessingTime: preProcessElapsedTime,
      )
    };
  }
}
