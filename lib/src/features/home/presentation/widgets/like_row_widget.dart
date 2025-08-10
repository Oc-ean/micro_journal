import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

class LikeRowWidget extends StatelessWidget {
  const LikeRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(SolarIconsOutline.heart, size: 20),
        SizedBox(width: 10),
        Text('Like'),
      ],
    );
  }
}
