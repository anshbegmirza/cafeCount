import 'package:flutter/material.dart';

/// Shared spacing + radius tokens (docs/DESIGN_SYSTEM.md).
abstract final class HrLayout {
  static const double side = 16;
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(side, 8, side, 24);
  static const EdgeInsets pageHeaderPadding = EdgeInsets.fromLTRB(side, 8, side, 8);
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(horizontal: side, vertical: 6);
  static const EdgeInsets chipRowPadding = EdgeInsets.symmetric(horizontal: side);

  static const double radiusSm = 12; // inputs, buttons
  static const double radiusMd = 16; // cards
  static const double radiusLg = 20; // pills / chips / nav indicator
  static const double radiusSheet = 24; // bottom sheet top

  static const Duration pageFade = Duration(milliseconds: 200);

  static BorderRadius get borderSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderSheet =>
      const BorderRadius.vertical(top: Radius.circular(radiusSheet));
}
