import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class VendorAnalyticsScreen extends StatelessWidget {
  const VendorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'تحليلات المورد',
      description: 'إحصائيات المبيعات، التحويل، والمنتجات الأعلى أداءً.',
      icon: Icons.analytics_outlined,
    );
  }
}
