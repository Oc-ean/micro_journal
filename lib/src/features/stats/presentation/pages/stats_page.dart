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
  String selectedPeriod = 'This Month';
  final List<String> periods = ['This Week', 'This Month', 'This Year'];

  late JournalStats stats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    stats = JournalStats.mockData;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'amazing':
        return Colors.purple;
      case 'happy':
        return Colors.green;
      case 'okay':
        return Colors.orange;
      case 'sad':
        return Colors.blue;
      case 'terrible':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'amazing':
        return '🤩';
      case 'happy':
        return '😊';
      case 'okay':
        return '😐';
      case 'sad':
        return '😢';
      case 'terrible':
        return '😭';
      default:
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Stats'),
        elevation: 0,
        actions: [
          Center(
            child: PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  selectedPeriod = value;
                });
              },
              itemBuilder: (context) => periods
                  .map(
                    (period) => PopupMenuItem(
                      value: period,
                      child: Text(period),
                    ),
                  )
                  .toList(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedPeriod,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).primaryColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.theme.textTheme.headlineSmall?.color,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Moods'),
            Tab(text: 'Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OverviewTab(stats: stats),
          MoodsTab(stats: stats),
          ActivityTab(weeklyActivity: stats.weeklyActivity),
        ],
      ),
    );
  }
}
