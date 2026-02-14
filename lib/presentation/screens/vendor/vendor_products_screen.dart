import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class VendorProductsScreen extends StatelessWidget {
  const VendorProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'منتجات المورد',
      description: 'إدارة جميع منتجات المورد وحالة الموافقة عليها.',
      icon: Icons.inventory_outlined,
    );
  }
}
