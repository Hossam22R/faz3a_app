import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class ProductsApprovalScreen extends StatelessWidget {
  const ProductsApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'موافقة المنتجات',
      description: 'مراجعة المنتجات الجديدة وقبولها أو رفضها.',
      icon: Icons.fact_check_outlined,
    );
  }
}
