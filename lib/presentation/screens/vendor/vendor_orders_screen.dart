import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class VendorOrdersScreen extends StatelessWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'طلبات المورد',
      description: 'إدارة الطلبات الواردة وتحديث حالاتها.',
      icon: Icons.assignment_outlined,
    );
  }
}
