import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class FinancesScreen extends StatelessWidget {
  const FinancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'المالية',
      description: 'تقارير العمولات، الاشتراكات، والإعلانات المميزة.',
      icon: Icons.payments_outlined,
    );
  }
}
