import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';

class TagContainer extends StatelessWidget {
  final String text;
  const TagContainer({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.isDarkMode
            ? const Color(0xff2e2e32)
            : const Color(0xFFf3f4f6),
      ),
      child: Center(
        child: Text(
          text,
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
