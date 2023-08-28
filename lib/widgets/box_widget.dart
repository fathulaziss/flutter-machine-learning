import 'package:flutter/material.dart';
import 'package:flutter_machine_learning/model/recognition_model.dart';

class BoxWidget extends StatelessWidget {
  const BoxWidget({super.key, required this.result});

  final RecognitionModel result;

  @override
  Widget build(BuildContext context) {
    // Color for bounding box
    final color = Colors.primaries[
        (result.label!.length + result.label!.codeUnitAt(0) + result.id!) %
            Colors.primaries.length];

    return Positioned(
      left: result.renderLocation.left,
      top: result.renderLocation.top,
      width: result.renderLocation.width,
      height: result.renderLocation.height,
      child: Container(
        width: result.renderLocation.width,
        height: result.renderLocation.height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 3),
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            child: Container(
              color: color,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    result.label!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  Text(
                    ' ${result.score!.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
