import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'التصنيفات',
      description: 'قائمة التصنيفات الرئيسية والفرعية للمتجر.',
      icon: Icons.category_outlined,
    );
  }
}
