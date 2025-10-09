import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:micro_journal/src/common/common.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavDestination> destinations;
  final String username;
  final String avatarUrl;
  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.username,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return ScaffoldWithNavigationBar(
        key: const Key('nav_bar'),
        body: body,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      );
    } else {
      return ScaffoldWithNavigationRail(
        key: const Key('nav_rail'),
        body: body,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
        username: username,
        avatarUrl: avatarUrl,
      );
    }
  }
}

class ScaffoldWithNavigationRail extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavDestination> destinations;
  final String username;
  final String avatarUrl;
  const ScaffoldWithNavigationRail({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.username,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          StyledNavigationRail(
            username: username,
            avatarUrl: avatarUrl,
            destinations: destinations,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            isExpanded: context.width > 850,
          ),
          Expanded(
            child: LimitedWidthView(child: body),
          ),
        ],
      ),
    );
  }
}

class ScaffoldWithNavigationBar extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavDestination> destinations;
  const ScaffoldWithNavigationBar(
      {super.key,
      required this.body,
      required this.selectedIndex,
      required this.onDestinationSelected,
      required this.destinations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: StyledBottomAppBar(
        currentIndex: selectedIndex,
        onIndexChanged: onDestinationSelected,
        destinations: destinations,
      ),
    );
  }
}

class StyledNavigationRail extends StatefulWidget {
  const StyledNavigationRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.avatarUrl,
    required this.username,
    this.isExpanded = false,
  });

  final List<NavDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final int selectedIndex;
  final String avatarUrl;
  final String username;
  final bool isExpanded;

  @override
  State<StyledNavigationRail> createState() => _StyledNavigationRailState();
}

class _StyledNavigationRailState extends State<StyledNavigationRail>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isExpanded = false;

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
    isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    const minWidth = 72.0;
    const maxWidth = 256.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: isExpanded ? maxWidth : minWidth,
      color:
          context.isDarkMode ? Colors.grey.shade900 : context.theme.cardColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 10),
        child: Column(
          children: [
            SizedBox(height: (context.topPadding * 2) + 40),

            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    isExpanded = !isExpanded;
                    setState(() {});
                  },
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(40, 40),
                        painter: CursiveMPainter(
                            progress: _animation, context: context),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: widget.destinations.length,
              itemBuilder: (context, index) {
                final destination = widget.destinations[index];
                return _buildItem(destination, context, isExpanded);
              },
            ),

            // for (final destination in widget.destinations)
            //   _buildItem(destination, context, isExpanded),
            const Spacer(),
            GestureDetector(
              onTap: () {
                // context.pushNamed(
                //   Routes.blogs.name,
                //   queryParameters: {'fromSettings': 'true'},
                // );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: isExpanded ? 8 : 5,
                  horizontal: isExpanded ? 8 : 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.avatarUrl,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (isExpanded) ...[
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.username,
                            style: context.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    NavDestination destination,
    BuildContext context,
    bool isExpanded,
  ) {
    final index = destination.index ?? widget.destinations.indexOf(destination);
    final isSelected = widget.selectedIndex == index;
    final color = isSelected ? Colors.white : Colors.grey;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showLabel = constraints.maxWidth >= 220;

        return GestureDetector(
          onTap: () => widget.onDestinationSelected(index),
          behavior: HitTestBehavior.translucent,
          child: AnimatedContainer(
            width: double.infinity,
            duration: const Duration(milliseconds: 100),
            height: 46.0,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: isExpanded ? 24.0 : 10),
            decoration: BoxDecoration(
              color: isSelected ? context.theme.primaryColor : null,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                right: BorderSide(
                  color: isSelected
                      ? context.theme.primaryColor
                      : Colors.transparent,
                  width: 2.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  destination.icon,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    color,
                    BlendMode.srcIn,
                  ),
                ),
                if (showLabel) ...[
                  const SizedBox(width: 12.0),
                  Flexible(
                    child: Text(
                      destination.label,
                      style:
                          context.textTheme.bodyLarge?.copyWith(color: color),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class StyledBottomAppBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int index) onIndexChanged;
  final List<NavDestination> destinations;
  const StyledBottomAppBar(
      {super.key,
      required this.currentIndex,
      required this.onIndexChanged,
      required this.destinations});

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = context.isDarkMode
        ? Colors.grey.withValues(alpha: 0.7)
        : Colors.grey.shade900;
    return BottomNavigationBar(
      elevation: 4,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedLabelStyle: TextStyle(color: selectedColor),
      onTap: (index) => onIndexChanged(index),
      items: List.generate(destinations.length, (index) {
        final isSelected = index == currentIndex;
        return BottomNavigationBarItem(
          icon: SvgPicture.asset(
            destinations[index].icon,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isSelected ? selectedColor : unselectedColor,
              BlendMode.srcIn,
            ),
          ),
          label: destinations[index].label,
        );
      }),
    );
  }
}
