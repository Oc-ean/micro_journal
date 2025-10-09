import 'package:flutter/material.dart';

class LimitedWidthView extends StatelessWidget {
  final AlignmentGeometry alignment;
  final Widget child;
  final bool ignore;
  final bool expandHeight;

  const LimitedWidthView({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
    this.ignore = false,
    this.expandHeight = true,
  });

  @override
  Widget build(BuildContext context) {
    if (ignore) {
      return child;
    }

    MediaQueryData mediaQuery = MediaQuery.of(context);
    const double maxWidth = 720;

    if (mediaQuery.size.width > maxWidth) {
      mediaQuery = mediaQuery.copyWith(
        size: Size(maxWidth, mediaQuery.size.height),
      );
    }

    return Stack(
      alignment: alignment,
      children: [
        Container(
          width: double.maxFinite,
          height: expandHeight ? MediaQuery.of(context).size.height : null,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        MediaQuery(
          data: mediaQuery,
          child: SizedBox(width: maxWidth, child: child),
        ),
      ],
    );
  }
}
