import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'تفاصيل المنتج',
      description: 'صور المنتج، المواصفات، التقييمات، وزر الإضافة للسلة.',
      icon: Icons.inventory_2_outlined,
    );
  }
}
