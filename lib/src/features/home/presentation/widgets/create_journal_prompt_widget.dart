import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_journal/src/common/common.dart';

class CreateJournalPromptWidget extends StatelessWidget {
  const CreateJournalPromptWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        border: Border.all(color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '✨',
            style: context.textTheme.titleLarge?.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 20),
          Text(
            'Ready to journal!',
            style: context.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Text(
            "Capture today's moment and mood",
            style: context.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          CustomButton(
            height: 45,
            width: 200,
            text: 'Start writing',
            onTap: () => context.push(Routes.create.path, extra: {
              'currentUserId': getIt<AuthRepository>().currentUser!.uid
            }),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
