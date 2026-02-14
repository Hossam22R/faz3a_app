import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'الملف الشخصي',
      description: 'بيانات المستخدم السريعة وروابط الإعدادات والمحفوظات.',
      icon: Icons.person_outline_rounded,
    );
  }
}
