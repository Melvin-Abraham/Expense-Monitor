import 'package:flutter/material.dart';
import 'dart:math' as math;

double map(double n, double start1, double stop1, double start2, double stop2) => 
  ((n-start1)/(stop1-start1))*(stop2-start2)+start2;

double viewportWidth(BuildContext context) => MediaQuery.of(context).size.width;

Map<String, Function> easingFunctions = {
  "LINEAR"         : (double t) => t,
  "EASEINQUAD"     : (double t) => math.pow(t, 2),
  "EASEOUTQUAD"    : (double t) => t * (2 - t),
  "EASEINOUTQUAD"  : (double t) => t < .5 ? 2 * math.pow(t, 2) : -1 + (4 - 2 * t) * t,
  "EASEINCUBIC"    : (double t) => math.pow(t, 3),
  "EASEOUTCUBIC"   : (double t) => math.pow(--t, 3) + 1,
  "EASEINOUTCUBIC" : (double t) => t < .5 ? 4 * math.pow(t, 3) : (t - 1) * (2 * t - 2) * (2 * t - 2) + 1,
  "EASEINQUART"    : (double t) => math.pow(t, 4),
  "EASEOUTQUART"   : (double t) => 1 - math.pow(--t, 4),
  "EASEINOUTQUART" : (double t) => t < .5 ? 8 * math.pow(t, 4) : 1 - 8 * math.pow(--t, 4),
  "EASEINQUINT"    : (double t) => math.pow(t, 5),
  "EASEOUTQUINT"   : (double t) => 1 + math.pow(--t, 5),
  "EASEINOUTQUINT" : (double t) => t < .5 ? 16 * math.pow(t, 5) : 1 + 16 * math.pow(--t, 5)
};

class EasingCurve {
  static const String linear = "LINEAR";

  static const String easeInQuad = "EASEINQUAD";
  static const String easeOutQuad = "EASEOUTQUAD";
  static const String easeInOutQuad = "EASEINOUTQUAD";

  static const String easeInCubic = "EASEINCUBIC";
  static const String easeOutCubic = "EASEOUTCUBIC";
  static const String easeInOutCubic = "EASEINOUTCUBIC";

  static const String easeInQuart = "EASEINQUART";
  static const String easeOutQuart = "EASEOUTQUART";
  static const String easeInOutQuart = "EASEINOUTQUART";

  static const String easeInQuint = "EASEINQUINT";
  static const String easeOutQuint = "EASEOUTQUINT";
  static const String easeInOutQuint = "EASEINOUTQUINT";
}

double lerp(double start, double end, double ratio) {
  return start + (end - start) * ratio;
}

double getTweenValue(double currentVal, double minVal, double maxVal, double minMapping, double maxMapping, String easing) {
  double t = map(currentVal, minVal, maxVal, 1.0, 0.0);
  double curve = lerp(maxVal, minVal, easingFunctions[easing](t));
  double tweenValue = map(curve, minVal, maxVal, minMapping, maxMapping);

  return tweenValue;
}
