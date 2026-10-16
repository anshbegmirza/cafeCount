import 'package:flutter/material.dart';

/// Shared spacing from Hidden Room design system (16–20pt sides).
abstract final class HrLayout {
  static const double side = 16;
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(side, 8, side, 24);
  static const EdgeInsets pageHeaderPadding = EdgeInsets.fromLTRB(side, 8, side, 8);
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(horizontal: side, vertical: 6);
  static const EdgeInsets chipRowPadding = EdgeInsets.symmetric(horizontal: side);
}
