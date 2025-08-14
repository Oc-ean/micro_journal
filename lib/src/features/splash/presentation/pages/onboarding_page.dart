import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:micro_journal/src/common/common.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  late AnimationController _emojiController;
  late Animation<double> _emojiAnimation;

  final List<OnboardingData> onboardingData = [
    const OnboardingData(
      emoji: '✨',
      title: 'Welcome to Micro \nJournal',
      subtitle:
          'Your pocket companion for daily reflection\n\nCapture moments, track moods, and discover patterns in your journey - one micro entry at a time.',
      buttonText: "Let's begin",
    ),
    const OnboardingData(
      emoji: '📝',
      title: 'Write Your Daily Story',
      subtitle:
          "Small thoughts, big insights\n\nShare what's on your mind with just a few words. Set daily intentions and track how you're feeling.",
      buttonText: "I'm ready!",
    ),
    const OnboardingData(
      emoji: '🌍',
      title: 'Connect & Inspire Others',
      subtitle:
          'Anonymous community support\n\nChoose to share your entries anonymously. Find inspiration from others on similar journeys.',
      buttonText: 'Sounds great',
    ),
    const OnboardingData(
      emoji: '🔒',
      title: 'Your Privacy First',
      subtitle:
          'Safe, secure, and private\n\nYour personal entries stay private. You control what to share. Your data belongs to you, always.',
      buttonText: 'Get started',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _emojiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _emojiAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _emojiController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await AppPreferences.setFirstTime(false);
      context.push(Routes.login.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: onboardingData.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            final data = onboardingData[index];
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ScaleTransition(
                    scale: _emojiAnimation,
                    child: Text(
                      data.emoji,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 60,
                      ),
                    ),
                  ),
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Flexible(
                    child: CustomButton(
                      height: 45,
                      text: data.buttonText,
                      onTap: _nextPage,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
