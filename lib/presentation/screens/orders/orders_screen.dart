import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'طلباتي',
      description: 'عرض جميع الطلبات الحالية والسابقة للمستخدم.',
      icon: Icons.list_alt_outlined,
    );
  }
}
