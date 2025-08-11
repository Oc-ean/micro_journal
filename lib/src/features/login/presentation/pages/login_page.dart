import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:micro_journal/src/common/constants/images.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(100, 100),
              painter: CursiveMPainter(progress: _animation, context: context),
            ),
            const SizedBox(height: 10),
            const Text('Journal', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            CustomButton(
              height: 45,
              width: 300,
              icon: Image.asset(
                googleLogo,
                height: 30,
              ),
              text: 'Login With Google',
              onTap: () => context.push(Routes.home.path),
            )
          ],
        ),
      ),
    );
  }
}
