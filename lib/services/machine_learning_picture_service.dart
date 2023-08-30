// ignore_for_file: avoid_print, cascade_invocations, no_default_cases

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:image/image.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

abstract class MachineLearningPictureService {
  MachineLearningPictureService({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }

    loadModel();
    loadLabels();
  }

  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;

  var logger = Logger();

  late List<int> _inputShape;
  late List<int> _outputShape;

  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;

  late TensorType _inputType;
  late TensorType _outputType;

  final String _labelsFileName = 'assets/datasets/labels.txt';

  late SequentialProcessor<TensorBuffer> _probabilityProcessor;

  late List<String> labels;

  String get modelName;

  NormalizeOp get preProcessNormalizeOp;
  NormalizeOp get postProcessNormalizeOp;

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(
        modelName,
        options: _interpreterOptions,
      );

      print('Interpreter Created Successfully');

      _inputShape = interpreter.getInputTensor(0).shape;
      _outputShape = interpreter.getOutputTensor(0).shape;
      _inputType = interpreter.getInputTensor(0).type;
      _outputType = interpreter.getOutputTensor(0).type;
      print('inputType : $_inputType');
      print('outputType : $_outputType');

      if (interpreter.getInputTensor(0).type == TensorType.uint8 &&
          interpreter.getOutputTensor(0).type == TensorType.uint8) {
        print('exe uint8');
        _outputBuffer = TensorBuffer.createFixedSize(
          _outputShape,
          TensorBufferUint8(_outputShape).getDataType(),
        );
        _probabilityProcessor =
            TensorProcessorBuilder().add(postProcessNormalizeOp).build();
      } else {
        print('exe float32');
        _outputBuffer = TensorBuffer.createFixedSize(
          _outputShape,
          TensorBufferFloat(_outputShape).getDataType(),
        );
        _probabilityProcessor =
            TensorProcessorBuilder().add(postProcessNormalizeOp).build();
      }
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: $e');
    }
  }

  Future<void> loadLabels() async {
    labels = await FileUtil.loadLabels(_labelsFileName);
    if (labels.isNotEmpty) {
      print('Labels loaded successfully');
    } else {
      print('Unable to load labels');
    }
  }

  TensorImage _preProcess() {
    final cropSize = min(_inputImage.height, _inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(
          ResizeOp(
            _inputShape[1],
            _inputShape[2],
            ResizeMethod.nearestneighbour,
          ),
        )
        .add(preProcessNormalizeOp)
        .build()
        .process(_inputImage);
  }

  Category predict(Image image) {
    final pres = DateTime.now().millisecondsSinceEpoch;

    if (interpreter.getInputTensor(0).type == TensorType.uint8 &&
        interpreter.getOutputTensor(0).type == TensorType.uint8) {
      _inputImage = TensorImage();
    } else {
      _inputImage = TensorImage(TensorBufferFloat(_outputShape).getDataType());
    }

    // _inputImage = TensorImage();
    // _inputImage = TensorImage(TensorBufferFloat(_outputShape).getDataType());

    _inputImage.loadImage(image);
    _inputImage = _preProcess();
    final pre = DateTime.now().millisecondsSinceEpoch - pres;

    print('Time to load image: $pre ms');

    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
    final run = DateTime.now().millisecondsSinceEpoch - runs;

    print('Time to run inference: $run ms');

    // final res = _probabilityProcessor.process(_outputBuffer);

    // final shape = res.getShape();
    // final resss = getFirstAxisWithSizeGreaterThanOne(res);

    final labeledProb = TensorLabel.fromList(
      labels,
      _probabilityProcessor.process(_outputBuffer),
    ).getMapWithFloatValue();

    final pred = getTopProbability(labeledProb);

    return Category(pred.key, pred.value);
  }

  void close() {
    interpreter.close();
  }
}

MapEntry<String, double> getTopProbability(Map<String, double> labeledProb) {
  final pq = PriorityQueue<MapEntry<String, double>>(compare);
  pq.addAll(labeledProb.entries);

  return pq.first;
}

int compare(MapEntry<String, double> e1, MapEntry<String, double> e2) {
  if (e1.value > e2.value) {
    return -1;
  } else if (e1.value == e2.value) {
    return 0;
  } else {
    return 1;
  }
}

int getFirstAxisWithSizeGreaterThanOne(TensorBuffer tensorBuffer) {
  final shape = tensorBuffer.getShape();
  for (var i = 0; i < shape.length; i++) {
    if (shape[i] > 1) {
      return i;
    }
  }
  throw ArgumentError(
    'Cannot find an axis to label. A valid axis to label should have size larger than 1.',
  );
}

Map<int, List<String>> makeMap(int axis, List<String> labels) {
  final map = <int, List<String>>{};
  map[axis] = labels;
  return map;
}
