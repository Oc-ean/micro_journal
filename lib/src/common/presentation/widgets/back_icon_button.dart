import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_icons/solar_icons.dart';

class BackIconButton extends StatelessWidget {
  final GestureTapCallback? onPressed;
  final BoxConstraints? constraints;
  final EdgeInsets? padding;

  const BackIconButton({
    super.key,
    this.onPressed,
    this.constraints,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: constraints,
      padding: padding,
      icon: const Icon(SolarIconsOutline.arrowLeft, size: 25),
      onPressed: () {
        onPressed == null ? context.pop() : onPressed!();
      },
    );
  }
}
