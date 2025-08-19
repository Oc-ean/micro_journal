import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_journal/src/common/common.dart';

class RootPage extends StatelessWidget {
  RootPage({
    Key? key,
    required StatefulNavigationShell statefulNavigationShell,
  }) : super(key: key ?? const ValueKey<String>('RootPage')) {
    navigationShell = statefulNavigationShell;
  }

  static late StatefulNavigationShell navigationShell;

  static void goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  final _destinations = [
    NavDestination(
      label: 'Home',
      icon: homeIcon,
    ),
    NavDestination(
      label: 'Calendar',
      icon: calendarIcon,
    ),
    NavDestination(
      label: 'Stats',
      icon: statsIcon,
    ),
    NavDestination(
      label: 'Settings',
      icon: profileIcon,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = context.isDarkMode
        ? Colors.grey.withValues(alpha: 0.7)
        : Colors.grey.shade900;
    return Scaffold(
      body: BlocListener<InternetCubit, InternetState>(
        bloc: getIt<InternetCubit>(),
        listener: (context, state) {
          if (state is InternetDisconnected) {
            showNoInternetPopup(context);
          } else if (state is InternetConnected) {
            context.showSnackBarUsingText('Back online');
          }
        },
        child: navigationShell,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 4,
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        selectedLabelStyle: TextStyle(color: selectedColor),
        onTap: (index) => goBranch(index),
        items: List.generate(_destinations.length, (index) {
          final isSelected = index == navigationShell.currentIndex;
          return BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _destinations[index].icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isSelected ? selectedColor : unselectedColor,
                BlendMode.srcIn,
              ),
            ),
            label: _destinations[index].label,
          );
        }),
      ),
    );
  }
}
