import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'لوحة الإدارة',
      description: 'نظرة شاملة على أداء المنصة والمقاييس الرئيسية.',
      icon: Icons.dashboard_outlined,
    );
  }
}
