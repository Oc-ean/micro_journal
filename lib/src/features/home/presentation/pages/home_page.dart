import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:solar_icons/solar_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late JournalCubit _journalCubit;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    _journalCubit = JournalCubit(getIt<JournalRepository>());
  }

  @override
  void dispose() {
    _controller.dispose();
    _journalCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(40, 40),
                  painter:
                      CursiveMPainter(progress: _animation, context: context),
                );
              },
            ),
            const SizedBox(width: 10),
            const Text('Journal'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _journalCubit.loadJournals(),
          ),
          IconButton(
            icon: const Icon(SolarIconsBold.bell),
            onPressed: () => context.push(Routes.notification.path),
          ),
        ],
      ),
      body: BlocBuilder<JournalCubit, JournalState>(
        bloc: _journalCubit,
        builder: (context, state) {
          if (state is JournalError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () => _journalCubit.loadJournals(),
            );
          }

          final journals = state is JournalLoaded
              ? state.journals
              : List.generate(4, (index) => JournalModel.sampleData());

          final isLoading = state is JournalLoading;
          final hasJournalledToday = !isLoading && hasJournalToday(journals);

          return RefreshIndicator(
            onRefresh: () async {
              _journalCubit.loadJournals();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 20),
                if (!isLoading) ...[
                  if (hasJournalledToday)
                    _buildAlreadyJournaledToday()
                  else
                    _buildCreateJournalPrompt(),
                ],
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Community Journal',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${journals.length} ${journals.length == 1 ? 'entry' : 'entries'}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Skeletonizer(
                  enabled: isLoading,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: journals.length,
                    itemBuilder: (context, index) {
                      final journal = journals[index];
                      return PostWidget(
                        journal: journal,
                        currentUserId: getIt<AuthRepository>().currentUser!.uid,
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                  ),
                ),
                const SizedBox(height: 20),
                if (state is JournalLoaded && state.journals.isEmpty) ...[
                  const SizedBox(height: 60),
                  _buildEmptyState(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateJournalPrompt() {
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
            onTap: () => context.push(Routes.create.path),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildAlreadyJournaledToday() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 40,
            color: Colors.green[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Journal Complete! ✨',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You've already shared your thoughts today",
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Come back tomorrow for another reflection',
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No journals yet',
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your thoughts!',
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
