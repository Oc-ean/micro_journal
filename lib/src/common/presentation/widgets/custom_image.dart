import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
  final String imagePath;
  final BoxShape boxShape;
  final double height;
  final double width;
  const CustomImage({
    super.key,
    required this.imagePath,
    this.boxShape = BoxShape.circle,
    this.height = 110,
    this.width = 110,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          shape: boxShape,
          image: DecorationImage(
            image: CachedNetworkImageProvider(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (imagePath.startsWith('file://')) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          shape: boxShape,
          image: DecorationImage(
            image: FileImage(File(Uri.parse(imagePath).path)),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (File(imagePath).existsSync()) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          shape: boxShape,
          image: DecorationImage(
            image: FileImage(File(Uri.parse(imagePath).path)),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          shape: boxShape,
          color: Colors.grey.shade300,
        ),
        child: const Icon(Icons.image_not_supported),
      );
    }
  }
}
