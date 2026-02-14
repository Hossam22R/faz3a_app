import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class CategoriesManagementScreen extends StatelessWidget {
  const CategoriesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'إدارة التصنيفات',
      description: 'إضافة وتعديل ترتيب التصنيفات الرئيسية والفرعية.',
      icon: Icons.category_rounded,
    );
  }
}
