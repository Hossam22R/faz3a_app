import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'لوحة المورد',
      description: 'ملخص المبيعات، الطلبات، والأداء العام للمورد.',
      icon: Icons.storefront_outlined,
    );
  }
}
