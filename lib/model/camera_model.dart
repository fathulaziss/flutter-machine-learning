import 'dart:ui';

class CameraModel {
  static double? ratio;
  static Size? screenSize;
  static Size? inputImageSize;

  static Size get actualPreviewSize =>
      Size(screenSize!.width, screenSize!.width * ratio!);
}
