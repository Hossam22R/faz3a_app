import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'منتجات التصنيف',
      description: 'شبكة المنتجات المفلترة حسب التصنيف ستُبنى هنا.',
      icon: Icons.grid_view_rounded,
    );
  }
}
