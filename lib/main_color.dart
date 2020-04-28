library main_color;

import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:flutter/painting.dart';

/// Returns the predominant color
///
/// The algorithm used to get the predominant color is subjective.
/// You can fine-tune it by modifying the [staturationCoef]
/// and/or the [valueCoef] when calling the methods.
class MainColor {
  static const double _defaultSaturationCoef = 1;
  static const double _defaultValueCoef = 1;

  static double get defaultSaturationCoef => _defaultSaturationCoef;
  static double get defaultValueCoef => _defaultValueCoef;

  /// Returns the predominant color from an image [bytes]
  ///
  ///
  /// Example:
  /// ```
  /// var pngFile = File(pngPath);
  /// Color mainColor = Color.fromImageBytes(pngFile.readAsBytesSync());
  /// ```
  static Color fromImageBytes(
    List<int> bytes, {
    double staturationCoef = _defaultSaturationCoef,
    double valueCoef = _defaultValueCoef,
  }) {
    Map<Color, double> scoreByColor = Map<Color, double>();
    Color colorWithHighestScore;
    img.Image photo = img.decodeImage(bytes);

    for (int i = 0; i < photo.height * photo.width; i++) {
      int pixel32 = photo.getPixelSafe(i % photo.width, i ~/ photo.width);
      int hex = _abgrToArgb(pixel32);
      Color color = Color(hex);
      if (!scoreByColor.containsKey(color)) {
        scoreByColor[color] =
            _computeColorScore(color, staturationCoef, valueCoef);
      }
      if (colorWithHighestScore == null ||
          scoreByColor[colorWithHighestScore] < scoreByColor[color]) {
        colorWithHighestScore = color;
      }
    }

    if (colorWithHighestScore != null) {
      return colorWithHighestScore;
    }
    return Color(0xFFFFFF);
  }

  static int _abgrToArgb(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }

  static double _computeColorScore(
      Color color, double saturationCoef, double valueCoef) {
    final hsvColor = HSVColor.fromColor(color);
    return hsvColor.saturation * saturationCoef + hsvColor.value * valueCoef;
  }
}
