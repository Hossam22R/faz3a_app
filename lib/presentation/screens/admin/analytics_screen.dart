import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'تحليلات المنصة',
      description: 'رسوم ولوحات متابعة الطلبات، الموردين، والتحويل.',
      icon: Icons.insights_outlined,
    );
  }
}
