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
  List<String> _userFollowing = [];
  JournalFilter _selectedFilter = JournalFilter.all;

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

  List<JournalModel> _filterJournals(
    List<JournalModel> journals,
    String? currentUserId,
  ) {
    if (currentUserId == null) return journals;

    switch (_selectedFilter) {
      case JournalFilter.all:
        return journals;

      case JournalFilter.anonymous:
        return journals
            .where((journal) => journal.isAnonymous == true)
            .toList();

      case JournalFilter.following:
        _loadUserFollowing();

        return journals
            .where(
              (journal) =>
                  journal.user != null &&
                  _userFollowing.contains(journal.user!.id) &&
                  journal.isAnonymous != true,
            )
            .toList();

      case JournalFilter.mine:
        return journals
            .where((journal) => journal.user?.id == currentUserId)
            .toList();
    }
  }

  Future<void> _loadUserFollowing() async {
    final currentUser = getIt<AuthRepository>().currentUser;
    if (currentUser != null) {
      try {
        final userData =
            await getIt<UserRepository>().getUserData(currentUser.uid);
        setState(() {
          _userFollowing = userData?.following ?? [];
        });
      } catch (e) {
        setState(() {
          _userFollowing = [];
        });
      }
    } else {
      logman.error('User is not logged in');
    }
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

          final allJournals = state is JournalLoaded
              ? state.journals
              : List.generate(4, (index) => JournalModel.sampleData());

          final currentUser = getIt<AuthRepository>().currentUser;
          final filteredJournals =
              _filterJournals(allJournals, currentUser?.uid);

          final isLoading = state is JournalLoading;
          final hasJournaledToday = !isLoading && hasJournalToday(allJournals);

          return RefreshIndicator(
            onRefresh: () async {
              _journalCubit.loadJournals();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 20),
                if (!isLoading) ...[
                  if (hasJournaledToday)
                    const AlreadyJournaledTodayWidget()
                  else
                    const CreateJournalPromptWidget(),
                ],
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community Journal',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_selectedFilter != JournalFilter.all)
                          Text(
                            'Filtered by: ${_selectedFilter.label}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${filteredJournals.length} ${filteredJournals.length == 1 ? 'entry' : 'entries'}',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: _selectedFilter != JournalFilter.all
                                ? Theme.of(context).primaryColor
                                : context.theme.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _selectedFilter != JournalFilter.all
                                  ? Theme.of(context).primaryColor
                                  : context.theme.dividerColor,
                            ),
                          ),
                          child: IconButton(
                            onPressed: _showFilterBottomSheet,
                            icon: Icon(
                              Icons.filter_list,
                              color: _selectedFilter != JournalFilter.all
                                  ? Colors.white
                                  : Colors.grey[600],
                              size: 20,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Journal
                Skeletonizer(
                  enabled: isLoading,
                  child: filteredJournals.isEmpty && !isLoading
                      ? _buildEmptyFilterState()
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredJournals.length,
                          itemBuilder: (context, index) {
                            final journal = filteredJournals[index];
                            final shouldDisableTap =
                                journal.user?.id == currentUser?.uid;

                            return GestureDetector(
                              onTap: shouldDisableTap || journal.isAnonymous
                                  ? null
                                  : () {
                                      context.push(
                                        Routes.follow.path,
                                        extra: {'userId': journal.user!.id},
                                      );
                                    },
                              child: PostCard(
                                journal: journal,
                                currentUserId: currentUser!.uid,
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                        ),
                ),
                const SizedBox(height: 20),
                if (state is JournalLoaded && allJournals.isEmpty) ...[
                  const SizedBox(height: 60),
                  const EmptyJournalStateWidget(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filter Journals',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedFilter != JournalFilter.all)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = JournalFilter.all;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            ...JournalFilter.values.map(
              (filter) => ListTile(
                leading: Icon(
                  filter.icon,
                  color: _selectedFilter == filter
                      ? Theme.of(context).primaryColor
                      : Colors.grey[600],
                ),
                title: Text(
                  filter.label,
                  style: TextStyle(
                    fontWeight: _selectedFilter == filter
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _selectedFilter == filter
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                ),
                subtitle: Text(
                  filter.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                trailing: _selectedFilter == filter
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                  });
                  Navigator.pop(context);
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedFilter.icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No ${_selectedFilter.label.toLowerCase()}',
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            getEmptyFilterMessage(_selectedFilter),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedFilter = JournalFilter.all;
              });
            },
            icon: const Icon(Icons.clear),
            label: const Text('Clear Filter'),
          ),
        ],
      ),
    );
  }
}
