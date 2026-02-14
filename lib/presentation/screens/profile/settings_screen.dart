import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'الإعدادات',
      description: 'إعدادات الثيم، اللغة، الإشعارات، وأمان الحساب.',
      icon: Icons.settings_outlined,
    );
  }
}
