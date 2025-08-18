import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late JournalStatsCubit _journalStatsCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _journalStatsCubit = getIt<JournalStatsCubit>();
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _journalStatsCubit.close();
    super.dispose();
  }

  void _loadStats() {
    final userId = getIt<AuthRepository>().currentUser?.uid;

    _journalStatsCubit.loadStats(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Stats'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.theme.textTheme.headlineSmall?.color,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Moods'),
          ],
        ),
      ),
      body: BlocBuilder<JournalStatsCubit, JournalStatsState>(
        bloc: _journalStatsCubit,
        builder: (context, state) {
          if (state is JournalStatsError) {
            return CustomErrorWidget(
                message: state.message, onRetry: _loadStats);
          }

          final stats = state is JournalStatsLoaded
              ? state.stats
              : JournalStats.sampleData();

          return TabBarView(
            controller: _tabController,
            children: [
              Skeletonizer(
                enabled: state is JournalStatsLoading,
                child: OverviewTab(stats: stats),
              ),
              Skeletonizer(
                enabled: state is JournalStatsLoading,
                child: MoodsTab(stats: stats),
              ),
            ],
          );
        },
      ),
    );
  }
}
