import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class OrdersManagementScreen extends StatelessWidget {
  const OrdersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'إدارة الطلبات',
      description: 'متابعة الحالات والتدخل لحل النزاعات التشغيلية.',
      icon: Icons.assignment_turned_in_outlined,
    );
  }
}
