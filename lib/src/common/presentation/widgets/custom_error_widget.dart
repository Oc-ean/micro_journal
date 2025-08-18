import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback onRetry;
  const CustomErrorWidget({
    super.key,
    this.title,
    this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            title ?? 'Oops! Something went wrong',
            style: context.theme.textTheme.titleLarge?.copyWith(
              color: Colors.red[600],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.theme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
