import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'التعريف بالتطبيق',
      description: 'شاشة Onboarding ستعرض مزايا نعمة ستور وخطوات البدء.',
      icon: Icons.slideshow_outlined,
    );
  }
}
