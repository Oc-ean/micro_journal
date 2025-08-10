import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

class CommentRowWidget extends StatelessWidget {
  const CommentRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(SolarIconsOutline.chatRound, size: 20),
        SizedBox(width: 10),
        Text('Comment'),
      ],
    );
  }
}
