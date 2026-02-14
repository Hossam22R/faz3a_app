import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'تقييمات المنتج',
      description: 'قائمة التقييمات وإضافة تقييم جديد بعد الشراء.',
      icon: Icons.reviews_outlined,
    );
  }
}
