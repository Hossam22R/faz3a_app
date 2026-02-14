import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class VendorsManagementScreen extends StatelessWidget {
  const VendorsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'إدارة الموردين',
      description: 'مراجعة واعتماد حسابات الموردين وتعليق المخالفين.',
      icon: Icons.store_mall_directory_outlined,
    );
  }
}
