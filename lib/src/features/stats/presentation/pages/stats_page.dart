import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/features/features.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late JournalStats stats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    stats = JournalStats.mockData;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      body: TabBarView(
        controller: _tabController,
        children: [
          OverviewTab(stats: stats),
          MoodsTab(stats: stats),
        ],
      ),
    );
  }
}
