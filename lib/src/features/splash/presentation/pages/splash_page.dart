import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_journal/src/common/common.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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

    Future.delayed(const Duration(seconds: 3), () async {
      final firstTime = await AppPreferences.isFirstTime();
      final authRepo = getIt<AuthRepository>();

      if (firstTime) {
        context.goNamed(Routes.onboarding.name);
      } else if (authRepo.currentUser != null) {
        context.goNamed(Routes.home.name);
      } else {
        context.goNamed(Routes.login.name);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(100, 100),
              painter: CursiveMPainter(progress: _animation, context: context),
            ),
            const SizedBox(height: 10),
            const Text(
              'Journal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
