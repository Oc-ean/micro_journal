import 'package:flutter/widgets.dart';

extension TextStyleXs on TextStyle {
  TextStyle get w200 => copyWith(fontWeight: FontWeight.w200);
  TextStyle get w100 => copyWith(fontWeight: FontWeight.w100);
  TextStyle get w300 => copyWith(fontWeight: FontWeight.w300);
  TextStyle get w400 => copyWith(fontWeight: FontWeight.w400);
  TextStyle get w500 => copyWith(fontWeight: FontWeight.w500);
  TextStyle get w600 => copyWith(fontWeight: FontWeight.w600);
  TextStyle get w700 => copyWith(fontWeight: FontWeight.w700);
  TextStyle get w800 => copyWith(fontWeight: FontWeight.w800);
  TextStyle get w900 => copyWith(fontWeight: FontWeight.w900);

  TextStyle get h10 => copyWith(height: fontSize! / 10.0);
  TextStyle get h12 => copyWith(height: fontSize! / 12.0);
  TextStyle get h14 => copyWith(height: fontSize! / 14.0);
  TextStyle get h16 => copyWith(height: fontSize! / 16.0);
  TextStyle get h18 => copyWith(height: fontSize! / 18.0);
  TextStyle get h20 => copyWith(height: fontSize! / 20.0);
  TextStyle get h22 => copyWith(height: fontSize! / 22.0);
  TextStyle get h24 => copyWith(height: fontSize! / 24.0);
  TextStyle get h32 => copyWith(height: fontSize! / 32.0);
  TextStyle get h34 => copyWith(height: fontSize! / 34.0);

  /// Returns a new [TextStyle] with the specified line height.
  ///
  /// The [height] parameter specifies the desired line height as a multiple
  /// of the font size. For example, a [height] of 1.5 means that lines in
  /// the text will have a height of 1.5 times the font size.
  TextStyle withHeight(double height) {
    return copyWith(height: height / fontSize!);
  }

  /// Returns a new [TextStyle] with the specified color.
  ///
  /// The [color] parameter specifies the desired color for the text.
  TextStyle withColor(Color color) {
    return copyWith(color: color);
  }

  /// Returns a new [TextStyle] with the specified color and line height.
  ///
  /// The [color] parameter specifies the desired color for the text, and
  /// the [height] parameter specifies the desired line height as a multiple
  /// of the font size.
  TextStyle withColorHeight(Color color, double height) {
    return copyWith(color: color, height: height / fontSize!);
  }
}
