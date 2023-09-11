import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:image_picker/image_picker.dart';

class Yolov5ClassificationView extends StatefulWidget {
  const Yolov5ClassificationView({super.key});

  static String routeName = '/yolov5-clasification';

  @override
  State<Yolov5ClassificationView> createState() =>
      _Yolov5ClassificationViewState();
}

class _Yolov5ClassificationViewState extends State<Yolov5ClassificationView> {
  ClassificationModel? _imageModel;
  late ModelObjectDetection _objectModel;
  String? _imagePrediction;
  List? _prediction;
  File? _image;
  ImagePicker _picker = ImagePicker();
  bool objectDetection = false;
  List<ResultObjectDetection?> objDetect = [];

  @override
  void initState() {
    loadModel();
    super.initState();
  }

  //load your model
  Future loadModel() async {
    const imageModelPath = 'assets/datasets/model_classification.pt';
    const objectDetectionModelPath =
        'assets/datasets/model_object_detection.torchscript';
    const imageLabelPath = 'assets/datasets/label_classification.txt';
    const objectDetectionLabelPath =
        'assets/datasets/label_object_detection.txt';
    try {
      _imageModel = await FlutterPytorch.loadClassificationModel(
        imageModelPath,
        224,
        224,
        labelPath: imageLabelPath,
      );

      _objectModel = await FlutterPytorch.loadObjectDetectionModel(
        objectDetectionModelPath,
        80,
        640,
        640,
        labelPath: objectDetectionLabelPath,
      );
    } catch (e) {
      if (e is PlatformException) {
        if (kDebugMode) {
          print('only supported for android, Error is $e');
        }
      } else {
        if (kDebugMode) {
          print('Error is $e');
        }
      }
    }
  }

  //run an image model
  Future runObjectDetectionWithoutLabels() async {
    //pick a random image
    final image = await _picker.pickImage(source: ImageSource.gallery);
    objDetect = await _objectModel
        .getImagePredictionList(await File(image!.path).readAsBytes());
    for (final element in objDetect) {
      if (kDebugMode) {
        print({
          'score': element?.score,
          'className': element?.className,
          'class': element?.classIndex,
          'rect': {
            'left': element?.rect.left,
            'top': element?.rect.top,
            'width': element?.rect.width,
            'height': element?.rect.height,
            'right': element?.rect.right,
            'bottom': element?.rect.bottom,
          },
        });
      }
    }
    setState(() {
      //this.objDetect = objDetect;
      _image = File(image.path);
    });
  }

  Future runObjectDetection() async {
    //pick a random image
    final image = await _picker.pickImage(source: ImageSource.gallery);
    objDetect = await _objectModel.getImagePrediction(
      await File(image!.path).readAsBytes(),
      minimumScore: 0.1,
      IOUThershold: 0.3,
    );
    for (final element in objDetect) {
      if (kDebugMode) {
        print({
          'score': element?.score,
          'className': element?.className,
          'class': element?.classIndex,
          'rect': {
            'left': element?.rect.left,
            'top': element?.rect.top,
            'width': element?.rect.width,
            'height': element?.rect.height,
            'right': element?.rect.right,
            'bottom': element?.rect.bottom,
          },
        });
      }
    }
    setState(() {
      //this.objDetect = objDetect;
      _image = File(image.path);
    });
  }

  Future runClassification() async {
    objDetect = [];
    //pick a random image
    final image = await _picker.pickImage(source: ImageSource.gallery);
    //get prediction
    //labels are 1000 random english words for show purposes
    if (kDebugMode) {
      print(image!.path);
    }
    _imagePrediction = await _imageModel!
        .getImagePrediction(await File(image!.path).readAsBytes());

    final predictionList = await _imageModel!.getImagePredictionList(
      await File(image.path).readAsBytes(),
    );

    if (kDebugMode) {
      print(predictionList);
    }
    final predictionListProbabilites =
        await _imageModel!.getImagePredictionListProbabilities(
      await File(image.path).readAsBytes(),
    );
    //Gettting the highest Probability
    var maxScoreProbability = double.negativeInfinity;
    var sumOfProbabilites = 0.0;
    var index = 0;
    for (var i = 0; i < predictionListProbabilites!.length; i++) {
      if (predictionListProbabilites[i]! > maxScoreProbability) {
        maxScoreProbability = predictionListProbabilites[i]!;
        sumOfProbabilites = sumOfProbabilites + predictionListProbabilites[i]!;
        index = i;
      }
    }
    if (kDebugMode) {
      print(predictionListProbabilites);
    }
    if (kDebugMode) {
      print(index);
    }
    if (kDebugMode) {
      print(sumOfProbabilites);
    }
    if (kDebugMode) {
      print(maxScoreProbability);
    }

    setState(() {
      //this.objDetect = objDetect;
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yolov5 Clasification')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: objDetect.isNotEmpty
                ? _image == null
                    ? const Text('No image selected.')
                    : _objectModel.renderBoxesOnImage(_image!, objDetect)
                : _image == null
                    ? const Text('No image selected.')
                    : Image.file(_image!),
          ),
          Center(
            child: Visibility(
              visible: _imagePrediction != null,
              child: Text('$_imagePrediction'),
            ),
          ),
          TextButton(
            onPressed: runClassification,
            style: TextButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              'Run Classification',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: runObjectDetection,
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text(
              'Run object detection with labels',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: runObjectDetectionWithoutLabels,
            style: TextButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              'Run object detection without labels',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Center(
            child: Visibility(
              visible: _prediction != null,
              child: Text(_prediction != null ? '${_prediction![0]}' : ''),
            ),
          )
        ],
      ),
    );
  }
}
